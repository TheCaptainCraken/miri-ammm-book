"""New exam-style simplex questions written for the book (Ch. 4, Ch. 8, mock exam).
Instances were picked with gen_simplex_questions.py (seed 2027)."""
from fractions import Fraction as F
from simplex_tools import tableau, ratio_test

# Ch.4 exam-level look-alike  (ex:simplex-new-a)
T = tableau([[-1, 1, 0, 1], [-1, 2, 1, 1]], [-2, 1], [2, -1, 0, 0], [1, 0])
assert [r[0] for r in T["rows"]] == [3, 5] and T["z0"] == 7
assert T["d"] == {2: -1, 3: 2} and ratio_test(T, 2) == (F(3), [0])

# Ch.4 practice: degenerate tie in the ratio test  (ex:simplex-new-tie)
T = tableau([[0, 2, 2, -2], [1, 2, -2, -1]], [2, 2], [1, 2, 1, 0], [0, 2])
assert [r[0] for r in T["rows"]] == [4, 1] and T["z0"] == 5
assert T["d"] == {1: -3, 3: 4} and ratio_test(T, 1) == (F(1), [0, 1])
# after the pivot (x1 enters, Bland: x0 leaves since x0 has smaller index)
T2 = tableau([[0, 2, 2, -2], [1, 2, -2, -1]], [2, 2], [1, 2, 1, 0], [1, 2])
assert [r[0] for r in T2["rows"]] == [1, 0] and T2["z0"] == 2   # degenerate basis: x2 = 0
print("tie: new basis (x1,x2) values", [r[0] for r in T2["rows"]], "obj", T2["z0"], "d", T2["d"])

# Mock exam Q1  (ex:mock-q1)
T = tableau([[1, 0, 1, 1], [0, -1, 0, 1]], [2, -2], [-2, 2, 2, 1], [2, 1])
assert [r[0] for r in T["rows"]] == [2, 2] and T["z0"] == 8
assert T["d"] == {0: -4, 3: 1} and ratio_test(T, 0) == (F(2), [0])

# Ch.8 branching look-alikes (Jan style)
T = tableau([[-2, -1, 1, 0], [2, -1, -1, -2]], [1, -2], [1, 1, 2, 0], [2, 3])
assert [r[0] for r in T["rows"]] == [1, F(1, 2)] and T["z0"] == 2 and T["d"] == {0: 5, 1: 3}
T = tableau([[1, -1, -2, -2], [2, -1, -2, 2]], [-2, 1], [0, 1, -2, -1], [0, 2])
assert [r[0] for r in T["rows"]] == [3, F(5, 2)] and T["z0"] == -5 and T["d"] == {1: 2, 3: 5}
print("ALL NEW SIMPLEX QUESTIONS VERIFIED")
# Worked example 4.x (same system as Ch. 3): after the pivot the basis (x2, x0) is optimal, value 4
T = tableau([[-1, 1, 0, 1], [-1, 2, 1, 1]], [-2, 1], [2, -1, 0, 0], [2, 0])
assert [r[0] for r in T["rows"]] == [3, 2] and T["z0"] == 4 and T["d"] == {1: 1, 3: 2}
# Your turn 4.1
A = [[-1, 0, -1, 1], [-1, -2, 2, -2]]; b = [-1, -2]; c = [2, 2, 2, 1]
T = tableau(A, b, c, [2, 1])
assert [r[0] for r in T["rows"]] == [1, 2] and T["z0"] == 6 and T["d"] == {0: -3, 3: 3}
assert T["rows"][1][1] == {0: F(-3, 2), 3: 0}
assert ratio_test(T, 0) == (F(1), [0])
T = tableau(A, b, c, [0, 1])
assert [r[0] for r in T["rows"]] == [1, F(1, 2)] and T["z0"] == 3 and T["d"] == {2: 3, 3: 0}
print("CH4 WORKED/YOUR-TURN OK")
# ch4-w3: reduced cost of x for basis (s1, s2, y) of min -x-2y
T = tableau([[1, 1, 1, 0, 0], [1, 0, 0, 1, 0], [0, 1, 0, 0, 1]], [3, 2, 2], [-1, -2, 0, 0, 0], [2, 3, 1])
assert T["d"][0] == -1 and T["d"][4] == 2 and T["z0"] == -4
# ch4-p3: unbounded LP  min -x-y ; x-y+s1=1 ; -x+y+s2=1
A = [[1, -1, 1, 0], [-1, 1, 0, 1]]
T = tableau(A, [1, 1], [-1, -1, 0, 0], [2, 3])
assert ratio_test(T, 0) == (F(1), [0])
T = tableau(A, [1, 1], [-1, -1, 0, 0], [0, 3])
assert T["z0"] == -1 and T["d"] == {1: -2, 2: 1} and ratio_test(T, 1) == (None, [])
# simplex-new-a: basis (x0, x1) of the Your-turn LP is optimal, value 3, d2 = 3, d3 = 0
T = tableau([[-1, 0, -1, 1], [-1, -2, 2, -2]], [-1, -2], [2, 2, 2, 1], [0, 1])
assert T["rows"][0] == (1, {2: -1, 3: 1}) and T["rows"][1] == (F(1, 2), {2: F(3, 2), 3: F(-3, 2)})
print("CH4 EXERCISES OK")
# ch5-r1 (review): min x0 + x2 ; x0 + x1 - x2 = 3 ; x0 - x1 + x3 = 1 ; basis (x0, x1)
T = tableau([[1, 1, -1, 0], [1, -1, 0, 1]], [3, 1], [1, 0, 1, 0], [0, 1])
assert [r[0] for r in T["rows"]] == [2, 1] and T["z0"] == 2 and T["d"] == {2: F(3, 2), 3: F(-1, 2)}
assert ratio_test(T, 3) == (F(4), [0])
print("CH5 REVIEW OK")
# Ch8 look-alikes: full tableaux used in the answers
T = tableau([[-2, -1, 1, 0], [2, -1, -1, -2]], [1, -2], [1, 1, 2, 0], [2, 3])
assert T["rows"] == [(1, {0: 2, 1: 1}), (F(1, 2), {0: 0, 1: -1})]
T = tableau([[1, -1, -2, -2], [2, -1, -2, 2]], [-2, 1], [0, 1, -2, -1], [0, 2])
assert T["rows"] == [(3, {1: 0, 3: -4}), (F(5, 2), {1: F(-1, 2), 3: -3})]
print("CH8 LOOKALIKES OK")
