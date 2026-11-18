"""Search (seeded, reproducible) for exam-style simplex questions with tidy numbers.
Used once to pick the new questions of Ch. 4 and of the mock exam; the chosen
instances are then pinned in v04_simplex_new.py."""
import random
from fractions import Fraction as F
from simplex_tools import tableau, ratio_test
random.seed(2027)
found = {"june": [], "jan": []}
vals = [-2, -1, 0, 1, 2]
while len(found["june"]) < 6 or len(found["jan"]) < 6:
    A = [[random.choice(vals) for _ in range(4)] for _ in range(2)]
    b = [random.choice([-2, -1, 1, 2]) for _ in range(2)]
    c = [random.choice(vals) for _ in range(4)]
    basis = random.sample(range(4), 2)
    try:
        T = tableau(A, b, c, basis)
    except StopIteration:
        continue
    beta = [r[0] for r in T["rows"]]
    if any(v < 0 for v in beta) or any(v == 0 for v in beta):
        continue
    if any(v.denominator > 2 for v in beta) or any(d.denominator > 1 for d in T["d"].values()):
        continue
    ds = list(T["d"].values())
    if all(d > 0 for d in ds) and any(v.denominator == 2 for v in beta):
        found["jan"].append((A, b, c, basis, beta, T["z0"], T["d"]))
    neg = [j for j, d in T["d"].items() if d < 0]
    pos = [j for j, d in T["d"].items() if d >= 0]
    if len(neg) == 1 and len(pos) == 1 and all(v.denominator == 1 for v in beta):
        r = ratio_test(T, neg[0])
        if r[0] is not None and r[0].denominator == 1:
            found["june"].append((A, b, c, basis, beta, T["z0"], T["d"], r))
for k in found:
    print(k)
    for q in found[k][:6]:
        print("  ", q)
