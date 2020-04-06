from collections import defaultdict

from peck.grammar.attributes.evaluators.evaluator_base import EvaluatorBase


class DemandDriven(EvaluatorBase):
    def __init__(self, grammar, cached=True, allow_overrides=False):
        super().__init__(grammar)

        self.grammar = grammar

        self.cached = cached
        self.allow_overrides = allow_overrides

        self.__interfaces = self.__build_attribute_interfaces()
        self.__allowed_access = []
        self.__current_rule = []

        self.__cache = {}

    def for_tree(self, root):
        self.grammar.validate_tree(root)

        root = self._prepare_tree(root)
        self.inject_interfaces(root)

        return root

    def evaluate(self, node, attribute, exclude_local_attributes=False):
        cache_key = (node, attribute)
        cache = self.__cache

        if self.cached and cache_key in cache:
            return cache[cache_key]

        rule_info = self[node].resolve_rule(attribute)

        if rule_info is None:
            if exclude_local_attributes:
                return
            return getattr(node, attribute)

        if len(self.__allowed_access) > 0:
            access = self.__allowed_access[-1]
            if attribute not in access[node]:  # Should always be available
                raise AttributeError(
                    f"Attribute '{attribute}' not declared as dependency in {self.__current_rule[-1]}.")

        if cache is not None:
            if cache_key not in cache:
                cache[cache_key] = self._evaluate_rule(rule_info)

            return cache[cache_key]

        return self._evaluate_rule(rule_info)

    def _execute_rule(self, rule, arguments):
        try:
            access = defaultdict(lambda: set())
            for node_name, attribute in rule.dependencies:
                nodes = arguments[node_name]
                for node in nodes if isinstance(nodes, (list, tuple)) else [nodes]:
                    access[node].add(attribute)

            self.__allowed_access.append(access)
            self.__current_rule.append(rule)

            for (node, attributes) in access.items():
                if node is not None:
                    for attribute in attributes:
                        self.evaluate(node, attribute, exclude_local_attributes=True)

            try:
                return super()._execute_rule(rule, arguments)
            except Exception as e:
                trace = '\n\t'.join([str(r) for r in self.__current_rule])
                from peck.grammar.attributes import AttributeGrammarError
                raise AttributeGrammarError(f"Error during evaluation of rule '{rule.name}'. "
                                            f"Rule trace: {trace}") from e
        finally:
            self.__allowed_access.pop()
            self.__current_rule.pop()

    def inject_interfaces(self, root):
        nodes = []

        def inject_attributes(node, _, context):
            nodes.append((node, context.is_root))

        self.grammar.traverse(root, inject_attributes)

        for node, is_root in nodes:
            node_type = type(node)
            a, s, _ = self.__interfaces[node_type]
            node.__class__ = s if is_root else a

    def __build_attribute_interfaces(self):
        interfaces = {}

        for symbol in self.grammar.productions:
            sym_type = symbol
            sym_name = symbol.__name__
            gen_type = sym_type.__class__

            def new_interface(name, attributes):
                t_symbol = DemandDriven.SymbolInterface
                t_attribute = DemandDriven.EvaluableAttribute

                name = f"{sym_name}__{name}Mixin"
                base = (sym_type, t_symbol)
                cls = gen_type(name, base, {
                    "__original_type__": sym_type,
                    "__attributes__": {}
                })

                for attribute in attributes:
                    evaluable_attribute = t_attribute(self, attribute)
                    setattr(cls, attribute, evaluable_attribute)
                    getattr(cls, "__attributes__")[attribute] = evaluable_attribute

                return cls

            g = self.grammar

            cls_i = new_interface("InheritedAttrs", g.inherited_attributes[symbol])
            cls_s = new_interface("SyntheticAttrs", g.synthesized_attributes[symbol])
            cls_a = new_interface("AllAttrs", g.attributes[symbol])

            interfaces[symbol] = (cls_a, cls_s, cls_i)

        return interfaces

    class EvaluableAttribute:
        def __init__(self, evaluator, name):
            self.__evaluator = evaluator
            self.__name = name

        def __get__(self, instance, owner):
            if self.__name in instance.__dict__:
                return instance.__dict__[self.__name]

            return self.__evaluator.evaluate(instance, self.__name)

        def __set__(self):
            raise AttributeError("Cannot override attributes")

    class SymbolInterface:
        __attributes__: dict

        def __setattr__(self, name, value):
            raise self.ImmutableError(
                f"Cannot set {name} on {self.__class__.__qualname__} object. "
                f"The object has been marked immutable.")

        def __delattr__(self, item):
            raise self.ImmutableError(
                f"Cannot delete {item} on {self.__class__.__qualname__} object. "
                f"The object has been marked immutable.")

        def __is_intrinsic_attribute__(self, attribute):
            if attribute in self.__dict__:
                return True

            return False

        class ImmutableError(AttributeError):
            pass
