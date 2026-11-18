"""Chapter 4 (simplex): past-exam Q1s, slide examples and new exercises.

Every assert below pins a number printed in the book.  Run:  python3 v04_simplex.py
"""
from fractions import Fraction as F
from simplex_tools import tableau, ratio_test, fmt

X = ["x0", "x1", "x2", "x3"]

# ---------------- Final June 2024, Q1 -------------------------------------
A = [[-2, 1, 0, -2], [2, 0, -1, -1]]
b = [1, -1]
c = [1, 1, -1, -1]
T = tableau(A, b, c, [1, 3])                     # basis (x1, x3)
print("Jun24\n" + fmt(T, X))
assert [r[0] for r in T["rows"]] == [3, 1]        # x1 = 3, x3 = 1
assert T["z0"] == 2
assert T["d"][0] == 5 and T["d"][2] == -2
assert ratio_test(T, 2) == (F(1), [1])            # x2 can grow to 1 (x3 leaves)

# ---------------- Final January 2025, Q1 ----------------------------------
A = [[2, 2, -1, 2], [-2, 2, 2, -1]]
b = [0, 1]
c = [2, 2, 1, -2]
T = tableau(A, b, c, [3, 2])                     # basis (x3, x2)
print("Jan25\n" + fmt(T, X))
assert [r[0] for r in T["rows"]] == [F(1, 3), F(2, 3)]
assert T["z0"] == 0
assert T["d"][0] == 4 and T["d"][1] == 4

# ---------------- Final June 2025, Q1 -------------------------------------
A = [[2, -1, -1, -1], [-1, 0, 1, 0]]
b = [0, -2]
c = [0, -1, -1, -1]
T = tableau(A, b, c, [0, 3])                     # basis (x0, x3)
print("Jun25\n" + fmt(T, X))
assert [r[0] for r in T["rows"]] == [2, 4]
assert T["z0"] == -4
assert T["d"][1] == 0 and T["d"][2] == -2
assert ratio_test(T, 2) == (None, [])             # x2 unbounded: +infinity

# ---------------- Final January 2026, Q1 ----------------------------------
A = [[0, -2, -2, 1], [-2, -2, 0, -1]]
b = [-2, -1]
c = [0, 0, -2, -1]
T = tableau(A, b, c, [3, 2])                     # basis (x3, x2)
print("Jan26\n" + fmt(T, X))
assert [r[0] for r in T["rows"]] == [1, F(3, 2)]
assert T["z0"] == -4
assert T["d"][0] == 4 and T["d"][1] == 6

# ---------------- Final June 2026, Q1 -------------------------------------
A = [[-2, 2, 0, 1], [1, 0, 2, -1]]
b = [-2, -2]
c = [-2, -2, 0, 2]
T = tableau(A, b, c, [0, 3])                     # basis (x0, x3)
print("Jun26\n" + fmt(T, X))
assert [r[0] for r in T["rows"]] == [4, 6]
assert T["z0"] == 4
assert T["d"][1] == -2 and T["d"][2] == 4
assert ratio_test(T, 1) == (None, [])             # x1 unbounded: +infinity

# ---------------- Slides "The Simplex Method": running example -------------
# min -x - 2y ; x+y+s1=3 ; x+s2=2 ; y+s3=2   (columns x,y,s1,s2,s3)
N = ["x", "y", "s1", "s2", "s3"]
A = [[1, 1, 1, 0, 0], [1, 0, 0, 1, 0], [0, 1, 0, 0, 1]]
b = [3, 2, 2]
c = [-1, -2, 0, 0, 0]
T0 = tableau(A, b, c, [2, 3, 4])
assert T0["z0"] == 0 and T0["d"] == {0: -1, 1: -2}
assert ratio_test(T0, 1) == (F(2), [2])           # y up to 2, s3 leaves
T1 = tableau(A, b, c, [2, 3, 1])
assert T1["z0"] == -4 and T1["d"] == {0: -1, 4: 2}
assert ratio_test(T1, 0) == (F(1), [0])           # x up to 1, s1 leaves
T2 = tableau(A, b, c, [0, 3, 1])
assert T2["z0"] == -5 and T2["d"] == {2: 1, 4: 1}
print("slides example: optimum -5 at (x,y)=(1,2)")

# ---------------- Phase I example (slides 18-24) ---------------------------
# x+y+s1=3, x+y-s2+z1=1, x+s3=2, y+s4=2 ; min z1
# columns: x y s1 s2 s3 s4 z1
A = [[1, 1, 1, 0, 0, 0, 0], [1, 1, 0, -1, 0, 0, 1], [1, 0, 0, 0, 1, 0, 0], [0, 1, 0, 0, 0, 1, 0]]
b = [3, 1, 2, 2]
c = [0, 0, 0, 0, 0, 0, 1]
P = tableau(A, b, c, [2, 6, 4, 5])
assert P["z0"] == 1 and P["d"][0] == -1 and P["d"][1] == -1
assert ratio_test(P, 0) == (F(1), [1])            # x enters, z1 leaves
P2 = tableau(A, b, c, [2, 0, 4, 5])
assert P2["z0"] == 0
# phase II: original objective min -x-2y on basis (s1,x,s3,s4)
c2 = [-1, -2, 0, 0, 0, 0, 0]
Q = tableau(A, b, c2, [2, 0, 4, 5])
assert Q["z0"] == -1 and Q["d"][1] == -1 and Q["d"][3] == -1
# finish phase II (book continues the slide's "..."): optimum of the LP
from itertools import combinations
best = None
Aorig = [row[:6] for row in A]
for basis in combinations(range(6), 4):
    try:
        T = tableau(Aorig, b, c2[:6], list(basis))
    except StopIteration:
        continue
    if all(r[0] >= 0 for r in T["rows"]):
        if best is None or T["z0"] < best[0]:
            best = (T["z0"], basis, T)
assert best[0] == -5
print("phase II optimum", best[0], "basis", [N[i] if i < 5 else "s4" for i in best[1]])

# continue phase II with Bland's rule (smallest index enters / leaves)
def bland_run(A, b, c, basis, names):
    path = []
    while True:
        T = tableau(A, b, c, basis)
        path.append((T["z0"], [names[i] for i in basis]))
        neg = sorted(j for j, d in T["d"].items() if d < 0)
        if not neg:
            return T, path
        j = neg[0]
        val, tight = ratio_test(T, j)
        assert val is not None
        i = min(tight, key=lambda r: basis[r])
        basis = basis[:i] + [j] + basis[i + 1:]

names = ["x", "y", "s1", "s2", "s3", "s4", "z1"]
Aphase2 = [row[:6] for row in A]
Tend, path = bland_run(Aphase2, b, c2[:6], [2, 0, 4, 5], names)
print("phase II path:", path)
assert path[0][0] == -1 and path[-1][0] == -5
assert path == [(-1, ['s1', 'x', 's3', 's4']), (-2, ['s1', 'y', 's3', 's4']),
                (-4, ['s1', 'y', 's3', 's2']), (-5, ['x', 'y', 's3', 's2'])]
PHASE2_PATH = path

# ---------------- Infeasible phase I example (slides 27-29) ----------------
# x+y-s1+z1=5, x+s2=2, y+s3=2 ; min z1   columns x y s1 s2 s3 z1
A = [[1, 1, -1, 0, 0, 1], [1, 0, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0]]
b = [5, 2, 2]
c = [0, 0, 0, 0, 0, 1]
T = tableau(A, b, c, [5, 3, 4])
assert T["z0"] == 5
T = tableau(A, b, c, [5, 0, 1])
assert T["z0"] == 1 and all(v >= 0 for v in T["d"].values())
print("infeasible example: phase I optimum 1 > 0")

# ---------------- Unboundedness example (slide 15) -------------------------
# min -x-y ; 2x+y-s=3 ; basis (y)
T = tableau([[2, 1, -1]], [3], [-1, -1, 0], [1])
assert T["z0"] == -3 and T["d"] == {0: 1, 2: -1}
assert ratio_test(T, 2) == (None, [])
print("unbounded example ok")

# ---------------- New exercises of chapter 4 --------------------------------
# NEW-4.a (warm-up): basis (s1,s2) of  min -3x1 - 2x2 ; x1+x2+s1=4 ; x1+3x2+s2=6
A = [[1, 1, 1, 0], [1, 3, 0, 1]]
b = [4, 6]
c = [-3, -2, 0, 0]
T = tableau(A, b, c, [2, 3])
assert ratio_test(T, 0) == (F(4), [0])
T = tableau(A, b, c, [0, 3])
assert T["z0"] == -12 and T["d"] == {1: 1, 2: 3}
assert [r[0] for r in T["rows"]] == [4, 2]
print("new 4.a ok: optimum -12 at x1=4")

print("ALL CHAPTER 4 CHECKS PASSED")
