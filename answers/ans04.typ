#import "../refs.typ": answer, exref, slidenote

#answer("ch4-yt1")[$x_2 = 1 - x_0 + x_3$; substituting, $-x_0 - 2 x_1 + 2(1 - x_0 + x_3) - 2 x_3 = -2$, so $x_1 = 2 - frac(3, 2) x_0$. Basic solution $x_2 = 1$, $x_1 = 2$; objective $2 dot 2 + 2 dot 1 = 6$. In non-basic variables $z = 2x_0 + 2(2 - frac(3,2) x_0) + 2(1 - x_0 + x_3) + x_3 = 6 - 3 x_0 + 3 x_3$. $x_3$ satisfies optimality ($d_3 = 3$); $x_0$ does not ($d_0 = -3$). Ratio test: $x_2 = 1 - x_0$ gives $x_0 <= 1$; $x_1 = 2 - frac(3,2) x_0$ gives $x_0 <= 4 slash 3$. Best value 1 ($x_2$ leaves).]

#answer("ch4-a")[(a) Basic solution = the constants of the rows (non-basic at 0); objective value = the constant of the $z$ row once written in non-basic variables. (b) All reduced costs $>= 0$. (c) Yes, it is optimal; but a zero reduced cost suggests other optimal solutions may exist (moving that variable does not change the cost).]

#answer("ch4-b")[(a) Those where the entering variable has a negative coefficient. (b) The LP is unbounded (best value $+infinity$). (c) By $d_j$ times the new value of $x_j$.]

#answer("ch4-c")[(a) Each artificial variable appears in only one row with coefficient 1 and $b >= 0$, so the artificial variables form an identity basis with values $b >= 0$. (b) The original LP is infeasible. (c) They are non-basic at 0 (if one is basic at value 0, pivot it out with a degenerate step); drop their columns and start phase II with the original objective.]

#answer("ch4-d")[(a) A pivot where the entering variable enters at value 0 because a basic variable in a limiting row is 0 (degenerate basis); the point and the objective do not change. (b) Choose the entering variable with the smallest index among those with negative reduced cost; among tight rows, the leaving variable with the smallest index. (c) $binom(n, m)$.]

#answer("ch4-w1")[Basic solution $x_1 = 4$, $x_3 = 1$, $x_2 = x_4 = 0$; objective 10; $d_2 = 3$, $d_4 = -1$. Not proven optimal: $x_4$ has a negative reduced cost.]

#answer("ch4-w2")[Increase $x_4$: $x_1 = 4 + 2 x_4$ is not limited; $x_3 = 1 - x_4$ gives $x_4 <= 1$. Best value 1, $x_3$ leaves; the objective drops to $10 - 1 = 9$.]

#answer("ch4-w3")[$B = (a_(s_1), a_(s_2), a_y)$ with columns $(1,0,0)$, $(0,1,0)$, $(1,0,1)$; $c_B = (0, 0, -2)$. Solve $B u = a_x = (1, 1, 0)$: third row gives $u_y = 0$, then $u_(s_1) = 1$, $u_(s_2) = 1$. So $d_x = c_x - c_B^T u = -1 - 0 = -1$, as in the substitution.]

#answer("ch4-p1")[Slack basis: $s_1 = 4 - x_1 - x_2$, $s_2 = 6 - x_1 - 3 x_2$, $z = -3x_1 - 2x_2$. Enter $x_1$ ($d = -3$): limits 4 and 6, $s_1$ leaves. New tableau $x_1 = 4 - x_2 - s_1$, $s_2 = 2 - 2 x_2 + s_1$, $z = -12 + x_2 + 3 s_1$. All reduced costs $>= 0$: optimal, $z^* = -12$ at $x_1 = 4$, $x_2 = 0$.]

#answer("simplex-new-tie")[(a) Tableau: from the first equation $x_2 = 1 - x_1 + x_3$; then $x_0 = 2 - 2 x_1 + 2 x_2 + x_3 = 4 - 4 x_1 + 3 x_3$; basic solution $x_0 = 4$, $x_2 = 1$; objective $4 + 1 = 5$; $z = 5 - 3 x_1 + 4 x_3$, so $d_1 = -3$, $d_3 = 4$. (b) For $x_1$: $x_0 = 4 - 4x_1$ gives $x_1 <= 1$ and $x_2 = 1 - x_1$ gives $x_1 <= 1$: a *tie*, both $x_0$ and $x_2$ become 0. (c) Bland: the leaving variable is the tight one with the smallest index, $x_0$. New basis $(x_1, x_2)$: $x_1 = 1$, $x_2 = 0$, objective $5 - 3 = 2$. It is degenerate ($x_2 = 0$ is basic); the next step, if any variable wanted to enter through the $x_2$ row, would be a degenerate step.]

#answer("ch4-p3")[Slack basis: $s_1 = 1 - x + y$, $s_2 = 1 + x - y$, $z = -x - y$. Enter $x$: only $s_1$ limits it ($x <= 1$); pivot: $x = 1 + y - s_1$, $s_2 = 2 - s_1$, $z = -1 - 2y + s_1$. Now $y$ has $d = -2$ and no row has a negative coefficient for $y$: unbounded. Direction: $(x, y) = (1 + t, t)$ for $t >= 0$ keeps $x - y = 1$ and $-x + y = -1 <= 1$, and the objective $-1 - 2t$ decreases without limit.]

#answer("ch4-p4")[If $x$ is feasible for $A x = b$, $x >= 0$, then $(x, z = 0)$ is feasible for phase I with cost 0; the phase-I objective is a sum of non-negative variables, so it cannot be below 0. Hence the optimum is exactly 0.]

#answer("jun24-q1")[*Tableau.* Second equation: $x_3 = 1 + 2 x_0 - x_2$. First: $x_1 = 1 + 2 x_0 + 2 x_3 = 3 + 6 x_0 - 2 x_2$. (a) $x_1 = 3$, $x_3 = 1$ (check: $0 + 3 - 2 = 1$ ✓, $0 - 0 - 1 = -1$ ✓). (b) Objective $= x_1 - x_3 = 3 - 1 = 2$. (c) $z = x_0 + (3 + 6x_0 - 2x_2) - x_2 - (1 + 2x_0 - x_2) = 2 + 5 x_0 - 2 x_2$: $d_0 = 5$, $d_2 = -2$. (d) $x_0$ satisfies the optimality condition. (e) $x_2$ does not; ratio test: $x_1 = 3 - 2 x_2$ gives $x_2 <= 3 slash 2$, $x_3 = 1 - x_2$ gives $x_2 <= 1$; best value *1*.]

#answer("jun25-q1")[*Tableau.* Second equation: $x_0 = 2 + x_2$. First: $x_3 = 2x_0 - x_1 - x_2 = 4 - x_1 + x_2$. (a) $x_0 = 2$, $x_3 = 4$. (b) $-x_3 = -4$. (c) $z = -x_1 - x_2 - (4 - x_1 + x_2) = -4 + 0 dot x_1 - 2 x_2$: $d_1 = 0$, $d_2 = -2$. (d) $x_1$ satisfies the optimality condition ($d_1 = 0 >= 0$). (e) $x_2$ does not; in both rows $x_2$ has a positive coefficient ($x_0 = 2 + x_2$, $x_3 = 4 + x_2$), so nothing limits it: best value $+infinity$ (the LP is unbounded).]

#answer("jun26-q1")[*Tableau.* Adding the equations: $-x_0 + 2 x_1 + 2 x_2 = -4$, so $x_0 = 4 + 2 x_1 + 2 x_2$; then $x_3 = x_0 + 2 x_2 + 2 = 6 + 2 x_1 + 4 x_2$. (a) $x_0 = 4$, $x_3 = 6$. (b) $-8 + 12 = 4$. (c) $z = -2(4 + 2x_1 + 2x_2) - 2 x_1 + 2(6 + 2x_1 + 4x_2) = 4 - 2 x_1 + 4 x_2$: $d_1 = -2$, $d_2 = 4$. (d) $x_1$ does not satisfy the optimality condition; both rows increase with $x_1$, so its best value is $+infinity$. (e) $x_2$ satisfies it.]

#answer("jan25-q1abc")[*Tableau.* From the first equation $x_2 = 2 x_0 + 2 x_1 + 2 x_3$; substituting in the second, $2 x_0 + 6 x_1 + 3 x_3 = 1$, so $x_3 = frac(1,3) - frac(2,3) x_0 - 2 x_1$ and $x_2 = frac(2,3) + frac(2,3) x_0 - 2 x_1$. (a) $x_3 = 1 slash 3$, $x_2 = 2 slash 3$. (b) $x_2 - 2 x_3 = 0$. (c) $z = 0 + 4 x_0 + 4 x_1$: the reduced costs of the non-basic $x_0$ and $x_1$ are 4 and 4, both non-negative, so the basic solution is optimal.]

#answer("jan26-q1abc")[*Tableau.* Second equation: $x_3 = 1 - 2 x_0 - 2 x_1$. First: $2 x_2 = 2 - 2x_1 + x_3 = 3 - 2 x_0 - 4 x_1$, so $x_2 = frac(3,2) - x_0 - 2 x_1$. (a) $x_3 = 1$, $x_2 = 3 slash 2$. (b) $-3 - 1 = -4$. (c) $z = -2 x_2 - x_3 = -4 + 4 x_0 + 6 x_1$: reduced costs 4 ($x_0$) and 6 ($x_1$), both $>= 0$, hence optimal.]

#answer("simplex-new-a")[Tableau for $(x_0, x_1)$: from the first equation $x_0 = 1 - x_2 + x_3$; then $-2 x_1 = -2 + x_0 - 2 x_2 + 2 x_3 = -1 - 3 x_2 + 3 x_3$, so $x_1 = frac(1,2) + frac(3,2) x_2 - frac(3,2) x_3$. (a) $x_0 = 1$, $x_1 = 1 slash 2$. (b) $2 + 1 = 3$. (c) $z = 3 + 3 x_2 + 0 dot x_3$: $d_2 = 3$, $d_3 = 0$. (d)–(e) Both satisfy the optimality condition, so the basis is optimal (value 3, the same as reached at the end of Your turn 4.1). The zero reduced cost of $x_3$ means that increasing $x_3$ (up to $1 slash 3$, when $x_1$ hits 0) gives other optimal solutions.]

#answer("ch4-r1")[$z >= e_1$, $z >= -e_1$, $z >= e_2$, $z >= -e_2$.]

#answer("ch4-r2")[$binom(4, 2) = 6$. Not necessarily: a pair whose two columns are proportional is singular (#exref("ch3-p2") had one).]
