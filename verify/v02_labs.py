"""Chapter 2 (OPL & CPLEX): numbers of Lab sessions 1-3, solved with CPLEX (docplex).
The OPL models printed in the book are line-by-line translations of these models."""
from docplex.mp.model import Model

rt4 = [261.27, 560.89, 310.51, 105.80]
rt5 = rt4 + [344.7]
rc = [505.67, 503.68, 701.78]


def P(rt, binary, K=None, reject_obj=False):
    T, C = range(len(rt)), range(len(rc))
    m = Model()
    x = {(t, c): (m.binary_var() if binary else m.continuous_var()) for t in T for c in C}
    z = m.continuous_var()
    rej = {t: m.binary_var() for t in T} if (K is not None or reject_obj) else None
    for t in T:
        m.add(m.sum(x[t, c] for c in C) == (1 - rej[t] if rej else 1))
    for c in C:
        load = m.sum(rt[t] * x[t, c] for t in T)
        m.add(load <= rc[c])
        m.add(z >= load / rc[c])
    if K is not None:
        m.add(m.sum(rej.values()) <= K)
    m.minimize(m.sum(rt[t] * rej[t] for t in T) if reject_obj else z)
    s = m.solve()
    if s is None:
        return None
    assign = {t: [c + 1 for c in C if x[t, c].solution_value > 0.5] for t in T} if binary else None
    return round(s.objective_value, 4), assign, m.number_of_variables, m.number_of_constraints


r = {}
r["P1_4"] = P(rt4, False)
r["P2a_4"] = P(rt4, True)
r["P1_5"] = P(rt5, False)
r["P2a_5"] = P(rt5, True)
for K in (1, 2, 3):
    r[f"P2d_K{K}"] = P(rt5, True, K=K)
r["P2e"] = P(rt5, True, reject_obj=True)
for k, v in r.items():
    print(k, v)
assert r["P1_4"][0] == 0.7238 and r["P1_5"][0] == 0.9252
assert r["P2a_4"][0] == 0.7992 and r["P2a_5"] is None          # P2 infeasible with 5 tasks
assert r["P2a_4"][1] == {0: [1], 1: [3], 2: [2], 3: [1]}
assert r["P2d_K1"][0] == 0.6419 and r["P2d_K2"][0] == 0.5167 and r["P2d_K3"][0] == 0.3723
assert r["P2e"][0] == 261.27 and r["P2e"][1][0] == []
assert r["P2a_4"][2:] == (13, 10)            # 12 binaries + z ; 4 + 3 + 3 constraints

# ---------------- Lab 3: P3 (threads on cores) -----------------
rh = [261.27, 261.27, 560.89, 560.89, 310.51, 310.51, 105.8, 105.8]
CK = [[1, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 1, 1]]
TH = [[1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 1, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1, 0, 0], [0, 0, 0, 0, 0, 0, 1, 1]]
T, C, H, Kc = range(4), range(3), range(8), range(9)


def P3(variant):
    m = Model()
    xtc = {(t, c): m.binary_var() for t in T for c in C}
    xhk = {(h, k): m.binary_var() for h in H for k in Kc}
    z = m.continuous_var()
    for h in H:
        m.add(m.sum(xhk[h, k] for k in Kc) == 1)
    for t in T:
        for c in C:
            m.add(m.sum(xhk[h, k] for h in H if TH[t][h] for k in Kc if CK[c][k]) == sum(TH[t]) * xtc[t, c])
    for c in C:
        for k in Kc:
            if CK[c][k]:
                m.add(m.sum(rh[h] * xhk[h, k] for h in H) <= rc[c])
        m.add(z >= m.sum(rh[h] * xhk[h, k] for h in H for k in Kc if CK[c][k]) / (sum(CK[c]) * rc[c]))
    if variant == "P3":
        m.minimize(z)
    else:   # P3a: maximise number of computers with all cores empty
        empty = {c: m.binary_var() for c in C}
        for c in C:
            for t in T:
                m.add(xtc[t, c] <= 1 - empty[c])
        m.maximize(m.sum(empty.values()))
    s = m.solve()
    return round(s.objective_value, 4), {t + 1: [c + 1 for c in C if xtc[t, c].solution_value > .5][0] for t in T}, m.number_of_variables, m.number_of_constraints


p3, p3a = P3("P3"), P3("P3a")
print("P3", p3, "\nP3a", p3a)
assert p3[0] == 0.5328 and p3[1] == {1: 1, 2: 3, 3: 2, 4: 1} and p3a[0] == 1
print("ALL LAB CHECKS PASSED")
