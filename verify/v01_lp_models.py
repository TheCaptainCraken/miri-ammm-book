"""Chapter 1: LP modelling — slide examples, the nine sheet exercises and Lab 1 (P1).

Solved with IBM CPLEX (Community Edition, via docplex).  Each assert pins a value
printed in the book (rounded as printed).
"""
from docplex.mp.model import Model

R = {}


def close(a, b, tol=0.006):
    return abs(a - b) <= tol


def solve(m):
    s = m.solve()
    assert s is not None, m.name
    return s


# ---------- Slides Example 1: factory with five products -------------------
m = Model("factory")
x = m.continuous_var_list(5, name="x")
profit = [550, 600, 350, 400, 200]
grind, drill = [12, 20, 0, 25, 15], [10, 8, 16, 0, 0]
m.maximize(m.dot(x, profit))
m.add(m.dot(x, grind) <= 288)
m.add(m.dot(x, drill) <= 192)
m.add(m.sum(20 * v for v in x) <= 384)
s = solve(m)
R["factory"] = (s.objective_value, [v.solution_value for v in x])
assert close(s.objective_value, 10920) and close(x[0].solution_value, 12) and close(x[1].solution_value, 7.2)
assert 8 * 2 * 6 == 96 and 3 * 96 == 288 and 2 * 96 == 192 and 8 * 48 == 384

# ---------- Slides Example 2: food manufacture (LP version) -----------------
m = Model("food")
x = m.continuous_var_list(5, name="x")
y = m.continuous_var(name="y")
cost, hard = [110, 120, 130, 110, 115], [8.8, 6.1, 2.0, 4.2, 5.0]
m.maximize(150 * y - m.dot(x, cost))
m.add(x[0] + x[1] <= 200)
m.add(x[2] + x[3] + x[4] <= 250)
m.add(m.sum(x) == y)
m.add(m.dot(x, hard) <= 6 * y)
m.add(m.dot(x, hard) >= 3 * y)
s = solve(m)
R["food"] = s.objective_value
assert close(s.objective_value, 17592.59, 0.01)
print("food LP:", round(s.objective_value, 2), [round(v.solution_value, 2) for v in x])

# ---------- Sheet 1: three products, four workstations ----------------------
t = [[5, 7, 4, 10], [6, 12, 8, 15], [13, 14, 9, 17]]
p = [[10, 8, 6, 9], [18, 20, 15, 17], [15, 16, 13, 17]]
dem = [100, 150, 100]
m = Model("ws")
x = {(i, j): m.continuous_var(name=f"x{i}{j}") for i in range(3) for j in range(4)}
m.maximize(m.sum(p[i][j] * x[i, j] for i in range(3) for j in range(4)))
for j in range(4):
    m.add(m.sum(t[i][j] * x[i, j] for i in range(3)) <= 35 * 60)
for i in range(3):
    m.add(m.sum(x[i, j] for j in range(4)) >= dem[i])
s = solve(m)
R["sheet1"] = s.objective_value
print("sheet1:", round(s.objective_value, 2), {k: round(v.solution_value, 2) for k, v in x.items() if v.solution_value > 1e-6})
assert close(s.objective_value, 15740.83)

# ---------- Sheet 2: cargo plane -------------------------------------------
W, V = [10, 16, 8], [6800, 8700, 5300]
w, vol, pr = [18, 15, 23, 12], [480, 650, 580, 390], [310, 380, 350, 285]
m = Model("plane")
x = {(i, j): m.continuous_var(name=f"x{i}{j}") for i in range(4) for j in range(3)}
m.maximize(m.sum(pr[i] * x[i, j] for i in range(4) for j in range(3)))
for i in range(4):
    m.add(m.sum(x[i, j] for j in range(3)) <= w[i])
for j in range(3):
    m.add(m.sum(x[i, j] for i in range(4)) <= W[j])
    m.add(m.sum(vol[i] * x[i, j] for i in range(4)) <= V[j])
for j in range(1, 3):
    m.add(m.sum(x[i, 0] for i in range(4)) * W[j] == m.sum(x[i, j] for i in range(4)) * W[0])
s = solve(m)
R["sheet2"] = s.objective_value
assert close(s.objective_value, 12151.58)
print("sheet2:", round(s.objective_value, 2), "per cargo",
      [round(sum(x[i, j].solution_value for j in range(3)), 3) for i in range(4)])

# ---------- Sheet 3: canning plants ----------------------------------------
sup, price = [200, 310, 420], [11, 10, 9]
ship = [[3, 3.5], [2, 2.5], [6, 4]]
cap, lab = [460, 560], [26, 21]
m = Model("can")
x = {(i, j): m.continuous_var(name=f"x{i}{j}") for i in range(3) for j in range(2)}
m.maximize(m.sum((50 - price[i] - ship[i][j] - lab[j]) * x[i, j] for i in range(3) for j in range(2)))
for i in range(3):
    m.add(m.sum(x[i, j] for j in range(2)) <= sup[i])
for j in range(2):
    m.add(m.sum(x[i, j] for i in range(3)) <= cap[j])
s = solve(m)
R["sheet3"] = s.objective_value
assert close(s.objective_value, 13070)
print("sheet3:", round(s.objective_value, 2), {k: round(v.solution_value, 2) for k, v in x.items() if v.solution_value > 1e-6})

# ---------- Sheet 4: four products, two machines ---------------------------
m = Model("mach")
x1 = m.continuous_var(name="x1")
yA = m.continuous_var_list(3, name="yA")      # products 2,3,4 on A
yB = m.continuous_var_list(3, name="yB")      # products 2,3,4 on B
P = [yA[k] + yB[k] for k in range(3)]
m.maximize(10 * x1 + 12 * P[0] + 17 * P[1] + 8 * P[2])
m.add(10 * x1 + 12 * yA[0] + 13 * yA[1] + 8 * yA[2] <= 0.95 * 35 * 60)
m.add(27 * x1 + 19 * yB[0] + 33 * yB[1] + 23 * yB[2] <= 0.93 * 35 * 60)
m.add(0.1 * x1 + 0.15 * P[0] + 0.5 * P[1] + 0.05 * P[2] <= 50)
m.add(P[0] >= 0.95 * 2 * P[1])
m.add(P[0] <= 1.05 * 2 * P[1])
s = solve(m)
R["sheet4"] = s.objective_value
assert close(s.objective_value, 3439.70)
assert close(0.95 * 35 * 60, 1995) and close(0.93 * 35 * 60, 1953)
print("sheet4:", round(s.objective_value, 2), "x1", round(x1.solution_value, 2), "P", [round(v.solution_value, 2) for v in P])

# ---------- Sheet 5: curve fitting ------------------------------------------
xs = [0.0, 0.5, 1.0, 1.5, 1.9, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.6, 7.0, 7.6, 8.5, 9.0, 10.0]
ys = [1.0, 0.9, 0.7, 1.5, 2.0, 2.4, 3.2, 2.0, 2.7, 3.5, 1.0, 4.0, 3.6, 2.7, 5.7, 4.6, 6.0, 6.8, 7.3]
assert len(xs) == len(ys) == 19


def fit(degree, kind):
    m = Model(f"fit{degree}{kind}")
    coef = m.continuous_var_list(degree + 1, lb=-1e6, name="a")  # free variables
    if kind == "sum":
        ep = m.continuous_var_list(len(xs), name="ep")
        em = m.continuous_var_list(len(xs), name="em")
        for i, (xv, yv) in enumerate(zip(xs, ys)):
            pred = m.sum(coef[k] * xv ** k for k in range(degree + 1))
            m.add(yv - pred == ep[i] - em[i])
        m.minimize(m.sum(ep) + m.sum(em))
    else:
        z = m.continuous_var(name="z")
        for xv, yv in zip(xs, ys):
            pred = m.sum(coef[k] * xv ** k for k in range(degree + 1))
            m.add(yv - pred <= z)
            m.add(pred - yv <= z)
        m.minimize(z)
    s = solve(m)
    return s.objective_value, [c.solution_value for c in coef]


R["fit"] = {k: fit(*k) for k in [(1, "sum"), (1, "max"), (2, "sum"), (2, "max")]}
expect = {(1, "sum"): 11.4663, (1, "max"): 1.725, (2, "sum"): 10.459, (2, "max"): 1.475}
for k, v in R["fit"].items():
    assert close(v[0], expect[k], 0.0006), (k, v[0])
    print("sheet5", k, round(v[0], 4), [round(c, 4) for c in v[1]])

# ---------- Sheet 6: portfolio -----------------------------------------------
risk, ret = [2, 5, 1, 1, 3], [0.043, 0.027, 0.025, 0.022, 0.045]


def portfolio(borrow=False):
    m = Model("pf")
    x = m.continuous_var_list(5, name="x")
    z = m.continuous_var(ub=1, name="z") if borrow else 0
    m.maximize(m.dot(x, ret) - (0.0275 * z if borrow else 0))
    m.add(m.sum(x) <= 10 + z)
    m.add(x[2] + x[3] >= 4)
    m.add(m.dot(x, risk) <= 1.4 * m.sum(x))
    s = solve(m)
    return s.objective_value, [v.solution_value for v in x], (z.solution_value if borrow else 0)


R["pf_a"], R["pf_b"] = portfolio(), portfolio(True)
assert close(R["pf_a"][0], 0.322, 1e-6) and close(R["pf_b"][0], 0.3267, 1e-6)
print("sheet6 a:", round(R["pf_a"][0] * 1000, 3), "k€", [round(v, 4) for v in R["pf_a"][1]])
print("sheet6 b:", round(R["pf_b"][0] * 1000, 3), "k€", [round(v, 4) for v in R["pf_b"][1]], "borrow", R["pf_b"][2])
# (c) minimise average risk with all 10 M€ invested and earnings >= 0.03 M€
m = Model("pfc")
x = m.continuous_var_list(5, name="x")
m.minimize(m.dot(x, risk) / 10)
m.add(m.sum(x) == 10)
m.add(x[2] + x[3] >= 4)
m.add(m.dot(x, ret) >= 0.03)
s = solve(m)
R["pf_c"] = s.objective_value
assert close(s.objective_value, 1.0)

# ---------- Sheet 7: sporks, packets, school packs ---------------------------


def sporks(reading):
    m = Model("sp")
    s_, p_, k_ = m.continuous_var(name="s"), m.continuous_var(name="p"), m.continuous_var(name="k")
    ss, ps = s_ - p_ - 10 * k_, p_ - 100 * k_          # thousands sold of loose sporks / packets
    m.add(ss >= 0)
    m.add(ps >= 0)
    m.maximize(5 * ss + 15 * ps + 300 * k_ - 2.5 * s_ - 4 * p_ - 8 * k_)
    mold, pack, sup = 0.8 * s_, 1.5 * p_ + 2.5 * k_, 0.2 * s_ + 0.5 * p_ + 0.5 * k_
    if reading == "each":
        m.add(mold <= 200); m.add(pack <= 200); m.add(sup <= 200)
    else:
        m.add(mold + pack + sup <= 200)
    sol = solve(m)
    return sol.objective_value, s_.solution_value, p_.solution_value, k_.solution_value


R["sp_each"], R["sp_total"] = sporks("each"), sporks("total")
assert close(R["sp_each"][0], 1425) and close(R["sp_total"][0], 566.667, 0.001)
print("sheet7 each-200h:", [round(v, 3) for v in R["sp_each"]])
print("sheet7 total-200h:", [round(v, 3) for v in R["sp_total"]])

# ---------- Sheet 8: assembly with labour transfers ---------------------------
m = Model("asm")
x = m.continuous_var_list(4, name="x")
tBA, tCA = m.continuous_var(name="tBA"), m.continuous_var(name="tCA")
m.maximize(m.dot(x, [10, 15, 22, 17]))
for v, ub in zip(x, [50, 60, 85, 70]):
    m.add(v <= ub)
m.add(m.dot(x, [2, 2, 1, 1]) <= 160 + tBA + tCA)
m.add(m.dot(x, [2, 4, 1, 2]) <= 200 - tBA)
m.add(m.dot(x, [3, 6, 1, 5]) <= 80 - tCA)
m.add(tBA <= 0.2 * 200)
m.add(tCA <= 0.3 * 80)
m.add(x[0] >= 0.9 * x[3])
m.add(x[0] <= 1.15 * x[3])
s = solve(m)
assert close(s.objective_value, 1760)
R["sheet8"] = (s.objective_value, [v.solution_value for v in x], tBA.solution_value, tCA.solution_value)
print("sheet8:", round(s.objective_value, 3), [round(v.solution_value, 3) for v in x], round(tBA.solution_value, 3), round(tCA.solution_value, 3))

# ---------- Sheet 9: two departments, three parts ----------------------------
m = Model("parts")
h1, h2 = m.continuous_var(ub=100, name="h1"), m.continuous_var(ub=110, name="h2")
a = m.continuous_var(lb=1050, ub=1200, name="a")
parts = [7 * h1 + 6 * h2, 6 * h1 + 11 * h2, 9 * h1 + 5 * h2]
for q in parts:
    m.add(a <= q)
m.add(m.sum(q - a for q in parts) <= 200)
m.minimize(25 * h1 + 12.5 * h2)
assert m.solve() is None                     # as stated, the sheet's instance is INFEASIBLE
m.remove_constraint(m.get_constraint_by_index(m.number_of_constraints - 1))
m.minimize(m.sum(q - a for q in parts))
s = solve(m)
assert close(s.objective_value, 333.33)      # at least 333.3 parts would have to be stored
# reading B: surplus parts may be scrapped, only stored parts count against the 200 limit
m = Model("parts2")
h1, h2 = m.continuous_var(ub=100, name="h1"), m.continuous_var(ub=110, name="h2")
a = m.continuous_var(lb=1050, ub=1200, name="a")
st = m.continuous_var_list(3, name="st")
for q, sv in zip([7 * h1 + 6 * h2, 6 * h1 + 11 * h2, 9 * h1 + 5 * h2], st):
    m.add(a + sv <= q)
m.add(m.sum(st) <= 200)
m.minimize(25 * h1 + 12.5 * h2)
s = solve(m)
assert close(s.objective_value, 2767.86) and close(h1.solution_value, 55.71) and close(h2.solution_value, 110)
R["sheet9"] = (s.objective_value, h1.solution_value, h2.solution_value, a.solution_value)
print("sheet9 (scrap reading):", [round(v, 3) for v in R["sheet9"]])

# ---------- Lab 1, P1 (split tasks) -------------------------------------------
rt = [261.27, 560.89, 310.51, 105.80]
rc = [505.67, 503.68, 701.78]
m = Model("P1")
x = {(t, c): m.continuous_var(name=f"x{t}{c}") for t in range(4) for c in range(3)}
z = m.continuous_var(name="z")
m.minimize(z)
for t in range(4):
    m.add(m.sum(x[t, c] for c in range(3)) == 1)
for c in range(3):
    m.add(m.sum(rt[t] * x[t, c] for t in range(4)) <= rc[c])
    m.add(z >= m.sum(rt[t] * x[t, c] for t in range(4)) / rc[c])
s = solve(m)
R["P1"] = s.objective_value
assert close(s.objective_value, sum(rt) / sum(rc), 1e-6)
assert close(sum(rt), 1238.47, 1e-6) and close(sum(rc), 1711.13, 1e-6)
print("P1 z* =", round(s.objective_value, 5), "=> capacities can shrink by", round(100 * (1 - s.objective_value), 2), "%")
assert close(100 * (1 - s.objective_value), 27.62, 0.01)

import json
json.dump({k: v for k, v in R.items() if k != "fit"}, open("out_v01.json", "w"), default=str, indent=1)
print("CHAPTER 1 MODELS SOLVED")
