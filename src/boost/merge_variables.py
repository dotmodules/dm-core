import sys
from collections import defaultdict

variables = defaultdict(list)
for line in sys.stdin:
    values = line.strip().split()
    name = values.pop(0)
    variables[name].extend(values)

for key in sorted(variables.keys()):
    values = sorted(set(variables[key]))
    print(f"{key} {' '.join(values)}")
