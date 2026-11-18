#import "../template.typ": *

== Chapter 8

#answer("ch8-yt1")[$y - frac(1,8) s_1 + frac(3,4) s_2 = 3 slash 2$. Fractional parts: $7 slash 8$, $3 slash 4$, $1 slash 2$. Cut: $frac(7,8) s_1 + frac(3,4) s_2 >= frac(1,2)$. Substituting: $frac(7,8)(24 - 6x - 4y) + frac(3,4)(6 - x - 2y) >= frac(1,2)$, i.e. $25.5 - 6x - 5y >= 0.5$: *$6 x + 5 y <= 25$*. It cuts off $(3, 1.5)$ ($18 + 7.5 = 25.5$) and every integer point of the region satisfies it. After adding it, the relaxation's optimum moves to $(10 slash 3, 1)$ with value $62 slash 3$.]

#answer("ch8-a")[(a) Relaxation infeasible; relaxation optimum integral; relaxation not better than the incumbent. (b) Prune it: nothing below it can exceed 19.5, and only integer values $>= 21$ would beat 20 anyway. (c) For an integer $x_j$, either $x_j <= floor(beta_j)$ or $x_j >= floor(beta_j) + 1 = ceil(beta_j)$; there is no integer strictly between.]

#answer("ch8-b")[(a) Only $x_1$: subproblems with $x_1 <= 1$ and with $x_1 >= 2$. (b) Non-basic variables are 0 in the basic solution — already integer.]

#answer("ch8-w1")[Yes; branch on $x_3 = 5 slash 2$: $x_3 <= 2$ and $x_3 >= 3$.]

#answer("ch8-w2")[37 cannot be pruned (it might hide a solution cheaper than 40); 40 and 45 can (cost $>= 40$).]

#answer("bb-new-tree")[Root: corners of the region are $(0,0)$, $(4, 0)$, $(3, 1.5)$, $(0, 3)$; the best is $(3, 1.5)$ with value 21. Branch on $y$. *$y >= 2$:* region $x <= 6 - 2y$, best corner $(2, 2)$, value 18, integer: incumbent 18. *$y <= 1$:* corners include $(10 slash 3, 1)$ ($6x + 4 = 24$), value $62 slash 3 approx 20.67 > 18$, fractional: branch on $x$. *$x >= 4$:* $(4, 0)$, value 20, integer: new incumbent 20. *$x <= 3$:* best $(3, 1)$, value 19 $<= 20$: pruned by bound. Optimum $(4, 0)$ with value 20. Tree: root (21) → [$y >= 2$: 18, integer] and [$y <= 1$: 20.67] → [$x >= 4$: 20, integer, optimal] and [$x <= 3$: 19, pruned].]

#answer("ch8-p2")[Written as $x + frac(5,2) s_1 + frac(1,2) s_2 = 4$, the right-hand side is an integer: $"frac"(4) = 0$ and the "cut" $frac(1,2) s_1 + frac(1,2) s_2 >= 0$ is always true. Gomory cuts need a row whose basic variable is fractional. The cut $-8x + 10y <= 12$: $(0, 1)$ gives 10, $(1, 2)$ gives 12 — both satisfy it; $(4, 4.5)$ gives 13 — violated.]

#answer("ch8-p3")[The integer problem is infeasible ($3(x - y)$ is a multiple of 3, never 1 or 2), but every subproblem's relaxation has a fractional solution: after $x <= 0$ / $x >= 1$ the relaxation finds $y = 1 slash 3$, then $x = 5 slash 3$, and so on, with the solutions drifting upward forever; no node is ever pruned. With $x, y <= 10$ each branch strictly shrinks a finite domain, so after finitely many branchings every node is infeasible or integral.]

#answer("jan25-q1d")[Yes: the optimal basic solution has $x_3 = 1 slash 3$ and $x_2 = 2 slash 3$ (and $x_0 = x_1 = 0$). Both can be branched on. On $x_3$: subproblems with $x_3 <= 0$ and with $x_3 >= 1$. On $x_2$: subproblems with $x_2 <= 0$ and with $x_2 >= 1$. (Going further than the question: adding the two equations gives $4 x_1 + x_2 + x_3 = 1$, which forces $x_1 = 0$ and $x_2 + x_3 = 1$ for integers, and neither choice satisfies the first equation — the integer problem is infeasible, and the tree confirms it after a few nodes.)]

#answer("jan26-q1d")[Yes: $x_3 = 1$ is integer, but $x_2 = 3 slash 2$ is not. Only $x_2$ can be branched on: subproblems with $x_2 <= 1$ and with $x_2 >= 2$. (Further: $x_2 >= 2$ is infeasible, and $x_2 <= 1$ has relaxation optimum $-5 slash 2$ at $x_1 = 1 slash 4$, $x_2 = 1$, $x_3 = 1 slash 2$. In fact the integer problem is infeasible: the second equation $2 x_0 + 2 x_1 + x_3 = 1$ forces $x_3 = 1$, $x_0 = x_1 = 0$, and then the first gives $x_2 = 3 slash 2$.)]

#answer("bb-new-j1")[(a) From the first equation $x_2 = 1 + 2 x_0 + x_1$; from the second $2 x_3 = 2 + 2x_0 - x_1 - x_2 = 1 - 2 x_1$, so $x_3 = frac(1,2) - x_1$. Basic solution $x_2 = 1$, $x_3 = 1 slash 2$; objective $2 dot 1 = 2$. (b) $z = x_0 + x_1 + 2(1 + 2x_0 + x_1) = 2 + 5 x_0 + 3 x_1$: reduced costs 5 and 3, both $>= 0$, so optimal. (c) Yes, $x_3 = 1 slash 2$ is fractional: subproblems $x_3 <= 0$ and $x_3 >= 1$. ($x_2 = 1$ is integer and is not a candidate.)]

#answer("bb-new-j3")[(a) Subtracting the first equation from the second: $x_0 + 4 x_3 = 3$, so $x_0 = 3 - 4 x_3$. Then $2 x_2 = x_0 - x_1 - 2 x_3 + 2 = 5 - x_1 - 6 x_3$, so $x_2 = frac(5,2) - frac(1,2) x_1 - 3 x_3$. Basic solution $x_0 = 3$, $x_2 = 5 slash 2$; objective $-2 dot 5/2 = -5$. (b) $z = x_1 - 2 x_2 - x_3 = -5 + 2 x_1 + 5 x_3$: reduced costs 2 and 5, both $>= 0$, optimal. (c) Yes, $x_2 = 5 slash 2$: subproblems $x_2 <= 2$ and $x_2 >= 3$.]

#answer("ch8-r1")[$S_1 + 3 <= S_2 + 20(1 - o)$, $S_2 + 2 <= S_1 + 20 o$, $o in {0,1}$.]

#answer("ch8-r2")[A weak big-M lets the LP relaxation satisfy the switched constraints with tiny fractional indicators, so the relaxation's bound is far from the integer optimum; little gets pruned by bound and the tree grows large.]
