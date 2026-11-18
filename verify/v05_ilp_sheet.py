"""Chapters 5-7: the ILP modelling sheet (12 exercises), solved with CPLEX where data exist,
and checked against brute force on small random instances where the sheet gives no data."""
import itertools
import random
from docplex.mp.model import Model

OUT = {}


def close(a, b, tol=0.006):
    return abs(a - b) <= tol


# ---------------- Ex 1: food manufacture with logical conditions -------------
cost, hard = [110, 120, 130, 110, 115], [8.8, 6.1, 2.0, 4.2, 5.0]
m = Model("food-mip")
x = m.continuous_var_list(5, name="x")
d = m.binary_var_list(5, name="d")
y = m.continuous_var(name="y")
m.maximize(150 * y - m.dot(x, cost))
m.add(x[0] + x[1] <= 200)
m.add(x[2] + x[3] + x[4] <= 250)
m.add(m.sum(x) == y)
m.add(m.dot(x, hard) <= 6 * y)
m.add(m.dot(x, hard) >= 3 * y)
for i in range(5):
    m.add(x[i] <= (200 if i < 2 else 250) * d[i])     # used -> may be positive
    m.add(x[i] >= 20 * d[i])                          # used -> at least 20 t
m.add(m.sum(d) >= 3)
m.add(d[0] <= d[4])
m.add(d[1] <= d[4])
s = m.solve()
OUT["food"] = (s.objective_value, [v.solution_value for v in x])
print("ex1 food MIP:", round(s.objective_value, 2), [round(v.solution_value, 2) for v in x])
assert close(s.objective_value, 17433.33, 0.01)

# ---------------- Ex 2: Sudoku -------------------------------------------------
G = ["53..7....", "6..195...", ".98....6.", "8...6...3", "4..8.3..1",
     "7...2...6", ".6....28.", "...419..5", "....8..79"]
m = Model("sudoku")
X = {(i, j, k): m.binary_var(name=f"x{i}{j}{k}") for i in range(9) for j in range(9) for k in range(9)}
for i in range(9):
    for j in range(9):
        m.add(m.sum(X[i, j, k] for k in range(9)) == 1)
        if G[i][j] != ".":
            m.add(X[i, j, int(G[i][j]) - 1] == 1)
for k in range(9):
    for i in range(9):
        m.add(m.sum(X[i, j, k] for j in range(9)) == 1)
    for j in range(9):
        m.add(m.sum(X[i, j, k] for i in range(9)) == 1)
    for bi in range(3):
        for bj in range(3):
            m.add(m.sum(X[3 * bi + a, 3 * bj + b, k] for a in range(3) for b in range(3)) == 1)
s = m.solve()
sol = ["".join(str(k + 1) for j in range(9) for k in range(9) if X[i, j, k].solution_value > .5) for i in range(9)]
print("ex2 sudoku:", sol)
assert sol[0] == "534678912" and sol[8] == "345286179"
OUT["sudoku"] = sol
assert m.number_of_variables == 729

# ---------------- Ex 3: the 3x3x3 cube ------------------------------------------
cells = list(itertools.product(range(3), repeat=3))
lines = set()
for p in cells:
    for dvec in itertools.product([-1, 0, 1], repeat=3):
        if dvec == (0, 0, 0):
            continue
        q = tuple(p[t] + dvec[t] for t in range(3))
        r = tuple(p[t] + 2 * dvec[t] for t in range(3))
        if all(0 <= v < 3 for v in q + r):
            lines.add(frozenset([p, q, r]))
lines = [tuple(sorted(l)) for l in lines]
assert len(lines) == 49
m = Model("cube")
w = {c: m.binary_var(name="w" + "".join(map(str, c))) for c in cells}     # 1 = white
mono = {l: m.binary_var() for l in lines}
m.add(m.sum(w.values()) == 13)
for l in lines:
    m.add(m.sum(w[c] for c in l) - 2 <= mono[l])     # all white -> mono
    m.add(1 - m.sum(w[c] for c in l) <= mono[l])     # all black -> mono
m.minimize(m.sum(mono.values()))
s = m.solve()
OUT["cube"] = s.objective_value
print("ex3 cube: min monochrome lines =", s.objective_value)
assert round(s.objective_value) == 4

# ---------------- Ex 5: graph colouring (checked on random graphs) -----------------
random.seed(5)
for trial in range(5):
    n = 6
    E = [(u, v) for u in range(n) for v in range(u + 1, n) if random.random() < 0.5]
    m = Model("col")
    c = {(v, k): m.binary_var() for v in range(n) for k in range(n)}
    u = [m.binary_var() for _ in range(n)]
    for v in range(n):
        m.add(m.sum(c[v, k] for k in range(n)) == 1)
        for k in range(n):
            m.add(c[v, k] <= u[k])
    for a, b in E:
        for k in range(n):
            m.add(c[a, k] + c[b, k] <= 1)
    m.minimize(m.sum(u))
    val = round(m.solve().objective_value)
    brute = min(k for k in range(1, n + 1) if any(all(col[a] != col[b] for a, b in E)
                                              for col in itertools.product(range(k), repeat=n)))
    assert val == brute
print("ex5 colouring model agrees with brute force on 5 random graphs")

# ---------------- Ex 8: depots (a) LP and (b) MIP --------------------------------
F_ = ["Liv", "Bri"]
D = ["New", "Bir", "Lon", "Exe"]
Cu = ["C1", "C2", "C3", "C4", "C5", "C6"]
fd = {("Liv", "New"): .5, ("Liv", "Bir"): .5, ("Liv", "Lon"): 1.0, ("Liv", "Exe"): .2,
      ("Bri", "Bir"): .3, ("Bri", "Lon"): .5, ("Bri", "Exe"): .2}
fc = {("Liv", "C1"): 1.0, ("Liv", "C3"): 1.5, ("Liv", "C4"): 2.0, ("Liv", "C6"): 1.0, ("Bri", "C1"): 2.0}
dc = {("New", "C2"): 1.5, ("New", "C3"): .5, ("New", "C4"): 1.5, ("New", "C6"): 1.0,
      ("Bir", "C1"): 1.0, ("Bir", "C2"): .5, ("Bir", "C3"): .5, ("Bir", "C4"): 1.0, ("Bir", "C5"): .5,
      ("Lon", "C2"): 1.5, ("Lon", "C3"): 2.0, ("Lon", "C5"): .5, ("Lon", "C6"): 1.5,
      ("Exe", "C3"): .2, ("Exe", "C4"): 1.5, ("Exe", "C5"): .5, ("Exe", "C6"): 1.5}
capF = {"Liv": 150, "Bri": 200}
thr = {"New": 70, "Bir": 50, "Lon": 100, "Exe": 40}
req = {"C1": 50, "C2": 10, "C3": 40, "C4": 35, "C5": 60, "C6": 20}


def depot_model(extended):
    fdx, dcx, thx = dict(fd), dict(dc), dict(thr)
    depots = list(D)
    if extended:
        depots += ["Brs", "Nor"]
        fdx.update({("Liv", "Brs"): .6, ("Bri", "Brs"): .4, ("Liv", "Nor"): .4, ("Bri", "Nor"): .3})
        dcx.update({("Brs", "C1"): 1.2, ("Brs", "C2"): .6, ("Brs", "C3"): .5, ("Brs", "C5"): .3, ("Brs", "C6"): .8,
                    ("Nor", "C2"): .4, ("Nor", "C4"): .5, ("Nor", "C5"): .6, ("Nor", "C6"): .9})
        thx.update({"Brs": 30, "Nor": 25})
    m = Model("depot")
    a = {k: m.continuous_var() for k in fdx}
    b = {k: m.continuous_var() for k in fc}
    g = {k: m.continuous_var() for k in dcx}
    cost = m.sum(fdx[k] * a[k] for k in fdx) + m.sum(fc[k] * b[k] for k in fc) + m.sum(dcx[k] * g[k] for k in dcx)
    for f in F_:
        m.add(m.sum(a[k] for k in fdx if k[0] == f) + m.sum(b[k] for k in fc if k[0] == f) <= capF[f])
    open_ = {}
    if extended:
        open_ = {dp: m.binary_var(name="open_" + dp) for dp in ["New", "Exe", "Brs", "Nor"]}
        exp = m.binary_var(name="expBir")
        m.add(m.sum(open_.values()) + 2 <= 4)            # Birmingham and London always open
        cost = cost + 12 * open_["Brs"] + 4 * open_["Nor"] + 3 * exp - 10 * (1 - open_["New"]) - 5 * (1 - open_["Exe"])
    for dp in depots:
        inflow = m.sum(a[k] for k in fdx if k[1] == dp)
        outflow = m.sum(g[k] for k in dcx if k[0] == dp)
        m.add(inflow == outflow)
        cap = thx[dp]
        if extended and dp in open_:
            m.add(outflow <= cap * open_[dp])
        elif extended and dp == "Bir":
            m.add(outflow <= 50 + 20 * exp)
        else:
            m.add(outflow <= cap)
    for cst in Cu:
        m.add(m.sum(b[k] for k in fc if k[1] == cst) + m.sum(g[k] for k in dcx if k[1] == cst) == req[cst])
    m.minimize(cost)
    s = m.solve()
    return s.objective_value, ({**{k: round(v.solution_value) for k, v in open_.items()}, "expBir": round(exp.solution_value)} if extended else None)


OUT["depot_a"], OUT["depot_b"] = depot_model(False), depot_model(True)
print("ex8 (a) cost (k£):", OUT["depot_a"][0], " (b):", OUT["depot_b"])
assert close(OUT["depot_a"][0], 198.5)
assert close(OUT["depot_b"][0], 174.0) and OUT["depot_b"][1] == {"New": 0, "Exe": 1, "Brs": 0, "Nor": 1, "expBir": 1}

# ---------------- Ex 9: factory planning (a) LP, (b) maintenance MIP ---------------
prof = [10, 6, 8, 4, 11, 9, 3]
use = {"grind": [.5, .7, 0, 0, .3, .2, .5], "vdrill": [.1, .2, 0, .3, 0, .6, 0],
       "hdrill": [.2, 0, .8, 0, 0, 0, .6], "bore": [.05, .03, 0, .07, .1, 0, .08], "plane": [0, 0, .01, 0, .05, 0, .05]}
count = {"grind": 4, "vdrill": 2, "hdrill": 3, "bore": 1, "plane": 1}
down = [{"grind": 1}, {"hdrill": 2}, {"bore": 1}, {"vdrill": 1}, {"grind": 1, "vdrill": 1}, {"plane": 1, "hdrill": 1}]
mk = [[500, 1000, 300, 300, 800, 200, 100], [600, 500, 200, 0, 400, 300, 150], [300, 600, 0, 0, 500, 400, 100],
      [200, 300, 400, 500, 200, 0, 100], [0, 100, 500, 100, 1000, 300, 0], [500, 500, 100, 300, 1100, 500, 60]]
H = 24 * 2 * 8


def factory(maint):
    m = Model("fp")
    P, Sl, St = ({(p, t): m.continuous_var() for p in range(7) for t in range(6)} for _ in range(3))
    for p in range(7):
        for t in range(6):
            m.add(Sl[p, t] <= mk[t][p])
            m.add(St[p, t] <= 100)
            prev = St[p, t - 1] if t > 0 else 0
            m.add(prev + P[p, t] - Sl[p, t] == St[p, t])
        m.add(St[p, 5] == 50)
    if maint:
        dn = {(mc, t): m.integer_var(lb=0, ub=count[mc]) for mc in count for t in range(6)}
        for mc in count:
            m.add(m.sum(dn[mc, t] for t in range(6)) == (2 if mc == "grind" else count[mc]))
    for t in range(6):
        for mc in count:
            avail = (count[mc] - dn[mc, t]) if maint else (count[mc] - down[t].get(mc, 0))
            m.add(m.sum(use[mc][p] * P[p, t] for p in range(7)) <= H * avail)
    m.maximize(m.sum(prof[p] * Sl[p, t] - 0.5 * St[p, t] for p in range(7) for t in range(6)))
    return m.solve().objective_value


OUT["fp_a"], OUT["fp_b"] = factory(False), factory(True)
print("ex9 (a):", round(OUT["fp_a"], 2), " (b):", round(OUT["fp_b"], 2))
assert close(OUT["fp_a"], 93715.18, 0.01) and close(OUT["fp_b"], 108855.00, 0.01)

# ---------------- Ex 10: mining (no discounting, as on the sheet) -------------------
roy, cap_m, qual = [5, 4, 4, 5], [2, 2.5, 1.3, 3], [1.0, .7, 1.5, .5]
target = [.9, .8, 1.2, .6, 1.0]
m = Model("mine")
work = {(i, t): m.binary_var() for i in range(4) for t in range(5)}
opn = {(i, t): m.binary_var() for i in range(4) for t in range(5)}
out = {(i, t): m.continuous_var() for i in range(4) for t in range(5)}
for t in range(5):
    m.add(m.sum(work[i, t] for i in range(4)) <= 3)
    m.add(m.sum(qual[i] * out[i, t] for i in range(4)) == target[t] * m.sum(out[i, t] for i in range(4)))
    for i in range(4):
        m.add(out[i, t] <= cap_m[i] * work[i, t])
        m.add(work[i, t] <= opn[i, t])
        if t < 4:
            m.add(opn[i, t + 1] <= opn[i, t])
m.maximize(m.sum(10 * out[i, t] for i in range(4) for t in range(5)) - m.sum(roy[i] * opn[i, t] for i in range(4) for t in range(5)))
s = m.solve()
OUT["mine"] = s.objective_value
plan = [[round(out[i, t].solution_value, 3) for i in range(4)] for t in range(5)]
print("ex10 mining profit (M€):", round(s.objective_value, 3), plan)
assert close(s.objective_value, 175.917, 0.001)
assert [round(opn[3, t].solution_value) for t in range(5)] == [1, 1, 1, 1, 0]          # mine 4 closes for year 5
assert close(sum(roy[i] * opn[i, t].solution_value for i in range(4) for t in range(5)), 85)

# ---------------- Ex 11: department relocation --------------------------------------
dep = "ABCDE"
cities = ["Bristol", "Brighton", "London"]
ben = {"Bristol": [10, 15, 10, 20, 5], "Brighton": [10, 20, 15, 15, 15], "London": [0] * 5}
Cq = {(0, 1): 0.0, (0, 2): 1.0, (0, 3): 1.5, (0, 4): 0.0, (1, 2): 1.4, (1, 3): 1.2, (1, 4): 0.0,
      (2, 3): 0.0, (2, 4): 2.0, (3, 4): 0.7}
Dc = {("Bristol", "Bristol"): 5, ("Bristol", "Brighton"): 14, ("Bristol", "London"): 13,
      ("Brighton", "Brighton"): 5, ("Brighton", "London"): 9, ("London", "London"): 10}
Dc.update({(b, a): v for (a, b), v in list(Dc.items())})


def brute_dept(dbb):
    Dl = dict(Dc)
    Dl[("Brighton", "Brighton")] = dbb
    best = None
    for assign in itertools.product(range(3), repeat=5):
        if any(assign.count(k) > 3 for k in range(3)):
            continue
        val = -sum(ben[cities[assign[i]]][i] for i in range(5)) + sum(
            q * Dl[(cities[assign[i]], cities[assign[k]])] for (i, k), q in Cq.items())
        if best is None or val < best[0]:
            best = (val, "".join(cities[a][0:3] + " " for a in assign))
    return best


m = Model("dept")
dlt = {(i, j): m.binary_var() for i in range(5) for j in range(3)}
gam = {(i, j, k, l): m.binary_var() for (i, k) in Cq for j in range(3) for l in range(3)}
for i in range(5):
    m.add(m.sum(dlt[i, j] for j in range(3)) == 1)
for j in range(3):
    m.add(m.sum(dlt[i, j] for i in range(5)) <= 3)
for (i, j, k, l), gv in gam.items():
    m.add(gv <= dlt[i, j])
    m.add(gv <= dlt[k, l])
    m.add(gv >= dlt[i, j] + dlt[k, l] - 1)
m.minimize(-m.sum(ben[cities[j]][i] * dlt[i, j] for i in range(5) for j in range(3))
           + m.sum(Cq[i, k] * Dc[(cities[j], cities[l])] * gv for (i, j, k, l), gv in gam.items()))
s = m.solve()
OUT["dept"] = (s.objective_value, [cities[j] for i in range(5) for j in range(3) if dlt[i, j].solution_value > .5])
print("ex11 departments: net yearly cost (k€):", round(s.objective_value, 3), OUT["dept"][1])
bf = brute_dept(5)
assert close(s.objective_value, bf[0]) and close(s.objective_value, -14.9)
assert OUT["dept"][1] == ["Bristol", "Brighton", "Brighton", "Bristol", "Brighton"]
print("   brute force with D(Bri,Bri)=5:", bf, " ; if it were 0:", brute_dept(0), " ; if 10:", brute_dept(10))

# ---------------- Ex 12: power generation (tariff rates) -----------------------------
dem = [15000, 30000, 25000, 40000, 27000]
hours = [6, 3, 6, 3, 6]
num = [12, 10, 5]
mn, mx = [850, 1250, 1500], [2000, 1750, 4000]
cmin, cmw, cst = [1000, 2600, 3000], [2, 1.3, 3], [2000, 1000, 500]


def power(cyclic=True):
    m = Model("power")
    n = {(k, t): m.integer_var(lb=0, ub=num[k]) for k in range(3) for t in range(5)}
    s_ = {(k, t): m.integer_var(lb=0) for k in range(3) for t in range(5)}
    xo = {(k, t): m.continuous_var() for k in range(3) for t in range(5)}
    for t in range(5):
        m.add(m.sum(xo[k, t] for k in range(3)) >= dem[t])
        m.add(m.sum(mx[k] * n[k, t] for k in range(3)) >= 1.15 * dem[t])
        for k in range(3):
            m.add(xo[k, t] >= mn[k] * n[k, t])
            m.add(xo[k, t] <= mx[k] * n[k, t])
            if t > 0:
                m.add(s_[k, t] >= n[k, t] - n[k, t - 1])
            elif cyclic:
                m.add(s_[k, 0] >= n[k, 0] - n[k, 4])
            else:
                m.add(s_[k, 0] >= n[k, 0])
    m.minimize(m.sum(hours[t] * (cmin[k] * n[k, t] + cmw[k] * (xo[k, t] - mn[k] * n[k, t])) + cst[k] * s_[k, t]
                     for k in range(3) for t in range(5)))
    s = m.solve()
    return s.objective_value, [[round(n[k, t].solution_value) for k in range(3)] for t in range(5)]


OUT["power"], OUT["power_noncyc"] = power(True), power(False)
print("ex12 power cost (cyclic day):", OUT["power"], "\n     (all units off before 12 p.m.):", OUT["power_noncyc"])
assert close(OUT["power"][0], 988540, 1)

import json
json.dump(OUT, open("out_v05.json", "w"), default=str, indent=1)
print("ILP SHEET CHECKS DONE")
