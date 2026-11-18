#import "../template.typ": *

= Modelling with linear programs

#symbols(
  ($x_j$, [decision variable: how much of item $j$ we choose (units, tons, hours…)]),
  ($c_j$, [contribution of one unit of item $j$ to the objective (profit or cost)]),
  ($a_(i j)$, [how much of resource $i$ one unit of item $j$ uses]),
  ($b_i$, [how much of resource $i$ is available (the right-hand side)]),
  ($n, m$, [number of variables, number of constraints]),
  ($e^+_k, e^-_k$, [positive and negative part of a deviation (§1.4)]),
  ($z$, [an auxiliary variable that stands for a maximum or a minimum (§1.4)]),
)

#pretest("ch1")[A food is a blend of five oils, $x_1, dots, x_5$ tons, and $y$ tons are produced. The hardness of the blend must not exceed 6: $(8.8 x_1 + 6.1 x_2 + 2 x_3 + 4.2 x_4 + 5 x_5) slash y <= 6$. Is this a linear constraint? If not, can you make it one?]

A factory makes five products. A unit of PROD1 brings 550 € of profit and needs 12 hours of grinding, 10 hours of drilling and 20 hours of assembly; the other products have their own numbers (table below). The factory has 3 grinding machines and 2 drills, works 6 days a week with two 8-hour shifts, and employs 8 assembly workers who each work one shift a day. How much of each product should it make in a week?

#btable(columns: 6, align: (left, right, right, right, right, right),
  header: ([], [PROD1], [PROD2], [PROD3], [PROD4], [PROD5]),
  [profit (€/unit)], [550], [600], [350], [400], [200],
  [grinding (h/unit)], [12], [20], [—], [25], [15],
  [drilling (h/unit)], [10], [8], [16], [—], [—],
  [assembly (h/unit)], [20], [20], [20], [20], [20],
)

Before any formula, notice what kind of question this is. We are not asked to _compute_ something from known quantities; we are asked to _choose_ five numbers, under limits, so that a score is as large as possible. Every problem in this course has that shape. This chapter is about writing it down.

== From a story to a model

=== The four questions

Read the story four times, each time with one question in mind.

+ *What is given?* The data: profits, hours per unit, machines, shifts, workers. Data are numbers we cannot change.
+ *What do we decide?* Here: how many units of each product. These become the *decision variables* $x_1, dots, x_5$.
+ *What do we want?* The largest total profit. This becomes the *objective function*.
+ *What stops us?* Machine hours and worker hours. These become the *constraints*.

#think[Before reading on, write the grinding capacity in hours per week. Where does every factor come from?]Each answer turns into a piece of mathematics.

*Variables.* $x_j$ = units of PROD$j$ made in the week, $j = 1, dots, 5$.

*Objective.* A unit of PROD1 brings 550 €, so $x_1$ units bring $550 x_1$; summing over products,
$ max quad 550 x_1 + 600 x_2 + 350 x_3 + 400 x_4 + 200 x_5. $

*Constraints.* One grinding machine works $8 times 2 times 6 = 96$ hours a week, so the three machines offer $3 times 96 = 288$ hours. Making $x_1$ units of PROD1 uses $12 x_1$ of them, and so on, hence
$ 12 x_1 + 20 x_2 + 25 x_4 + 15 x_5 <= 288 quad "(grinding)". $
Two drills give $2 times 96 = 192$ hours: $10 x_1 + 8 x_2 + 16 x_3 <= 192$. Each worker works $8 times 1 times 6 = 48$ hours, so 8 workers give $384$ hours: $20(x_1 + x_2 + x_3 + x_4 + x_5) <= 384$.

That is the whole model. A solver (Chapter 2) returns $x_1 = 12$, $x_2 = 7.2$ and the other products at zero, with a profit of 10 920 €. Check it: grinding $12 dot 12 + 20 dot 7.2 = 288$ (full), drilling $120 + 57.6 = 177.6 <= 192$ (spare), assembly $20 dot 19.2 = 384$ (full). Two resources are the bottleneck; the third has slack.

#definition[Linear program (LP)][An optimization problem in which a linear expression of real variables is maximized or minimized subject to linear equations and inequalities. _Linear_ means a sum of terms "constant × variable" plus a constant: no products of variables, no divisions by variables, no $|dot|$, $max$, $sqrt(dot)$.]

The general shape, with $n$ variables and $m$ constraints, is
$ max sum_(j=1)^n c_j x_j quad "s.t." quad sum_(j=1)^n a_(i j) x_j <= b_i quad (i = 1, dots, m), quad x_j >= 0. $
In the factory, $c_j$ is the profit, $a_(i j)$ the hours of resource $i$ per unit of product $j$ and $b_i$ the hours available.

=== Two assumptions hidden in every LP

*Non-negativity.* We cannot make $-3$ units. The constraints $x_j >= 0$ are so common that LP texts, and the slides, leave them implicit "unless stated otherwise". In the exam, write them: it costs nothing and graders notice when a variable that must be non-negative is not.

*Divisibility.* The answer $x_2 = 7.2$ is fine if PROD2 is beer in litres, not if it is aircraft. When fractions make no sense _and_ rounding would cost too much, the variable must be integer and the model becomes an integer linear program (Chapters 5–8). Integer programs are much harder to solve, which is why we do not ask for integrality unless we need it.

#stopbox("ch1-a")[
  + Name the four ingredients of a model and say which of them the solver may change.
  + Why is the grinding capacity 288 hours and not 96?
  + In the optimal plan, which constraint is not tight, and how much of it is unused?
]

== Models are separate from data

Change the profit of PROD3 from 350 to 380 €: it is still the same _model_, only with different _data_. For that reason we write models with symbols for the data. With a set $P$ of products, a set $R$ of resources, profit $c_p$, consumption $a_(r p)$ and availability $b_r$:
$ max sum_(p in P) c_p x_p quad "s.t." quad sum_(p in P) a_(r p) x_p <= b_r quad forall r in R, quad x_p >= 0 quad forall p in P. $

This one line describes every instance of the factory problem. The modelling language OPL (Chapter 2) is built around the same split: a `.mod` file with the model and a `.dat` file with the numbers. The same Margarita recipe works whichever tequila is on the shelf; the recipe is the model, the bottle is the data.

#side[The slides index products with $p$ and resources implicitly. The book uses $j$ for "columns" (variables) and $i$ for "rows" (constraints) in general formulas, and meaningful letters ($p$, $t$, $c$, …) in applications.]Building a model is worth it even before solving it: writing the constraints forces you to understand the system (the slides call this _improving understanding_), and once written it can be analysed mathematically and computationally, which you usually cannot do with the real factory. Note also the two meanings of "programming": *mathematical programming* means planning, as in "TV programme"; it has nothing to do with writing code, although we use computers to solve the models.

#stopbox("ch1-b")[
  + What is the difference between a model and an instance?
  + In $sum_(p in P) a_(r p) x_p <= b_r$ for all $r in R$, how many constraints does the factory instance have?
]

== Keeping it linear: ratios and balances

The second example of the slides is the pretest of this chapter. A food is made by refining five raw oils (two vegetable, three non-vegetable) and blending them; the data are below. At most 200 tons of vegetable oil and 250 tons of non-vegetable oil can be refined, there is no loss of weight, the product sells for 150 €/ton and its hardness (the weighted average of the oils' hardness) must lie between 3 and 6.

#btable(columns: 6, align: (left, right, right, right, right, right),
  header: ([], [VEG 1], [VEG 2], [NON 1], [NON 2], [NON 3]),
  [hardness], [8.8], [6.1], [2.0], [4.2], [5.0],
  [cost (€/ton)], [110], [120], [130], [110], [115],
)

#example[Food manufacture as an LP][
  *Variables:* $x_1, dots, x_5$ = tons of each oil bought, refined and blended; $y$ = tons of food produced.

  *Objective:* revenue minus cost, $max 150 y - 110 x_1 - 120 x_2 - 130 x_3 - 110 x_4 - 115 x_5$.

  *Refining capacity:* $x_1 + x_2 <= 200$ and $x_3 + x_4 + x_5 <= 250$.

  *No loss of weight* (a balance): $x_1 + x_2 + x_3 + x_4 + x_5 - y = 0$.

  *Hardness:* the weighted average is $(8.8 x_1 + 6.1 x_2 + 2 x_3 + 4.2 x_4 + 5 x_5) slash y$ — a division by a variable, so not linear as written. Multiply both sides of "average $<= 6$" by $y$:
  $ 8.8 x_1 + 6.1 x_2 + 2 x_3 + 4.2 x_4 + 5 x_5 - 6 y & <= 0, \ 8.8 x_1 + 6.1 x_2 + 2 x_3 + 4.2 x_4 + 5 x_5 - 3 y & >= 0. $
  Multiplying is allowed because $y >= 0$: an inequality keeps its direction when multiplied by a non-negative number. (If $y = 0$ every $x_i = 0$ by the balance, and both sides are 0.)

  CPLEX gives a profit of 17 592.59 € with 159.26 t of VEG 1, 40.74 t of VEG 2 and 250 t of NON 2.
]

#revisit("ch1")[The constraint is not linear as written, because $y$ divides. Since $y >= 0$, multiply through: $8.8 x_1 + dots + 5 x_5 - 6 y <= 0$ is linear and equivalent. This "clear the denominator" step is the most frequent linearization in the course.]

The same idea handles every *ratio* or *proportion* in a story:

- "The ratio (product 1)/(product 4) lies between 0.9 and 1.15" becomes $0.9 x_4 <= x_1 <= 1.15 x_4$ (two constraints).
- "Product 2 is about twice product 3, ±5 %" becomes $0.95 dot 2 x_3 <= x_2 <= 1.05 dot 2 x_3$.
- "The average risk of the portfolio is at most 1.4" becomes $sum_j "risk"_j x_j <= 1.4 sum_j x_j$.
- "Each compartment is loaded in the same proportion of its capacity" becomes $(sum_i x_(i 1)) slash 10 = (sum_i x_(i 2)) slash 16$, i.e. $16 sum_i x_(i 1) = 10 sum_i x_(i 2)$, and the same for the next pair.

And *balances* ("what goes in comes out") are equalities: weight in = weight out; sporks produced = sporks sold + sporks put into packets; stock today = stock yesterday + production − sales. Whenever an item can be used in several ways, give each way its own variable and write the balance.

#yourturn("ch1-yt1")[
  A bakery makes bread ($x_1$ kg) and cake ($x_2$ kg). Flour: bread uses 0.6 kg/kg, cake 0.3 kg/kg, and 120 kg are available. The oven runs 40 hours; a kg of bread takes 0.1 h and a kg of cake 0.2 h. At least a quarter of the output (by weight) must be cake. Profits are 1.5 €/kg and 4 €/kg. Complete the model.

  - objective: $max$ #blank(w: 8em)
  - flour: #blank(w: 8em) $<= 120$
  - oven: #blank(w: 8em) $<= 40$
  - cake share: $x_2 >=$ #blank(w: 7em), i.e. #blank(w: 7em) $>= 0$, and $x_1, x_2 >= 0$.
]

#stopbox("ch1-c")[
  + Why may we multiply "average hardness $<= 6$" by $y$ without flipping the inequality?
  + Write "at least 60 % of the portfolio in bonds A and C" linearly, with $x_A, dots, x_E$ the amounts invested.
  + What kind of constraint expresses "no loss of weight"?
]

== Keeping it linear: absolute values and maxima

Two more non-linear-looking objectives appear in the sheets and in the labs, and both have a standard linear rewrite.

=== Absolute deviations

Exercise 5 of the LP sheet asks for the straight line $y = a x + b$ that best fits 19 data points $(x_k, y_k)$, minimizing $sum_k |y_k - a x_k - b|$. Note first that $a$ and $b$ are the _variables_ and the data are constants, so $y_k - a x_k - b$ is linear in $(a, b)$. The trouble is $|dot|$.

Introduce two non-negative variables per point, $e^+_k$ and $e^-_k$, and impose
$ y_k - (a x_k + b) = e^+_k - e^-_k, quad e^+_k, e^-_k >= 0, quad "minimize" sum_k (e^+_k + e^-_k). $

#think[Why can the solver not "cheat" by making both $e^+_k$ and $e^-_k$ large?]Any deviation $d$ can be written as $e^+ - e^-$ in many ways ($3 = 3 - 0 = 5 - 2$), but $e^+ + e^-$ is smallest exactly when one of them is zero, and then $e^+ + e^- = |d|$. Because we minimize, the solver picks that split by itself. This trick only works when the absolute value is being _minimized_ (or appears with a positive coefficient in a minimization); maximizing $|d|$ is not an LP.

Also note that $a$ and $b$ may be negative. LP variables are non-negative by default, so declare them *free* (in OPL, `dvar float a;` instead of `float+`). Chapter 3 shows the classical trick $a = a^+ - a^-$ that turns a free variable into two non-negative ones.

=== Minimizing a maximum

The same sheet asks for the line that minimizes the _largest_ absolute deviation, $max_k |y_k - a x_k - b|$. Introduce one variable $z$ and say "$z$ is at least every deviation":
$ min z quad "s.t." quad y_k - a x_k - b <= z, quad -(y_k - a x_k - b) <= z quad forall k. $
At the optimum $z$ cannot stay above all deviations with room to spare, because lowering it would improve the objective; so $z$ equals the largest one.

Lab 1 uses exactly this device. Tasks $t in T$ request $r_t$ units of processing and computers $c in C$ have capacity $R_c$. With $x_(t c) in [0, 1]$ the fraction of task $t$ served by computer $c$, the load of $c$ is $(1 slash R_c) sum_t r_t x_(t c)$, and we want to minimize the load of the busiest computer: #slidenote(deck: "Lab 1 and Greedy examples", where: "notation", says: [$r_t$ for the request of task $t$ and $r_c$ for the capacity of computer $c$ — one letter, told apart only by the name of the index.], correct: [The book writes $r_t$ for requests and $R_c$ for capacities.], why: [With $r_1$ you cannot tell whether task 1 or computer 1 is meant.], kind: "lab")
$ min z quad "s.t." quad sum_c x_(t c) = 1 quad forall t, quad sum_t r_t x_(t c) <= R_c quad forall c, quad z >= 1/R_c sum_t r_t x_(t c) quad forall c. $

#example[Why $z$ equals the maximum load (Lab 1, task b)][
  The constraints say $z >= "load"_c$ for every $c$, so $z >= max_c "load"_c$. If at an optimal solution $z$ were strictly larger than every load, we could decrease $z$ a little and stay feasible with a better objective — a contradiction. So $z = max_c "load"_c$ at every optimal solution. The trick is valid because we _minimize_ a quantity that only appears in "$>=$" constraints. With the lab data ($r = (261.27, 560.89, 310.51, 105.80)$, $R = (505.67, 503.68, 701.78)$) the optimum is $z^* = 1238.47 slash 1711.13 approx 0.7238$: when tasks may be split, every computer ends at the same load, total request over total capacity.
]

The pattern "min of a max" (or "max of a min", with $z <= dots$) returns in almost every exam: the January 2025 exam maximizes the _minimum_ compatibility inside a class (Chapter 6).

#stopbox("ch1-d")[
  + Write the constraints that make $z$ equal to $max(u, v, w)$ in a minimization.
  + Why does the split $d = e^+ - e^-$ not work if we maximize $|d|$?
  + In Lab 1, by what percentage could all capacities shrink uniformly and the instance stay feasible?
]

== A checklist for modelling questions

When an exercise says "formulate as an LP", the answer is a list, always in this order. Graders read it in this order too.

+ *Sets and parameters* — name the data, with units.
+ *Variables* — each with its meaning in words ("$x_(i j)$ = tons of cargo $i$ placed in compartment $j$") and its domain (real $>= 0$, free, integer, binary).
+ *Objective* — the formula and the direction (max or min).
+ *Constraints* — each family with a one-line meaning and its "for all".
+ *Check* — units on both sides of every constraint, every story sentence used once, no products or divisions of variables left.

The last step catches most mistakes. A constraint mixing tons and cubic metres, or a sentence of the story that never became a constraint, shows up immediately.

#summary[
  + A model has data, decision variables, an objective (max/min) and constraints; only the variables are chosen.
  + LP = linear objective and constraints over real variables; write $x >= 0$ explicitly and ask for integers only when fractions are meaningless.
  + Ratios become linear by multiplying through by the (non-negative) denominator; balances are equalities.
  + $|d|$ in a minimization: $d = e^+ - e^-$, minimize $e^+ + e^-$. A maximum in a minimization: one variable $z >= $ each term.
  + Write models with sets and parameters so that one model fits every instance.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch1-w1", time: 4, tier: "warm")[Which of these are linear in the variables $x, y$? (a) $3x - 2y + 7$; (b) $x y$; (c) $x slash 4 + y$; (d) $x slash y$; (e) $|x|$; (f) $2^3 x$; (g) $min(x, y)$.]

#exercise("ch1-w2", time: 4, tier: "warm")[A shop sells $x_1$ kg of coffee and $x_2$ kg of tea. "Tea must be at most 30 % of what we sell." Write this as a linear constraint.]

#exercise("ch1-w3", time: 5, tier: "warm")[In the factory model, a fourth machine type, polishing, is added: PROD1 and PROD5 need 2 h each per unit, there is one polisher and it works only one shift a day. Write the new constraint.]

#tier("practice", note: [one technique at a time; formulate, then check the optimum in the answers])

#exercise("lp-sheet-1", source: "LP sheet · Ex 1", time: 12)[A company makes three products on four workstations. Production times (minutes per unit) and profits (€ per unit) depend on the workstation:

#btable(columns: 9, align: center, header: ([], [time WS1], [WS2], [WS3], [WS4], [profit WS1], [WS2], [WS3], [WS4]),
  [Product 1], [5], [7], [4], [10], [10], [8], [6], [9],
  [Product 2], [6], [12], [8], [15], [18], [20], [15], [17],
  [Product 3], [13], [14], [9], [17], [15], [16], [13], [17])

Each workstation has 35 working hours next week. At least 100 units of product 1, 150 of product 2 and 100 of product 3 are needed. Formulate the problem of maximizing profit as an LP.]

#exercise("lp-sheet-3", source: "LP sheet · Ex 3", time: 12)[A canning company has two plants. Growers offer fresh fruit: S1 200 t at 11 €/t, S2 310 t at 10 €/t, S3 420 t at 9 €/t. Shipping costs (€/t) are S1: 3 to A, 3.5 to B; S2: 2 to A, 2.5 to B; S3: 6 to A, 4 to B. Plant A has capacity 460 t and labour cost 26 €/t; plant B 560 t and 21 €/t. Canned fruit sells at 50 €/t and everything produced can be sold. Formulate the LP that maximizes net profit.]

#exercise("lp-sheet-6", source: "LP sheet · Ex 6", time: 15)[A portfolio manager has 10 M€ to invest in five bonds:

#btable(columns: 4, align: (center, left, center, center), header: ([bond], [type], [risk], [annual return]),
  [A], [municipal], [2], [4.3 %], [B], [corporate], [5], [2.7 %], [C], [government], [1], [2.5 %],
  [D], [government], [1], [2.2 %], [E], [municipal], [3], [4.5 %])

Government bonds must total at least 4 M€ and the average risk cannot exceed 1.4. Formulate as LPs: (a) maximize the earnings after one year; (b) the same, if up to 1 M€ can be borrowed at 2.75 %; (c) drop the risk limit, require earnings of at least 30 k€, and minimize the average risk.]

#exercise("lp-sheet-7", source: "LP sheet · Ex 7", time: 15)[A plastics division makes sporks, packets (1 spork + 1 napkin + 1 straw, wrapped) and school packs (100 packets + 10 loose sporks). Per 1000 units: sporks need 0.8 h of moulding, 0.2 h of supervision and 2.50 € of direct cost; packets 1.5 h of packaging area, 0.5 h of supervision, 4.00 €; school packs 2.5 h of packaging area, 0.5 h of supervision, 8.00 €. Napkins and straws are unlimited. The three products sell, in any quantity, at 5, 15 and 300 € per thousand. There are 200 hours of production time next month. Formulate the LP that maximizes profit. (Say how you read "200 hours of production time".)]

#exercise("lp-sheet-8", source: "LP sheet · Ex 8", time: 15)[Four products with profits 10, 15, 22, 17 €/unit and sales limits 50, 60, 85, 70 units go through three assembly stages. Man-hours per unit:

#btable(columns: 5, align: center, header: ([], [P1], [P2], [P3], [P4]), [stage A], [2], [2], [1], [1], [stage B], [2], [4], [1], [2], [stage C], [3], [6], [1], [5])

Nominal hours are 160 (A), 200 (B) and 80 (C). Workers of stage B may spend up to 20 % of their time on stage A, and workers of stage C up to 30 % of theirs on stage A. The ratio (units of P1)/(units of P4) must lie between 0.9 and 1.15. Formulate the LP.]

#exercise("lp-sheet-2", source: "LP sheet · Ex 2", time: 15)[A cargo plane has three compartments with weight limits 10, 16, 8 t and volume limits 6800, 8700, 5300 m³ (front, centre, rear). For balance, (weight in a compartment)/(its weight limit) must be the same in all three. Four cargoes are offered (any fraction can be taken):

#btable(columns: 4, align: center, header: ([cargo], [weight (t)], [volume (m³/t)], [profit (€/t)]),
  [C1], [18], [480], [310], [C2], [15], [650], [380], [C3], [23], [580], [350], [C4], [12], [390], [285])

Formulate the LP that decides how much of each cargo to accept and where to put it.]

#exercise("lp-sheet-4", source: "LP sheet · Ex 4", time: 15)[Four products are made on machines A and B; minutes per unit are P1: 10 on A and 27 on B; P2: 12/19; P3: 13/33; P4: 8/23. Profits are 10, 12, 17, 8 €/unit. P1 must go through both machines; P2, P3, P4 need only one, A or B. Floor space for a week's production is 50 m², and a unit takes 0.1, 0.15, 0.5, 0.05 m². Over a week, units of P2 should be about twice the units of P3 (±5 %). Machine A is down 5 % of the time and B 7 %. The working week is 35 hours. Formulate the LP.]

#tier("exam", note: [mixes several techniques; time yourself])

#exercise("lp-sheet-5", source: "LP sheet · Ex 5", time: 20)[These 19 pairs $(x_k, y_k)$ were measured:

#text(size: 0.85em)[$x$: 0.0, 0.5, 1.0, 1.5, 1.9, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.6, 7.0, 7.6, 8.5, 9.0, 10.0 \ $y$: 1.0, 0.9, 0.7, 1.5, 2.0, 2.4, 3.2, 2.0, 2.7, 3.5, 1.0, 4.0, 3.6, 2.7, 5.7, 4.6, 6.0, 6.8, 7.3]

(a) Fit $y = a x + b$ minimizing the sum of absolute deviations. (b) Fit it minimizing the maximum absolute deviation. (c) Fit $y = a x^2 + b x + c$ with the objective of (a). (d) The same with the objective of (b). Formulate each as an LP.]

#exercise("lp-sheet-9", source: "LP sheet · Ex 9", time: 15)[#slidenote(deck: "LP sheet", where: "Ex 5 (c), (d)", says: [“the same objectives as in (1)” and “as in (2)”.], correct: [It means parts (a) and (b).], why: [The parts are labelled (a)–(d); (1) and (2) are leftovers of an older numbering.], kind: "sheet") A product is assembled from one unit of each of three parts. One hour in department 1 produces exactly 7, 6 and 9 units of parts 1, 2, 3 at 25 €/h; one hour in department 2 produces 6, 11 and 5 units at 12.5 €/h. This week 1050 products are needed and up to 1200 may be made. Department 1 has 100 h, department 2 has 110 h. At most 200 unassembled parts (all types together) can be stored at the end of the week. Formulate the LP that minimizes cost. Then check the answer: something is odd about this instance.]

#exercise("ch1-new-exam", source: "new, exam style", time: 15)[A Barcelona bike-sharing operator moves bikes overnight between three depots. Depot $i$ has $s_i$ spare bikes, and station $k$ needs $d_k$ bikes by 7 a.m.; a van trip from depot $i$ to station $k$ costs $c_(i k)$ € per bike. Each depot can load at most $L$ bikes onto vans per night, and at least 40 % of all bikes delivered must come from depot 1 (it is being emptied for works). (a) Define the variables. (b) Write the objective. (c) Write the constraints, each with its meaning. (d) Which constraint would change if a station could also receive _more_ bikes than it needs?]
