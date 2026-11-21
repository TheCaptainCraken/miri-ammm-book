#import "../template.typ": *

= Integer models I: binary decisions

#symbols(
  ($x_(i j) in {0, 1}$, [assignment variable: 1 if $i$ is assigned to $j$]),
  ($u_k in {0, 1}$, [usage variable: 1 if resource (colour, class, plan…) $k$ is used]),
  ($y_(i j)$, [pair variable for an unordered pair ${i, j}$, written with $i < j$]),
  ($overline(x) = 1 - x$, [the negation of a binary $x$, used to write logic linearly]),
  ($V, E$, [vertices and edges of a graph $G = (V, E)$]),
  ($n, m$, [sizes of the two sets in the story (they change meaning from exercise to exercise)]),
)

#pretest("ch5")[Binary $x, y, z$. Write a linear constraint that says "if $x$ and $y$ are both 1, then $z$ must be 1". (Hint: think of when the constraint should bite.)]

Four of the five past question 2s are built only from yes/no decisions: assign each student to a class, choose who has a date with whom, select neighbours to visit, select astronauts. The art is not the arithmetic — it is choosing variables whose meaning is crisp, and then translating each sentence of the story into a linear constraint on them. This chapter collects the translations that recur.

== When variables must be integer

Two kinds of quantity need integers. *Indivisible amounts* — generators running, units of a product that cannot be fractional. And *decisions*: open the depot or not, assign task $t$ to computer $c$ or not. Decisions use *binary* variables, $x in {0, 1}$, read as true/false. A model with some integer variables is a *mixed integer linear program* (MILP); with only binaries, a 0–1 program.

Lab 2 already showed the price: the same capacity constraints, with $x_(t c)$ binary instead of in $[0, 1]$, turned a feasible LP into an infeasible ILP and moved the optimum from 0.7238 to 0.7992. Chapter 8 explains how solvers cope. Here we write models.

== Assignment, selection and counting

Most binary models have one of three skeletons.

*Assignment* — $x_(i j) = 1$ if item $i$ goes to place $j$.
- each item to exactly one place: $sum_j x_(i j) = 1$ for all $i$;
- at most one: $sum_j x_(i j) <= 1$ (items may stay out);
- capacity of place $j$: $sum_i w_i x_(i j) <= W_j$; size limits $l <= sum_i x_(i j) <= u$.

*Selection* — $x_i = 1$ if $i$ is chosen: at least $K$, $sum_i x_i >= K$; exactly $K$; budget $sum_i c_i x_i <= C$.

*Counting comparisons* — sums of binaries are counts, so "as many A as B" is $sum x = sum y$; "the good students at least double the bad ones in class $j$" is $sum_(i in G) x_(i j) >= 2 sum_(i in B) x_(i j)$.

#question(label: [Think first])[A vote passes with a strict majority. You vote YES; $n$ neighbours vote too ($n$ even); $y_i = 1$ if neighbour $i$ votes YES. Which constraint on $sum_i y_i$ guarantees the vote passes?]For the vote: YES votes are $1 + sum_i y_i$ and NO votes are $n - sum_i y_i$. A strict majority needs $1 + sum y > n - sum y$, i.e. $2 sum y > n - 1$; since $sum y$ is an integer and $n$ is even, this is $sum_i y_i >= n slash 2$. Always derive such thresholds by writing YES and NO explicitly: off-by-one errors here are the most common way to lose easy points.

#stopbox("ch5-a")[
  + Write "each task runs on exactly one of the computers" and "each computer runs at most 3 tasks".
  + With $n$ voters in total (you not included) and $n$ odd, what is the majority constraint?
  + Write "class $j$ has at least as many girls ($F$) as boys ($M$)".
]

== Logic with binaries

A binary is a proposition. The translation table below is all you need; derive any other case from it.

#table(align: left, columns: (auto, 1fr, auto), table.header([logic], [meaning], [linear form]),
  [$not x$], [not $x$], [$1 - x$],
  [$x or y$], [at least one], [$x + y >= 1$],
  [$not (x and y)$], [not both], [$x + y <= 1$],
  [$x -> y$], [if $x$ then $y$], [$x <= y$],
  [$x and y -> z$], [if both, then $z$], [$x + y - 1 <= z$],
  [$x -> y and z$], [if $x$, then both], [$x <= y$, $x <= z$],
  [$z <-> x and y$], [$z$ is the AND], [$z <= x$, $z <= y$, $z >= x + y - 1$],
  [$z <-> x or y$], [$z$ is the OR], [$z >= x$, $z >= y$, $z <= x + y$],
  [$or.big_k ell_k$], [a clause of literals], [$sum_k ell_k >= 1$, with $not x$ written $1 - x$],
)

The last line is the general method: write the condition as a clause (a disjunction of variables and negated variables), replace each negated $x$ by $1 - x$ and require the sum to be at least 1. For instance $x and y -> z$ is the clause $not x or not y or z$, i.e. $(1 - x) + (1 - y) + z >= 1$, which is $x + y - 1 <= z$. The official solutions of the exams often write exactly this clause form.

#revisit("ch5")[$x + y - 1 <= z$. If $x = y = 1$ it forces $z >= 1$; in every other case the left side is $<= 0$ and the constraint says nothing. Equivalently $(1 - x) + (1 - y) + z >= 1$.]

#yourturn("ch5-yt1")[
  Five projects; $p_k = 1$ if project $k$ is funded. Write: (a) at most three projects: #blank(w: 8em); (b) if project 1 is funded, so is project 2: #blank(w: 6em); (c) not both 3 and 4: #blank(w: 6em); (d) at least one of 4 and 5: #blank(w: 6em); (e) if 2 and 5 are funded, then 1 is not: #blank(w: 9em).
]

== Linking variables

Often the story's goal is about one kind of variable and its rules about another; *linking constraints* tie them together so that each keeps its meaning.

*Use.* In graph colouring $c_(v k) = 1$ if vertex $v$ gets colour $k$, and $u_k = 1$ if colour $k$ is used at all. "If a vertex has colour $k$, colour $k$ is used" is $c_(v k) <= u_k$. We minimize $sum_k u_k$, so the solver will not switch on a $u_k$ needlessly; the link only has to work in one direction.

*Coverage.* In the January 2026 exam, $x_j = 1$ if you persuade neighbour $j$ and $M_(j i) = 1$ if $j$ can convince $i$. A new variable $y_i$ ("$i$ votes YES") must only be 1 if some selected neighbour influences $i$: $y_i <= sum_j M_(j i) x_j$.

*Pairs.* When the story speaks of pairs — "any two crew members must have collaborated or trained together" — create one variable per unordered pair, $y_(i j)$ with $i < j$, and link it: if both $i$ and $j$ are chosen, they must be trained, $x_i + x_j - 1 <= y_(i j)$. Only create pair variables where they are needed (here, pairs that have _not_ collaborated). #note[Ask of every linking constraint: _which direction does the objective push?_ Only the direction it pushes against needs a constraint.]

#example[Graph colouring as an ILP][
  Given $G = (V, E)$ with $n = |V|$, find the fewest colours so that adjacent vertices differ. At most $n$ colours are ever needed.

  *Variables:* $c_(v k) in {0,1}$, vertex $v$ painted with colour $k$ ($v in V$, $1 <= k <= n$); $u_k in {0, 1}$, colour $k$ used.

  *Objective:* $min sum_(k=1)^n u_k$.

  *Constraints:*
  - each vertex gets exactly one colour: $sum_k c_(v k) = 1$ for all $v in V$;
  - adjacent vertices differ: $c_(v k) + c_(w k) <= 1$ for all ${v, w} in E$ and all $k$;
  - a colour that is painted is used: $c_(v k) <= u_k$ for all $v, k$.

  The slides contrast this with the quadratic version, $c_(v k) c_(w k) = 0$ and $c_(v k)(1 - u_k) = 0$: same problem, same optimal value, but on a random graph with 13 vertices the linear model solves instantly and the quadratic one takes much longer. Linear is worth the effort. (A refinement worth mentioning in an exam: add $u_k >= u_(k+1)$ so that the colours used are $1, 2, dots$; it removes symmetric copies of the same solution and speeds up branch & bound.)
]

#stopbox("ch5-b")[
  + Translate "if $a$ then ($b$ or $c$)" into a linear constraint.
  + Why does $c_(v k) <= u_k$ not need its converse $u_k <= sum_v c_(v k)$ in the colouring model?
  + How many pair variables $y_(i j)$, $i < j$, does a set of 8 candidates have?
]

== How to answer a question 2

The exam asks for variables (when not given), each family of constraints with its meaning, and the objective with its direction. A method that matches the grading:

+ *List the requirements* of the story, one line each (the official heuristics solutions do exactly this: C1, C2, …).
+ *Variables:* use the given ones; add new ones only when a requirement cannot be written with them, and state type and meaning ("binary $y_i$: neighbour $i$ votes YES").
+ *One constraint family per requirement*, with its "for all" and a sentence of meaning.
+ *Objective* and direction.
+ *Check* the extreme cases: what if nobody is selected? What if a class is empty? Does every requirement appear once?

Part (e)/(d) of the exams — "are there other constraints needed to get a correct model?" — is a test of step 5: it hides the most obvious requirement (each student in exactly one class; each man at most one date). Re-read the story looking for "each", "every", "only", "at most".

#tip(label: [The chapter in five lines])[
  + Binary variables encode decisions; sums of binaries count.
  + Assignment: $sum_j x_(i j) = 1$ (or $<= 1$); capacity and size limits on $sum_i$.
  + Logic: write the condition as a clause, replace $not x$ by $1 - x$, require sum $>= 1$; $x -> y$ is $x <= y$, $x and y -> z$ is $x + y - 1 <= z$.
  + Linking constraints keep the meaning of auxiliary variables; only the direction the objective pushes against is needed.
  + Derive thresholds (majorities, doubles) by writing both sides explicitly.
]

== Exercises

#chapter-time()

=== Warm-up

#exercise("ch5-w1", time: 4, tier: "warm")[Binary $a, b, c$. Write linearly: (a) exactly one of them; (b) at most two of them; (c) $a$ if and only if $b$; (d) if $a$ then not $c$.]

#exercise("ch5-w2", time: 4, tier: "warm")[A school has $m$ classes and binary $x_(i j)$ ("student $i$ in class $j$"). Write: student 7 and student 9 are not in the same class.]

=== Practice

#exercise("ilp-sheet-2", source: "ILP sheet · Ex 2", time: 15)[Formulate as a MIP the problem of completing this Sudoku (each row, column and $3 times 3$ box must contain $1, dots, 9$ once):

```
5 3 . | . 7 . | . . .
6 . . | 1 9 5 | . . .
. 9 8 | . . . | . 6 .
8 . . | . 6 . | . . 3
4 . . | 8 . 3 | . . 1
7 . . | . 2 . | . . 6
. 6 . | . . . | 2 8 .
. . . | 4 1 9 | . . 5
. . . | . 8 . | . 7 9
```
]

#exercise("ilp-sheet-5", source: "ILP sheet · Ex 5", time: 10)[Model graph colouring as a MIP, without looking at Worked example 5.1. Then add constraints that break the symmetry between colours, and explain why they do not change the optimal value.]

#exercise("ilp-sheet-3", source: "ILP sheet · Ex 3", time: 20)[Twenty-seven cells form a $3 times 3 times 3$ cube. Three cells lie on the same line if they are on the same horizontal or vertical line or on the same diagonal; diagonals exist on each horizontal and vertical section and between opposite vertices of the cube (49 lines in all). Place 13 white and 14 black balls, one per cell, so as to minimize the number of lines whose three balls have the same colour. Formulate as a MIP.]

=== Exam level

_Three past question 2s; about 25 minutes each._

#exercise("jun25-q2be", source: "Final Jun 2025 · Q2(b–e)", time: 22, tier: "exam")[The "First Dates" problem of #exref("jun25-q2a") ($n$ men, $m$ women, scores $f_(i j)$ and $s_(i j)$, binaries $x_(i j)$ "date, man first" and $y_(i j)$ "date, man second"). (b) Express the objective function as a linear function and give the direction. (c) Give linear constraints expressing that exactly as many men as women confess first. (d) Let $I$ and $J$ be the men and women who are past participants; at least one past participant (man or woman) must be chosen. Give a linear constraint. (e) Are other linear constraints needed for a correct ILP model? If so, give their meaning and formal description (and any extra variables).]

#exercise("jan26-q2", source: "Final Jan 2026 · Q2", time: 25, tier: "exam")[You own a flat in Barcelona and want the homeowners' meeting to approve solar panels. Not counting you there are $n$ homeowners ($n$ even). An $n times n$ binary matrix $M$ says that for $i != j$, $M_(i j) = 1$ if neighbour $i$ can convince neighbour $j$ to vote in favour ($M_(i i) = 1$ by convention). You will persuade some neighbours yourself, and they will convince the ones they influence. Decisions need strictly more YES than NO votes; the only votes are YES and NO, and absent owners count as NO. Visiting neighbour $i$ takes you $T_i$ time. Which neighbours should you visit to ensure approval with the least of your time? Binary $x_i$: "neighbour $i$ is selected". (Integer division `/` rounds down.) (a) Give the objective and its direction; add variables and constraints if needed, with type and meaning. (b) Give the linear constraints of the model, formally and with their meaning; add variables if needed.]

#exercise("jun26-q2", source: "Final Jun 2026 · Q2", time: 25, tier: "exam")[A new ISS crew is chosen from $N$ candidates ($1, dots, N$). The crew needs at least $K$ astronauts, and any two crew members must have collaborated before or have been trained together. $E$ is the list of pairs ${i, j}$ who worked together in an earlier mission. A training course for the pair $i, j$ costs $c_(i j)$ € and gives them the same congeniality. An astronaut can follow at most $M$ courses. Choose the crew minimizing costs. (a) Define the variables, their types and meaning. (b) Give the linear constraints, formally and with meaning. (c) Give the objective and the direction of optimization.]

=== Spaced review

_From Chapters 1–4._

#exercise("ch5-r1", source: "review of Ch. 4", time: 8, tier: "review")[$min x_0 + x_2$ s.t. $x_0 + x_1 - x_2 = 3$, $x_0 - x_1 + x_3 = 1$, $x >= 0$, basis $(x_0, x_1)$. Give the basic solution, objective value and reduced costs. Is it optimal? If not, do the ratio test.]

#exercise("ch5-r2", source: "review of Ch. 2", time: 4, tier: "review")[Write in OPL: for all pairs $i < j$ of $1..N$ with `E[i][j] == 0`, $x_i + x_j - 1 <= y_(i j)$.]
