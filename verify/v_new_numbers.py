"""Small numbers that appear in new examples and exercises written for the book."""
from docplex.mp.model import Model

# Ch1, Your turn 1.1 (bakery): optimum 800 € with 200 kg of cake and no bread
m = Model(); x1, x2 = m.continuous_var(), m.continuous_var()
m.maximize(1.5 * x1 + 4 * x2); m.add(0.6 * x1 + 0.3 * x2 <= 120); m.add(0.1 * x1 + 0.2 * x2 <= 40)
m.add(x2 >= 0.25 * (x1 + x2))
s = m.solve()
assert abs(s.objective_value - 800) < 1e-6 and abs(x2.solution_value - 200) < 1e-6
# Ch1 warm-up 3: polisher hours
assert 8 * 1 * 6 == 48
# Ch1 stop box: capacities can shrink by 1 - 0.7238 = 27.62 %
assert abs((1 - 1238.47 / 1711.13) * 100 - 27.62) < 0.005
print("NEW NUMBERS OK")
# Ch7 worked example: three months
m = Model(); mk = m.continuous_var_list(3, ub=60); st = m.continuous_var_list(3, ub=30)
d = [40, 70, 50]
for t in range(3):
    m.add((st[t - 1] if t else 0) + mk[t] == d[t] + st[t])
m.minimize(m.sum(10 * v for v in mk) + m.sum(2 * v for v in st))
s = m.solve()
assert abs(s.objective_value - 1620) < 1e-6 and [round(v.solution_value) for v in mk] == [50, 60, 50]
# Ch7 review 2: bases of x0+x1+x2=4, x0-x1=0
from simplex_tools import tableau
A = [[1, 1, 1], [1, -1, 0]]
assert [r[0] for r in tableau(A, [4, 0], [0, 0, 0], [0, 1])["rows"]] == [2, 2]
assert [r[0] for r in tableau(A, [4, 0], [0, 0, 0], [0, 2])["rows"]] == [0, 4]
assert [r[0] for r in tableau(A, [4, 0], [0, 0, 0], [1, 2])["rows"]] == [0, 4]
print("CH7 NEW OK")
# Ch10 p1: requests can grow by 1/0.7238 - 1 = 38.16 %
assert abs((1711.13 / 1238.47 - 1) * 100 - 38.16) < 0.01
# Ch11: greedy on Lab 2's five-task instance detects infeasibility at task t1
rt = {"t1": 261.27, "t2": 560.89, "t3": 310.51, "t4": 105.80, "t5": 344.7}
rc = {"c1": 505.67, "c2": 503.68, "c3": 701.78}
used = {c: 0.0 for c in rc}; trace = []
for t in sorted(rt, key=rt.get, reverse=True):
    cand = {c: round((used[c] + rt[t]) / rc[c], 4) for c in rc if used[c] + rt[t] <= rc[c]}
    trace.append((t, cand))
    if not cand:
        break
    c = min(cand, key=cand.get); used[c] += rt[t]
assert trace == [("t2", {"c3": 0.7992}), ("t5", {"c1": 0.6817, "c2": 0.6844}),
                 ("t3", {"c2": 0.6165}), ("t1", {})], trace
# Ch11 your turn (knapsack): greedy by value/weight gets 17, optimum 34
import itertools
v, w, cap = [10, 7, 25, 24], [2, 1, 6, 5], 7
order = sorted(range(4), key=lambda i: -v[i] / w[i]); load = val = 0
for i in order:
    if load + w[i] <= cap:
        load += w[i]; val += v[i]
assert order == [1, 0, 3, 2] and val == 17
assert max(sum(v[i] for i in S) for r in range(5) for S in itertools.combinations(range(4), r) if sum(w[i] for i in S) <= cap) == 34
# TSP search-space sizes on the slides: (n-1)!/2
from math import factorial
assert factorial(19) // 2 == 60822550204416000 and factorial(9) // 2 == 181440
print("CH10-11 NEW OK")
# Ch11 p2: cost-aware set covering greedy, ties -> most new elements, then lowest index
P = {1: {3, 4}, 2: {3}, 3: {2}, 4: {2, 3, 4}, 5: {3, 4, 5}, 6: {1, 4, 5}, 7: {2, 3}, 8: {4}}
cost = {1: 2, 2: 1, 3: 1, 4: 3, 5: 3, 6: 3, 7: 2, 8: 1}
R, S = set(), []
while R != {1, 2, 3, 4, 5}:
    q = {j: (cost[j] / len(P[j] - R), -len(P[j] - R), j) for j in P if P[j] - R}
    j = min(q, key=q.get); S.append(j); R |= P[j]
assert S == [4, 6] and sum(cost[j] for j in S) == 6
assert abs(12 / 16 - 0.75) < 1e-12
print("CH11 P2 OK")
# Ch12: 2-opt on the 40-tour from city 5 reaches 36
D = {(1, 2): 10, (1, 3): 12, (1, 4): 7, (1, 5): 9, (2, 3): 11, (2, 4): 17, (2, 5): 4, (3, 4): 5, (3, 5): 14, (4, 5): 9}
dd = lambda a, b: D[(min(a, b), max(a, b))]
L = lambda t: sum(dd(t[i], t[(i + 1) % len(t)]) for i in range(len(t)))
assert L([5, 2, 1, 4, 3]) == 40 and L([5, 2, 3, 4, 1]) == 36
nb = sorted(L(t[:i + 1] + t[i + 1:j + 1][::-1] + t[j + 1:]) for t in [[5, 2, 1, 4, 3]] for i in range(4) for j in range(i + 2, 5) if not (i == 0 and j == 4))
assert nb == [36, 40, 51, 54, 55]
# Ch12: reassignment local search on tasks from (t1->c1, t2->c3, t3->c2, t4->c3)
rt = [261.27, 560.89, 310.51, 105.80]; rc = [505.67, 503.68, 701.78]
def loads(a):
    u = [0.0] * 3
    for t, c in enumerate(a): u[c] += rt[t]
    return [round(u[c] / rc[c], 4) for c in range(3)], all(u[c] <= rc[c] for c in range(3))
a = [0, 2, 1, 2]
assert loads(a) == ([0.5167, 0.6165, 0.95], True)
moves = {}
for t in range(4):
    for c in range(3):
        if c != a[t]:
            b = a[:]; b[t] = c; l, ok = loads(b)
            if ok: moves[(t + 1, c + 1)] = max(l)
assert moves == {(4, 1): 0.7992, (4, 2): 0.8265}
print("CH12 NEW OK")
# Ch12 w1: 2-opt neighbours n(n-3)/2 ; review r2
assert 5 * (5 - 3) // 2 == 5
T = tableau([[1, 1, 0, 0], [0, 1, -1, 1]], [2, 1], [0, 1, 0, 1], [0, 3])
assert [r[0] for r in T["rows"]] == [2, 1] and T["z0"] == 1 and T["d"] == {1: 0, 2: 1}
# Ch12 p2: no improving swap from the greedy solution (max load stays 0.7992)
a = [1, 2, 0, 1]
base = max(loads(a)[0]); assert base == 0.7992
best = min(max(loads(b)[0]) for i in range(4) for j in range(i + 1, 4) if a[i] != a[j]
           for b in [[a[j] if k == i else a[i] if k == j else a[k] for k in range(4)]] if loads(b)[1])
assert best >= base
print("CH12 MORE OK")
# Ch13: GRASP thresholds for task t4 (q values 0.8233, 0.7288, 0.95)
qs = {"c1": (310.51 + 105.8) / 505.67, "c2": (261.27 + 105.8) / 503.68, "c3": (560.89 + 105.8) / 701.78}
lo, hi = min(qs.values()), max(qs.values())
thr07 = lo + 0.7 * (hi - lo)
assert abs(thr07 - 0.8836) < 5e-4 and sorted(c for c, v in qs.items() if v <= thr07) == ["c1", "c2"]
thr03 = lo + 0.3 * (hi - lo)
assert sorted(c for c, v in qs.items() if v <= thr03) == ["c2"]
# step #2 (t3): RCL with alpha 0.3 is {c1} only
q2 = {"c1": 310.51 / 505.67, "c2": 310.51 / 503.68}
t2 = min(q2.values()) + 0.3 * (max(q2.values()) - min(q2.values()))
assert [c for c, v in q2.items() if v <= t2] == ["c1"]
# RCL figure: q = 9,10,11,11,13,18 with alpha 0.3 -> threshold 11.7
assert abs(9 + 0.3 * 9 - 11.7) < 1e-12
print("CH13 NEW OK")
# Ch13 p1/p2
q2 = {"c1": 310.51 / 505.67, "c2": 310.51 / 503.68}
t07 = min(q2.values()) + 0.7 * (max(q2.values()) - min(q2.values()))
assert [c for c, v in q2.items() if v <= t07] == ["c1"]
P = {1: {3, 4}, 2: {3}, 3: {2}, 4: {2, 3, 4}, 5: {3, 4, 5}, 6: {1, 4, 5}, 7: {2, 3}, 8: {4}}
newq = {j: len(P[j] - {3, 4}) for j in P}
useful = {j: v for j, v in newq.items() if v > 0}
assert useful == {3: 1, 4: 1, 5: 1, 6: 2, 7: 1}
assert [j for j, v in useful.items() if v >= 2 - 0.5 * (2 - 1)] == [6]
print("CH13 MORE OK")
# Ch14: elite-set update example
ES = {"A": ({1, 2, 3}, 10), "B": ({1, 4, 5}, 12), "C": ({2, 4, 6}, 15)}
dist = lambda X, Y: len(X ^ Y)
dES = min(dist(ES[a][0], ES[b][0]) for a in ES for b in ES if a < b)
assert dES == 4
S1, f1 = {1, 2, 6}, 11
assert min(dist(S1, v[0]) for v in ES.values()) == 2          # too close -> rejected (11 > best 10)
S2, f2 = {3, 5, 6}, 14
assert [dist(S2, v[0]) for v in ES.values()] == [4, 4, 4]       # far enough, 14 < 15 -> enters
leave = min((k for k, v in ES.items() if v[1] >= f2), key=lambda k: dist(S2, ES[k][0]))
assert leave == "C"
# PR example: init and guiding differ in 4 users -> symmetric difference of (user, AP) pairs has 8 elements
init = [3, 1, 3, 3, 3, 1, 1, 5, 1, 5]; guide = [3, 1, 3, 3, 1, 3, 3, 1, 1, 5]
A_ = {(u + 1, a) for u, a in enumerate(init)}; B_ = {(u + 1, a) for u, a in enumerate(guide)}
assert len(A_ ^ B_) == 8 and sum(x != y for x, y in zip(init, guide)) == 4
print("CH14 NEW OK")
# Ch14 w1 and r1
A_ = {(1, 1), (2, 3), (3, 2), (4, 1)}; B_ = {(1, 2), (2, 3), (3, 1), (4, 1)}
assert len(A_ ^ B_) == 4
q = [5, 9, 9, 1]; thr = max(q) - 0.5 * (max(q) - min(q))
assert thr == 5 and [i + 1 for i, v in enumerate(q) if v >= thr] == [1, 2, 3]
print("CH14 MORE OK")
