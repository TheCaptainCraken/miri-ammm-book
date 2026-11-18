"""Exact (rational) simplex helpers used by the verification scripts.

Everything is done with fractions.Fraction so that no rounding can hide an
error.  The functions follow the notation of the book:

    min c^T x  s.t.  A x = b,  x >= 0
    basis B (list of column indices), non-basic R = the rest
    x_B = B^-1 b - B^-1 R x_R          (the tableau)
    d_R = c_R - c_B^T B^-1 R           (reduced costs)
"""
from fractions import Fraction as F


def mat(rows):
    return [[F(v) for v in r] for r in rows]


def inverse(M):
    n = len(M)
    A = [row[:] + [F(int(i == j)) for j in range(n)] for i, row in enumerate(M)]
    for col in range(n):
        piv = next(r for r in range(col, n) if A[r][col] != 0)
        A[col], A[piv] = A[piv], A[col]
        p = A[col][col]
        A[col] = [v / p for v in A[col]]
        for r in range(n):
            if r != col and A[r][col] != 0:
                f = A[r][col]
                A[r] = [a - f * b for a, b in zip(A[r], A[col])]
    return [row[n:] for row in A]


def matvec(M, v):
    return [sum(a * b for a, b in zip(row, v)) for row in M]


def tableau(A, b, c, basis):
    """Return dict with the tableau of a basis.

    rows[i] = (beta_i, {j: coeff}) meaning x_basis[i] = beta_i + sum coeff*x_j
    (coefficients are those of -B^-1 R, i.e. already with the sign of the tableau)
    obj = (z0, {j: d_j})  meaning  c^T x = z0 + sum d_j x_j
    """
    A, b, c = mat(A), [F(v) for v in b], [F(v) for v in c]
    m, n = len(A), len(A[0])
    Bm = [[A[i][j] for j in basis] for i in range(m)]
    Binv = inverse(Bm)
    beta = matvec(Binv, b)
    nonbasic = [j for j in range(n) if j not in basis]
    rows = []
    for i in range(m):
        coeffs = {}
        for j in nonbasic:
            col = [A[r][j] for r in range(m)]
            coeffs[j] = -matvec(Binv, col)[i]
        rows.append((beta[i], coeffs))
    z0 = sum(c[basis[i]] * beta[i] for i in range(m))
    d = {j: c[j] + sum(c[basis[i]] * rows[i][1][j] for i in range(m)) for j in nonbasic}
    return {"basis": basis, "rows": rows, "z0": z0, "d": d, "nonbasic": nonbasic}


def ratio_test(T, j):
    """Largest value the non-basic x_j can take (others frozen at 0).

    Returns (value, list of tight basic positions); value None means +infinity.
    """
    best, tight = None, []
    for i, (beta, coeffs) in enumerate(T["rows"]):
        a = coeffs[j]
        if a < 0:                       # x_B[i] = beta + a*x_j decreases
            lim = beta / (-a)
            if best is None or lim < best:
                best, tight = lim, [i]
            elif lim == best:
                tight.append(i)
    return best, tight


def pivot_basis(T, j, i):
    """New basis after x_j enters and the basic variable in row i leaves."""
    nb = list(T["basis"])
    nb[i] = j
    return nb


def fmt(T, names):
    out = []
    for i, (beta, co) in enumerate(T["rows"]):
        terms = " ".join(f"{'+' if v >= 0 else '-'} {abs(v)}*{names[j]}" for j, v in co.items() if v != 0)
        out.append(f"{names[T['basis'][i]]} = {beta} {terms}")
    terms = " ".join(f"{'+' if v >= 0 else '-'} {abs(v)}*{names[j]}" for j, v in T["d"].items() if v != 0)
    out.append(f"obj = {T['z0']} {terms}")
    return "\n".join(out)


def solve_lp_exact(A_ub, b_ub, A_eq, b_eq, c, sense="min"):
    """Tiny exact LP solver by vertex enumeration (only for small textbook LPs).

    Variables are x >= 0.  Inequalities A_ub x <= b_ub get slack columns.
    Returns (status, value, x) with status in {"optimal", "infeasible"}.
    Unboundedness must be excluded by the caller (bounded textbook problems).
    """
    from itertools import combinations
    A_ub, A_eq = A_ub or [], A_eq or []
    n = len(c)
    m_ub, m_eq = len(A_ub), len(A_eq)
    rows, rhs = [], []
    for i, r in enumerate(A_ub):
        rows.append([F(v) for v in r] + [F(int(k == i)) for k in range(m_ub)]); rhs.append(F(b_ub[i]))
    for i, r in enumerate(A_eq):
        rows.append([F(v) for v in r] + [F(0)] * m_ub); rhs.append(F(b_eq[i]))
    cc = [F(v) if sense == "min" else -F(v) for v in c] + [F(0)] * m_ub
    m, N = len(rows), n + m_ub
    best = None
    for basis in combinations(range(N), m):
        Bm = [[rows[i][j] for j in basis] for i in range(m)]
        try:
            Binv = inverse(Bm)
        except StopIteration:
            continue
        xb = matvec(Binv, rhs)
        if any(v < 0 for v in xb):
            continue
        x = [F(0)] * N
        for k, j in enumerate(basis):
            x[j] = xb[k]
        val = sum(a * b for a, b in zip(cc, x))
        if best is None or val < best[0]:
            best = (val, x[:n])
    if best is None:
        return "infeasible", None, None
    val = best[0] if sense == "min" else -best[0]
    return "optimal", val, best[1]
