#import "../template.typ": *

= The simplex method

#symbols(
  ($beta_i$, [value of the $i$-th basic variable in the basic solution, $beta = B^(-1) b$]),
  ($alpha_(i j)$, [coefficient of non-basic $x_j$ in the tableau row of basic variable $i$: $x_(B_i) = beta_i + sum_j alpha_(i j) x_j$]),
  ($z_0$, [objective value at the basic solution]),
  ($d_j$, [reduced cost of non-basic $x_j$: its coefficient once the objective is written in the non-basic variables]),
  ($z_1$, [artificial variable of phase I]),
)

#pretest("ch4")[In a tableau for a minimization, the objective reads $z = 7 - x_2 + 2 x_3$ (with $x_2, x_3$ non-basic). Which non-basic variable would you like to increase, and why only that one?]

Question 1 of every past exam is the same exercise with different numbers: a small LP in canonical form, two given basic variables, and the questions "what is the basic solution, what is the objective value, what are the reduced costs, is each non-basic variable optimal, and if not how far can it grow?". It is worth 2.1 points out of 10 and takes about 15 minutes once the method is automatic. This chapter makes it automatic, and then shows the rest of the simplex method (phase I, degeneracy) that the slides cover. Like a pilot who knows one harbour by heart, you will enter this one in the dark.

== The tableau

Take the polygon of Chapter 3 with $min -x - 2y$. With the slacks as basic variables, the tableau (the equations solved for the basic variables) is
$ s_1 = 3 - x - y, quad s_2 = 2 - x, quad s_3 = 2 - y, quad z = -x - 2y. $

Two things are visible at a glance. The *basic solution*: set the non-basic $x, y$ to 0 and read the constants — $s_1 = 3$, $s_2 = 2$, $s_3 = 2$. The *objective value*: the constant of the $z$ row, here 0.

In general the objective contains basic variables too. Then *substitute the tableau into the objective* so that it depends only on non-basic variables. For the basis $(x, y, s_2)$ the tableau is $x = 1 + s_3 - s_1$, $y = 2 - s_3$, $s_2 = 1 - s_3 + s_1$, and
$ -x - 2y = -(1 + s_3 - s_1) - 2(2 - s_3) = -5 + s_1 + s_3. $
So at this basic solution ($x = 1$, $y = 2$) the objective is $-5$.

#definition[Reduced cost][Once the objective is written in terms of the non-basic variables only, $z = z_0 + sum_(j "non-basic") d_j x_j$, the coefficient $d_j$ is the reduced cost of $x_j$. It is the change of the objective per unit increase of $x_j$ when the other non-basic variables stay at 0 and the basic ones adjust to keep $A x = b$.]

In matrix form $d_j = c_j - c_B^T B^(-1) a_j$, but by hand the substitution is faster and harder to get wrong. Reduced costs of basic variables are 0 by definition. #side[$d_j$ is "reduced" because the raw cost $c_j$ is corrected by the costs of the basic variables that must move when $x_j$ moves.]

== Optimality

If every reduced cost is $>= 0$ (minimization), no non-basic variable can be increased without increasing the objective, and non-basic variables cannot decrease below 0. So *the basic solution is optimal*. In the tableau above, $z = -5 + s_1 + s_3$: optimal, value $-5$ at $(x, y) = (1, 2)$.

The condition is *sufficient, not necessary*: a degenerate optimal basis can show a negative reduced cost (the variable cannot actually move, Section 4.5). In the exam you only need the sufficient direction: "all reduced costs are non-negative, hence optimal".

A non-basic variable with $d_j >= 0$ "satisfies the optimality condition"; one with $d_j < 0$ does not — increasing it would improve the objective.

#revisit("ch4")[$x_2$, because its reduced cost is $-1 < 0$: each unit of $x_2$ lowers $z$ by 1. Increasing $x_3$ would raise $z$ by 2 per unit, and decreasing it is impossible since $x_3 >= 0$ is already at 0.]

#stopbox("ch4-a")[
  + How do you read the basic solution and the objective value from a tableau?
  + State the optimality condition for a minimization.
  + A reduced cost is 0. Is the basis optimal? Is it the only optimum?
]

== Improving: the ratio test

Suppose $d_j < 0$. Increase $x_j$ from 0 to some value $t$, keeping the other non-basic variables at 0. The equations stay satisfied if the basic variables follow the tableau, and the objective drops by $|d_j| t$. The only danger is that some basic variable becomes negative. Each row $x_(B_i) = beta_i + alpha_(i j) t$ gives a limit:

- if $alpha_(i j) >= 0$, the basic variable does not decrease: *no limit*;
- if $alpha_(i j) < 0$, we need $beta_i + alpha_(i j) t >= 0$, i.e. $t <= beta_i slash (-alpha_(i j))$.

The best value is the *smallest* of these limits — the *ratio test*. If no row limits $t$, the objective decreases forever: the LP is *unbounded*. Otherwise the row that gives the minimum is *tight*: its basic variable becomes 0 and leaves the basis, and $x_j$ enters. Rewriting the tableau for the new basis is called *pivoting*. #fig("/figures/simplex-path.svg", caption: [The simplex path for $min -x - 2y$: from $(0, 0)$ to $(0, 2)$ when $y$ enters, then to $(1, 2)$ when $x$ enters.], margin: true)

#example[The slides' run, step by step][
  *Start:* $s_1 = 3 - x - y$, $s_2 = 2 - x$, $s_3 = 2 - y$, $z = -x - 2y$. Both $x$ and $y$ have negative reduced costs. Choose $y$ ($d_y = -2$).

  *Ratio test for $y$:* $s_1 = 3 - y >= 0$ gives $y <= 3$; $s_2 = 2$ does not depend on $y$; $s_3 = 2 - y >= 0$ gives $y <= 2$. Best value $min(3, 2) = 2$; $s_3$ is tight and leaves.

  *Pivot:* isolate $y$ from the tight row, $y = 2 - s_3$, and substitute it everywhere:
  $ s_1 = 1 - x + s_3, quad s_2 = 2 - x, quad y = 2 - s_3, quad z = -4 - x + 2 s_3. $

  *Second iteration:* $d_x = -1 < 0$. Ratio test: $s_1 = 1 - x$ gives $x <= 1$; $s_2 = 2 - x$ gives $x <= 2$; $y$ does not depend on $x$. So $x = 1$, $s_1$ leaves. Pivot with $x = 1 - s_1 + s_3$:
  $ x = 1 - s_1 + s_3, quad s_2 = 1 + s_1 - s_3, quad y = 2 - s_3, quad z = -5 + s_1 + s_3. $
  All reduced costs are $>= 0$: optimal, $z^* = -5$ at $(x, y) = (1, 2)$.
]

Each step changes the objective by $d_j times$ (the new value of $x_j$): $-2 times 2 = -4$, then $-1 times 1 = -1$. That is a quick check of your arithmetic.

#stopbox("ch4-b")[
  + In the ratio test, which rows limit the entering variable?
  + What do you conclude if no row limits it?
  + By how much does the objective change in one simplex step?
]

== The exam question, done the same way every time

Here is a question in exactly the format of the finals, solved the way you should write it.

#example[An exam-style question 1][
  $min 2 x_0 - x_1$ s.t. $-x_0 + x_1 + x_3 = -2$, $-x_0 + 2 x_1 + x_2 + x_3 = 1$, $x >= 0$. The variables $(x_1, x_0)$ form a feasible basis.

  *Step 1 — tableau.* Solve the two equations for $x_1$ and $x_0$ (Chapter 3): subtracting, $x_1 + x_2 = 3$, so $x_1 = 3 - x_2$; then $x_0 = x_1 + x_3 + 2 = 5 - x_2 + x_3$.

  *Step 2 — basic solution* (constants): $x_1 = 3$, $x_0 = 5$. Plug back in: $-5 + 3 + 0 = -2$ ✓, $-5 + 6 + 0 + 0 = 1$ ✓.

  *Step 3 — objective in non-basic variables:* $2 x_0 - x_1 = 2(5 - x_2 + x_3) - (3 - x_2) = 7 - x_2 + 2 x_3$. Objective value at the basic solution: *7*. Reduced costs: $d_2 = -1$, $d_3 = 2$.

  *Step 4 — optimality, one variable at a time.* $x_3$: $d_3 = 2 >= 0$, it satisfies the optimality condition. $x_2$: $d_2 = -1 < 0$, it does not.

  *Step 5 — ratio test for $x_2$* (with $x_3 = 0$): $x_1 = 3 - x_2 >= 0$ gives $x_2 <= 3$; $x_0 = 5 - x_2 >= 0$ gives $x_2 <= 5$. Best value *3* ($x_1$ leaves). Had no coefficient of $x_2$ been negative, the answer would be $+infinity$.

  (Pivoting once more gives $x_2 = 3 - x_1$, $x_0 = 2 + x_1 + x_3$, $z = 4 + x_1 + 2 x_3$: optimal with value 4. The objective fell by $1 times 3 = 3$, as predicted.)
]

#think[In step 5, why do we keep $x_3$ at 0 while $x_2$ grows?]The phrase "the best value it can be assigned to according to the ratio test" means exactly the minimum ratio of step 5. The phrase "satisfies the optimality conditions" means "has a non-negative reduced cost". The January variants ask instead "justify why the basic solution is optimal": answer with the reduced costs and the sentence "all reduced costs are $>= 0$, so the basic solution is optimal".

#yourturn("ch4-yt1")[
  $min 2x_0 + 2x_1 + 2x_2 + x_3$ s.t. $-x_0 - x_2 + x_3 = -1$, $-x_0 - 2x_1 + 2x_2 - 2x_3 = -2$; basis $(x_2, x_1)$.
  - From the first equation, $x_2 = $ #blank(w: 6em). Substituting, $x_1 = 2 - $ #blank(w: 4em) $x_0$.
  - Basic solution: $x_2 = $ #blank(), $x_1 = $ #blank(). Objective value: #blank().
  - Objective in non-basic variables: $z = 6$ #blank(w: 3em) $x_0$ #blank(w: 3em) $x_3$.
  - $x_3$ satisfies the optimality condition: #blank(w: 3em). $x_0$: #blank(w: 3em); ratio test for $x_0$: $x_2$ gives $x_0 <= $ #blank(), $x_1$ gives $x_0 <= $ #blank(); best value #blank().
]

== Finding a first feasible basis: phase I

The simplex method needs a feasible basis to start. With constraints $<= b$, $b >= 0$, the slacks are one. With a $>=$ constraint they are not: for $1 <= x + y <= 3$, $x <= 2$, $y <= 2$, the slack of $x + y - s_2 = 1$ gives $s_2 = -1 + x + y$, which is $-1$ at the origin.

The fix is to add an *artificial variable* $z_1 >= 0$ to that equation, $x + y - s_2 + z_1 = 1$, use $z_1$ in the basis ($z_1 = 1 - x - y + s_2$) and first solve
$ min z_1 quad "s.t. the constraints with" z_1. $
This *phase I* problem has an obvious feasible basis, so the simplex method applies to it. Its optimum is 0 exactly when the original problem is feasible: if $z_1 = 0$ the original constraint holds. Then $z_1$ is non-basic, we drop it, and the final basis of phase I is a feasible basis to start *phase II* (the real objective). #fig("/figures/phase1.svg", caption: [Phase I: the origin is not feasible for $x + y >= 1$; one pivot reaches the feasible vertex $(1, 0)$.], margin: true)

#example[Phase I (slides 18–24)][
  $min z_1$ with $s_1 = 3 - x - y$, $z_1 = 1 - x - y + s_2$, $s_3 = 2 - x$, $s_4 = 2 - y$. The objective in non-basic variables is $1 - x - y + s_2$. Choose $x$: the limits are 3, 1 and 2, so $x = 1$ and $z_1$ leaves. New tableau: $x = 1 - z_1 - y + s_2$, $s_1 = 2 + z_1 - s_2$, $s_3 = 1 + z_1 + y - s_2$, $s_4 = 2 - y$, objective $z_1$: optimal with value 0. Drop $z_1$: the basis $(s_1, x, s_3, s_4)$ is feasible for the original problem. In phase II, $-x - 2y = -1 - y - s_2$: both $y$ and $s_2$ can enter. Continuing with the smallest index first ($y$, then $s_2$, then $x$ again) the objective goes $-1, -2, -4, -5$ and stops at $(x, y) = (1, 2)$ with value $-5$.
]

In general, for $A x = b$ with $b >= 0$ (multiply rows by $-1$ if needed) add one artificial variable per row — or only to rows whose slack has the wrong sign — and minimize their sum. If the phase-I optimum is positive, the original LP is *infeasible*. The slides show this with $x + y >= 5$, $x <= 2$, $y <= 2$: phase I stops at $z_1 = 1$, the best one can do is $x + y = 4$.

#stopbox("ch4-c")[
  + Why does phase I always have an easy starting basis?
  + What does a positive phase-I optimum tell you?
  + After phase I ends with value 0, what do you do with the artificial variables?
]

== Unboundedness, degeneracy and termination

*Unboundedness.* $max x + y$ s.t. $2x + y >= 3$: as a minimization, with basis $y$, $y = 3 - 2x + s$ and $z = -x - y = -3 + x - s$. The variable $s$ has reduced cost $-1$ and appears in the $y$ row with a positive coefficient: nothing limits it. The LP is unbounded. In the exam this is the "$+infinity$" answer (June 2025 and June 2026 both had one).

*Degeneracy.* If a basic variable is 0, the ratio test can return 0: the entering variable enters at value 0, the basis changes but the point does not move and the objective does not improve (a *degenerate step*). Since $Delta "cost" = d_j times Delta x_j$, there is no improvement exactly when the step is degenerate.

*Termination.* Without degenerate steps the objective strictly improves, so no basis is visited twice; there are at most $binom(n, m)$ bases, so the method stops. That bound is exponential, and pathological LPs (the Klee–Minty cube) really need exponentially many steps, yet in practice the simplex method is fast. With degeneracy the method can *cycle* — return to a basis forever. *Bland's rule* prevents it: fix an order of the variables; among the variables with negative reduced cost choose the first, and among tight rows choose the one whose basic variable comes first.

Interior-point methods solve LPs in polynomial time; the simplex method remains the workhorse inside branch & bound because it restarts quickly after a bound changes (Chapter 8).

#stopbox("ch4-d")[
  + What is a degenerate step, and why can it happen?
  + State Bland's rule.
  + What is the maximum number of bases with $n$ variables and $m$ equations?
]

#summary[
  + Tableau: basic variables as functions of non-basic ones; constants give the basic solution, the constant of $z$ gives its value.
  + Reduced costs: substitute the tableau into the objective; $d_j$ = coefficient of non-basic $x_j$.
  + Minimization: all $d_j >= 0$ ⇒ optimal. A non-basic $x_j$ with $d_j < 0$ violates optimality.
  + Ratio test: rows with negative coefficient limit $x_j$ to $beta_i slash (-alpha_(i j))$; take the minimum; no limit ⇒ $+infinity$ (unbounded).
  + Phase I minimizes artificial variables to find a feasible basis (value > 0 ⇒ infeasible); Bland's rule prevents cycling.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch4-w1", time: 3, tier: "warm")[A tableau reads $x_1 = 4 - x_2 + 2x_4$, $x_3 = 1 + x_2 - x_4$, $z = 10 + 3 x_2 - x_4$. Give the basic solution, its objective value and the reduced costs. Is it optimal?]

#exercise("ch4-w2", time: 5, tier: "warm")[In the tableau of the previous exercise, do the ratio test for the variable that violates optimality. Which variable leaves?]

#exercise("ch4-w3", time: 5, tier: "warm")[Check the reduced cost $d_x = -1$ of the second iteration of Worked example 4.1 with the formula $d_j = c_j - c_B^T B^(-1) a_j$, for the basis $(s_1, s_2, y)$.]

#tier("practice")

#exercise("ch4-p1", time: 12)[Solve $min -3 x_1 - 2 x_2$ s.t. $x_1 + x_2 + s_1 = 4$, $x_1 + 3 x_2 + s_2 = 6$, $x, s >= 0$ with the simplex method, starting from the slack basis and always choosing the most negative reduced cost.]

#exercise("simplex-new-tie", source: "new", time: 10)[$min x_0 + 2 x_1 + x_2$ s.t. $2 x_1 + 2 x_2 - 2 x_3 = 2$, $x_0 + 2 x_1 - 2 x_2 - x_3 = 2$, $x >= 0$; basis $(x_0, x_2)$. (a) Give the basic solution, objective and reduced costs. (b) Do the ratio test for the non-optimal variable: what is special? (c) Apply Bland's rule to choose the leaving variable and give the new basic solution. Is it degenerate?]

#exercise("ch4-p3", time: 6)[Show that $min -x - y$ s.t. $x - y + s_1 = 1$, $-x + y + s_2 = 1$, $x, y, s >= 0$ is unbounded, starting from the slack basis. Give a feasible direction along which the objective decreases forever.]

#exercise("ch4-p4", time: 6)[Explain why the optimal value of a phase-I problem is 0 whenever the original LP is feasible, and why it cannot be negative.]

#tier("exam", note: [all five past question 1s; 12–15 minutes each])

#exercise("jun24-q1", source: "Final Jun 2024 · Q1", time: 15, tier: "exam")[$min x_0 + x_1 - x_2 - x_3$ s.t. $-2 x_0 + x_1 - 2 x_3 = 1$, $2 x_0 - x_2 - x_3 = -1$, $x_i >= 0$. The variables $(x_1, x_3)$ form a feasible basis. (a) Give the values of the basic variables $x_1$ and $x_3$. (b) Give the objective value at the basic solution. (c) Give the reduced costs of $x_0$ and $x_2$. (d) Does $x_0$ satisfy the optimality conditions? If not, give the best value it can be assigned according to the ratio test ($+infinity$ if none). (e) The same for $x_2$.]

#exercise("jun25-q1", source: "Final Jun 2025 · Q1", time: 15, tier: "exam")[$min -x_1 - x_2 - x_3$ s.t. $2 x_0 - x_1 - x_2 - x_3 = 0$, $-x_0 + x_2 = -2$, $x_i >= 0$. The variables $(x_0, x_3)$ form a feasible basis. (a) Values of $x_0$ and $x_3$. (b) Objective value. (c) Reduced costs of $x_1$ and $x_2$. (d) Does $x_1$ satisfy the optimality conditions? If not, its best value by the ratio test. (e) The same for $x_2$.]

#exercise("jun26-q1", source: "Final Jun 2026 · Q1", time: 15, tier: "exam")[$min -2 x_0 - 2 x_1 + 2 x_3$ s.t. $-2 x_0 + 2 x_1 + x_3 = -2$, $x_0 + 2 x_2 - x_3 = -2$, $x_i >= 0$. The variables $(x_0, x_3)$ form a feasible basis. (a) Values of $x_0$ and $x_3$. (b) Objective value. (c) Reduced costs of $x_1$ and $x_2$. (d) Does $x_1$ satisfy the optimality conditions? If not, its best value by the ratio test. (e) The same for $x_2$.]

#exercise("jan25-q1abc", source: "Final Jan 2025 · Q1(a–c)", time: 12, tier: "exam")[$min 2 x_0 + 2 x_1 + x_2 - 2 x_3$ s.t. $2 x_0 + 2 x_1 - x_2 + 2 x_3 = 0$, $-2 x_0 + 2 x_1 + 2 x_2 - x_3 = 1$, $x_i >= 0$. The variables $(x_3, x_2)$ form a feasible basis. (a) Values of $x_3$ and $x_2$. (b) Objective value. (c) Justify why the basic solution is optimal, giving the reduced costs. (Part (d) is #exref("jan25-q1d").)]

#exercise("jan26-q1abc", source: "Final Jan 2026 · Q1(a–c)", time: 12, tier: "exam")[$min -2 x_2 - x_3$ s.t. $-2 x_1 - 2 x_2 + x_3 = -2$, $-2 x_0 - 2 x_1 - x_3 = -1$, $x_i >= 0$. The variables $(x_3, x_2)$ form a feasible basis. (a) Values of $x_3$ and $x_2$. (b) Objective value. (c) Justify why the basic solution is optimal, giving the reduced costs. (Part (d) is #exref("jan26-q1d").)]

#exercise("simplex-new-a", source: "new, exam style", time: 12, tier: "exam")[$min 2 x_0 + 2 x_1 + 2 x_2 + x_3$ s.t. $-x_0 - x_2 + x_3 = -1$, $-x_0 - 2 x_1 + 2 x_2 - 2 x_3 = -2$, $x_i >= 0$. Without looking at Your turn 4.1, take the basis $(x_0, x_1)$ and answer: (a) basic values; (b) objective value; (c) reduced costs of $x_2$ and $x_3$; (d)–(e) optimality of each, with the ratio test where needed.]

#tier("review", note: [from Chapters 1–3])

#exercise("ch4-r1", source: "review of Ch. 1", time: 4, tier: "review")[Write the LP constraints that make $z$ the largest of $|e_1|, |e_2|$ in a minimization of $z$.]

#exercise("ch4-r2", source: "review of Ch. 3", time: 4, tier: "review")[How many choices of 2 basic variables does a $2 times 4$ system have? Can all of them be bases?]
