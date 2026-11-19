#import "../template.typ": *

= Solving MILPs: branch & bound and cutting planes

#symbols(
  ($P_0$, [the original MILP; $P_1, P_2, dots$ its subproblems]),
  ($"LP"(P)$, [the LP relaxation of $P$: the same problem without integrality]),
  ($beta_j$, [value of $x_j$ in the optimal solution of the relaxation]),
  ($floor(beta), ceil(beta)$, [round down, round up]),
  ($Z$, [cost of the best integer solution found so far (the incumbent)]),
  ($"frac"(a) = a - floor(a)$, [fractional part, always in $[0, 1)$; $"frac"(-1 slash 8) = 7 slash 8$]),
  ($h^T x <= k$, [a cut]),
)

#pretest("ch8")[The LP relaxation of $max x + y$, $-2x + 2y >= 1$, $-8x + 10y <= 13$, $x, y >= 0$ has its optimum at $(4, 4.5)$, value 8.5. Guess the optimal _integer_ solution. Is it near $(4, 4.5)$?]

Chapter 5 promised that integer variables are expensive. Here is why, and what solvers do about it. The answer is an old idea: solve LPs (which is fast), and when their solutions are fractional, split the problem in two and recurse. The exam asks only the first step of this recursion (January 2025 and 2026, Q1(d)), but understanding the whole tree is what makes that step obvious. #slidenote(deck: "Solving MILPs", where: "slide 5", says: [“Integer Programming is NP-complete problem”.], correct: [The decision version ("is there an integer solution with cost $<= k$?") is NP-complete; the optimization problem is NP-hard.], why: [NP-completeness is defined for yes/no questions. Harmless, but say "NP-hard" in an answer.])

== Relaxations and why rounding fails

#fig("/figures/bb-region.svg", caption: [The LP optimum $(4, 4.5)$ is far from the integer optimum $(1, 2)$: no rounding of it is even feasible. Two cuts are drawn (§8.4).], margin: true)A mixed integer linear program (MILP) is an LP plus *integrality constraints* $x_i in ZZ$ for $i in I$. Dropping them gives its *LP relaxation*. Because the relaxation has more solutions, its optimum is at least as good: for a maximization, $"opt"(P) <= "opt"("LP"(P))$. The relaxation is a *bound*.

#revisit("ch8")[Look at the figure above. The feasible region is a thin sliver between two almost parallel lines, and the only integer points inside are $(0, 1)$ and $(1, 2)$. The relaxation's optimum $(4, 4.5)$ rounds to $(4, 4)$ or $(4, 5)$, both infeasible, and the true optimum $(1, 2)$ with value 3 is nowhere near. Rounding is not an algorithm. The integer optimum is $(1, 2)$ with value 3 — far from $(4, 4.5)$, with value 8.5. In thin regions, integer optima can be anywhere along the sliver.]

Integer programming is NP-hard (its decision version is NP-complete), while LPs are solvable in polynomial time. Do not expect a fast exact method for all instances; expect a method that is fast on many.

== Branch & bound

Solve $"LP"(P_0)$ and get $beta$. If every integer variable has an integer value, $beta$ is optimal for $P_0$ too — done. Otherwise pick an integer variable $x_j$ with fractional $beta_j$ and *branch*:
$ P_1 := P_0 and x_j <= floor(beta_j), quad P_2 := P_0 and x_j >= ceil(beta_j). $
No integer solution is lost (an integer $x_j$ is either $<= floor(beta_j)$ or $>= ceil(beta_j)$), and $beta$ is excluded from both. Solve the two subproblems the same way: this builds a binary tree whose leaves are pending problems.

A pending problem $P$ is *pruned* (fathomed) — not split further — in three cases:
+ $"LP"(P)$ is *infeasible*: so is $P$.
+ $"LP"(P)$ has an *integer* optimum: it is a candidate; keep it if it beats the incumbent $Z$.
+ *By bound*: $"LP"(P)$ is no better than the incumbent. Minimizing, if $"cost"("LP"(P)) >= Z$ then every solution below $P$ costs $>= Z$; maximizing, if $"value"("LP"(P)) <= Z$.

The third rule is what makes branch & bound practical: an early good solution prunes large parts of the tree.

```pseudo
S := {P0};  Z := +infinity        // minimization version
while S is not empty:
    remove a problem P from S
    solve LP(P)
    if LP(P) infeasible: continue         // prune
    let beta be its optimal basic solution
    if beta is integral on I:
        if cost(beta) < Z: store beta; Z := cost(beta)
    else if cost(LP(P)) >= Z: continue    // prune by bound
    else: pick j in I with beta_j fractional
          S := S + { P and x_j <= floor(beta_j),
                     P and x_j >= ceil(beta_j) }
return Z
```

#fig("/figures/bb-tree.svg", caption: [The tree of the slides' example, branching on the fractional variable each time. Grey nodes are infeasible. Each child's value is no better than its parent's.], width: 95%)

#example[The slides' example, node by node][
  $max x + y$, $-2x + 2y >= 1$, $-8x + 10y <= 13$, $x, y >= 0$ integer. Root: $(4, 4.5)$, value 8.5. Branch on $y$: $y >= 5$ is infeasible; $y <= 4$ gives $(3.5, 4)$, 7.5. Branch on $x$: $x >= 4$ infeasible; $x <= 3$ gives $(3, 3.7)$, 6.7. Then $y >= 4$ infeasible, $y <= 3$: $(2.5, 3)$, 5.5; $x >= 3$ infeasible, $x <= 2$: $(2, 2.9)$, 4.9; $y >= 3$ infeasible, $y <= 2$: $(1.5, 2)$, 3.5; $x >= 2$ infeasible, $x <= 1$: $(1, 2)$, value 3, integer. No pending problems remain: the optimum is $(1, 2)$ with value 3. The tree walks down the sliver one unit at a time, which is why the sliver is a bad case.
]

#example[Pruning by bound][
  $max 2x + 3y$ s.t. $x + 2y <= 5$, $2x + y <= 5$, $x, y >= 0$ integer. Root: $x = y = 5 slash 3$, value $25 slash 3 approx 8.33$. Branch on $y$. Child $y >= 2$: optimum $(1, 2)$, value 8, integer — incumbent $Z = 8$. Child $y <= 1$: optimum $(2, 1)$, value 7. It happens to be integer, but even if it were not, $7 <= 8 = Z$ prunes it: nothing below can beat 8. Optimum: $(1, 2)$, value 8. #slidenote(deck: "Solving MILPs", where: "slide 47", says: [The CPLEX log for $max 2x + 3y$ at $x = y = 1.666667$ reads "Objective = 4.1666666667".], correct: [$2 dot 5/3 + 3 dot 5/3 = 25/3 approx 8.3333$.], why: [The printed value is half the correct one (it would be the value of $x + 1.5y$); the rest of the example, 8 and 7, is right.])
]

=== Choices and termination

Two choices are free: *which pending problem* to solve next (depth-first finds integer solutions early and uses little memory; best-first — the pending problem with the best relaxation bound — proves optimality with fewer nodes; breadth-first is rarely used) and *which fractional variable* to branch on (closest to $0.5$, most important, e.g. a binary that decides a structure, largest coefficient…). No rule is best for every problem.

Branch & bound terminates when integer variables are *bounded*: every branch shrinks a finite domain. Without bounds it may run forever: $min 0$ s.t. $1 <= 3x - 3y <= 2$, $x, y$ integer, is infeasible ($3(x - y)$ is a multiple of 3), yet each relaxation has a fractional solution ($x = 2 slash 3$, then $y = 1 slash 3$, then $x = 5 slash 3$, …) and the tree never ends.

The *gap* reported by CPLEX is the relative distance between the incumbent $Z$ and the best bound among pending problems. `epgap = 0.01` (Chapter 2) stops when it is below 1 %: the incumbent is then proven within 1 % of the optimum.

#stopbox("ch8-a")[
  + Name the three reasons to prune a node.
  + In a maximization, the incumbent is 20 and a pending node's relaxation is 19.5. What do you do?
  + Why does branching on $x_j <= floor(beta_j)$ and $x_j >= ceil(beta_j)$ lose no integer solution?
]

== The exam question: do we need to branch?

The January versions of Q1 add: "assume all variables are integer and we apply branch & bound. Do we need to branch? If so, indicate all variables that can be branched on, and the subproblems obtained in each case." The answer has three parts:

+ *Need to branch?* Yes if the optimal basic solution (all variables, basic and non-basic) has a fractional value; no if it is integral (then it is optimal for the integer problem).
+ *Candidates:* exactly the variables with fractional values. Non-basic variables are 0 — never candidates.
+ *Subproblems:* for each candidate $x_j = beta_j$, the original problem plus $x_j <= floor(beta_j)$, and the original problem plus $x_j >= ceil(beta_j)$.

For instance, if the optimum has $x_3 = 1 slash 3$ and $x_2 = 2 slash 3$, both can be branched on: $x_3 <= 0$ / $x_3 >= 1$, or $x_2 <= 0$ / $x_2 >= 1$. A value like $x_2 = 3 slash 2$ gives $x_2 <= 1$ / $x_2 >= 2$ — do not write $x_2 <= 1.5$.

#stopbox("ch8-b")[
  + The relaxation's optimum is $x_0 = 0$, $x_1 = 7 slash 4$, $x_2 = 2$, $x_3 = 0$. Which variables can be branched on, and what are the subproblems?
  + Why is a non-basic variable never a branching candidate in this question?
]

== Cutting planes

Instead of splitting, we can *cut*: add a linear inequality that every integer solution satisfies but the current fractional optimum violates. Formally, if $w$ is feasible for the relaxation but not for the MILP, a *cut* for $w$ is $h^T x <= k$ with $h^T s <= k$ for every feasible integer $s$ and $h^T w > k$. The feasible integer set does not change; the relaxation gets tighter. In practice solvers combine both: *branch & cut* adds cuts while useful, then branches.

=== Gomory's fractional cut

Take a row of the optimal tableau of a pure integer problem (all variables, slacks included, integer), written with all variables on the left:
$ x_(B_i) + sum_j a_j x_j = beta_i quad "with" beta_i "fractional". $
Since the variables are non-negative integers and $x_(B_i)$ is an integer, taking fractional parts gives the *Gomory cut*
$ sum_j "frac"(a_j) x_j >= "frac"(beta_i). $
It holds for every integer solution and is violated by the current one (there all non-basic $x_j = 0$, so the left side is $0 < "frac"(beta_i)$).

#example[A Gomory cut for the sliver][
  In canonical form the slides' example is $min -x - y$, $-2x + 2y - s_1 = 1$, $-8x + 10y + s_2 = 13$. At the optimum the $y$ row is $y = 9/2 - 2 s_1 - 1/2 s_2$, i.e. $y + 2 s_1 + 1/2 s_2 = 9 slash 2$. Fractional parts: $0 dot s_1 + 1/2 s_2 >= 1/2$, so $s_2 >= 1$, i.e. $-8x + 10 y <= 12$. It cuts off $(4, 4.5)$ (where $-32 + 45 = 13$) and keeps both integer points. #slidenote(deck: "Solving MILPs", where: "slides 59–62", says: [From $y - 4 = 1/2 - 2 s_1 - 1/2 s_2$: "$-2 s_1 - 1/2 s_2 <= 0$, so $y - 4 < 1$, hence $y <= 4$", called a Gomory cut.], correct: [The cut $y <= 4$ is valid, but the argument only works because every non-basic coefficient in that row has the same sign. The general Gomory cut is $sum "frac"(a_j) x_j >= "frac"(beta)$; here it gives $-8x + 10y <= 12$.], why: [With mixed signs, "the rest is $<= 0$" fails and the shortcut produces nothing; the fractional-part rule always works.])
]

#yourturn("ch8-yt1")[
  $max 5x + 4y$, $6x + 4y + s_1 = 24$, $x + 2y + s_2 = 6$, all integer. At the LP optimum the $y$ row is $y = 3/2 + 1/8 s_1 - 3/4 s_2$.
  - With all variables on the left: $y$ #blank(w: 4em) $s_1$ #blank(w: 4em) $s_2 = 3 slash 2$.
  - Fractional parts: $"frac"(-1 slash 8) = $ #blank(), $"frac"(3 slash 4) = $ #blank(), $"frac"(3 slash 2) = $ #blank().
  - Cut in slacks: #blank(w: 10em). Substituting $s_1 = 24 - 6x - 4y$, $s_2 = 6 - x - 2y$: #blank(w: 8em).
]

#summary[
  + The LP relaxation bounds the MILP; rounding its solution can be infeasible or far from optimal.
  + Branch on a fractional $x_j = beta_j$: $x_j <= floor(beta_j)$ or $x_j >= ceil(beta_j)$.
  + Prune when the relaxation is infeasible, integral, or not better than the incumbent.
  + Exam Q1(d): branch iff some variable is fractional; candidates are exactly the fractional ones; give both subproblems for each.
  + Gomory cut from a tableau row: $sum "frac"(a_j) x_j >= "frac"(beta)$; branch & cut mixes cuts and branching.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch8-w1", time: 3, tier: "warm")[A relaxation has optimum $x = (2, 0, 5 slash 2, 1)$ for a pure integer problem. Do we need to branch? On which variable, and with which subproblems?]

#exercise("ch8-w2", time: 3, tier: "warm")[Minimizing, the incumbent costs 40. Pending nodes have relaxation values 37, 40 and 45. Which can be pruned?]

#tier("practice")

#exercise("bb-new-tree", source: "new", time: 20)[Solve $max 5x + 4y$ s.t. $6x + 4y <= 24$, $x + 2y <= 6$, $x, y >= 0$ integer by branch & bound, solving each relaxation graphically or by checking its corners. Explore the child "$>=$" first and prune by bound when you can. Draw the tree.]

#exercise("ch8-p2", time: 8)[In the slides' example the optimal tableau also has the row $x = 4 - 5/2 s_1 - 1/2 s_2$. Try to derive a Gomory cut from it. What happens, and why? Then check that the cut $-8x + 10y <= 12$ of Worked example 8.3 is satisfied by the integer points $(0, 1)$ and $(1, 2)$ and violated by $(4, 4.5)$.]

#exercise("ch8-p3", time: 6)[Explain why branch & bound can run forever on $min 0$ s.t. $1 <= 3x - 3y <= 2$, $x, y >= 0$ integer, and how adding bounds $x, y <= 10$ fixes it.]

#tier("exam", note: [Q1(d) of the January exams and two look-alikes])

#exercise("jan25-q1d", source: "Final Jan 2025 · Q1(d)", time: 5, tier: "exam")[For the LP of #exref("jan25-q1abc"), assume now all variables are integer and we apply branch & bound. Do we need to branch? If so, indicate all variables that can be branched on and the subproblems obtained in each case.]

#exercise("jan26-q1d", source: "Final Jan 2026 · Q1(d)", time: 5, tier: "exam")[The same question for the LP of #exref("jan26-q1abc").]

#exercise("bb-new-j1", source: "new, exam style", time: 12, tier: "exam")[$min x_0 + x_1 + 2 x_2$ s.t. $-2 x_0 - x_1 + x_2 = 1$, $2 x_0 - x_1 - x_2 - 2 x_3 = -2$, $x >= 0$. (a) Show that $(x_2, x_3)$ is a feasible basis and give the basic solution and objective value. (b) Justify that it is optimal, giving the reduced costs. (c) If all variables are integer, do we need to branch? On which variables, with which subproblems?]

#exercise("bb-new-j3", source: "new, exam style", time: 12, tier: "exam")[$min x_1 - 2 x_2 - x_3$ s.t. $x_0 - x_1 - 2 x_2 - 2 x_3 = -2$, $2 x_0 - x_1 - 2 x_2 + 2 x_3 = 1$, $x >= 0$; basis $(x_0, x_2)$. Answer (a)–(c) of the previous exercise.]

#tier("review", note: [from Chapters 5–7])

#exercise("ch8-r1", source: "review of Ch. 7", time: 4, tier: "review")[Write the non-overlap constraints for tasks 1 (duration 3) and 2 (duration 2), horizon 20.]

#exercise("ch8-r2", source: "review of Ch. 6", time: 4, tier: "review")[Why does a weak big-M make branch & bound slower? Answer using the word "relaxation".]
