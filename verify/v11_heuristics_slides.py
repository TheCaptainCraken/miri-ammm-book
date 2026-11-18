"""Chapters 10-15: every number used from the heuristics slides, recomputed.

Tasks-to-computers greedy & GRASP traces, set covering (greedy, GRASP, local search),
network planning (greedy, local search, path relinking), TSP nearest neighbour,
BRKGA crossover and weighted-distance decoder."""
import itertools
import math
import random

ok = lambda a, b, t=5e-5: abs(a - b) <= t

# ----------------------------------------------------------------------------- tasks
rt = {"t1": 261.27, "t2": 560.89, "t3": 310.51, "t4": 105.80}
rc = {"c1": 505.67, "c2": 503.68, "c3": 701.78}


def greedy_tasks(alpha=None, pick=None, log=None):
    used = {c: 0.0 for c in rc}
    S = []
    for t in sorted(rt, key=rt.get, reverse=True):
        cand = {c: (used[c] + rt[t]) / rc[c] for c in rc if used[c] + rt[t] <= rc[c]}
        if not cand:
            return None
        qmin, qmax = min(cand.values()), max(cand.values())
        if alpha is None:
            c = min(cand, key=cand.get)
            rcl = [c]
        else:
            thr = qmin + alpha * (qmax - qmin)
            rcl = [c for c in cand if cand[c] <= thr + 1e-12]
            c = pick(t, rcl) if pick else random.choice(rcl)
        if log is not None:
            log.append((t, {k: round(v, 4) for k, v in cand.items()}, rcl))
        used[c] += rt[t]
        S.append((t, c))
    return S, max(used[c] / rc[c] for c in rc), used


log = []
S, f, used = greedy_tasks(log=log)
assert [s for s in S] == [("t2", "c3"), ("t3", "c1"), ("t1", "c2"), ("t4", "c2")]
assert ok(f, 0.7992)
assert log[1][1] == {"c1": 0.6141, "c2": 0.6165} and log[2][1] == {"c2": 0.5187}
assert log[3][1] == {"c1": 0.8233, "c2": 0.7288, "c3": 0.95}
assert ok(rc["c1"] - 310.51, 195.16) and ok(rc["c2"] - 261.27, 242.41) and ok(rc["c3"] - 560.89, 140.89)
assert ok(rc["c2"] - 261.27 - 105.8, 136.61)
print("tasks greedy: max load", round(f, 4), "(equals the ILP optimum 0.7992 of Lab 2)")

# GRASP alpha = 0.3 at the last step (task t4): the slide's threshold is wrong
qmin, qmax = (rt["t4"] + 261.27) / rc["c2"], (rt["t4"] + 560.89) / rc["c3"]
thr = qmin + 0.3 * (qmax - qmin)
assert ok(thr, 0.795, 5e-4) and not ok(thr, 0.8651, 1e-3)   # book prints 0.795
assert ok((310.51 + 105.8) / 505.67, 0.8233) and (310.51 + 105.8) / 505.67 > thr  # c1 NOT in the RCL
# slide value 0.8651 corresponds to alpha =
alpha_slide = (0.8651 - qmin) / (qmax - qmin)
print("GRASP t4: correct threshold %.4f (RCL={c2}); slide's 0.8651 would need alpha=%.2f" % (thr, alpha_slide))
assert ok(0.6141 + 0.3 * (0.6165 - 0.6141), 0.6148, 1e-4)
# slide's (wrong) final solution with t4 on c1: max load
assert ok((310.51 + 105.8) / 505.67, 0.8233)

# ----------------------------------------------------------------------------- set covering
P = {1: {3, 4}, 2: {3}, 3: {2}, 4: {2, 3, 4}, 5: {3, 4, 5}, 6: {1, 4, 5}, 7: {2, 3}, 8: {4}}
cost = {1: 2, 2: 1, 3: 1, 4: 3, 5: 3, 6: 3, 7: 2, 8: 1}
M = {1, 2, 3, 4, 5}
covers = [S for r in range(1, 9) for S in itertools.combinations(P, r) if set().union(*[P[j] for j in S]) == M]
best = min(sum(cost[j] for j in S) for S in covers)
assert best == 5
assert sorted(tuple(S) for S in covers if sum(cost[j] for j in S) == 5) == [(2, 3, 6), (6, 7)]
assert sum(cost[j] for j in (1, 3, 6)) == 6 and sum(cost[j] for j in (4, 6)) == 6


def greedy_sc(score):
    R, S = set(), []
    trace = []
    while R != M:
        q = {j: score(j, R) for j in P if j not in S and P[j] - R}
        j = (max if score is new else min)(q, key=lambda k: (q[k], -k) if score is new else (q[k], k))
        trace.append(q)
        S.append(j); R |= P[j]
    return S, sum(cost[j] for j in S), trace


new = lambda j, R: len(P[j] - R)
ratio = lambda j, R: cost[j] / len(P[j] - R)
S1, c1, tr1 = greedy_sc(new)
assert S1 == [4, 6] and c1 == 6
assert {j: len(P[j]) for j in P} == {1: 2, 2: 1, 3: 1, 4: 3, 5: 3, 6: 3, 7: 2, 8: 1}
S2, c2, tr2 = greedy_sc(ratio)
print("set covering: cardinality greedy", S1, c1, "| cost-per-new-element greedy", S2, c2, tr2[0])
assert c2 == 6 and S2 == [1, 3, 6] and set(tr2[0].values()) == {1.0}   # all ratios tie at 1 (cost = cardinality)

# GRASP (max version, alpha=0.5) as on the slides: random picks p1, p6, p7
R = set()
for pick, expect_rcl in [(1, [1, 4, 5, 6, 7]), (6, [3, 4, 5, 6, 7]), (7, [3, 4, 7])]:
    q = {j: len(P[j] - R) for j in P}
    cand = {j: v for j, v in q.items() if j not in [1, 6, 7][:[1, 6, 7].index(pick)]}
    qmax, qmin = max(cand.values()), min(cand.values())
    rcl = sorted(j for j, v in cand.items() if v >= qmax - 0.5 * (qmax - qmin))
    assert rcl == expect_rcl, (pick, rcl)
    R |= P[pick]
assert R == M and sum(cost[j] for j in (1, 6, 7)) == 7
# local search: drop redundant sets
times = {e: [j for j in (1, 6, 7) if e in P[j]] for e in M}
assert times == {1: [6], 2: [7], 3: [1, 7], 4: [1, 6], 5: [6]}
print("set covering GRASP+LS: 7 -> 5 by removing p1")
# greedy solution {p4,p6}: exchange p4 for p7 gives the optimum
assert P[7] | P[6] == M

# ----------------------------------------------------------------------------- network planning
U = {1: (1, 1), 2: (2, 3), 3: (0, 1), 4: (4, 1), 5: (1, 2), 6: (2, 2), 7: (0, 1), 8: (1, 1), 9: (3, 4), 10: (2, 4)}
A = {1: (2, 3), 2: (1, 2), 3: (1, 1), 4: (0, 2), 5: (1, 3)}
cr = {1: 2, 2: 3, 3: 4, 4: 1, 5: 2, 6: 2, 7: 1, 8: 2, 9: 3, 10: 4}
MODELS = [("R1", 100, 6, 2), ("R2", 140, 8, 3), ("R3", 180, 10, 4)]
dist = {(u, a): math.dist(U[u], A[a]) for u in U for a in A}
assert round(dist[1, 1], 1) == 2.2 and round(dist[4, 4], 1) == 4.1 and round(dist[9, 3], 1) == 3.6


def cheapest(users, a):
    if not users:
        return None
    need_d = max(dist[u, a] for u in users)
    need_k = sum(cr[u] for u in users)
    for m in MODELS:
        if m[3] + 1e-9 >= need_d and m[2] >= need_k:
            return m
    return "inf"


def plan_cost(assign):
    tot = 0
    for a in A:
        m = cheapest([u for u in assign if assign[u] == a], a)
        if m == "inf":
            return math.inf
        tot += m[1] if m else 0
    return tot


def greedy_np():
    assign, C = {}, set(U)
    while C:
        best = None
        for u in sorted(C):
            for a in A:
                cur = cheapest([v for v in assign if assign[v] == a], a)
                new_m = cheapest([v for v in assign if assign[v] == a] + [u], a)
                if new_m == "inf":
                    continue
                q = new_m[1] - (cur[1] if cur else 0)
                key = (q, dist[u, a], u)
                if best is None or key < best[0]:
                    best = (key, u, a)
        _, u, a = best
        assign[u] = a
        C.remove(u)
    return assign


g = greedy_np()
order_check = g
assert plan_cost(g) == 460
assert {a: sorted(u for u in g if g[u] == a) for a in A} == {1: [2, 9, 10], 2: [], 3: [1, 4, 5, 6, 7, 8], 4: [3], 5: []}


def local_search(assign):
    improved = True
    while improved:
        improved = False
        for u in sorted(assign):
            for a in A:
                if a == assign[u]:
                    continue
                trial = dict(assign); trial[u] = a
                if plan_cost(trial) < plan_cost(assign):
                    assign, improved = trial, True
    return assign


ls = local_search(dict(g))
assert plan_cost(ls) == 420
print("network planning: greedy 460 -> local search", plan_cost(ls), {a: sorted(u for u in ls if ls[u] == a) for a in A})
# path relinking example of the slides (assignment vectors u1..u10)
init = [3, 1, 3, 3, 3, 1, 1, 5, 1, 5]
guide = [3, 1, 3, 3, 1, 3, 3, 1, 1, 5]
mids = [[3, 1, 3, 3, 3, 1, 3, 5, 1, 5], [3, 1, 3, 3, 1, 1, 3, 5, 1, 5], [3, 1, 3, 3, 1, 3, 3, 5, 1, 5]]
vec = lambda v: {u: v[u - 1] for u in U}
costs = [plan_cost(vec(v)) for v in [init] + mids + [guide]]
print("path relinking costs:", costs)
assert costs == [460, 420, 420, 420, 460]
sd = lambda a, b: sum(x != y for x, y in zip(a, b))
assert sd(init, guide) == 4

# ----------------------------------------------------------------------------- TSP
D = {(1, 2): 10, (1, 3): 12, (1, 4): 7, (1, 5): 9, (2, 3): 11, (2, 4): 17, (2, 5): 4, (3, 4): 5, (3, 5): 14, (4, 5): 9}
d = lambda a, b: D[(min(a, b), max(a, b))]


def nn(start, w=d):
    tour = [start]
    while len(tour) < 5:
        tour.append(min((v for v in range(1, 6) if v not in tour), key=lambda v: (w(tour[-1], v), v)))
    return tour, sum(d(tour[i], tour[(i + 1) % 5]) for i in range(5))


tours = {s: nn(s) for s in range(1, 6)}
print("NN tours:", tours)
opt_len = min(sum(d(t[i], t[(i + 1) % 5]) for i in range(5)) for t in ([1] + list(p) for p in itertools.permutations([2, 3, 4, 5])))
print("optimal tour length:", opt_len)
assert tours[1] == ([1, 4, 3, 2, 5], 36) and tours[5] == ([5, 2, 1, 4, 3], 40) and opt_len == 36
assert math.factorial(4) // 2 == 12 and math.factorial(9) // 2 == 181440

# BRKGA weighted distances (chromosome 2 on the slides)
ch2 = {(1, 2): .3, (1, 3): .7, (1, 4): .6, (1, 5): .4, (2, 3): .4, (2, 4): .7, (2, 5): .3, (3, 4): .9, (3, 5): .3, (4, 5): .65}
wd = {e: round(D[e] * ch2[e], 2) for e in D}
assert wd == {(1, 2): 3.0, (1, 3): 8.4, (1, 4): 4.2, (1, 5): 3.6, (2, 3): 4.4, (2, 4): 11.9, (2, 5): 1.2, (3, 4): 4.5, (3, 5): 4.2, (4, 5): 5.85}
t2, _ = nn(1, lambda a, b: wd[(min(a, b), max(a, b))])
real = sum(d(t2[i], t2[(i + 1) % 5]) for i in range(5))
print("decoder with chromosome 2 (NN on weighted distances from 1):", t2, "real length", real)
assert t2 == [1, 2, 5, 3, 4] and real == 40   # 10+4+14+5+7

# BRKGA parametrised uniform crossover (slide example)
a_ = (0.25, 0.19, 0.67, 0.05, 0.89)
b_ = (0.63, 0.90, 0.76, 0.93, 0.08)
child = (0.25, 0.90, 0.76, 0.05, 0.89)
assert [0 if c == x else 1 for c, x, y in zip(child, a_, b_)] == [0, 1, 1, 0, 0]

# GA path-representation strings (slides)
p1, p2 = "124385967", "452187693"
c1 = p1[:3] + p2[3:7] + p1[7:]
c2_ = p2[:3] + p1[3:7] + p2[7:]
assert (c1, c2_) == ("124187667", "452385993")
assert p1[:3] + p1[3:7][::-1] + p1[7:] == "124958367"
print("ALL HEURISTICS-SLIDES CHECKS PASSED")
# Ch14 p1: the four possible first PR steps from the initiating plan
firsts = {}
for u, a in [(5, 1), (6, 3), (7, 3), (8, 1)]:
    v = init[:]; v[u - 1] = a; firsts[u] = plan_cost(vec(v))
assert firsts == {5: math.inf, 6: math.inf, 7: 420, 8: math.inf}
assert sum(cr[u] for u in (2, 5, 6, 7, 9)) == 11 and sum(cr[u] for u in (1, 3, 4, 5, 6)) == 11
print("PR FIRST STEPS OK")
