"""Chapter 3: bases, basic solutions, degeneracy (slide LPs and new exercises)."""
from fractions import Fraction as F
from itertools import combinations
from simplex_tools import tableau

N = ["x", "y", "s1", "s2", "s3"]


def classify(A, b, names, c=None):
    c = c or [0] * len(names)
    out = {}
    for B in combinations(range(len(names)), len(A)):
        try:
            T = tableau(A, b, c, list(B))
        except StopIteration:
            out[tuple(names[i] for i in B)] = "singular"; continue
        vals = [r[0] for r in T["rows"]]
        kind = "infeasible" if any(v < 0 for v in vals) else ("degenerate" if any(v == 0 for v in vals) else "feasible")
        out[tuple(names[i] for i in B)] = (kind, dict(zip([names[i] for i in B], vals)))
    return out


A = [[1, 1, 1, 0, 0], [1, 0, 0, 1, 0], [0, 1, 0, 0, 1]]
res = classify(A, [3, 2, 2], N)
for k, v in res.items():
    print(k, v)
sing = [k for k, v in res.items() if v == "singular"]
feas = [k for k, v in res.items() if v != "singular" and v[0] != "infeasible"]
assert sorted(sing) == sorted([("x", "s1", "s2"), ("y", "s1", "s3")])
assert len(feas) == 5 and len(res) == 10
assert res[("x", "y", "s1")] == ("infeasible", {"x": 2, "y": 2, "s1": -1})
assert res[("y", "s1", "s2")] == ("feasible", {"y": 2, "s1": 1, "s2": 2})
# degenerate version (x + y + s1 = 4): vertex (2,2) has several bases
res2 = classify(A, [4, 2, 2], N)
at22 = [k for k, v in res2.items() if v != "singular" and v[0] != "infeasible" and v[1].get("x", 0) == 2 and v[1].get("y", 0) == 2]
print("bases of vertex (2,2) when b1 = 4:", at22)
assert sorted(at22) == sorted([("x", "y", "s1"), ("x", "y", "s2"), ("x", "y", "s3")])
# exam-style system used in chapter 3 exercises
A3 = [[-1, 1, 0, 1], [-1, 2, 1, 1]]
res3 = classify(A3, [-2, 1], ["x0", "x1", "x2", "x3"])
for k, v in res3.items():
    print("ex3", k, v)
assert res3[("x0", "x1")] == ("feasible", {"x0": 5, "x1": 3})
assert res3[("x2", "x3")] == ("infeasible", {"x2": 3, "x3": -2})
assert res3[("x0", "x3")] == "singular"
assert res3[("x0", "x2")] == ("feasible", {"x0": 2, "x2": 3})
assert res3[("x1", "x2")] == ("infeasible", {"x1": -2, "x2": 5})
assert res3[("x1", "x3")] == ("infeasible", {"x1": 3, "x3": -5})
print("ALL CHAPTER 3 CHECKS PASSED")
# ch3-e1 (new exam style): min x1 - x3 ; 2x0 + x1 - x2 = 2 ; x0 - x2 + x3 = 2
A = [[2, 1, -1, 0], [1, 0, -1, 1]]
T = tableau(A, [2, 2], [0, 1, 0, -1], [0, 3])
assert [r[0] for r in T["rows"]] == [1, 1] and T["z0"] == -1
T = tableau(A, [2, 2], [0, 1, 0, -1], [1, 2])
assert [r[0] for r in T["rows"]] == [0, -2]          # x1 = 0, x2 = -2: infeasible
# your turn 3.1: basis (x0, x2) of the exam-style system: x0 = 2, x2 = 3
assert res3[("x0", "x2")][1] == {"x0": 2, "x2": 3}
# warm-up 3.2 inverses
from simplex_tools import inverse
assert inverse([[F(2), F(1)], [F(1), F(1)]]) == [[1, -1], [-1, 2]]
assert inverse([[F(0), F(-2)], [F(-2), F(0)]]) == [[0, F(-1, 2)], [F(-1, 2), 0]]
print("CH3 EXTRA OK")
