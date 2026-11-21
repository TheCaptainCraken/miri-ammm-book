#import "../template.typ": *

= Non-linear programming

#symbols(
  ($f, g_i$, [objective and constraint functions, now allowed to be non-linear]),
  ($S$, [feasible region]),
  ($Q$, [symmetric matrix of a quadratic form $x^T Q x$]),
  ($b_0 < b_1 < dots < b_r$, [breakpoints of a piecewise linear approximation]),
  ($lambda_0, dots, lambda_r$, [weights of the breakpoints: $x = sum lambda_k b_k$, $y = sum lambda_k f(b_k)$, $sum lambda_k = 1$]),
  ($mu_k, delta_k$, [binaries used to encode an SOS2 with integer programming]),
)

#pretest("ch9")[You approximate $x^3$ on $[0, 2]$ by straight segments between the points at $x = 0, 1, 1.5, 2$, and minimize $x - x^3 + z$. Could the LP "cheat" and return a value of $x^3$ that is not on the segments? In which direction?]

The last chapter of Part I is the one the exam has never asked about. It is short, but it explains two things you will use anyway: why we work so hard to keep models linear, and how to cope when a story is not linear (concave costs, distances, products). The new exam-style questions at the end show what a question on it could look like.

== What changes when the model is not linear

A *non-linear program* (NLP) has a non-linear expression in the objective or in a constraint: $x^2$, $x y$, $x slash y$, $|x|$, $sqrt(x)$, $e^x$, $min(x, y)$… Two examples from the slides: buying $x$ tons of oranges costs $400 ln(1 + x)$ (the more you buy, the cheaper each ton), so the profit $1000 x - 400 ln(1 + x)$ is non-linear; two items at $(x_1, y_1)$ and $(x_2, y_2)$ at least 10 km apart need $(x_2 - x_1)^2 + (y_2 - y_1)^2 >= 100$ — still non-linear even after squaring away the root.

Non-linear programs are much harder than linear ones of the same size. The slides' experiment: graph colouring (Chapter 5) written linearly ($c_(v k) + c_(w k) <= 1$) or quadratically ($c_(v k) c_(w k) = 0$) — the same problem, solved by CPLEX on 13 vertices: the linear model instantly, the quadratic one much more slowly. Some non-linearities can be removed exactly (Chapters 1 and 6: ratios, absolute values, products with binaries). This chapter is about the ones that cannot.

== Convexity: when local is enough

#definition[Convex set, convex function][A region is convex if the segment between any two of its points stays inside it. A function $f$ is convex if the region above its graph, ${(x, y) : y >= f(x)}$, is convex — equivalently, every chord lies on or above the graph. A *convex program* minimizes a convex function over a convex region.]

#figure(image("/figures/convexity.svg"), caption: [A convex function (chords stay above), a non-convex one with a local minimum that is not global, and a non-convex region (a ring).])

Why care? For a minimization, a *global* minimum $z in S$ satisfies $f(z) <= f(y)$ for all $y in S$; a *local* minimum only for the $y in S$ close to $z$. In a convex program *every local minimum is global*. Many NLP algorithms (gradient methods, Chapter 10's starting point) only find local minima, so they solve convex programs exactly and non-convex ones only approximately.

LPs are convex: a linear function is convex, each linear inequality defines a half-space (convex), and an intersection of convex sets is convex. A quadratic $x^T Q x$ is convex — and $x^T Q x <= k$ a convex region — when $Q$ is positive semidefinite (all eigenvalues $>= 0$). Examples from the slides: $min x^2 + y^2$ over a polygon is convex; $min x - x^3 + y$ is not ($-x^3$ is concave for $x > 0$); $4 <= x^2 + y^2 <= 16$ is a ring, not convex. #question(label: [Think first])[Maximizing a concave function is a convex program. Why? (Hint: $max f = -min(-f)$.)]

#stopbox("ch9-a")[
  + Define a convex program.
  + Is $f(x) = |x|$ convex? Is the region $x^2 + y^2 >= 4$ convex?
  + Why do we care whether a program is convex?
]

== Separable programming: piecewise linear approximations

#definition[Separable][A function is separable if it is a sum of functions of one variable each: $x_1^2 + 2 x_2 + e^(x_3)$ is separable, $x_1 x_2$ is not. A program is separable if its objective and all constraint functions are.]

A separable program can be approximated by an LP: replace each non-linear one-variable term by a piecewise linear function. Take the slides' example
$ min x^2 - 4x - 2z quad "s.t." quad & x + z <= 4, quad 2x + z <= 5, \
  & -x + 4z >= 2, quad x, z >= 0. $
Only $x^2$ is non-linear, and $x$ ranges over $[0, 2]$ in the feasible region. Choose breakpoints $0, 1, 2$, where $x^2$ equals $0, 1, 4$. A point on the broken line through $(0, 0)$, $(1, 1)$, $(2, 4)$ is a *weighted average of two adjacent breakpoints*:
$ x = 0 lambda_0 + 1 lambda_1 + 2 lambda_2, quad y = 0 lambda_0 + 1 lambda_1 + 4 lambda_2, \
  lambda_0 + lambda_1 + lambda_2 = 1, quad lambda >= 0, $
with *at most two $lambda$'s non-zero, and if two, adjacent*. Replace $x^2$ by $y$: the objective becomes $y - 4x - 2z$, linear.

#figure(image("/figures/piecewise.svg"), caption: [Left: for a convex term the LP stays on the broken line. Right: for $x^3$ the chord between $(0,0)$ and $(2,8)$ lies above the curve; minimizing $-y$ pulls the LP onto it unless adjacency is enforced.])

#example[The approximation in the convex case][
  Here the objective is convex, and an LP solver returns $x = 1$, $z = 3$, value $-9$, using only $lambda_1 = 1$. This is also the exact optimum of the non-linear problem (along the boundary the objective is $x^2 - 2x - 8$ for $x <= 1$ and $x^2 - 10$ for $x >= 1$, both smallest at $x = 1$). For a convex program the adjacency condition is satisfied automatically by the LP optimum: mixing non-adjacent breakpoints puts $y$ on a chord _above_ the convex curve, which only costs more when we minimize.
]

#revisit("ch9")[Yes, upward: $x^3$ is not convex on the region, and the objective contains $-x^3$, so minimizing pushes $y$ up. Mixing the breakpoints $x = 0$ and $x = 2$ gives points on the chord $y = 4x$, above $x^3$. With an added constraint $x <= 1.5$ the LP without adjacency returns $x = 1.5$ with $y = 6$ (value $-29 slash 8$) although $1.5^3 = 3.375$; with adjacency enforced it returns the correct value $-1$.]

=== When adjacency must be enforced: SOS2

In a non-convex program the condition "at most two consecutive $lambda$'s are non-zero" must be imposed explicitly. Such a set of variables is a *special ordered set of type 2* (SOS2). Solvers accept SOS2 declarations directly (a variant of branch & bound branches on them), or we encode them with binaries. For 0–1 variables $mu_1, dots, mu_n$, introduce $delta_1, dots, delta_(n-1) in {0, 1}$ ("segment $k$ is the active one") and require
$ mu_1 <= delta_1, quad mu_k <= delta_(k-1) + delta_k quad (1 < k < n), quad mu_n <= delta_(n-1), quad sum_k delta_k <= 1. $
If $delta_k$ is the only non-zero $delta$, only $mu_k$ and $mu_(k+1)$ can be 1. For continuous $lambda_k$, add indicators $mu_k$ with $lambda_k <= mu_k$ (upper bound 1) and impose the SOS2 on the $mu$'s. #slidenote(deck: "Non-linear programming", where: "slides 19–20", says: [The example $min x - x^3 + z$ over the polygon illustrates that without the adjacency condition "the optimization will take us away from the approximation".], correct: [The warning is right in general, but in this instance the optimum is at the breakpoint $x = 2$ and both versions return $-5$ at $(x, z) = (2, 1)$. Adding $x <= 1.5$ exposes the failure: $-29 slash 8$ without adjacency, $-1$ with it.], why: [Solved exactly with and without the SOS2 condition (script `v09_nlp.py`).])

#yourturn("ch9-yt1")[
  Approximate $x^2$ on $[0, 3]$ with breakpoints $0, 1, 2, 3$ by weights $lambda_0, dots, lambda_3$.
  - $x = $ #blank(w: 9em), $y = $ #blank(w: 9em), $sum lambda_k = 1$.
  - In a _minimization_ with $+ x^2$ in the objective, SOS2 needed? #blank(w: 3em). In a minimization with $- x^2$? #blank(w: 3em).
  - With $lambda_1 = lambda_2 = 0.5$: $x = $ #blank(), $y = $ #blank(), true $x^2 = $ #blank().
]

#stopbox("ch9-b")[
  + What is a separable function? Is $x_1 x_2$ separable?
  + When is the adjacency condition automatically satisfied?
  + How many binaries $delta$ does the SOS2 encoding of 5 weights need?
]

== Making things separable

Many non-separable functions can be rewritten. The product of two variables is the classic case:
$ x_1 x_2 = u_1^2 - u_2^2 quad "with" quad u_1 = (x_1 + x_2) slash 2, quad u_2 = (x_1 - x_2) slash 2. $
Check: $u_1^2 - u_2^2 = (u_1 - u_2)(u_1 + u_2) = x_2 x_1$. Now $u_1^2$ and $-u_2^2$ are one-variable terms that can be approximated piecewise — note that $-u_2^2$ is concave, so an SOS2 is needed for it in a minimization. Products of more variables are reduced two at a time. And when one factor is binary, no approximation is needed at all: Chapter 6 linearized $x_1 dots x_k y$ exactly.

#tip(label: [The chapter in five lines])[
  + Non-linear programs are much harder than linear ones; linearize exactly whenever possible.
  + Convex program = convex objective (minimized) over a convex region; there, local minima are global.
  + Separable programs can be approximated by LPs: $x = sum lambda_k b_k$, $y = sum lambda_k f(b_k)$, $sum lambda_k = 1$.
  + Convex case: adjacency of the $lambda$'s comes for free; non-convex case: impose SOS2 (solver feature or binaries $delta$).
  + $x_1 x_2 = u_1^2 - u_2^2$ makes a product separable; products with binaries are linearized exactly.
]

== Exercises

#chapter-time()

=== Warm-up

#exercise("ch9-w1", time: 4, tier: "warm")[Linear or not? (a) $x + y + 1$; (b) $x y + x$; (c) $x slash y + y$; (d) $|x| + |y| + 1$; (e) $sqrt(x) + 2x$; (f) $e^x - y$; (g) $min(x, y) - 1$; (h) $0$.]

#exercise("ch9-w2", time: 4, tier: "warm")[Convex or not on the given set? (a) $x^2$ on $RR$; (b) $-x^2$ on $RR$; (c) $x^3$ on $[0, infinity)$; (d) $x^3$ on $RR$; (e) $e^x$ on $RR$; (f) $ln x$ on $(0, infinity)$.]

=== Practice

#exercise("ch9-p1", time: 10)[Write the slides' approximate model of $min x - x^3 + z$ (same polygon, breakpoints $0, 1, 1.5, 2$) and the binary SOS2 encoding of its four weights.]

#exercise("ch9-p2", time: 8)[Show that $x_1 x_2 = u_1^2 - u_2^2$ with $u_1, u_2$ as in §9.4, and check it for $x_1 = 3$, $x_2 = -1$. Which of the two new terms is convex?]

#exercise("ch9-p3", time: 6)[A concave cost (economies of scale) appears in a minimization. Explain with a picture why the LP approximation without adjacency underestimates the cost.]

=== Exam level

_Never examined so far; written in the style of the finals._

#exercise("nlp-new-exam", source: "new, exam style", time: 20, tier: "exam")[A shop needs 50 tons of coffee. Supplier B sells at 6.5 €/t. Supplier A gives volume discounts: its cost is the piecewise linear function through $(0, 0)$, $(10, 100)$, $(30, 220)$, $(60, 370)$ (tons, €), and it sells at most 60 t. (a) Is A's cost function convex or concave? Justify with its slopes. (b) Write the $lambda$-formulation of the problem of buying the 50 tons at minimum cost. (c) Solve the LP _without_ the adjacency condition and say why its answer is wrong. (d) Give the true optimum and the binary constraints that would make the LP return it.]

=== Spaced review

_From Chapters 4–8._

#exercise("ch9-r1", source: "review of Ch. 8", time: 4, tier: "review")[A relaxation of a maximization gives 41.5 with $x_2 = 6.5$; the incumbent is 41. Branch or prune?]

#exercise("ch9-r2", source: "review of Ch. 6", time: 4, tier: "review")[Linearize $w = x y$ with $x in {0, 1}$ and $0 <= y <= 8$.]
