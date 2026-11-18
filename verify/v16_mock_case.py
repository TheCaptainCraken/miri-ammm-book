"""Chapter 16: the case study (VM placement) and the mock exam (exam timetabling).
Models checked against brute force; heuristics checked for feasibility; trace numbers pinned."""
import itertools
import random
from fractions import Fraction as F
from docplex.mp.model import Model
from simplex_tools import tableau, ratio_test

# ================================ case study: VM placement ===============================
cap = {1: 10, 2: 8, 3: 7}
price = {1: 3, 2: 5, 3: 2}
w = {1: 3, 2: 2, 3: 4, 4: 2, 5: 2}
allowed = {1: [1, 3], 2: [2, 3], 3: [1, 2, 3], 4: [1, 2, 3], 5: [1, 2, 3]}


def cost(a):
    used = {d: 0 for d in cap}
    for v, d in a.items():
        if d not in allowed[v]:
            return None
        used[d] += w[v]
    if any(used[d] > cap[d] for d in cap):
        return None
    return sum(price[d] * w[v] for v, d in a.items())


best = min((cost(dict(zip(w, c))), c) for c in itertools.product(cap, repeat=5) if cost(dict(zip(w, c))) is not None)
assert best == (32, (3, 3, 1, 1, 3))


def greedy(order):
    used = {d: 0 for d in cap}; a = {}; trace = []
    for v in order:
        cand = {d: price[d] * w[v] for d in allowed[v] if used[d] + w[v] <= cap[d]}
        trace.append((v, cand))
        if not cand:
            return None, trace
        d = min(cand, key=lambda d: (cand[d], d)); a[v] = d; used[d] += w[v]
    return a, trace


g, tr = greedy(sorted(w, key=lambda v: (-w[v], v)))
assert [v for v, _ in tr] == [3, 1, 2, 4, 5]
assert tr == [(3, {1: 12, 2: 20, 3: 8}), (1, {1: 9, 3: 6}), (2, {2: 10}), (4, {1: 6, 2: 10}), (5, {1: 6, 2: 10})]
assert g == {3: 3, 1: 3, 2: 2, 4: 1, 5: 1} and cost(g) == 36
# no improving single move or swap: the greedy result is a local optimum of both neighbourhoods
for v in g:
    for d in allowed[v]:
        if d != g[v]:
            b = dict(g); b[v] = d
            assert cost(b) is None or cost(b) >= 36
for v1, v2 in itertools.combinations(g, 2):
    if g[v1] != g[v2]:
        b = dict(g); b[v1], b[v2] = g[v2], g[v1]
        assert cost(b) is None or cost(b) >= 36
# the decoder with keys (0.2, 0.3, 0.9, 0.8, 0.4) processes VMs by increasing key: 1, 2, 5, 4, 3
keys = {1: 0.2, 2: 0.3, 3: 0.9, 4: 0.8, 5: 0.4}
a2, tr2 = greedy(sorted(w, key=lambda v: keys[v]))
assert [v for v, _ in tr2] == [1, 2, 5, 4, 3] and cost(a2) == 32 and a2 == {1: 3, 2: 3, 5: 3, 4: 1, 3: 1}
# ILP of the case study gives 32 as well
m = Model()
x = {(v, d): m.binary_var() for v in w for d in allowed[v]}
for v in w:
    m.add(m.sum(x[v, d] for d in allowed[v]) == 1)
for d in cap:
    m.add(m.sum(w[v] * x[v, d] for v in w if d in allowed[v]) <= cap[d])
m.minimize(m.sum(price[d] * w[v] * x[v, d] for (v, d) in x))
assert round(m.solve().objective_value) == 32
print("case study: greedy 36 (local optimum for move and swap), decoder 32 = optimum")

# ================================ mock exam Q1 ==========================================
T = tableau([[1, 0, 1, 1], [0, -1, 0, 1]], [2, -2], [-2, 2, 2, 1], [2, 1])
assert T["rows"] == [(2, {0: -1, 3: -1}), (2, {0: 0, 3: 1})]
assert T["z0"] == 8 and T["d"] == {0: -4, 3: 1} and ratio_test(T, 0) == (F(2), [0])
T = tableau([[1, 0, 1, 1], [0, -1, 0, 1]], [2, -2], [-2, 2, 2, 1], [0, 1])
assert T["z0"] == 0 and all(v >= 0 for v in T["d"].values())   # one more pivot: optimal, value 0

# ================================ mock exam Q2 and Q3: exam timetabling =================


def tt_model(n, mslots, A, s, S):
    m = Model()
    x = {(e, t): m.binary_var() for e in range(n) for t in range(1, mslots + 1)}
    z = m.integer_var(lb=0, ub=mslots)
    for e in range(n):
        m.add(m.sum(x[e, t] for t in range(1, mslots + 1)) == 1)
        for t in range(1, mslots + 1):
            m.add(z >= t * x[e, t])
    for t in range(1, mslots + 1):
        m.add(m.sum(s[e] * x[e, t] for e in range(n)) <= S)
    for e in range(n):
        for f in range(e + 1, n):
            if A[e][f]:
                for t in range(1, mslots + 1):
                    m.add(x[e, t] + x[f, t] <= 1)
                    if t < mslots:
                        m.add(x[e, t] + x[f, t + 1] <= 1)
                        m.add(x[f, t] + x[e, t + 1] <= 1)
    m.minimize(z)
    sol = m.solve()
    return None if sol is None else round(sol.objective_value)


def tt_feasible(n, A, s, S, slot):
    for e in range(n):
        for f in range(e + 1, n):
            if A[e][f] and abs(slot[e] - slot[f]) <= 1:
                return False
    return all(sum(s[e] for e in range(n) if slot[e] == t) <= S for t in set(slot))


def tt_brute(n, mslots, A, s, S):
    best = None
    for slot in itertools.product(range(1, mslots + 1), repeat=n):
        if tt_feasible(n, A, s, S, slot):
            v = max(slot)
            best = v if best is None else min(best, v)
    return best


def tt_greedy(n, mslots, A, s, S, ch=None):
    """Most constrained exam first (saturation, then conflicts, then students), earliest feasible slot."""
    ch = ch or [0.0] * n
    slot = {}
    deg = [sum(A[e]) for e in range(n)]
    while len(slot) < n:
        def forbidden(e):
            return {t2 for f in slot if A[e][f] for t2 in (slot[f] - 1, slot[f], slot[f] + 1)}
        def ok(e, t):
            return t not in forbidden(e) and sum(s[f] for f in slot if slot[f] == t) + s[e] <= S
        cand = [e for e in range(n) if e not in slot]
        e = max(cand, key=lambda e: (len({t for t in forbidden(e) if 1 <= t <= mslots}) + ch[e], deg[e], s[e], -e))
        ts = [t for t in range(1, mslots + 1) if ok(e, t)]
        if not ts:
            return None
        slot[e] = ts[0]
    return [slot[e] for e in range(n)]


random.seed(16)
agree, gaps, fails = 0, [], 0
for _ in range(60):
    n, mslots = 5, 6
    A = [[0] * n for _ in range(n)]
    for e in range(n):
        for f in range(e + 1, n):
            A[e][f] = A[f][e] = int(random.random() < 0.35)
    s = [random.randint(10, 60) for _ in range(n)]
    S = 100
    br = tt_brute(n, mslots, A, s, S)
    mo = tt_model(n, mslots, A, s, S)
    assert br == mo
    agree += 1
    g = tt_greedy(n, mslots, A, s, S)
    if br is None:
        continue
    if g is None:
        fails += 1; continue
    assert tt_feasible(n, A, s, S, g)
    gaps.append(max(g) - br)
print("mock Q2 model == brute force on", agree, "instances; greedy: optimal in", sum(1 for x in gaps if x == 0), "of", len(gaps), ", failed", fails)
MOCK_STATS = (sum(1 for x in gaps if x == 0), len(gaps), fails)

# worked mock instance used in the solution (6 exams)
A6 = [[0, 1, 1, 0, 0, 0], [1, 0, 1, 0, 0, 0], [1, 1, 0, 1, 0, 0], [0, 0, 1, 0, 1, 0], [0, 0, 0, 1, 0, 1], [0, 0, 0, 0, 1, 0]]
s6 = [40, 30, 50, 20, 60, 30]
g6 = tt_greedy(6, 8, A6, s6, 100)
b6 = tt_brute(6, 8, A6, s6, 100)
print("mock example: greedy slots", g6, "last", max(g6), " optimum", b6)
assert g6 == [3, 5, 1, 3, 5, 1] and max(g6) == 5 and b6 == 5
assert MOCK_STATS == (49, 56, 0)
print("ALL CHAPTER 16 CHECKS PASSED", MOCK_STATS)
# ---- interleaved problem mix-1: the slides' second B&B LP in canonical form -----------
T = tableau([[1, 2, 1, 0], [2, 1, 0, 1]], [5, 5], [-2, -3, 0, 0], [0, 1])
assert T["rows"] == [(F(5, 3), {2: F(1, 3), 3: F(-2, 3)}), (F(5, 3), {2: F(-2, 3), 3: F(1, 3)})]
assert T["z0"] == F(-25, 3) and T["d"] == {2: F(4, 3), 3: F(1, 3)}
print("MIX-1 OK")
# case-b move costs and case-c: after VM 3 goes to DC 1 the greedy completes to 32
gcase, _ = greedy(sorted(w, key=lambda v: (-w[v], v)))
moves = {}
for v in gcase:
    for d in allowed[v]:
        if d != gcase[v]:
            b = dict(gcase); b[v] = d; moves[(v, d)] = cost(b)
assert moves == {(1, 1): 39, (2, 3): None, (3, 1): 40, (3, 2): 48, (4, 2): 40, (4, 3): None, (5, 2): 40, (5, 3): None}
used = {1: 4, 2: 0, 3: 0}; a3 = {3: 1}
for v in [1, 2, 4, 5]:
    cand = {d: price[d] * w[v] for d in allowed[v] if used[d] + w[v] <= cap[d]}
    d = min(cand, key=lambda d: (cand[d], d)); a3[v] = d; used[d] += w[v]
assert cost(a3) == 32
assert 8 + (1 / 3) * 12 == 12
print("CASE B/C OK")
