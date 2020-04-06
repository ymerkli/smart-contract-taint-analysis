import argparse
import json
from pathlib import Path

from peck.ir import visualizer
from peck.solidity import compile_cfg
from peck.staticanalysis import factencoder, souffle, visualization as fact_visualizer

def analyze(compile_output, contract_graph, contract_facts, *, output_dir):
    # TODO: Implement your analysis here.

    # Optional: Use Datalog (Souffle).

    # Run the Datalog analyzer
    datalog_analyzer = Path(__file__).parent / "analyze.dl"
    output, facts_out = souffle.run_souffle(
        datalog_analyzer,
        facts=contract_facts,
        fact_dir=output_dir / "facts_in",
        output_dir=output_dir / "facts_out")

    # The output must be either 'Tainted' or 'Safe':
    print("Tainted" if facts_out['tainted_sinks'] else "Safe")


def visualize(compile_output, contract_graph, contract_facts, *, output_dir):
    # Visualize control flow graph.
    # You may want to replace `only_blocks=True` with `highlight=['ContractDefinition']`.
    visualizer.draw_cfg(
        compile_output.cfg,
        file=output_dir / "graph",
        format='pdf',
        only_blocks=True)

    # Dump abstract syntax tree returned by the Solidity compiler.
    #with open(output_dir / "ast.json", 'wt') as f:
    #    json.dump(compile_output.ast_dict, f, indent=2)

    # Visualize Datalog facts.
    fact_visualizer.visualize(contract_facts).render(
        filename=output_dir / "facts",
        format='pdf',
        cleanup=True,
        view=True)


if __name__ == '__main__':
    # Parse command line.
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument("--visualize", action='store_true')
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()

    # Initialize options.
    if args.output_dir is None:
        args.output_dir = args.source.parent / (Path(args.source.name).stem + "_out")

    # Compile source to a control flow graph and Datalog facts.
    compile_output = compile_cfg(str(args.source))
    contract_graph = compile_output.cfg.contracts[0]
    contract_facts = factencoder.encode(contract_graph)


    # Perform command
    if args.visualize:
        visualize(compile_output, contract_graph, contract_facts, output_dir=args.output_dir)
    else:
        analyze(compile_output, contract_graph, contract_facts, output_dir=args.output_dir)
