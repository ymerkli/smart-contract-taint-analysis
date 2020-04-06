from abc import ABC, abstractmethod
from ast import parse, Name, Set, Dict, Attribute
from collections import defaultdict
from inspect import signature, Parameter, getmembers, getfile, findsource
from typing import Tuple, List

from peck.grammar.attributes import SynthesizeRule, PushdownRule, AttributeGrammarError, \
    AttributeGrammarValidationError, RuleArgument, AttributeOccurrence


class RuleParser(ABC):
    @abstractmethod
    def __call__(self, grammar, classes):
        ...


class DefaultRuleParser(RuleParser):

    def __init__(self, implicit_rules) -> None:
        super().__init__()
        self.implicit_rules = implicit_rules

    def __call__(self, grammar, classes):
        rules = [(c, t) for cls in classes for c, t in self.for_class(cls)]
        return DefaultRuleParser.infer_attributes(grammar, rules, self.implicit_rules)

    @staticmethod
    def for_class(cls):
        annotations = getmembers(cls, lambda x: isinstance(x, RuleAnnotation))
        return [rule for _, a in annotations for rule in a.rules(cls)]

    @staticmethod
    def infer_attributes(grammar, semantic_rules, implicit_rules):
        r_s: Dict[type, Dict[Tuple[str, str], List[SynthesizeRule]]] = defaultdict(lambda: defaultdict(lambda: []))
        r_i: Dict[type, Dict[Tuple[str, str], List[PushdownRule]]] = defaultdict(lambda: defaultdict(lambda: []))

        a_s: Dict[type, Set[str]] = defaultdict(lambda: set())
        a_i: Dict[type, Set[str]] = defaultdict(lambda: set())
        a_a: Dict[type, Set[str]] = defaultdict(lambda: set())

        for symbol, rule in semantic_rules:
            if isinstance(rule, SynthesizeRule) and isinstance(rule, PushdownRule):
                raise AttributeGrammarError("A rule cannot be inherited and synthesized at the same time.")
            if isinstance(rule, SynthesizeRule):
                r_s[symbol][rule.target].append(rule)
            if isinstance(rule, PushdownRule):
                r_i[symbol][rule.target].append(rule)

        @repeat_until_convergence(lambda: list(map(len, a_s.values())))
        def infer_synthesized_attributes():
            for s in grammar.productions:
                a_s[s] |= {a for _, a in r_s[s].keys()}

            for s, sub_symbols in grammar.sub_productions.items():
                if len(sub_symbols) > 0:
                    attributes = [a_s[s] for s in sub_symbols]
                    common_attributes = set.intersection(*attributes)
                    a_s[s] |= common_attributes

        @repeat_until_convergence(lambda: list(map(len, a_i.values())))
        def infer_inherited_attributes():
            for parent, rule_targets in r_i.items():
                productions = grammar.productions[parent]
                for (node, attr), rules in rule_targets.items():
                    if node not in productions:
                        raise AttributeGrammarValidationError(
                            f"Semantic rules [{[r.name for r in rules]}] references unavailable "
                            f"child node '{node}' in symbol '{parent.__name__}'.")

                    child = productions[node]
                    affected_symbols = grammar.get_sub_productions(child.symbols)

                    for s in affected_symbols:
                        a_i[s].add(attr)

        @repeat_until_convergence(lambda: list(map(len, r_i.values())))
        def infer_implicit_rules():
            def identity(attribute):
                def identity(self):
                    return getattr(self, attribute)

                return identity

            for s, ps in grammar.productions.items():
                inheritable_rules = r_i[s].keys()

                for n, p in ps.items():
                    attribute_sets = [a_i[s1] for ss in p.symbols for s1 in grammar.get_sub_productions([ss])]
                    required_attributes = set.union(*attribute_sets)

                    for a in required_attributes:
                        if (n, a) not in inheritable_rules:
                            from peck.grammar.attributes import AttributeOccurrence
                            r_i[s][(n, a)].append(PushdownRule(
                                func=identity(a),
                                arguments=[RuleArgument("self")],
                                dependencies=[AttributeOccurrence("self", a)],
                                target=AttributeOccurrence(n, a),
                                name=f"{n}_{a}",
                            ))

        while True:
            no_changes = True
            no_changes &= infer_synthesized_attributes()
            no_changes &= infer_inherited_attributes()

            if implicit_rules:
                no_changes &= infer_implicit_rules()

            if no_changes:
                break

        for s in grammar.productions:
            if not set.isdisjoint(a_s[s], a_i[s]):
                raise AttributeGrammarValidationError(
                    f"Inherited and synthesized attributes not disjoint for symbol "
                    f"{s.__name__} (intersection: {{{a_s[s] & a_i[s]}}})."
                )

            a_a[s] = a_s[s] | a_i[s]

        a_s = {r: frozenset(a) for r, a in a_s.items()}
        a_i = {r: frozenset(a) for r, a in a_i.items()}
        a_a = {r: frozenset(a) for r, a in a_a.items()}

        return r_s, r_i, a_s, a_i, a_a


class RuleAnnotation(ABC):
    def __set_name__(self, owner, name):
        self.__name__ = name
        self.name = name
        self.owner = owner

    def __get__(self, instance, owner):
        if instance is None:
            return self

        raise self.error(f"Semantic rules cannot be accessed directly. "
                         f"Use an evaluator. ({self.name} in {self.owner.__name__})")

    @abstractmethod
    def rules(self, cls):
        ...

    @staticmethod
    def error(message):
        from peck.grammar.attributes import AttributeGrammarError
        return AttributeGrammarError(message)

    @staticmethod
    def _parse_dependencies(func):
        from peck.grammar.attributes import AttributeOccurrence

        node_dependencies = []
        dependencies = []

        for _, parameter in signature(func).parameters.items():
            node = parameter.name
            attribute_description = parameter.annotation

            node_dependencies.append(node)
            if attribute_description is Parameter.empty:
                continue

            expr = parse(attribute_description, mode='eval').body
            line = findsource(func)[1] + 2

            try:
                attributes = RuleAnnotation._attributes_from_ast(expr)
            except SyntaxError as e:
                raise SyntaxError(f"Attribute dependencies of rule '{func.__name__}' could not be parsed: \n{e.msg}",
                                  (getfile(func), line, e.offset, attribute_description)) from None

                # raise SyntaxError("Attribute dependencies cannot be parsed.") from e

            for attribute in attributes:
                dependency = AttributeOccurrence(node, attribute)
                dependencies.append(dependency)

        return dependencies, node_dependencies

    @staticmethod
    def _attributes_from_ast(expr):
        def name_or_attribute(expr):
            if isinstance(expr, Name):
                return expr.id
            elif isinstance(expr, Attribute):
                return expr.attr
            else:
                raise SyntaxError("Expected attribute identifier.", (None, None, expr.col_offset + 1, None))

        if isinstance(expr, (Name, Attribute)):
            attributes = [name_or_attribute(expr)]
        elif isinstance(expr, Set):
            attributes = [name_or_attribute(r) for r in expr.elts]
        elif isinstance(expr, Dict) and len(expr.values) == 0:
            attributes = []
        else:
            raise SyntaxError("Expected '{attribute1, attribute2}'", (None, None, expr.col_offset, None))

        return attributes


class SynthesizeRuleAnnotation(RuleAnnotation):
    def __init__(self, func):
        self.func = func
        self.dependencies, self.node_dependencies = self._parse_dependencies(func)

    def rules(self, cls):
        from peck.grammar.attributes import SynthesizeRule, RuleArgument
        return [(cls,
                 SynthesizeRule(self.func, [RuleArgument(n) for n in self.node_dependencies],
                                self.dependencies,
                                self.name))]


class InheritableRuleAnnotation(RuleAnnotation):
    def __init__(self, func):
        self.func = func
        self.targets = self._parse_targets(func)
        self.dependencies, self.node_dependencies = self._parse_dependencies(func)

    def rules(self, cls):
        from peck.grammar.attributes import PushdownRule, RuleArgument
        return [(cls,
                 PushdownRule(
                     self.func, [RuleArgument(n) for n in self.node_dependencies],
                     self.dependencies,
                     target=target,
                     name=self.name
                 )) for target in self.targets]

    @staticmethod
    def _parse_targets(func):
        from peck.grammar.attributes import AttributeOccurrence

        if "return" not in func.__annotations__:
            raise SyntaxError(f"Attribute target not specified for function {func.__name__}.")

        target_annotation = func.__annotations__["return"]

        targets = []
        try:
            ast = parse(target_annotation, mode='eval').body

            for node, values in zip(ast.keys, ast.values):
                node_name = node.id
                node_attributes = RuleAnnotation._attributes_from_ast(values)

                targets += [AttributeOccurrence(node_name, a) for a in node_attributes]

                if len(node_attributes) > len(set(node_attributes)):
                    raise SyntaxError(f"Attribute target occurs twice in {func.__name__} -> {node_name}")

            return targets

        except SyntaxError as e:
            raise SyntaxError(f"Attribute targets could not be parsed for function {func.__name__}.") from e

seen = set()

class InheritableInductiveRuleAnnotation(RuleAnnotation):
    def __init__(self, base=None, step=None):
        self.base_rule: InheritableRuleAnnotation = None
        self.step_rule: InheritableRuleAnnotation = None

        if base is not None:
            self.base(base)

        if step is not None:
            self.step(step)

    def base(self, base):
        self.base_rule = InheritableRuleAnnotation(base)
        self.__check_rules()
        return self

    def step(self, step):
        self.step_rule = InheritableRuleAnnotation(step)
        self.__check_rules()
        return self

    def __check_rules(self):
        from peck.grammar.attributes import AttributeGrammarError
        if self.step_rule is not None and self.base_rule is not None:
            if self.step_rule.targets != self.base_rule.targets:
                raise AttributeGrammarError(f"Target error in inductive rule '{self.base_rule}': "
                                            f"Base and step functions must have the same target.")

            if len(self.step_rule.targets) > 1 or len(self.base_rule.targets) > 1:
                raise AttributeGrammarError(f"Target error in inductive rule '{self.base_rule}': "
                                            f"Inductive rules cannot have multiple targets.")

    def rules(self, cls):
        from peck.grammar.attributes import AttributeGrammarError

        if self.base_rule is None:
            raise AttributeGrammarError(f"Base of inductive rule '{self.name}' has not been specified.")
        if self.step_rule is None:
            raise AttributeGrammarError(f"Step of inductive rule '{self.name}' has not been specified.")

        self.base_rule.__set_name__(self.owner, self.name)
        self.step_rule.__set_name__(self.owner, self.name)

        base: PushdownRule = self.base_rule.rules(cls)[0][1]
        step: PushdownRule = self.step_rule.rules(cls)[0][1]

        step_target = step.target

        assert len(step.arguments) == 2
        assert all(n == step_target.node for n, _ in step.dependencies)

        original_function = step.func

        def func2(self):
            kwargs = {"self": ...,
                      step_target.node: self}
            return original_function(**kwargs)

        step = PushdownRule(
            func2,
            [RuleArgument("self")],
            [AttributeOccurrence("self", a) for _, a in step.dependencies],
            target=AttributeOccurrence("next", step_target.attribute),
            name=self.name
        )

        if cls in seen:
            return []

        seen.add(cls)

        def get_list_type(ancestor_type, name):
            def to_camel_case(snake_str):
                return ''.join(x.title() for x in snake_str.split('_'))

            return getattr(ancestor_type, to_camel_case(name) + "Elem")

        return [
            (cls, base),
            (get_list_type(cls, step_target.node), step),
        ]


def pushdown(func):
    return InheritableRuleAnnotation(func)


def synthesized(func):
    return SynthesizeRuleAnnotation(func)


def inheritable_inductive_base(func):
    return InheritableInductiveRuleAnnotation(base=func)


def inheritable_inductive_step(func):
    return InheritableInductiveRuleAnnotation(step=func)


pushdown.base = inheritable_inductive_base
pushdown.step = inheritable_inductive_step


def repeat_until_convergence(convergence_property):
    def transform_function(func):
        def transformed_function(*args, **kwargs):
            no_changes = True
            while True:
                p_old = convergence_property()
                func(*args, **kwargs)
                p_new = convergence_property()
                if p_old != p_new:
                    no_changes = False
                else:
                    break

            # print(p_old)

            return no_changes

        return transformed_function

    return transform_function
