#import "../template.typ": *

= OPL and CPLEX from zero

#symbols(
  ([`.mod`, `.dat`], [OPL model file and data file]),
  ([`dvar`], [declares a decision variable; `float+`, `int+`, `boolean` give its domain]),
  ([`range`], [an integer interval such as `1..n`, used as an index set]),
  ([`forall`, `sum`], [OPL's "for all" and $sum$, both with optional filters after `:`]),
  ([`execute`, `main`], [script blocks: pre/post-processing, and flow control]),
  ($T, C, H, K$, [tasks, computers, threads, cores (Labs 1–3)]),
  ($r_t, R_c$, [request of task $t$, capacity of computer $c$ (Lab 1; the lab writes $r_c$)]),
  ($x_(t c)$, [share of task $t$ on computer $c$ (Lab 1) — or 1 if $t$ runs on $c$ (Lab 2)]),
)

#pretest("ch2")[In OPL, what is wrong with the line `dvar float x[1..5]; maximize sum(i in 1..5) x[i]*x[i];`? And with `subject to { x[1] < 3; }`?]

The exam is on paper, so why learn a tool? Because question 2 of every past exam _starts_ with a fragment of OPL that you must read, the labs and the project are written in OPL, and seeing a model run is the fastest way to find out that it is wrong. This chapter teaches enough OPL to do everything in the slides and in Labs 1–3. No installation is assumed in the exercises: you can do them on paper and compare with the answers, which show the code and the results CPLEX returned.

== What CPLEX and OPL are

*CPLEX* is IBM's solver: it takes a linear (or integer, or quadratic) program and returns an optimal solution, or tells you the problem is infeasible or unbounded. *OPL* (Optimization Programming Language) is the modelling language of CPLEX: you write the model almost as you would on paper, and OPL generates the matrices that CPLEX needs. Both come in *IBM ILOG CPLEX Optimization Studio*, an Eclipse-based IDE.

In the IDE you create a *project*. A project holds model files (`.mod`), data files (`.dat`), settings files (`.ops`) and *run configurations*. A run configuration says which model to run with which data; right-click it and choose _Run_. After a run, the _Problem browser_ shows the solution, the _Engine log_ shows what CPLEX did, and the _Statistics_ and _Profiler_ tabs count variables and constraints and show times — Lab 2 asks you to look there.

== A first model: the factory

The slides show the factory of Chapter 1 in OPL twice. Here is the second, more general version, with comments that say what each line does.

```
int nProds     = 5;                       // a constant
int nResources = 3;
range Prods     = 1..nProds;              // the index set {1,...,5}
range Resources = 1..nResources;

dvar float+ x[Prods];                     // x[p] >= 0, real: units of product p

float profit[Prods] = [550, 600, 350, 400, 200];
float consum[Resources][Prods] = [        // hours of resource r per unit of p
    [12, 20,  0, 25, 15],                 // grinding
    [10,  8, 16,  0,  0],                 // drilling
    [20, 20, 20, 20, 20] ];               // assembly
float avail[Resources] = [288, 192, 384];

maximize
  sum(p in Prods) profit[p] * x[p];

subject to {
  forall (r in Resources)
    sum(p in Prods) consum[r][p] * x[p] <= avail[r];
}
```

Read it against the mathematics: `range` is an index set, `dvar float+` declares non-negative real variables (one per element of `Prods`), `maximize` gives the objective, and `forall (r in Resources)` writes one constraint per resource — exactly $sum_p a_(r p) x_p <= b_r$ for all $r in R$. Every statement ends with `;`.

#think[What would change in the OPL code if PROD3 became a product that must be made in whole units?]The first version on the slides writes the three constraints separately and gives them *labels*:
```
subject to {
  Grinding: sum(p in Prods) grinding[p] * x[p] <= grindingLimit;
  Drilling: sum(p in Prods) drilling[p] * x[p] <= drillingLimit;
  Workers:  sum(p in Prods) workers[p]  * x[p] <= workersLimit;
}
```
Labels appear in the solution browser with their slack and dual value, and they are how you find a constraint when CPLEX reports a conflict. Label your constraints in the labs.

=== The syntax you will actually use

#btable(columns: (auto, 1fr), header: ([OPL], [meaning]),
  [`dvar float x;`], [free real variable ($x in RR$)],
  [`dvar float+ x;`], [$x >= 0$, real],
  [`dvar int+ n;`, `dvar int n in 0..10;`], [integer $>= 0$; integer with bounds],
  [`dvar boolean y;`], [$y in {0, 1}$],
  [`dvar float+ x[I][J];`], [a matrix of variables $x_(i j)$],
  [`sum(i in I) a[i]*x[i]`], [$sum_(i in I) a_i x_i$],
  [`sum(i in I, j in J : i != j)`], [sum over pairs with a filter],
  [`forall (i in I : d[i] > 0) ...`], [one constraint for each $i$ with $d_i > 0$],
  [`==`, `<=`, `>=`], [the only relations: no `<` or `>` for real constraints],
  [`minimize`, `maximize`], [direction of optimization],
)

#revisit("ch2")[#side[Strict inequalities do not exist in LP: the set $x < 3$ has no maximum. With integers write `x <= 2` instead of `x < 3`.] `x[i]*x[i]` is a product of two decision variables: the objective is quadratic, not linear. Maximizing $sum x_i^2$ is a non-convex problem (Chapter 9); by default CPLEX only accepts quadratic objectives that are convex for a minimization, so the run stops with an error. (And with free, unbounded $x$ it would be unbounded anyway.) `x[1] < 3` is rejected because OPL has no strict inequalities in constraints on real variables — and an LP could not attain the supremum anyway.]

#stopbox("ch2-a")[
  + Write the OPL declaration of $y_(i j) in {0, 1}$ for $i in 1..n$, $j in 1..m$.
  + Translate into OPL: $sum_(j=1)^m y_(i j) = 1$ for every $i$.
  + Which window of the IDE tells you how many variables and constraints a model has?
]

== Models and data in separate files

The factory model contains its numbers. Lab 1 separates them, which is what you always want (Chapter 1, §1.2). In the model file, a data item declared with `= ...;` is read from the data file.

```
// P1.mod  — Lab 1: assign (fractions of) tasks to computers
int nTasks = ...;
int nCPUs  = ...;
range T = 1..nTasks;
range C = 1..nCPUs;
float rt[t in T] = ...;            // request of task t        (r_t)
float rc[c in C] = ...;            // capacity of computer c   (R_c)

dvar float+ x_tc[t in T, c in C];  // share of task t served by computer c
dvar float+ z;                     // load of the most loaded computer

minimize z;
subject to {
  forall (t in T)  sum(c in C) x_tc[t,c] == 1;                     // all of t is served
  forall (c in C)  sum(t in T) rt[t] * x_tc[t,c] <= rc[c];         // capacity
  forall (c in C)  z >= (1/rc[c]) * sum(t in T) rt[t] * x_tc[t,c]; // z >= load of c
}
```

```
// P1.dat
nTasks = 4;
nCPUs  = 3;
rt = [261.27 560.89 310.51 105.80];
rc = [505.67 503.68 701.78];
```

Two details. `x_tc[t,c]` and `x_tc[t][c]` are the same thing in OPL. And `(1/rc[c])` is fine: `rc[c]` is _data_, so the coefficient is a number. Dividing by a _variable_ would not be accepted.

With these data CPLEX returns $z^* = 0.7238$, which is total request over total capacity, $1238.47 slash 1711.13$, as Chapter 1 explained.

== Scripts: pre-processing, post-processing and `main`

OPL lets you run small JavaScript-like scripts. An `execute` block placed _before_ the objective runs before solving (pre-processing); one placed _after_ the constraints runs after solving (post-processing) and can read the solution.

```
execute {                                   // pre-processing (Lab 1, Table 2)
  var totalLoad = 0;
  for (var t = 1; t <= nTasks; t++) totalLoad += rt[t];
  writeln("Total load " + totalLoad);
}
...
execute {                                   // post-processing (Lab 1, Table 3)
  for (var c = 1; c <= nCPUs; c++) {
    var load = 0;
    for (var t = 1; t <= nTasks; t++) load += rt[t] * x_tc[t][c];
    writeln("CPU " + c + " loaded at " + 100 * load / rc[c] + "%");
  }
}
```
In scripts the indices are written `x_tc[t][c]`, and `stop()` aborts the run (Lab 1 asks you to stop when the total capacity is too small).

A `main` block takes control of the whole run: it loads a model and its data, generates the problem, sets solver parameters, solves and reads the results. Lab 1, Table 5, is the template you will copy for the project:

```
main {
  var src  = new IloOplModelSource("P1.mod");
  var def  = new IloOplModelDefinition(src);
  var cplex = new IloCplex();
  var model = new IloOplModel(def, cplex);
  var data = new IloOplDataSource("P1.dat");
  model.addDataSource(data);
  model.generate();
  cplex.epgap = 0.01;                // stop when the MIP gap is below 1 %
  if (cplex.solve()) {
    writeln("Max load " + 100 * cplex.getObjValue() + "%");
    // model.x_tc[t][c] gives the solution values
  } else writeln("No solution found");
  model.end(); data.end(); def.end(); cplex.end(); src.end();
}
```
The parameter `epgap` is the *relative MIP gap*: CPLEX stops as soon as its best integer solution is proven to be within 1 % of the optimum (Chapter 8 explains where the bound comes from). `cplex.tilim` sets a time limit in seconds. Lab 4 asks for "30 min or gap ≤ 1 %": `cplex.tilim = 1800; cplex.epgap = 0.01;`.

#stopbox("ch2-b")[
  + Where in the model file must a post-processing `execute` block go?
  + What does `cplex.epgap = 0.01` change, and why is it irrelevant for P1?
  + Write the declaration of a data array `d` indexed by `T`, read from the `.dat` file.
]

== From LP to MILP: Labs 2 and 3

Lab 2 forbids splitting: each task runs on exactly one computer. The model is the same, only the variables change:
```
dvar boolean x_tc[t in T, c in C];   // 1 if task t runs on computer c
```
The constraint `sum(c in C) x_tc[t,c] == 1` now means "exactly one computer". This is a *mixed* integer linear program (binary $x$, real $z$), and CPLEX switches from the simplex method to branch & bound (Chapter 8). With the four tasks the optimum rises from 0.7238 to 0.7992: task 2 (560.89) only fits on computer 3 and fills it to $560.89 slash 701.78 = 0.7992$. With a fifth task of 344.7 the MILP becomes *infeasible* while the LP still has a solution (load 0.9252): splitting lets tasks squeeze into gaps that whole tasks cannot use.

Infeasibility is information, not an error. Lab 2 then lets the model reject tasks. One binary per task and a budget $K$ of rejections:
```
int K = ...;
dvar boolean rej[t in T];                       // 1 if task t is rejected
subject to {
  forall (t in T) sum(c in C) x_tc[t,c] == 1 - rej[t];   // served once, or rejected
  sum(t in T) rej[t] <= K;
  ...                                           // capacity and z as before
}
```

#example[Reading the results of P2d][
  With five tasks, CPLEX gives a maximum load of 0.6419 for $K = 1$ (task 2 is rejected), 0.5167 for $K = 2$ and 0.3723 for $K = 3$. Each extra rejection buys a lower load, with diminishing returns. If instead the objective is the rejected load, `minimize sum(t in T) rt[t]*rej[t];` (P2e), the optimum rejects only task 1: 261.27 units.
]

Lab 3 splits tasks into threads and computers into cores. Its data are given as 0–1 matrices: `TH[t][h] = 1` if thread $h$ belongs to task $t$, `CK[c][k] = 1` if core $k$ belongs to computer $c$. Counting threads or cores is a pre-processing step, and OPL can do it in a declaration:
```
int nThreadsOf[t in T] = sum(h in H) TH[t][h];   // |H(t)|
int nCoresOf[c in C]   = sum(k in K) CK[c][k];   // |K(c)|
```

#stopbox("ch2-c")[
  + Which single word changes P1 (LP) into P2 (MILP)?
  + Why can P1 be feasible while P2 is infeasible on the same data?
  + Write the OPL objective of P2e.
]

== The interactive optimizer and the LP file format

The branch & bound slides do not use OPL. They call CPLEX's *interactive optimizer*, a command line, on files in *LP format*:
```
Max  x + y
Subject To
 -2 x + 2 y >= 1
 -8 x + 10 y <= 13
Bounds
 y <= 4
End
```
```
CPLEX> read example.lp
CPLEX> optimize
Dual simplex - Optimal:  Objective = 7.5000000000e+00
CPLEX> display solution variables x
x       3.500000
```
In LP format variables are non-negative unless a `Bounds` section says otherwise (`x free`, `-3 <= x <= 5`); integer variables are listed in a `General` section and binaries in a `Binary` section. Reading this output is all you need for Chapter 8.

== How question 2 of the exam uses OPL

Every past question 2 shows a few lines of OPL and asks you to "give an informal description of the meaning of the constraints", adding that "textual descriptions will not be accepted". Both phrases point at the same thing: do not read the code aloud ("`tr[k]` is greater than or equal to zero and less than or equal to the sum…"); say what it _means_ in the story ("job $k$ starts after time 0 and finishes before the rental ends"). The official answers are one or two sentences.

A method that always works:
+ Find what is indexed by the `forall`: one constraint per job, per class, per pair…
+ Translate each sum into a quantity of the story ("the number of students in class $j$", "the rental duration of the chosen plan", using that exactly one plan is chosen).
+ Say the relation in words, including _both_ bounds if there are two.

#example[A constraint from June 2024][
  ```
  forall (k in 1..n) {
    tr[k] >= 0;
    tr[k] <= ( sum (i in 1..r, j in 1..s) H[i] * c[i][j] ) - h[k];
  }
  ```
  `c[i][j]` is 1 for exactly one rental plan, so the sum is the duration $H_i$ of the chosen plan. The constraints say $0 <= "tr"_k$ and $"tr"_k + h_k <= H_i$: *job $k$ starts no earlier than time 0 and ends no later than the end of the rental.*
]

#summary[
  + OPL mirrors the mathematics: `range` = index set, `dvar` = variable with its domain, `forall`/`sum` = $forall$/$sum$, `minimize`/`maximize` + `subject to`.
  + Keep the model in a `.mod` file and the numbers in a `.dat` file (`= ...;`).
  + `execute` blocks run before or after solving; `main` controls loading, parameters (`epgap`, `tilim`), solving and reporting.
  + `float+` → LP (simplex); `boolean`/`int` → MILP (branch & bound). A MILP can be infeasible where its LP relaxation is not.
  + In the exam, describe what an OPL constraint _means_ in the story, never a literal reading of the code.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch2-w1", time: 5, tier: "warm")[Write in mathematical notation what this OPL fragment states:
```
dvar boolean y[1..n][1..m];
subject to {
  forall (j in 1..m) sum(i in 1..n) w[i]*y[i][j] <= cap[j];
  forall (i in 1..n) sum(j in 1..m) y[i][j] <= 1;
}
```]

#exercise("ch2-w2", time: 8, tier: "warm")[This model has four mistakes that stop it from compiling or make it wrong. Find them.
```
int n = ...;
range I = 1..n;
float cost[I] = ...;
dvar float x[I];                  // amounts to buy, must be >= 0
minimize sum(i in I) cost[i]*x[i]
subject to {
  sum(i in I) x[i] = 10;
  forall (i in I) x[i] / cost[i] <= 3;
}
```]

#tier("exam", note: [the "(a)" part of three past exams])

#exercise("jun24-q2a", source: "Final Jun 2024 · Q2(a)", time: 8, tier: "exam")[We prepare $n$ jobs to run concurrently. Job $k$ needs a block of $w_k$ Mb of contiguous memory, exclusively, and runs for $h_k$ seconds. A cloud provider offers $r$ rental durations $H_1 < dots < H_r$ (seconds) and $s$ memory capacities $W_1 < dots < W_s$ (Mb); renting for $H_i$ seconds a computer with $W_j$ Mb costs $p_(i j)$ €. We want the cheapest rental plan that can run all jobs. Data are positive integers; time starts at 0 and the lowest address is 0. Variables: $c_(i j)$ binary, "we rent for $H_i$ s a computer with $W_j$ Mb"; $"tr"_k$ integer, "time at which job $k$ starts"; $"lc"_k$ integer, "lowest address of the block of job $k$". Give an informal description of the meaning of constraints [A] and [B]:
```
// Constraints [A]
forall (k in 1..n) {
  tr[k] >= 0;
  tr[k] <= ( sum (i in 1..r, j in 1..s) H[i] * c[i][j] ) - h[k];
}
// Constraints [B]
forall (k in 1..n) {
  lc[k] >= 0;
  lc[k] <= ( sum (i in 1..r, j in 1..s) W[j] * c[i][j] ) - w[k];
}
```]

#exercise("jan25-q2a", source: "Final Jan 2025 · Q2(a)", time: 6, tier: "exam")[A school distributes $n$ incoming students (1..$n$) into $m$ classes (1..$m$). Each class must have between $l$ and $u$ students. $G$ and $B$ are the (disjoint) sets of good and bad students; in each class the number of good students must be at least twice the number of bad ones. $C_(i j) in [0, 1]$ is the compatibility of students $i$ and $j$ ($C$ symmetric, ones on the diagonal). The goal is to maximize the minimum compatibility between students in the same class. Binary $x_(i j)$ means "student $i$ is assigned to class $j$". Describe the meaning of:
```
forall (j in 1..m) {
  sum (i in 1..n) x[i][j] >= l;
  sum (i in 1..n) x[i][j] <= u;
}
```]

#exercise("jun25-q2a", source: "Final Jun 2025 · Q2(a)", time: 5, tier: "exam")["First Dates" is a TV show in which couples have dinner and then, in the "confession room", each member says in turn whether they want to continue. There are $n$ single men and $m$ single women (dates are man–woman). For man $i$ and woman $j$, $f_(i j)$ is the profit for the TV station when they have a date and $i$ confesses first, and $s_(i j)$ when they have a date and $i$ confesses second. The goal is to maximize the total score. Binary $x_(i j)$: "man $i$ and woman $j$ have a date, and $i$ confesses first"; binary $y_(i j)$: the same with $i$ second. Describe:
```
forall (i in 1..n)
  forall (j in 1..m)
    x[i][j] + y[i][j] <= 1;
```]

#tier("tool", note: [Labs 1–3; on paper or in the IDE])

#exercise("lab1-ab", source: "Lab 1 · tasks (a), (b)", time: 6, tier: "tool")[Describe in plain language the objective and each constraint family of P1. Then explain why the variable $z$ equals the load of the most loaded computer at an optimal solution.]

#exercise("lab1-ce", source: "Lab 1 · tasks (c), (e)", time: 15, tier: "tool")[Implement P1 in OPL with the data of the lab, once with a run configuration (model + data) and once through a `main` block. Report the optimal value and an optimal solution. Why is the optimal solution not unique?]

#exercise("lab1-d", source: "Lab 1 · task (d)", time: 8, tier: "tool")[Write a pre-processing block that checks whether the computers have enough total capacity for all requests, and stops the run if not.]

#exercise("lab1-f", source: "Lab 1 · task (f)", time: 5, tier: "tool")[Could all capacities be reduced by the same percentage, keeping the requests, and P1 stay feasible? By how much?]

#exercise("lab2-ab", source: "Lab 2 · tasks (a), (b)", time: 12, tier: "tool")[Implement P2 (each task on exactly one computer). What changes in the code? Compare P1 and P2 on the four-task data: optimal value, algorithm used by CPLEX, and number of variables (of each type) and constraints.]

#exercise("lab2-c", source: "Lab 2 · task (c)", time: 6, tier: "tool")[Solve P2 with a fifth task of 344.7. Is it feasible? Compare with P1 on the same data, and explain the difference without running anything.]

#exercise("lab2-d", source: "Lab 2 · task (d)", time: 12, tier: "tool")[Write P2d, which may reject up to $K$ tasks while minimizing the maximum load, and give the optimal values for $K = 1, 2, 3$ on the five-task data.]

#exercise("lab2-ef", source: "Lab 2 · tasks (e), (f)", time: 12, tier: "tool")[Write P2e, which may reject any tasks and minimizes the total rejected load. Compare P2a, P2d ($K = 1$) and P2e in number of variables and constraints.]

#exercise("lab3-a", source: "Lab 3 · task (a)", time: 18, tier: "tool")[Lab 3 (P3): each task $t$ is a set of threads $H(t)$, thread $h$ requests $r_h$; computer $c$ has the cores $K(c)$, each of capacity $R_c$. Every thread goes to one core, all threads of a task to cores of the same computer, core capacities hold, and $z$ (to minimize) is the highest computer load $1 slash (|K(c)| R_c) sum_(h, k in K(c)) r_h x_(h k)$. The model is
$ sum_(k in K) x_(h k) = 1 quad forall h, quad sum_(h in H(t)) sum_(k in K(c)) x_(h k) = |H(t)| x_(t c) quad forall t, c, quad sum_h r_h x_(h k) <= R_c quad forall c, k in K(c), $
plus the $z$ constraints. Write it in OPL with the lab's data format (`CK`, `TH` matrices; 4 tasks of 2 threads with requests 261.27, 560.89, 310.51, 105.8 each; 3 computers with 3 cores of 505.67, 503.68, 701.78) and solve it. Why is there no constraint "each task on exactly one computer"?]

#exercise("lab3-cd", source: "Lab 3 · tasks (c), (d)", time: 12, tier: "tool")[Modify P3 to maximize the number of computers whose cores are all empty (P3a). What is the optimum on the lab data? How do the sizes of P3 and P3a compare?]
