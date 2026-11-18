"""Chapter 9 (non-linear programming): separable programming, SOS2, product terms."""
from fractions import Fraction as F
import itertools
from simplex_tools import solve_lp_exact

# region: x+z<=4, 2x+z<=5, -x+4z>=2 (i.e. x-4z<=-2), x,z>=0 ; variables (x, z, y, l1..l4)
REG = [[1, 1], [2, 1], [1, -4]]
RHS = [4, 5, -2]


def approx(breaks, f, obj, extra=None, sos2=True):
    """Piecewise-linear lambda formulation.  obj = coefficients on (x, z, y)."""
    k = len(breaks)
    n = 3 + k
    A_ub = [r + [0] * (1 + k) for r in REG]
    b_ub = list(RHS)
    if extra:
        for row, rhs in extra:
            A_ub.append(row + [0] * (1 + k)); b_ub.append(rhs)
    A_eq = [[-1, 0, 0] + [F(b) for b in breaks], [0, 0, -1] + [F(f(b)) for b in breaks], [0, 0, 0] + [1] * k]
    b_eq = [0, 0, 1]
    c = list(obj) + [0] * k
    if not sos2:
        return solve_lp_exact(A_ub, b_ub, A_eq, b_eq, c)
    best = None
    for i in range(k - 1):                       # only lambda_i, lambda_{i+1} may be non-zero
        fix = [[0] * n for _ in range(k)]
        rows, rhs = [], []
        for j in range(k):
            if j not in (i, i + 1):
                r = [0] * n; r[3 + j] = 1; rows.append(r); rhs.append(0)
        st, v, x = solve_lp_exact(A_ub + rows, b_ub + rhs, A_eq, b_eq, c)
        if st == "optimal" and (best is None or v < best[1]):
            best = (st, v, x)
    return best


# convex separable example: min x^2 - 4x - 2z, breakpoints 0,1,2
st, v, x = approx([0, 1, 2], lambda t: t * t, [-4, -2, 1], sos2=False)
assert v == -9 and x[:2] == [1, 3]
print("separable convex example: approx optimum -9 at x=1, z=3 (also the exact optimum)")
# exact optimum by calculus on the boundary (checked numerically)
grid = min((xx * xx - 4 * xx - 2 * min(4 - xx, 5 - 2 * xx), xx) for xx in [i / 1000 for i in range(0, 2001)]
           if (2 + xx) / 4 <= min(4 - xx, 5 - 2 * xx))
assert abs(grid[0] + 9) < 1e-9 and abs(grid[1] - 1) < 1e-9

# non-convex example: min x - x^3 + z, breakpoints 0, 1, 1.5, 2
cube = lambda t: F(t) ** 3
B = [0, 1, F(3, 2), 2]
assert [cube(b) for b in B] == [0, 1, F(27, 8), 8]
nos = approx(B, cube, [1, 1, -1], sos2=False)
yes = approx(B, cube, [1, 1, -1], sos2=True)
print("non-convex slide example: without SOS2", nos[1], nos[2][:3], " with SOS2", yes[1], yes[2][:3])
assert nos[1] == yes[1] == -5            # optimum at the breakpoint x=2: the slide example does not show the failure
# add x <= 3/2 : now the relaxation without adjacency goes 'away from the curve'
ex = [([2, 0], 3)]                       # 2x <= 3
nos = approx(B, cube, [1, 1, -1], extra=ex, sos2=False)
yes = approx(B, cube, [1, 1, -1], extra=ex, sos2=True)
print("with x <= 3/2: without SOS2", nos[1], [str(t) for t in nos[2][:3]], " with SOS2", yes[1], [str(t) for t in yes[2][:3]])
assert nos[1] == F(-29, 8) and nos[2][2] == 6           # y = 6 although x^3 = 27/8 at x = 3/2
assert yes[1] == -1 and yes[2][:3] == [F(3, 2), F(7, 8), F(27, 8)]
assert F(3, 2) - F(27, 8) + F(7, 8) == -1                # true objective at the SOS2 answer

# convex program min x^2 + y^2 over the polygon of the slides: nearest point to the origin
best = min(((i / 400) ** 2 + (j / 400) ** 2, i / 400, j / 400) for i in range(0, 1601) for j in range(0, 1601)
           if i / 400 + j / 400 <= 4 and 2 * i / 400 + j / 400 <= 5 and -i / 400 + 4 * j / 400 >= 2)
print("min x^2+y^2 on the polygon ~", best)
# exact: projection of origin on -x+4y=2 is (-2/17, 8/17) -> outside x>=0 ; so x=0, y=1/2, value 1/4
assert abs(best[0] - 0.25) < 1e-9

# product of two variables: x1*x2 = u1^2 - u2^2 with u1=(x1+x2)/2, u2=(x1-x2)/2
for x1, x2 in itertools.product(range(-3, 4), repeat=2):
    u1, u2 = F(x1 + x2, 2), F(x1 - x2, 2)
    assert u1 * u1 - u2 * u2 == x1 * x2

# product of k binaries and a bounded y: w = x1...xk * y via linear constraints (check by enumeration)
u = 5
for xs in itertools.product([0, 1], repeat=2):
    for y in range(0, u + 1):
        feas = [w for w in range(0, u + 1) if all(w <= u * xj for xj in xs) and w <= y and w >= u * (sum(xs) - 2) + y]
        assert feas == [y * xs[0] * xs[1]]

# SOS2 encoding with binaries delta (slide 23): n = 4 -> deltas 1..3
for mu in itertools.product([0, 1], repeat=4):
    sos2 = sum(mu) <= 2 and not (sum(mu) == 2 and not any(mu[i] and mu[i + 1] for i in range(3)))
    enc = any(sum(d) <= 1 and mu[0] <= d[0] and mu[1] <= d[0] + d[1] and mu[2] <= d[1] + d[2] and mu[3] <= d[2]
              for d in itertools.product([0, 1], repeat=3))
    assert sos2 == enc, mu
print("ALL CHAPTER 9 CHECKS PASSED")

# ---- New exam-style question (Ch. 9): concave purchase cost ------------------------
# buy x from A with piecewise-linear concave cost through (0,0),(10,100),(30,220),(60,370),
# y from B at 6.5/unit, x + y = 50, minimise.  Variables: l0..l3, y  (x = 10 l1 + 30 l2 + 60 l3)
B = [0, 10, 30, 60]; G = [0, 100, 220, 370]
slopes = [F(G[i + 1] - G[i], B[i + 1] - B[i]) for i in range(3)]
assert slopes == [10, 6, 5]                                  # decreasing slopes: concave
def buy(sos2):
    A_eq = [[B[0], B[1], B[2], B[3], 1], [1, 1, 1, 1, 0]]
    b_eq = [50, 1]
    c = G + [F(13, 2)]
    if not sos2:
        return solve_lp_exact(None, None, A_eq, b_eq, c)
    best = None
    for i in range(3):
        rows = [[1 if j == k else 0 for j in range(5)] for k in range(4) if k not in (i, i + 1)]
        r = solve_lp_exact(rows, [0] * len(rows), A_eq, b_eq, c)
        if r[0] == "optimal" and (best is None or r[1] < best[1]):
            best = r
    return best
nos, yes = buy(False), buy(True)
print("concave purchase: without SOS2", nos[1], nos[2], " with SOS2", yes[1], yes[2])
assert nos[1] == F(925, 3) and yes[1] == 320                 # 308.33 (wrong, below the curve) vs 320
# piecewise x^2 at x = 1.5 with breakpoints 0,1,2: 0.5*1 + 0.5*4 = 2.5 vs 2.25
assert F(1, 2) * 1 + F(1, 2) * 4 == F(5, 2)
# oranges: derivative 1000 - 400/(1+x) > 0 for x >= 0  -> profit increasing
assert all(1000 - 400 / (1 + x) > 0 for x in [0, 0.5, 1, 10])
print("CH9 NEW OK")
