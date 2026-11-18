#import "../template.typ": *

== Chapter 2

#answer("ch2-a")[(a) `dvar boolean y[1..n][1..m];` (b) `forall (i in 1..n) sum(j in 1..m) y[i][j] == 1;` (c) The Statistics tab (after a run), or the engine log.]

#answer("ch2-b")[(a) After the `subject to { }` block. (b) It tells a MIP search to stop once the best solution is within 1 % of the bound; P1 is an LP, solved exactly by the simplex method, so there is no gap. (c) `float d[T] = ...;` (or `float d[t in T] = ...;`).]

#answer("ch2-c")[(a) `float+` → `boolean` in the declaration of `x_tc`. (b) Fractions of tasks can fill leftover capacity that no whole task fits into; the LP relaxation has more solutions. (c) `minimize sum(t in T) rt[t] * rej[t];`]

#answer("ch2-w1")[With $y_(i j) in {0, 1}$: $sum_(i=1)^n w_i y_(i j) <= "cap"_j$ for every $j$ (the weight put in $j$ fits its capacity), and $sum_(j=1)^m y_(i j) <= 1$ for every $i$ (each item goes to at most one place). It is a multiple-knapsack assignment.]

#answer("ch2-w2")[(1) `dvar float x[I];` makes $x$ free: write `dvar float+ x[I];`. (2) The objective has no `;` after it. (3) `=` must be `==` in a constraint. (4) `x[i] / cost[i]` is accepted (it divides by data), but it is suspicious if some `cost[i]` is 0; the intended "at most 3 times the cost" is `x[i] <= 3 * cost[i]`. A fifth, frequent slip: forgetting the `.dat` entry for `n` or `cost`.]

#answer("jun24-q2a")[[A]: job $k$ starts no earlier than time 0 and finishes ($"tr"_k + h_k$) no later than the end of the rental duration of the chosen plan. [B]: job $k$ gets a block of memory that starts at address 0 or above and ends ($"lc"_k + w_k$) within the memory capacity of the chosen plan. (Both use that exactly one $c_(i j)$ equals 1, so the sums are $H_i$ and $W_j$ of the chosen plan.)]

#answer("jan25-q2a")[The number of students assigned to each class is at least $l$ and at most $u$ (each classroom is neither too empty nor overcrowded).]

#answer("jun25-q2a")[For each man–woman pair, the man cannot be both the first and the second to confess: a couple has at most one order of confession (and if they do not have a date, neither variable is 1).]

#answer("lab1-ab")[(a) Objective: minimize the load of the most loaded computer. Constraints: (3) every task is served completely (its shares sum to 1); (4) no computer receives more requests than its capacity; (5) $z$ is at least the load of every computer. (b) Since $z >= "load"_c$ for all $c$, $z >= max_c "load"_c$; at an optimum $z$ cannot be strictly larger than all loads, otherwise decreasing it would stay feasible and improve the objective. See Worked example 1.2.]

#answer("lab1-ce")[The code is the `P1.mod`/`P1.dat` pair of §2.3 and the `main` block of §2.4. Optimal value $z^* = 0.7238$ (72.38 %). In any optimal solution every computer has load exactly $0.7238$ (otherwise moving a fraction of a task from the busiest computer to a less loaded one would lower the maximum), i.e. computer $c$ receives $0.7238 R_c$ units of work. Many different splits of the tasks achieve those three totals — for example, task 2 can be spread over the three computers in infinitely many ways — so the solution is not unique; only the loads are.]

#answer("lab1-d")[
```
execute {
  var req = 0, cap = 0;
  for (var t = 1; t <= nTasks; t++) req += rt[t];
  for (var c = 1; c <= nCPUs; c++)  cap += rc[c];
  writeln("Requested " + req + ", available " + cap);
  if (req > cap) { writeln("Not enough capacity"); stop(); }
}
```
It must be placed before the objective. With the lab data: 1238.47 requested, 1711.13 available.]

#answer("lab1-f")[Yes, by $1 - z^* = 27.62 %$. Scaling every $R_c$ by $z^* = 0.7238$ makes total capacity equal to total request; the optimal split then loads every computer at exactly 100 %.]

#answer("lab2-ab")[Only the declaration changes: `dvar boolean x_tc[t in T, c in C];`. On the four-task data: P1 (LP) optimum 0.7238, solved by the simplex method (CPLEX reports "dual simplex"), 13 continuous variables, 10 constraints. P2 (MILP) optimum 0.7992, solved by branch & bound (the MIP engine), 12 binary + 1 continuous variables, the same 10 constraints. The optimal assignment is task 1 and task 4 → computer 1, task 3 → computer 2, task 2 → computer 3; computer 3 sets the maximum ($560.89 slash 701.78$). P2 is larger in solving effort, not in size: the integrality makes the difference.]

#answer("lab2-c")[P2 is infeasible: task 2 (560.89) only fits on computer 3, leaving 140.89 there, so only task 4 can join it; tasks 1 (261.27), 3 (310.51) and 5 (344.7) must go to computers 1 and 2, but any two of them exceed 505.67, so one computer would need two of them. P1 is feasible with $z^* = 1583.17 slash 1711.13 = 0.9252$ because fractions of tasks fill the leftovers.]

#answer("lab2-d")[
```
int K = ...;
dvar boolean x_tc[t in T, c in C];
dvar boolean rej[t in T];
dvar float+ z;
minimize z;
subject to {
  forall (t in T) sum(c in C) x_tc[t,c] == 1 - rej[t];
  sum(t in T) rej[t] <= K;
  forall (c in C) sum(t in T) rt[t]*x_tc[t,c] <= rc[c];
  forall (c in C) z >= (1/rc[c]) * sum(t in T) rt[t]*x_tc[t,c];
}
```
Optimal values: $K = 1$: 0.6419 (reject task 2); $K = 2$: 0.5167; $K = 3$: 0.3723.]

#answer("lab2-ef")[P2e: same variables; objective `minimize sum(t in T) rt[t]*rej[t];`, no budget $K$ (and $z$ may be dropped). Optimum: reject task 1 only, 261.27. Sizes on the five-task data: P2a 16 variables (15 binary + $z$) and 11 constraints (infeasible); P2d 21 variables (20 binary + $z$) and 12 constraints; P2e 21 variables and 11 constraints if you keep $z$ (20 binary and 8 constraints if you drop it, since $z$ no longer matters).]

#answer("lab3-a")[
```
int nTasks = ...; int nThreads = ...; int nCPUs = ...; int nCores = ...;
range T = 1..nTasks; range H = 1..nThreads; range C = 1..nCPUs; range K = 1..nCores;
float rh[h in H] = ...;
float rc[c in C] = ...;
int CK[c in C][k in K] = ...;      // core k belongs to computer c
int TH[t in T][h in H] = ...;      // thread h belongs to task t
int nThreadsOf[t in T] = sum(h in H) TH[t][h];
int nCoresOf[c in C]   = sum(k in K) CK[c][k];

dvar boolean x_tc[t in T, c in C];
dvar boolean x_hk[h in H, k in K];
dvar float+ z;
minimize z;
subject to {
  forall (h in H) sum(k in K) x_hk[h,k] == 1;
  forall (t in T, c in C)
    sum(h in H, k in K : TH[t][h] == 1 && CK[c][k] == 1) x_hk[h,k] == nThreadsOf[t] * x_tc[t,c];
  forall (c in C, k in K : CK[c][k] == 1) sum(h in H) rh[h]*x_hk[h,k] <= rc[c];
  forall (c in C)
    z >= (1/(nCoresOf[c]*rc[c])) * sum(h in H, k in K : CK[c][k] == 1) rh[h]*x_hk[h,k];
}
```
Optimum $z^* = 0.5328$: tasks 1 and 4 on computer 1, task 3 on computer 2, task 2 on computer 3 ($2 dot 560.89 slash (3 dot 701.78)$). No "one computer per task" constraint is needed: summing constraint (3) over $c$ gives $|H(t)| = |H(t)| sum_c x_(t c)$, because every thread is on exactly one core; hence $sum_c x_(t c) = 1$ follows.]

#answer("lab3-cd")[Add `dvar boolean empty[c in C];`, the constraints `forall (t in T, c in C) x_tc[t,c] <= 1 - empty[c];` (no task on an empty computer — every thread of a task sits on its computer) and the objective `maximize sum(c in C) empty[c];`. Optimum: 1 empty computer (all eight threads fit on two computers). P3a has 3 more binaries and 12 more constraints (88 variables and 44 constraints against 85 and 32 in the docplex count); on the larger generated instances it is typically harder to prove optimal, because many assignments empty the same number of computers (lots of ties).]
