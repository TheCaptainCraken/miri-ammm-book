#import "../template.typ": *

= Bases, vertices and basic solutions

#symbols(
  ($A, b, c$, [constraint matrix ($m times n$), right-hand side ($m$), cost vector ($n$)]),
  ($a_j$, [column $j$ of $A$ — the column of variable $x_j$]),
  ($s_i$, [slack variable of constraint $i$]),
  ($B$, [basis: an invertible $m times m$ matrix made of $m$ columns of $A$]),
  ($R$, [the remaining columns ("rest"), so that $A x = B x_B + R x_R$]),
  ($x_B, x_R$, [basic and non-basic variables]),
  ($B^(-1)$, [inverse of $B$; for $2 times 2$: $mat(a, b; c, d)^(-1) = 1/(a d - b c) mat(d, -b; -c, a)$]),
)

#pretest("ch3")[The LP $max x + 2y$ with $x + y <= 3$, $x <= 2$, $y <= 2$, $x, y >= 0$ gets three slack variables, so it has 5 variables and 3 equations. In how many ways can you pick 3 of the 5 variables? How many of those choices do you think correspond to corners of the feasible polygon?]

Draw the feasible region of the pretest LP (left of Figure 3.1). It is a polygon with five corners. Slide a level line $x + 2y = "const"$ outward: the last point it touches is a corner, $(1, 2)$. That picture is the whole idea of this chapter and the next: *optimal solutions of an LP can be found at corners*, and the simplex method is an algebraic way of walking from corner to corner. To walk algebraically we first need to say "corner" algebraically. That word is *basis*.

#figure(image("/figures/lp-region.svg"), caption: [Left: the level lines of $x + 2y$ slide outward until the last feasible point, a corner. Right: every corner is the basic solution of a basis (the basic variables are listed).])

== One standard form for every LP

Algorithms want a single format. The slides call it *canonical form*:
$ min c^T x quad "s.t." quad A x = b, quad x >= 0, $
with $A$ an $m times n$ matrix of rank $m$ (no redundant equation) and $n >= m$. Any LP can be brought to this form by four mechanical steps.

+ *Max to min.* $max f(x) = -min(-f(x))$: negate the objective, solve, negate the value.
+ *Equalities to inequalities* (only needed to reach "all $<=$"): $a^T x = b$ becomes $a^T x <= b$ and $a^T x >= b$.
+ *$>=$ to $<=$*: multiply by $-1$.
+ *Free variables*: replace a free $x$ by $x^+ - x^-$ with $x^+, x^- >= 0$. Only variables that are not already non-negative need it.
+ *Inequalities to equalities*: add a *slack* $s_i >= 0$ to each $<=$: $a_i^T x + s_i = b_i$. (Subtracting a "surplus" from a $>=$ row is the same thing after step 3.)

The slack measures the unused amount of a resource: in the factory, the drilling slack at the optimum is $192 - 177.6 = 14.4$ hours.

#example[Canonical form][
  $max x + 2y$ s.t. $x + y <= 3$, $x <= 2$, $y <= 2$, $x, y >= 0$ becomes
  $ min -x - 2y quad "s.t." quad & x + y + s_1 = 3, quad x + s_2 = 2, quad y + s_3 = 2, \
  & x, y, s_1, s_2, s_3 >= 0. $
  Here $n = 5$, $m = 3$; the slack columns form the identity matrix, so the rank is 3 automatically.
]

The exam LPs are already in canonical form ($min$, equations, $x >= 0$), so in practice you will only use this section to read slides and to check your own models.

=== Words that mean different things

A *solution* is any $x$ with $A x = b$; it is *feasible* if also $x >= 0$; an LP is *feasible* if it has a feasible solution and *infeasible* otherwise. A feasible $x^*$ is *optimal* if no feasible $x$ has a better objective value — for a minimization $c^T x^* <= c^T x$, for a maximization $>=$.

#slidenote(deck: "Basics on LP", where: "slides 17–20", says: [“$x^*$ is optimal if $c^T x^* <= c^T x$ for all feasible $x$”, followed by examples that _maximize_ $x + 2y$.], correct: [$<=$ for minimization; $>=$ for maximization (or first convert max to min).], why: [The definition is stated for the canonical (min) form; the examples keep the original max.])An LP is *unbounded* when it is feasible but has no optimal solution, because the objective can be improved without limit. Careful: a feasible _region_ can be unbounded (no box contains it) while the LP still has an optimum — maximize $x + 2y$ over $x + y <= 3$, $0 <= x <= 2$, $y <= 2$ with $y$ free: the region extends downward forever, but the optimum is $(1, 2)$.

*Fundamental theorem of LP.* For every LP exactly one of the following holds: it is infeasible; it is unbounded; it has an optimal _basic feasible_ solution. So it suffices to look at basic feasible solutions — which we now define.

#stopbox("ch3-a")[
  + Bring to canonical form: $max 2x - y$ s.t. $x - y >= -1$, $x <= 4$, $x >= 0$, $y$ free.
  + Can an LP with an unbounded feasible region have an optimal solution? Give a one-line example.
  + What does a slack variable measure?
]

== Bases and basic solutions

Number the columns of $A$: $a_1, dots, a_n$, one per variable. Pick $m$ of them and put them side by side in a square matrix $B$. If $B$ is invertible, it is called a *basis*, the chosen variables are *basic* ($x_B$) and the others *non-basic* ($x_R$, with columns $R$). Then $A x = b$ reads $B x_B + R x_R = b$, and multiplying by $B^(-1)$:
$ x_B = B^(-1) b - B^(-1) R thin x_R. $
This expresses the basic variables as functions of the non-basic ones. Setting the non-basic variables to 0 gives the *basic solution* of $B$:
$ x_R = 0, quad x_B = B^(-1) b. $

#definition[Basic feasible solution][The basic solution of a basis $B$ is feasible if $x_B = B^(-1) b >= 0$; then $B$ is a *feasible basis*. If some basic variable equals 0, the basis is *degenerate*.]

#question(label: [Think first])[Why is "set the non-basic variables to zero" the algebraic version of "stand on a corner"?]Geometrically, a non-basic variable at 0 means "this inequality is tight" (a slack at 0) or "this variable sits on its bound" ($x = 0$). With $n - m$ of them at zero we are at the intersection of $n - m$ boundary lines — a corner, if it is feasible. Figure 3.1 (right) labels each corner of the polygon with its basis.

#example[Three bases of the same LP][
  System: $x + y + s_1 = 3$, $x + s_2 = 2$, $y + s_3 = 2$.

  *Basis $(s_1, s_2, s_3)$.* $B$ is the identity, so the tableau is read off directly: $s_1 = 3 - x - y$, $s_2 = 2 - x$, $s_3 = 2 - y$. Basic solution $(s_1, s_2, s_3) = (3, 2, 2)$, $x = y = 0$: feasible, the corner $(0, 0)$.

  *Basis $(x, y, s_1)$.* Solve the equations for $x, y, s_1$: from the second and third, $x = 2 - s_2$ and $y = 2 - s_3$; then $s_1 = 3 - x - y = -1 + s_2 + s_3$. Basic solution $x = 2$, $y = 2$, $s_1 = -1$: *infeasible* ($s_1 < 0$) — the point $(2, 2)$ violates $x + y <= 3$.

  *Basis $(x, s_1, s_2)$.* The columns are $(1, 1, 0)$, $(1, 0, 0)$, $(0, 1, 0)$: all have a 0 in the third row, so $B$ is singular and this is *not* a basis. (No choice of $x, s_1, s_2$ can satisfy $y + s_3 = 2$ with $y = s_3 = 0$.)
]

Of the $binom(5, 3) = 10$ ways to choose three variables, two are singular, three give infeasible basic solutions and five give the five corners.

#revisit("ch3")[$binom(5, 3) = 10$ choices: $(x, s_1, s_2)$ and $(y, s_1, s_3)$ are singular; $(x, y, s_1)$, $(x, s_2, s_3)$ and $(y, s_2, s_3)$ are infeasible; the other five are exactly the five corners. In general, feasible bases ↔ corners (several bases can share a corner when it is degenerate).]

=== Computing a basic solution by hand

The exam gives a $2 times 4$ system and two basic variables. Do not invert matrices unless you like it: *solve the two equations for the two basic variables*, keeping the non-basic ones as symbols. You then have the full tableau, which Chapter 4 needs anyway.

#example[A $2 times 2$ basis][
  System: $-x_0 + x_1 + x_3 = -2$, $-x_0 + 2 x_1 + x_2 + x_3 = 1$. Basis $(x_0, x_1)$.

  Subtract the first equation from the second: $x_1 + x_2 = 3$, so $x_1 = 3 - x_2$. Put it in the first: $-x_0 + 3 - x_2 + x_3 = -2$, so $x_0 = 5 - x_2 + x_3$.

  Tableau: $x_0 = 5 - x_2 + x_3$, $x_1 = 3 - x_2$. Basic solution: $x_0 = 5$, $x_1 = 3$, $x_2 = x_3 = 0$. Feasible and not degenerate.

  Check with the formula: $B = mat(-1, 1; -1, 2)$, $det B = -2 + 1 = -1$, $B^(-1) = mat(-2, 1; -1, 1)$, $B^(-1) b = mat(-2, 1; -1, 1) mat(-2; 1) = mat(5; 3)$. Same answer.
]

Always check your basic solution by plugging it back into _both_ original equations: here $-5 + 3 = -2$ and $-5 + 6 = 1$. It takes ten seconds and catches most sign errors.

#yourturn("ch3-yt1")[
  Same system, basis $(x_0, x_2)$. From the first equation $x_0 =$ #blank(w: 6em). Substituting into the second gives $x_2 =$ #blank(w: 6em). Basic solution: $x_0 =$ #blank(), $x_2 =$ #blank(); feasible? #blank(w: 3em)
]

=== Degeneracy

Change the first constraint to $x + y + s_1 = 4$. The corner $(2, 2)$ is now feasible and three lines pass through it ($x + y = 4$, $x = 2$, $y = 2$). Each of the bases $(x, y, s_1)$, $(x, y, s_2)$, $(x, y, s_3)$ has $x = y = 2$ and one basic variable equal to 0: three degenerate bases, one corner. Degeneracy is harmless for reading a tableau, but it is what can make the simplex method stall (Chapter 4).

#stopbox("ch3-b")[
  + State the formula of the basic solution of a basis $B$.
  + When is a basis feasible? When is it degenerate?
  + How many bases can an LP with $n$ variables and $m$ equations have at most?
]

#tip(label: [The chapter in five lines])[
  + Canonical form: $min c^T x$, $A x = b$, $x >= 0$; reach it with max→min, ×(−1), $x = x^+ - x^-$ and slacks.
  + A basis is an invertible choice of $m$ columns; $x_B = B^(-1) b - B^(-1) R x_R$ is its tableau.
  + Basic solution: non-basic variables at 0, $x_B = B^(-1) b$; feasible if $>= 0$, degenerate if some basic value is 0.
  + Feasible bases are the corners of the feasible region; several degenerate bases may share one corner.
  + By hand, solve the equations for the basic variables, then plug the values back in to check.
]

== Exercises

#chapter-time()

=== Warm-up

#exercise("ch3-w1", time: 5, tier: "warm")[Bring to canonical form: $max 3x - y$ s.t. $x + 2y <= 4$, $x - y >= -1$, $x >= 0$, $y$ free.]

#exercise("ch3-w2", time: 3, tier: "warm")[Invert $mat(2, 1; 1, 1)$ and $mat(0, -2; -2, 0)$.]

#exercise("ch3-w3", time: 4, tier: "warm")[True or false? (a) Every solution of $A x = b$ is feasible. (b) A basic solution has at most $m$ non-zero variables. (c) An unbounded LP has an unbounded feasible region. (d) An unbounded feasible region implies an unbounded LP.]

=== Practice

#exercise("ch3-p1", time: 10)[For the system $x + y + s_1 = 3$, $x + s_2 = 2$, $y + s_3 = 2$, compute the basic solutions of $(x, y, s_2)$, $(x, y, s_3)$, $(x, s_1, s_3)$, $(x, s_2, s_3)$ and $(y, s_2, s_3)$. Classify each as feasible or infeasible and match the feasible ones with the corners in Figure 3.1.]

#exercise("ch3-p2", time: 8)[For the system $-x_0 + x_1 + x_3 = -2$, $-x_0 + 2x_1 + x_2 + x_3 = 1$, examine all six pairs of variables: which are bases, and which bases are feasible?]

#exercise("ch3-p3", time: 6)[Replace the first equation of the polygon LP by $x + y + s_1 = 4$. List every basis whose basic solution is the point $x = y = 2$, and say why each of them is degenerate.]

=== Exam level

#exercise("ch3-e1", source: "new, exam style", time: 8, tier: "exam")[Consider $min x_1 - x_3$ s.t. $2 x_0 + x_1 - x_2 = 2$, $x_0 - x_2 + x_3 = 2$, $x >= 0$. (a) Show that $(x_0, x_3)$ is a feasible basis and give the basic solution and the objective value. (b) Is $(x_1, x_2)$ a feasible basis?]

=== Spaced review

_From Chapters 1–2._

#exercise("ch3-r1", source: "review of Ch. 1", time: 3, tier: "review")["The average quality of the blend must be at least 0.9", with $x_i$ tons of ore of quality $q_i$. Write it linearly.]

#exercise("ch3-r2", source: "review of Ch. 2", time: 3, tier: "review")[Write the OPL declaration of a free real variable $a$ and of non-negative reals $e[k]$ for $k in 1..19$.]
