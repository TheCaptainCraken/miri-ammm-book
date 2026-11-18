"""Chapter 8: branch & bound and cutting planes (slides examples, past exams, new exercises)."""
from fractions import Fraction as F
from math import floor, ceil
from simplex_tools import solve_lp_exact, tableau


def lp(A_ub, b_ub, c, bounds, sense):
    """bounds: list of (var_index, '<=' or '>=', value)."""
    A, b = [r[:] for r in A_ub], list(b_ub)
    n = len(c)
    for j, op, v in bounds:
        row = [0] * n
        row[j] = 1 if op == "<=" else -1
        A.append(row)
        b.append(v if op == "<=" else -v)
    return solve_lp_exact(A, b, None, None, c, sense)


def branch_and_bound(A_ub, b_ub, c, sense, names, order="depth-right-first", var_rule="first"):
    """Depth-first B&B as on the slides; returns incumbent and a log of nodes."""
    log = []
    best_val, best_x = None, None
    stack = [[]]
    better = (lambda a, b: a > b) if sense == "max" else (lambda a, b: a < b)
    while stack:
        bounds = stack.pop()
        st, val, x = lp(A_ub, b_ub, c, bounds, sense)
        tag = " & ".join(f"{names[j]}{op}{v}" for j, op, v in bounds) or "root"
        if st == "infeasible":
            log.append((tag, "infeasible", None)); continue
        frac = [j for j, v in enumerate(x) if v.denominator != 1]
        if best_val is not None and not better(val, best_val):
            log.append((tag, f"pruned by bound {val}", x)); continue
        if not frac:
            log.append((tag, f"integer {val}", x))
            best_val, best_x = val, x
            continue
        j = frac[0] if var_rule == "first" else frac[-1]
        log.append((tag, f"LP {val}, branch on {names[j]}={x[j]}", x))
        lo = bounds + [(j, "<=", floor(x[j]))]
        hi = bounds + [(j, ">=", ceil(x[j]))]
        stack += [lo, hi] if order == "depth-right-first" else [hi, lo]
    return best_val, best_x, log


# ---- Slides example 1: max x+y ; -2x+2y>=1 ; -8x+10y<=13 ; x,y in Z ----
A = [[2, -2], [-8, 10]]       # -2x+2y>=1  <=>  2x-2y <= -1
b = [-1, 13]
st, v, x = lp(A, b, [1, 1], [], "max")
assert v == F(17, 2) and x == [4, F(9, 2)]
# the exact node values shown on the slides
chain = [([(1, "<=", 4)], F(15, 2), [F(7, 2), 4]),
         ([(1, "<=", 4), (0, "<=", 3)], F(67, 10), [3, F(37, 10)]),
         ([(1, "<=", 4), (0, "<=", 3), (1, "<=", 3)], F(11, 2), [F(5, 2), 3]),
         ([(1, "<=", 4), (0, "<=", 3), (1, "<=", 3), (0, "<=", 2)], F(49, 10), [2, F(29, 10)]),
         ([(1, "<=", 4), (0, "<=", 3), (1, "<=", 3), (0, "<=", 2), (1, "<=", 2)], F(7, 2), [F(3, 2), 2]),
         ([(1, "<=", 4), (0, "<=", 3), (1, "<=", 3), (0, "<=", 2), (1, "<=", 2), (0, "<=", 1)], F(3), [1, 2])]
for bnds, val, sol in chain:
    st, v, x = lp(A, b, [1, 1], bnds, "max")
    assert (v, x) == (val, sol), (bnds, v, x)
for dead in [[(1, ">=", 5)], [(1, "<=", 4), (0, ">=", 4)], [(1, "<=", 4), (0, "<=", 3), (1, ">=", 4)],
             [(1, "<=", 4), (0, "<=", 3), (1, "<=", 3), (0, ">=", 3)],
             [(1, "<=", 4), (0, "<=", 3), (1, "<=", 3), (0, "<=", 2), (1, ">=", 3)],
             [(1, "<=", 4), (0, "<=", 3), (1, "<=", 3), (0, "<=", 2), (1, "<=", 2), (0, ">=", 2)]]:
    assert lp(A, b, [1, 1], dead, "max")[0] == "infeasible", dead
best, bx, log = branch_and_bound(A, b, [1, 1], "max", ["x", "y"], var_rule="last")
assert best == 3 and bx == [1, 2]
print("example 1 B&B log:")
for l in log:
    print("  ", l[0], "->", l[1])

# ---- Slides example 2: max 2x+3y ; x+2y<=5 ; 2x+y<=5 -------------------
A2, b2 = [[1, 2], [2, 1]], [5, 5]
st, v, x = lp(A2, b2, [2, 3], [], "max")
assert v == F(25, 3) and x == [F(5, 3), F(5, 3)]      # slide prints 4.1666..., which is wrong
assert float(v) != 4.1666666667
assert lp(A2, b2, [2, 3], [(1, ">=", 2)], "max")[1:] == (F(8), [1, 2])
assert lp(A2, b2, [2, 3], [(1, "<=", 1)], "max")[1:] == (F(7), [2, 1])
print("example 2: root LP value 25/3 =", float(F(25, 3)))

# ---- Gomory cut on example 1 -------------------------------------------
# canonical form: min -x-y ; -2x+2y-s1=1 ; -8x+10y+s2=13 ; basis (x,y)
T = tableau([[-2, 2, -1, 0], [-8, 10, 0, 1]], [1, 13], [-1, -1, 0, 0], [0, 1])
assert T["z0"] == F(-17, 2) and T["d"] == {2: F(9, 2), 3: 1}
assert T["rows"][0] == (4, {2: F(-5, 2), 3: F(-1, 2)})
assert T["rows"][1] == (F(9, 2), {2: -2, 3: F(-1, 2)})
# general Gomory (fractional) cut from the y-row: frac coefficients >= frac(rhs)
# y + 2 s1 + 1/2 s2 = 9/2  ->  0*s1 + 1/2*s2 >= 1/2  -> s2 >= 1 -> -8x+10y <= 12
# check the slide's cut y<=4 and the textbook cut are both valid on all integer points
pts = [(x, y) for x in range(0, 10) for y in range(0, 10) if -2 * x + 2 * y >= 1 and -8 * x + 10 * y <= 13]
assert all(y <= 4 for x, y in pts) and all(-8 * x + 10 * y <= 12 for x, y in pts)
assert max(x + y for x, y in pts) == 3
# LP after adding the slide's cut y <= 4 equals the B&B child y<=4
assert lp(A + [[0, 1]], b + [4], [1, 1], [], "max")[1] == F(15, 2)
# LP after adding the fractional cut
st, v, x = lp(A + [[-8, 10]], b + [12], [1, 1], [], "max")
print("after Gomory cut -8x+10y<=12: LP value", v, x)
assert v == F(15, 2) and x == [F(7, 2), 4]

# ---- Past exams Q1(d) : which variables can be branched on --------------
# Jan 2025: x3 = 1/3, x2 = 2/3  -> branch x3<=0 | x3>=1 ; x2<=0 | x2>=1
# Jan 2026: x3 = 1, x2 = 3/2    -> only x2: x2<=1 | x2>=2
assert floor(F(1, 3)) == 0 and floor(F(2, 3)) == 0 and floor(F(3, 2)) == 1

# ---- New exercise: finish the B&B of Jan 2026 (pure integer version) -----
#   min -2x2 - x3 ; -2x1-2x2+x3=-2 ; -2x0-2x1-x3=-1 ; x>=0 integer
# second equation: 2x0 + 2x1 + x3 = 1 -> x3 odd... we solve exactly
from itertools import product
best = None
for xs in product(range(0, 6), repeat=4):
    x0, x1, x2, x3 = xs
    if -2 * x1 - 2 * x2 + x3 == -2 and -2 * x0 - 2 * x1 - x3 == -1:
        val = -2 * x2 - x3
        if best is None or val < best[0]:
            best = (val, xs)
print("Jan 2026 integer optimum (brute force):", best)
assert best is None          # the pure integer version is infeasible (parity: 2x0+2x1+x3=1 forces x3=1, then x2=3/2)
for extra, rhs in [([0, 0, 1, 0], 1), ([0, 0, -1, 0], -2)]:
    r = solve_lp_exact([extra], [rhs], Aeq_j26 := [[0, -2, -2, 1], [-2, -2, 0, -1]], [-2, -1], [0, 0, -2, -1])
    print("  Jan26 child", "x2<=1" if rhs == 1 else "x2>=2", r)
JAN26_CHILD_LE = solve_lp_exact([[0, 0, 1, 0]], [1], [[0, -2, -2, 1], [-2, -2, 0, -1]], [-2, -1], [0, 0, -2, -1])
JAN26_CHILD_GE = solve_lp_exact([[0, 0, -1, 0]], [-2], [[0, -2, -2, 1], [-2, -2, 0, -1]], [-2, -1], [0, 0, -2, -1])
assert JAN26_CHILD_GE[0] == "infeasible"
assert JAN26_CHILD_LE[1] == F(-5, 2) and JAN26_CHILD_LE[2] == [0, F(1, 4), 1, F(1, 2)]
# Jan 2025 integer version
Aeq = [[2, 2, -1, 2], [-2, 2, 2, -1]]
beq = [0, 1]
c = [2, 2, 1, -2]
best = None
for xs in product(range(0, 8), repeat=4):
    if all(sum(a * v for a, v in zip(r, xs)) == bb for r, bb in zip(Aeq, beq)):
        val = sum(a * v for a, v in zip(c, xs))
        if best is None or val < best[0]:
            best = (val, xs)
print("Jan 2025 integer optimum (brute force, box 0..7):", best)
assert best is None   # also infeasible: adding the rows gives 4x1+x2+x3=1
for extra, rhs in [([0, 0, 0, 1], 0), ([0, 0, 0, -1], -1), ([0, 0, 1, 0], 0), ([0, 0, -1, 0], -1)]:
    print("  Jan25 child", extra, rhs, solve_lp_exact([extra], [rhs], Aeq, beq, c))

# ---- New exercise (ex:bb-new-tree): max 5x+4y ; 6x+4y<=24 ; x+2y<=6 ; x,y int
A3, b3 = [[6, 4], [1, 2]], [24, 6]
st, v, x = lp(A3, b3, [5, 4], [], "max")
assert v == 21 and x == [3, F(3, 2)]
best, bx, log = branch_and_bound(A3, b3, [5, 4], "max", ["x", "y"])
print("new tree:")
for l in log:
    print("  ", l)
assert best == 20 and bx == [4, 0]
assert [l[1] for l in log] == ["LP 21, branch on y=3/2", "integer 18", "LP 62/3, branch on x=10/3",
                              "integer 20", "pruned by bound 19"]
print("ALL CHAPTER 8 CHECKS PASSED")

# ---- Your turn 8.1: Gomory cut for max 5x+4y ; 6x+4y+s1=24 ; x+2y+s2=6 -----------
T = tableau([[6, 4, 1, 0], [1, 2, 0, 1]], [24, 6], [-5, -4, 0, 0], [0, 1])
assert T["rows"][0] == (3, {2: F(-1, 4), 3: F(1, 2)})
assert T["rows"][1] == (F(3, 2), {2: F(1, 8), 3: F(-3, 4)})
# y - 1/8 s1 + 3/4 s2 = 3/2  ->  fractional parts: 7/8 s1 + 3/4 s2 >= 1/2  ->  6x + 5y <= 25
from math import floor as fl
fr = lambda q: q - fl(q)
assert (fr(F(-1, 8)), fr(F(3, 4)), fr(F(3, 2))) == (F(7, 8), F(3, 4), F(1, 2))
pts = [(x, y) for x in range(0, 6) for y in range(0, 6) if 6 * x + 4 * y <= 24 and x + 2 * y <= 6]
assert all(6 * x + 5 * y <= 25 for x, y in pts) and 6 * 3 + 5 * F(3, 2) > 25
st, v, x = lp([[6, 4], [1, 2], [6, 5]], [24, 6, 25], [5, 4], [], "max")
print("after cut 6x+5y<=25:", v, x)
assert v == F(62, 3) and x == [F(10, 3), 1]
print("YOUR TURN 8.1 OK")
