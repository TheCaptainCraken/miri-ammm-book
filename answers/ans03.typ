#import "../template.typ": *

== Chapter 3

#answer("ch3-yt1")[$x_0 = 2 + x_1 + x_3$; then $-(2 + x_1 + x_3) + 2 x_1 + x_2 + x_3 = 1$ gives $x_2 = 3 - x_1$. Basic solution $x_0 = 2$, $x_2 = 3$ ($x_1 = x_3 = 0$): feasible. Check: $-2 + 0 + 0 = -2$ ✓, $-2 + 0 + 3 + 0 = 1$ ✓.]

#answer("ch3-a")[(a) $min -2x + y^+ - y^-$ s.t. $-x + y^+ - y^- + s_1 = 1$ (the $>=$ row times $-1$, plus slack), $x + s_2 = 4$, all variables $>= 0$. (b) Yes: $max x + 2y$ over $x + y <= 3$, $0 <= x <= 2$, $y <= 2$ with $y$ free has optimum $(1, 2)$ although the region is unbounded below. (c) The unused amount of the resource of that constraint (its distance from being tight).]

#answer("ch3-b")[(a) $x_R = 0$, $x_B = B^(-1) b$. (b) Feasible if $B^(-1) b >= 0$; degenerate if some component of $B^(-1) b$ is 0. (c) $binom(n, m)$ (not every choice is invertible).]

#answer("ch3-w1")[$min -3x + y^+ - y^-$ s.t. $x + 2 y^+ - 2 y^- + s_1 = 4$, $-x + y^+ - y^- + s_2 = 1$, $x, y^+, y^-, s_1, s_2 >= 0$.]

#answer("ch3-w2")[$mat(2, 1; 1, 1)^(-1) = mat(1, -1; -1, 2)$ (determinant 1). $mat(0, -2; -2, 0)^(-1) = 1/(-4) mat(0, 2; 2, 0) = mat(0, -1 slash 2; -1 slash 2, 0)$.]

#answer("ch3-w3")[(a) False: feasibility also needs $x >= 0$. (b) True: the $n - m$ non-basic ones are 0. (c) True: if the region were bounded, the continuous objective would attain its optimum on it. (d) False: see the example in §3.1.]

#answer("ch3-p1")[$(x, y, s_2)$: $x = 1$, $y = 2$, $s_2 = 1$ — corner $(1, 2)$. $(x, y, s_3)$: $x = 2$, $y = 1$, $s_3 = 1$ — corner $(2, 1)$. $(x, s_1, s_3)$: $x = 2$, $s_1 = 1$, $s_3 = 2$ — corner $(2, 0)$. $(x, s_2, s_3)$: $x = 3$, $s_2 = -1$, $s_3 = 2$ — infeasible (the point $(3, 0)$ breaks $x <= 2$). $(y, s_2, s_3)$: $y = 3$, $s_2 = 2$, $s_3 = -1$ — infeasible (point $(0, 3)$). Together with $(s_1, s_2, s_3)$ → $(0, 0)$ and $(y, s_1, s_2)$ → $(0, 2)$ these are the five corners.]

#answer("ch3-p2")[$(x_0, x_1)$: $x_0 = 5$, $x_1 = 3$, feasible. $(x_0, x_2)$: $x_0 = 2$, $x_2 = 3$, feasible. $(x_0, x_3)$: the columns $(-1, -1)$ and $(1, 1)$ are proportional — singular, not a basis. $(x_1, x_2)$: $x_1 = -2$, $x_2 = 5$, infeasible. $(x_1, x_3)$: $x_1 = 3$, $x_3 = -5$, infeasible. $(x_2, x_3)$: $x_2 = 3$, $x_3 = -2$, infeasible.]

#answer("ch3-p3")[$(x, y, s_1)$, $(x, y, s_2)$ and $(x, y, s_3)$: each has $x = y = 2$ and the third basic variable equal to 0 ($s_1 = 4 - 4$, $s_2 = 2 - 2$, $s_3 = 2 - 2$). Three lines meet at $(2, 2)$, so any two of the three corresponding slacks can be non-basic.]

#answer("ch3-e1")[(a) From the first equation, $x_0 = 1 - x_1 slash 2 + x_2 slash 2$; from the second, $x_3 = 2 - x_0 + x_2 = 1 + x_1 slash 2 + x_2 slash 2$. Basic solution $x_0 = 1$, $x_3 = 1$ ($x_1 = x_2 = 0$), feasible; objective $x_1 - x_3 = -1$. (b) With $x_0 = x_3 = 0$: $-x_2 = 2$ gives $x_2 = -2$ and then $x_1 = 2 + x_2 = 0$. It is a basis (the columns $(1, 0)$, $(-1, -1)$ are independent) but not feasible.]

#answer("ch3-r1")[$sum_i q_i x_i >= 0.9 sum_i x_i$.]

#answer("ch3-r2")[`dvar float a;` and `dvar float+ e[1..19];`]
