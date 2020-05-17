import argparse
import json
from datetime import datetime
from subprocess import Popen, PIPE


class BatchTest(object):
    def __init__(self, test_dir: str = None, include_hard_contracts: bool = False) -> None:
        """
        A test wrapper to test a batch of contracts and display statistics on the analysis performance
        """

        self.test_dir = test_dir
        self.include_hard_contracts = include_hard_contracts
        self.true_positives = []
        self.true_negatives = []
        self.false_positives = []
        self.false_negatives = []
        self.timings = []

        with open('batch_test.json') as f:
            self.test_labels = json.load(f)

    def test_batch(self) -> None:
        if self.test_dir:
            print(f'Testing {self.test_dir} contracts')
            for contract_id, label in self.test_labels[self.test_dir].items():
                label_hat = self.test(self.test_dir, contract_id)
                self.analysis(self.test_dir, contract_id, label, label_hat)
        else:
            for test_dir, labels in self.test_labels.items():
                print(f'Testing {test_dir} contracts')
                if test_dir == 'hard' and not self.include_hard_contracts:
                    print('-- Skipping hard contracts')
                    continue

                for contract_id, label in labels.items():
                    label_hat = self.test(test_dir, contract_id)
                    self.analysis(test_dir, contract_id, label, label_hat)

        self.summary()

    def test(self, test_dir: str, contract_id: str) -> str:
        start = datetime.now()
        proc = Popen(['python3', 'analyze.py', f'test_contracts/{test_dir}/{contract_id}.sol'], stdout=PIPE)
        output, _ = proc.communicate()
        end = datetime.now()
        self.timings.append((f'{test_dir}/{contract_id}', (end - start).total_seconds()))

        # the last line of the output is the label (in case Datalog facts are in the output)
        label = output.splitlines()[-1].decode('utf-8')
        return label

    def analysis(self, test_dir: str, contract_id: str, label: str, label_hat: str):
        contract = f'{test_dir}/{contract_id}'
        if label_hat == 'Tainted':
            if label == 'Tainted':
                self.true_negatives.append(contract)
            elif label == 'Safe':
                self.false_negatives.append(contract)
            else:
                raise ValueError(f'Error: unknown label {label}')
        elif label_hat == 'Safe':
            if label == 'Tainted':
                self.false_positives.append(contract)
            elif label == 'Safe':
                self.true_positives.append(contract)
            else:
                raise ValueError(f'Error: unknown label {label}')
        else:
            raise ValueError(f'Error: unknown label {label_hat}')

    def summary(self) -> None:
        print('---')
        print('Positive = "Safe"')
        print(f'True positives: {self.true_positives}')
        print(f'True negatives: {self.true_negatives}')
        print(f'False positives: {self.false_positives}')
        print(f'False negatives: {self.false_negatives}')

        print(f'Points: {len(self.true_positives) - 2 * len(self.false_positives)} '
              f'of {len(self.true_positives) + len(self.false_negatives)}')

        contract, time = max(self.timings, key=lambda x: x[1])
        print(f'Max analysis duration: {time} seconds for contract {contract}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Batch analyze contracts and compute metrics')
    parser.add_argument('-d', type=str, required=False, help='Test only specific sub-directory')
    parser.add_argument('-hc', action='store_true', required=False, help='Include hard test contracts')
    args = parser.parse_args()

    batch_tester = BatchTest(args.d, args.hc)
    batch_tester.test_batch()
