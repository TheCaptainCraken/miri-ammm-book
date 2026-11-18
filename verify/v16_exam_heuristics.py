"""Q3 of the past exams: the book's greedy algorithms and BRKGA decoders, run on random
instances.  Every solution they return is checked for feasibility and compared with the
brute-force optimum (the gap statistics quoted in the book come from this script).
Also recomputes the worked example of the official June 2026 solution under both readings."""
import itertools
import random
import statistics

random.seed(42)


def gaps(pairs):
    g = [(h - o) / o if o else 0 for h, o in pairs]
    return round(100 * statistics.mean(g), 1), sum(1 for x in g if x == 0)


# ============================ January 2026: neighbours ===================================
def jan26_greedy(n, M, T, ch=None):
    ch = ch or [1.0] * n
    reach = {i: {j for j in range(n) if M[i][j]} for i in range(n)}
    X, Y = [], set()
    while len(Y) < n // 2:
        cand = [i for i in range(n) if i not in X and reach[i] - Y]
        if not cand:
            return None
        best = min(cand, key=lambda i: (ch[i] * T[i] / len(reach[i] - Y), i))
        X.append(best)
        Y |= reach[best]
    for i in list(X):                      # clean-up: drop selections that became redundant
        rest = set().union(*[reach[j] for j in X if j != i]) if len(X) > 1 else set()
        if len(rest) >= n // 2:
            X.remove(i)
    return X


def jan26_opt(n, M, T):
    best = None
    for sel in itertools.product([0, 1], repeat=n):
        yes = {j for i in range(n) if sel[i] for j in range(n) if M[i][j]}
        if len(yes) >= n // 2:
            v = sum(T[i] for i in range(n) if sel[i])
            best = v if best is None else min(best, v)
    return best


res = []
for _ in range(300):
    n = random.choice([6, 8, 10])
    M = [[1 if i == j else int(random.random() < .25) for j in range(n)] for i in range(n)]
    T = [random.randint(1, 20) for _ in range(n)]
    X = jan26_greedy(n, M, T)
    assert len({j for i in X for j in range(n) if M[i][j]}) >= n // 2
    res.append((sum(T[i] for i in X), jan26_opt(n, M, T)))
JAN26 = gaps(res)
print("Jan26 greedy: mean gap %.1f%%, optimal in %d/300" % JAN26)

# worked example used in the book (n = 6): the greedy is myopic here
M6 = [[1, 1, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0], [1, 0, 1, 0, 0, 0], [1, 1, 0, 1, 1, 0], [0, 1, 0, 0, 1, 1], [0, 0, 0, 0, 1, 1]]
T6 = [3, 2, 4, 9, 8, 9]
X = jan26_greedy(6, M6, T6)
print("Jan26 example: selected", [i + 1 for i in X], "time", sum(T6[i] for i in X), "optimum", jan26_opt(6, M6, T6))
assert [i + 1 for i in X] == [1, 3] and sum(T6[i] for i in X) == 7 and jan26_opt(6, M6, T6) == 6
CH = [0.9, 0.3, 0.6, 0.5, 0.7, 0.4]
X2 = jan26_greedy(6, M6, T6, ch=CH)
print("   with chromosome", CH, [i + 1 for i in X2], "time", sum(T6[i] for i in X2))
assert [i + 1 for i in X2] == [2, 3] and sum(T6[i] for i in X2) == 6


# ============================ June 2026: ISS crew =========================================
def jun26_greedy(N, K, E, c, Mx, ch=None):
    ch = ch or [1.0] * N
    nonE = lambda i, j: (min(i, j), max(i, j)) not in E
    S, courses = [], [0] * N
    deg = [sum(1 for j in range(N) if j != i and nonE(i, j)) for i in range(N)]
    while len(S) < K:
        best = None
        for i in range(N):
            if i in S:
                continue
            new = [j for j in S if nonE(i, j)]
            if len(new) > Mx or any(courses[j] + 1 > Mx for j in new):
                continue                                  # infeasible candidate
            q = sum(c[min(i, j), max(i, j)] for j in new)       # training cost added
            key = ((1 + q) * ch[i], deg[i], i)                  # ties: fewer non-colleagues first
            if best is None or key < best[0]:
                best = (key, i, new)
        if best is None:
            return None
        _, i, new = best
        S.append(i)
        for j in new:
            courses[j] += 1
        courses[i] += len(new)
    return S


def jun26_cost(S, E, c):
    return sum(c[i, j] for i in S for j in S if i < j and (i, j) not in E)


def jun26_opt(N, K, E, c, Mx):
    best = None
    for r in range(K, N + 1):
        for S in itertools.combinations(range(N), r):
            need = [(i, j) for i in S for j in S if i < j and (i, j) not in E]
            if all(sum(1 for p in need if i in p) <= Mx for i in range(N)):
                v = sum(c[p] for p in need)
                best = v if best is None else min(best, v)
    return best


res, fails, infeas = [], 0, 0
for _ in range(300):
    N = random.choice([6, 7, 8])
    E = {(i, j) for i in range(N) for j in range(i + 1, N) if random.random() < .6}
    c = {(i, j): random.randint(1, 9) for i in range(N) for j in range(i + 1, N)}
    K, Mx = random.choice([3, 4]), random.choice([1, 2])
    o = jun26_opt(N, K, E, c, Mx)
    S = jun26_greedy(N, K, E, c, Mx)
    if o is None:
        infeas += 1
        assert S is None
        continue
    if S is None:
        fails += 1
        continue
    need = [(i, j) for i in S for j in S if i < j and (i, j) not in E]
    assert len(S) >= K and all(sum(1 for p in need if i in p) <= Mx for i in range(N))
    res.append((jun26_cost(S, E, c), o))
JUN26 = (sum(a == b for a, b in res), len(res), fails, round(statistics.mean(a - b for a, b in res), 2))
print("Jun26 greedy: optimal in %d/%d feasible instances, no crew found in %d, mean excess cost %.2f" % JUN26)
assert JUN26[:3] == (260, 294, 3)

# --- the official June 2026 worked example, under both readings of the greedy function ---
E4 = [[1, 1, 1, 0], [1, 1, 0, 0], [1, 0, 1, 1], [0, 0, 1, 1]]
C4 = [[0, 0, 0, 1], [0, 0, 2, 3], [0, 2, 0, 0], [1, 3, 0, 0]]
q_empty = [sum(1 - E4[i][j] for j in range(4) if j != i) for i in range(4)]
assert q_empty == [1, 2, 1, 2]                         # matches the solution's first line
reading_eq1 = [sum(C4[i][j] * (1 - E4[i][j]) for j in [0]) for i in range(4)]       # sum over S = {1}
reading_rowsum = [sum(C4[i][j] * (1 - E4[i][j]) for j in range(4) if j != i) for i in range(4)]
print("Jun26 official example after S={1}: eq.1 gives", reading_eq1[1:], " row sums give", reading_rowsum[1:])
assert reading_eq1[1:] == [0, 0, 1] and reading_rowsum[1:] == [5, 2, 4]
# chromosome 2 = (1.0, 0.2, 1.0, 1.0), first step: 0.2*2 = 0.4 -> member 2 first
assert [round(a * b, 2) for a, b in zip([1.0, 0.2, 1.0, 1.0], q_empty)] == [1.0, 0.4, 1.0, 2.0]


# ============================ June 2025: First Dates ======================================
def jun25_greedy(n, m, f, s, I, J, ch=None):
    ch = ch or {(i, j): 1.0 for i in range(n) for j in range(m)}
    freeM, freeW, S = set(range(n)), set(range(m)), []
    X = Y = 0
    while True:
        roles = ["F", "S"] if X == Y else (["S"] if X > Y else ["F"])
        cand = [(ch[i, j] * (f[i][j] if r == "F" else s[i][j]), i, j, r) for i in freeM for j in freeW for r in roles]
        if not S:                                            # first date must involve a past participant
            cand = [c for c in cand if c[1] in I or c[2] in J] or cand
        if not cand:
            break
        v, i, j, r = max(cand, key=lambda c: (c[0], -c[1], -c[2]))
        if X == Y and v <= 0 and S:
            break
        S.append((i, j, r)); freeM.discard(i); freeW.discard(j)
        X += r == "F"; Y += r == "S"
    while X != Y:                                            # repair: drop the last unbalanced date
        i, j, r = S.pop()
        X -= r == "F"; Y -= r == "S"
    if not any(i in I or j in J for i, j, _ in S):
        return None
    return S


def jun25_val(S, f, s):
    return sum(f[i][j] if r == "F" else s[i][j] for i, j, r in S)


def jun25_opt(n, m, f, s, I, J):
    best = None
    for match in itertools.product(range(-1, m), repeat=n):
        used = [j for j in match if j >= 0]
        if len(used) != len(set(used)):
            continue
        idx = [i for i in range(n) if match[i] >= 0]
        for first in itertools.product([0, 1], repeat=len(idx)):
            if 2 * sum(first) != len(idx) or not any(i in I or match[i] in J for i in idx):
                continue
            v = sum(f[i][match[i]] if fi else s[i][match[i]] for i, fi in zip(idx, first))
            best = v if best is None else max(best, v)
    return best


res = []
for _ in range(300):
    n, m = random.choice([(3, 3), (4, 3), (4, 4)])
    f = [[random.randint(1, 20) for _ in range(m)] for _ in range(n)]
    s = [[random.randint(1, 20) for _ in range(m)] for _ in range(n)]
    I, J = {random.randrange(n)}, {random.randrange(m)}
    S = jun25_greedy(n, m, f, s, I, J)
    o = jun25_opt(n, m, f, s, I, J)
    if S is None:
        continue
    assert sum(r == "F" for _, _, r in S) == sum(r == "S" for _, _, r in S)
    res.append((o, jun25_val(S, f, s)))                       # maximisation: gap = (opt-h)/h style
JUN25 = round(100 * statistics.mean((o - h) / o for o, h in res), 1), sum(1 for o, h in res if o == h)
print("Jun25 greedy: mean gap %.1f%%, optimal in %d/%d" % (JUN25[0], JUN25[1], len(res)))


# ============================ January 2025: classes ======================================
def jan25_greedy(n, mc, l, u, G, B, C, ch=None):
    """Bad students first, then good, then the rest; q = min compatibility of the class
    after the insertion (maximise).  Look-ahead keeps the partial solution completable."""
    ch = ch or [1.0] * n
    rest = [i for i in range(n) if i not in G and i not in B]
    order = sorted(B, key=lambda i: ch[i]) + sorted(G, key=lambda i: ch[i]) + sorted(rest, key=lambda i: ch[i])
    cls = [[] for _ in range(mc)]

    def completable(cl, placed):
        good_left = sum(1 for i in order[placed:] if i in G)
        left = n - placed
        deficit = [max(0, 2 * sum(k in B for k in c) - sum(k in G for k in c)) for c in cl]
        if sum(deficit) > good_left:
            return False                                   # not enough good students left
        if any(len(c) + dft > u for c, dft in zip(cl, deficit)):
            return False                                   # no room for the good ones it needs
        return sum(max(0, l - len(c)) for c in cl) <= left  # lower bound l still reachable

    for pos, i in enumerate(order):
        best = None
        for j in range(mc):
            if len(cls[j]) >= u:
                continue
            trial = [c + [i] if k == j else c for k, c in enumerate(cls)]
            if not completable(trial, pos + 1):
                continue
            q = min([C[a][b] for a in trial[j] for b in trial[j] if a < b], default=1.0)
            key = (q, -len(cls[j]), -j)
            if best is None or key > best[0]:
                best = (key, j)
        if best is None:
            return None
        cls[best[1]].append(i)
    return cls


def jan25_val(cls, C):
    return min([C[a][b] for c in cls for a in c for b in c if a < b], default=1.0)


def jan25_opt(n, mc, l, u, G, B, C):
    best = None
    for a in itertools.product(range(mc), repeat=n):
        cls = [[i for i in range(n) if a[i] == j] for j in range(mc)]
        if any(not l <= len(c) <= u for c in cls):
            continue
        if any(sum(i in G for i in c) < 2 * sum(i in B for i in c) for c in cls):
            continue
        v = jan25_val(cls, C)
        best = v if best is None else max(best, v)
    return best


res, nofeas = [], 0
for _ in range(200):
    n, mc = 8, 2
    l, u = 3, 5
    stu = list(range(n)); random.shuffle(stu)
    G, B = set(stu[:4]), set(stu[4:6])
    C = [[1.0] * n for _ in range(n)]
    for i in range(n):
        for k in range(i + 1, n):
            C[i][k] = C[k][i] = round(random.uniform(.1, 1), 2)
    o = jan25_opt(n, mc, l, u, G, B, C)
    cls = jan25_greedy(n, mc, l, u, G, B, C)
    if cls is None:
        nofeas += 1; continue
    assert all(l <= len(c) <= u for c in cls) and sorted(sum(cls, [])) == list(range(n))
    assert all(sum(i in G for i in c) >= 2 * sum(i in B for i in c) for c in cls)
    res.append((o, jan25_val(cls, C)))
JAN25 = (len(res), sum(1 for o, h in res if abs(o - h) < 1e-9), round(statistics.mean(o - h for o, h in res), 3))
print("Jan25 greedy: feasible %d/200, optimal in %d, mean loss in min-compatibility %.3f" % JAN25)
# official greedy's bad-student test |G(j)| < 2|B(j)| lets a bad student into an empty class:
assert not (0 < 2 * 0)                                         # 0 < 0 is false -> accepted -> 0 good vs 1 bad


# ============================ June 2024: rental (2-D packing) ==============================
def jun24_greedy(n, w, h, H, W, p, ch=None):
    ch = ch or [1.0] * n
    order = sorted(range(n), key=lambda k: -h[k] * w[k] * ch[k])
    placed, points = {}, [(0, 0)]

    def overlap(k, t, a):
        return any(not (t + h[k] <= t2 or t2 + h[q] <= t or a + w[k] <= a2 or a2 + w[q] <= a) for q, (t2, a2) in placed.items())

    def plan(maxT, maxW):
        ok = [(p[i][j], i, j) for i in range(len(H)) for j in range(len(W)) if H[i] >= maxT and W[j] >= maxW]
        return min(ok) if ok else None

    for k in order:
        best = None
        for (t, a) in points:
            if overlap(k, t, a):
                continue
            maxT = max([t + h[k]] + [t2 + h[q] for q, (t2, a2) in placed.items()])
            maxW = max([a + w[k]] + [a2 + w[q] for q, (t2, a2) in placed.items()])
            pl = plan(maxT, maxW)
            if pl is None:
                continue
            key = (pl[0], maxT * maxW, t, a)
            if best is None or key < best[0]:
                best = (key, (t, a))
        if best is None:
            return None
        t, a = best[1]
        placed[k] = (t, a)
        points.remove((t, a))
        points += [(t + h[k], a), (t, a + w[k])]
    maxT = max(t + h[k] for k, (t, a) in placed.items())
    maxW = max(a + w[k] for k, (t, a) in placed.items())
    return plan(maxT, maxW)[0], placed


def jun24_opt(n, w, h, H, W, p):
    def fits(Hc, Wc):
        for ts in itertools.product(*[range(Hc - h[k] + 1) for k in range(n)]):
            for ls in itertools.product(*[range(Wc - w[k] + 1) for k in range(n)]):
                if all(ts[k] + h[k] <= ts[q] or ts[q] + h[q] <= ts[k] or ls[k] + w[k] <= ls[q] or ls[q] + w[q] <= ls[k]
                       for k in range(n) for q in range(k + 1, n)):
                    return True
        return False
    ok = [p[i][j] for i in range(len(H)) for j in range(len(W)) if fits(H[i], W[j])]
    return min(ok) if ok else None


res, miss = [], 0
for _ in range(120):
    n = 3
    w = [random.randint(1, 3) for _ in range(n)]
    h = [random.randint(1, 3) for _ in range(n)]
    H, W = sorted(random.sample(range(3, 8), 3)), sorted(random.sample(range(3, 8), 3))
    p = [[H[i] * W[j] + random.randint(0, 5) for j in range(3)] for i in range(3)]
    o = jun24_opt(n, w, h, H, W, p)
    g = jun24_greedy(n, w, h, H, W, p)
    if o is None:
        assert g is None; continue
    if g is None:
        miss += 1; continue
    cost, placed = g
    assert all(t + h[k] <= max(H) and a + w[k] <= max(W) for k, (t, a) in placed.items())
    res.append((cost, o))
JUN24 = gaps(res)
print("Jun24 greedy: mean gap %.1f%%, optimal in %d/%d, no plan found in %d feasible cases" % (JUN24[0], JUN24[1], len(res), miss))

open("out_v16.txt", "w").write(repr({"JAN26": JAN26, "JUN26": JUN26, "JUN25": JUN25, "JAN25": JAN25, "JUN24": JUN24}))
print("ALL EXAM-HEURISTIC CHECKS PASSED")
assert JAN26 == (4.5, 260) and JUN25 == (3.5, 188) and JAN25 == (200, 95, 0.051) and JUN24 == (2.4, 111)
print("statistics pinned")

# ---- June 2026 Q3(b) example with the book's decoder: two chromosomes, two crews -----
E4s = {(0, 1), (0, 2), (2, 3)}                       # pairs that collaborated (0-based, i<j)
C4s = {(0, 1): 0, (0, 2): 0, (0, 3): 1, (1, 2): 2, (1, 3): 3, (2, 3): 0}
crew1 = jun26_greedy(4, 2, E4s, C4s, 1, ch=[1.0, 1.0, 1.0, 1.0])
crew2 = jun26_greedy(4, 2, E4s, C4s, 1, ch=[1.0, 0.2, 1.0, 1.0])
assert crew1 == [0, 2] and crew2 == [1, 0]           # {1,3} and {2,1} in 1-based numbering
# official greedy under reading eq.1 (sum over j in S) gives the same crew for both chromosomes
def official(ch, rowsum):
    S, A = [], [0, 1, 2, 3]
    while len(S) < 2:
        def q(i):
            if not S:
                return ch[i] * sum(1 - E4[i][j] for j in A if j != i)
            js = [j for j in range(4) if j != i] if rowsum else S
            return ch[i] * sum(C4[i][j] * (1 - E4[i][j]) for j in js)
        i = min(A, key=lambda k: (q(k), k)); A.remove(i); S.append(i)
    return S
assert official([1, 1, 1, 1], False) == [0, 1] and official([1, .2, 1, 1], False) == [1, 0]
assert official([1, 1, 1, 1], True) == [0, 2] and official([1, .2, 1, 1], True) == [1, 0]
print("JUN26 EXAMPLE OK")
