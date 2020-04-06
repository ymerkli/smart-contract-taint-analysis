from pathlib import Path

from peck.ir import visualizer
from peck.solidity import compile_cfg_from_string, compile_cfg
from peck.staticanalysis import souffle
from peck.staticanalysis.factencoder import encode
from peck.staticanalysis.visualization import visualize

if __name__ == '__main__':
    cfg = compile_cfg("testContract.sol").cfg
    visualizer.draw_cfg(cfg, file='out/cfg', format='png', only_blocks=True, view=False)

    facts = encode(cfg.contracts[0])
    visualize(facts).render("out/dl", format="png", cleanup=True)

    # for f in facts:
    #     print(f)
    # print(format_facts_as_code(facts, fact_types))

    path_base = Path(__file__).parent

    souffle_source = path_base / 'souffle_analysis' / 'analysis.dl'

    souffle_output, facts_out = souffle.run_souffle(
        souffle_source,
        facts=facts,
        fact_dir=path_base / 'facts_in',
        output_dir=path_base / 'facts_out')

    print(souffle_output.stderr)
    print(souffle_output.stdout)
