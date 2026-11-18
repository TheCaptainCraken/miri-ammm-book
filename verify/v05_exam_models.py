"""Past-exam Q2 models (official solutions and the book's alternatives) and the sheet
models without data (Ex 4, 6, 7), each compared with brute force on random small
instances.  If a model were wrong, some random instance would disagree."""
import itertools
import random
from docplex.mp.model import Model

random.seed(2026)
TRIALS = 25


def opt(m):
    s = m.solve()
    return None if s is None else round(s.objective_value, 6)


# ------------------------- Final June 2024 Q2 (rental plan) ----------------------------
def jun24_model(n, w, h, H, W, p):
    r, s = len(H), len(W)
    Hr, Ws = H[-1], W[-1]
    m = Model()
    c = {(i, j): m.binary_var() for i in range(r) for j in range(s)}
    tr = [m.integer_var(lb=0, ub=Hr) for _ in range(n)]
    lc = [m.integer_var(lb=0, ub=Ws) for _ in range(n)]
    a = {(k, q): m.binary_var() for k in range(n) for q in range(n) if k != q}
    l = {(k, q): m.binary_var() for k in range(n) for q in range(n) if k != q}
    m.add(m.sum(c.values()) == 1)
    for k in range(n):
        m.add(tr[k] <= m.sum(H[i] * c[i, j] for i in range(r) for j in range(s)) - h[k])   # [A]
        m.add(lc[k] <= m.sum(W[j] * c[i, j] for i in range(r) for j in range(s)) - w[k])   # [B]
    for k in range(n):
        for q in range(n):
            if k != q:
                m.add(tr[k] - tr[q] - h[q] >= (1 - a[k, q]) * (1 - Hr - h[q]))
                m.add(lc[k] - lc[q] - w[q] >= (1 - l[k, q]) * (1 - Ws - w[q]))
    for k in range(n):
        for q in range(k + 1, n):
            m.add(a[k, q] + a[q, k] + l[k, q] + l[q, k] >= 1)
    m.minimize(m.sum(p[i][j] * c[i, j] for i in range(r) for j in range(s)))
    return opt(m)


def packs(n, w, h, Hc, Wc):
    rng_t = [range(0, Hc - h[k] + 1) for k in range(n)]
    rng_l = [range(0, Wc - w[k] + 1) for k in range(n)]
    for ts in itertools.product(*rng_t):
        for ls in itertools.product(*rng_l):
            ok = all(ts[k] + h[k] <= ts[q] or ts[q] + h[q] <= ts[k] or ls[k] + w[k] <= ls[q] or ls[q] + w[q] <= ls[k]
                     for k in range(n) for q in range(k + 1, n))
            if ok:
                return True
    return False


for _ in range(TRIALS):
    n = random.choice([2, 3])
    w = [random.randint(1, 3) for _ in range(n)]
    h = [random.randint(1, 3) for _ in range(n)]
    H, W = sorted(random.sample(range(2, 7), 2)), sorted(random.sample(range(2, 7), 2))
    p = [[random.randint(1, 9) for _ in W] for _ in H]
    brute = min((p[i][j] for i in range(2) for j in range(2) if packs(n, w, h, H[i], W[j])), default=None)
    assert jun24_model(n, w, h, H, W, p) == brute, (n, w, h, H, W, p)
print("Jun24 Q2 official model == brute force on", TRIALS, "instances")


# ------------------------- Final January 2025 Q2 (classes) ------------------------------
def jan25_model(n, m_, l, u, G, B, C):
    m = Model()
    x = {(i, j): m.binary_var() for i in range(n) for j in range(m_)}
    z = m.continuous_var(lb=-1e3, ub=1)
    for j in range(m_):
        m.add(m.sum(x[i, j] for i in range(n)) >= l)
        m.add(m.sum(x[i, j] for i in range(n)) <= u)
        m.add(m.sum(x[i, j] for i in G) >= 2 * m.sum(x[i, j] for i in B))
        for i in range(n):
            for k in range(i + 1, n):
                m.add(z <= C[i][k] + 2 - x[i, j] - x[k, j])
    for i in range(n):
        m.add(m.sum(x[i, j] for j in range(m_)) == 1)
    m.maximize(z)
    return opt(m)


def jan25_brute(n, m_, l, u, G, B, C):
    best = None
    for a in itertools.product(range(m_), repeat=n):
        cls = [[i for i in range(n) if a[i] == j] for j in range(m_)]
        if any(not (l <= len(c) <= u) for c in cls):
            continue
        if any(sum(i in G for i in c) < 2 * sum(i in B for i in c) for c in cls):
            continue
        pairs = [C[i][k] for c in cls for i in c for k in c if i < k]
        val = min(pairs) if pairs else 1
        best = val if best is None else max(best, val)
    return best


for _ in range(TRIALS):
    n, m_ = 6, 2
    l, u = random.choice([(2, 4), (3, 3), (1, 5)])
    stu = list(range(n)); random.shuffle(stu)
    G, B = stu[:3], stu[3:4]
    C = [[1.0] * n for _ in range(n)]
    for i in range(n):
        for k in range(i + 1, n):
            C[i][k] = C[k][i] = round(random.random(), 2)
    br = jan25_brute(n, m_, l, u, G, B, C)
    mo = jan25_model(n, m_, l, u, G, B, C)
    assert (br is None and mo is None) or abs(br - mo) < 1e-6, (br, mo)
print("Jan25 Q2 official model == brute force on", TRIALS, "instances")


# ------------------------- Final June 2025 Q2 (First Dates) ------------------------------
def jun25_model(n, m_, f, s, I, J):
    m = Model()
    x = {(i, j): m.binary_var() for i in range(n) for j in range(m_)}
    y = {(i, j): m.binary_var() for i in range(n) for j in range(m_)}
    for i in range(n):
        for j in range(m_):
            m.add(x[i, j] + y[i, j] <= 1)
    m.add(m.sum(x.values()) == m.sum(y.values()))
    m.add(m.sum(x[i, j] + y[i, j] for i in I for j in range(m_)) + m.sum(x[i, j] + y[i, j] for i in range(n) for j in J) >= 1)
    for i in range(n):
        m.add(m.sum(x[i, j] + y[i, j] for j in range(m_)) <= 1)
    for j in range(m_):
        m.add(m.sum(x[i, j] + y[i, j] for i in range(n)) <= 1)
    m.maximize(m.sum(f[i][j] * x[i, j] + s[i][j] * y[i, j] for i in range(n) for j in range(m_)))
    return opt(m)


def jun25_brute(n, m_, f, s, I, J):
    best = None
    for match in itertools.product(range(-1, m_), repeat=n):        # woman of each man (-1 none)
        used = [j for j in match if j >= 0]
        if len(used) != len(set(used)):
            continue
        idx = [i for i in range(n) if match[i] >= 0]
        for first in itertools.product([0, 1], repeat=len(idx)):     # 1 = man confesses first
            if sum(first) * 2 != len(idx):
                continue
            if not any(i in I or match[i] in J for i in idx):
                continue
            val = sum(f[i][match[i]] if fi else s[i][match[i]] for i, fi in zip(idx, first))
            best = val if best is None else max(best, val)
    return best


for _ in range(TRIALS):
    n, m_ = 3, 3
    f = [[random.randint(-2, 9) for _ in range(m_)] for _ in range(n)]
    s = [[random.randint(-2, 9) for _ in range(m_)] for _ in range(n)]
    I, J = [random.randrange(n)], [random.randrange(m_)]
    assert jun25_model(n, m_, f, s, I, J) == jun25_brute(n, m_, f, s, I, J)
print("Jun25 Q2 official model == brute force on", TRIALS, "instances (scores may be negative)")


# ------------------------- Final January 2026 Q2 (neighbours) ----------------------------
def jan26_model(n, M, T):
    m = Model()
    x = [m.binary_var() for _ in range(n)]
    y = [m.binary_var() for _ in range(n)]
    m.add(m.sum(y) >= n // 2)
    for i in range(n):
        m.add(m.sum(M[j][i] * x[j] for j in range(n)) >= y[i])
    m.minimize(m.sum(T[i] * x[i] for i in range(n)))
    return opt(m)


def jan26_brute(n, M, T):
    best = None
    for sel in itertools.product([0, 1], repeat=n):
        yes = sum(1 for i in range(n) if any(sel[j] and M[j][i] for j in range(n)))
        if 1 + yes > n - yes:                                      # you vote YES too
            val = sum(T[i] for i in range(n) if sel[i])
            best = val if best is None else min(best, val)
    return best


for _ in range(TRIALS):
    n = random.choice([4, 6])
    M = [[1 if i == j else int(random.random() < .3) for j in range(n)] for i in range(n)]
    T = [random.randint(1, 9) for _ in range(n)]
    assert jan26_model(n, M, T) == jan26_brute(n, M, T)
print("Jan26 Q2 official model == brute force on", TRIALS, "instances")


# ------------------------- Final June 2026 Q2 (ISS crew) ---------------------------------
def jun26_model(N, K, E, c, Mx):
    m = Model()
    x = [m.binary_var() for _ in range(N)]
    nonE = [(i, j) for i in range(N) for j in range(i + 1, N) if (i, j) not in E]
    y = {p: m.binary_var() for p in nonE}
    m.add(m.sum(x) >= K)
    for (i, j) in nonE:
        m.add((1 - x[i]) + (1 - x[j]) + y[i, j] >= 1)
    for i in range(N):
        m.add(m.sum(y[p] for p in nonE if i in p) <= Mx)
    m.minimize(m.sum(c[p] * y[p] for p in nonE))
    return opt(m)


def jun26_brute(N, K, E, c, Mx):
    best = None
    for sel in itertools.product([0, 1], repeat=N):
        if sum(sel) < K:
            continue
        crew = [i for i in range(N) if sel[i]]
        need = [(i, j) for i in crew for j in crew if i < j and (i, j) not in E]
        if any(sum(1 for p in need if i in p) > Mx for i in range(N)):
            continue
        val = sum(c[p] for p in need)
        best = val if best is None else min(best, val)
    return best


for _ in range(TRIALS):
    N = 5
    E = {(i, j) for i in range(N) for j in range(i + 1, N) if random.random() < .5}
    c = {(i, j): random.randint(1, 9) for i in range(N) for j in range(i + 1, N)}
    K, Mx = random.choice([2, 3, 4]), random.choice([1, 2])
    assert jun26_model(N, K, E, c, Mx) == jun26_brute(N, K, E, c, Mx)
print("Jun26 Q2 official model == brute force on", TRIALS, "instances")


# ------------------------- Sheet Ex 4 (outbreaks) ---------------------------------------
def ex4_model(Mt, N, t, d):
    m = Model()
    x = {(i, j): m.binary_var() for i in range(Mt) for j in range(N)}
    y = {(i, a, b): m.binary_var() for i in range(Mt) for a in range(N) for b in range(a + 1, N)}
    z = m.continuous_var()
    for j in range(N):
        m.add(m.sum(x[i, j] for i in range(Mt)) == 1)
    for i in range(Mt):
        m.add(m.sum(x[i, j] for j in range(N)) <= 2)
        for a in range(N):
            for b in range(a + 1, N):
                m.add(y[i, a, b] >= x[i, a] + x[i, b] - 1)
        m.add(z >= m.sum(t[i][j] * x[i, j] for j in range(N)) + m.sum(d[a][b] * y[i, a, b] for a in range(N) for b in range(a + 1, N)))
    m.minimize(z)
    return opt(m)


def ex4_brute(Mt, N, t, d):
    best = None
    for a in itertools.product(range(Mt), repeat=N):
        if any(a.count(i) > 2 for i in range(Mt)):
            continue
        tot = []
        for i in range(Mt):
            js = [j for j in range(N) if a[j] == i]
            tot.append(sum(t[i][j] for j in js) + (d[js[0]][js[1]] if len(js) == 2 else 0))
        best = max(tot) if best is None else min(best, max(tot))
    return best


for _ in range(TRIALS):
    Mt, N = 3, 4
    t = [[random.randint(1, 9) for _ in range(N)] for _ in range(Mt)]
    d = [[0] * N for _ in range(N)]
    for a in range(N):
        for b in range(a + 1, N):
            d[a][b] = d[b][a] = random.randint(1, 5)
    assert ex4_model(Mt, N, t, d) == ex4_brute(Mt, N, t, d)
print("Sheet Ex4 model == brute force")


# ------------------------- Sheet Ex 6 (drug supply) --------------------------------------
def ex6_model(Ms, T, dem, c, l, h):
    m = Model()
    BIG = sum(dem) + max(l)
    x = {(i, t): m.continuous_var() for i in range(Ms) for t in range(T)}
    dl = {(i, t): m.binary_var() for i in range(Ms) for t in range(T)}
    st = [m.continuous_var(ub=h) for _ in range(T)]
    ws = [m.continuous_var() for _ in range(T)]
    for t in range(T):
        prev = st[t - 1] if t else 0
        m.add(prev + m.sum(x[i, t] for i in range(Ms)) == dem[t] + st[t] + ws[t])
        for i in range(Ms):
            m.add(x[i, t] >= l[i] * dl[i, t])
            m.add(x[i, t] <= BIG * dl[i, t])
    m.minimize(m.sum(c[i][t] * x[i, t] for i in range(Ms) for t in range(T)))
    return opt(m)


def ex6_brute(Ms, T, dem, c, l, h):
    best = None
    rng = range(0, sum(dem) + max(l) + 1)
    for xs in itertools.product(rng, repeat=Ms * T):
        ok, stock = True, 0
        for t in range(T):
            buy = [xs[i * T + t] for i in range(Ms)]
            if any(0 < b < l[i] for i, b in enumerate(buy)):
                ok = False; break
            avail = stock + sum(buy)
            if avail < dem[t]:
                ok = False; break
            stock = min(h, avail - dem[t])
        if ok:
            val = sum(c[i][t] * xs[i * T + t] for i in range(Ms) for t in range(T))
            best = val if best is None else min(best, val)
    return best


for _ in range(8):
    Ms, T = 2, 2
    dem = [random.randint(1, 4) for _ in range(T)]
    c = [[random.randint(1, 6) for _ in range(T)] for _ in range(Ms)]
    l = [random.randint(1, 4) for _ in range(Ms)]
    h = random.randint(0, 3)
    assert ex6_model(Ms, T, dem, c, l, h) == ex6_brute(Ms, T, dem, c, l, h)
print("Sheet Ex6 model == brute force (integer data, continuous model)")


# ------------------------- Sheet Ex 7 (nurse) --------------------------------------------
def ex7_model(P, q, lo, up):
    n = len(P)
    BIG = sum(P) + sum(q) + sum(up) + 1
    m = Model()
    a = [m.continuous_var() for _ in range(n)]      # start of examination
    b = [m.continuous_var() for _ in range(n)]      # start of check-up
    Cmax = m.continuous_var()
    tasks = [(a[i], P[i]) for i in range(n)] + [(b[i], q[i]) for i in range(n)]
    for i in range(n):
        m.add(b[i] >= a[i] + P[i] + lo[i])
        m.add(b[i] <= a[i] + P[i] + up[i])
        m.add(Cmax >= b[i] + q[i])
    for u in range(len(tasks)):
        for v in range(u + 1, len(tasks)):
            o = m.binary_var()                          # 1: task u before task v
            (su, du), (sv, dv) = tasks[u], tasks[v]
            m.add(su + du <= sv + BIG * (1 - o))
            m.add(sv + dv <= su + BIG * o)
    m.minimize(Cmax)
    return opt(m)


def ex7_brute(P, q, lo, up):
    n = len(P)
    Hz = sum(P) + sum(q) + sum(up)
    best = None
    for st in itertools.product(range(Hz + 1), repeat=n):
        for gap in itertools.product(*[range(lo[i], up[i] + 1) for i in range(n)]):
            iv = [(st[i], st[i] + P[i]) for i in range(n)] + [(st[i] + P[i] + gap[i], st[i] + P[i] + gap[i] + q[i]) for i in range(n)]
            if all(x2 <= y1 or y2 <= x1 for k, (x1, x2) in enumerate(iv) for (y1, y2) in iv[k + 1:]):
                val = max(e for _, e in iv)
                best = val if best is None or val < best else best
    return best


for _ in range(6):
    P = [random.randint(1, 3) for _ in range(2)]
    q = [random.randint(1, 2) for _ in range(2)]
    lo = [random.randint(0, 2) for _ in range(2)]
    up = [l_ + random.randint(0, 2) for l_ in lo]
    assert ex7_model(P, q, lo, up) == ex7_brute(P, q, lo, up), (P, q, lo, up)
print("Sheet Ex7 model == brute force (integer data)")
print("ALL EXAM/SHEET MODEL CHECKS PASSED")
