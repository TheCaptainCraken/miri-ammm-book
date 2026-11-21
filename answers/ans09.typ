#import "../refs.typ": answer, exref, slidenote

#answer("ch9-yt1")[$x = lambda_1 + 2 lambda_2 + 3 lambda_3$; $y = lambda_1 + 4 lambda_2 + 9 lambda_3$. With $+x^2$ minimized (convex term): no SOS2 needed. With $-x^2$ minimized (concave term): needed. With $lambda_1 = lambda_2 = 0.5$: $x = 1.5$, $y = 2.5$, true value $2.25$ — the approximation overestimates a convex function between breakpoints.]

#answer("ch9-a")[(a) Minimizing a convex function over a convex region (or maximizing a concave one). (b) $|x|$ is convex (its epigraph is a "V" region, convex). $x^2 + y^2 >= 4$ is the outside of a disc — not convex (the segment between $(-2, 0)$ and $(2, 0)$ passes through the origin). (c) In a convex program every local minimum is global, so local methods are exact.]

#answer("ch9-b")[(a) A sum of one-variable functions; $x_1 x_2$ is not. (b) When the program is convex (convex terms minimized, concave terms maximized): then the LP optimum uses at most two adjacent breakpoints. (c) Four ($n - 1$).]

#answer("ch9-w1")[Linear: (a), (h). All the others are non-linear.]

#answer("ch9-w2")[(a) convex; (b) concave, not convex; (c) convex (second derivative $6x >= 0$); (d) neither; (e) convex; (f) concave.]

#answer("ch9-p1")[$min x - y + z$ s.t. $x + z <= 4$, $2x + z <= 5$, $-x + 4z >= 2$, $x = lambda_1 + 1.5 lambda_2 + 2 lambda_3$, $y = lambda_1 + 3.375 lambda_2 + 8 lambda_3$, $lambda_0 + lambda_1 + lambda_2 + lambda_3 = 1$, all $>= 0$, plus SOS2 on $(lambda_0, dots, lambda_3)$. Encoding: binaries $mu_k$ with $lambda_k <= mu_k$, and $delta_1, delta_2, delta_3$ with $mu_0 <= delta_1$, $mu_1 <= delta_1 + delta_2$, $mu_2 <= delta_2 + delta_3$, $mu_3 <= delta_3$, $delta_1 + delta_2 + delta_3 <= 1$. (The $lambda$'s are indexed from 0 here, so $delta_k$ activates segment $[b_(k-1), b_k]$.)]

#answer("ch9-p2")[$u_1^2 - u_2^2 = (u_1 + u_2)(u_1 - u_2) = x_1 x_2$. For $3, -1$: $u_1 = 1$, $u_2 = 2$, $1 - 4 = -3 = 3 dot (-1)$ ✓. $u_1^2$ is convex; $-u_2^2$ is concave.]

#answer("ch9-p3")[For a concave cost every chord lies _below_ the curve. Without adjacency the LP may mix two far-apart breakpoints and pay the chord's value, which is cheaper than the true cost — so it underestimates and may choose a wrong plan. (Picture: the dashed chord of Figure 9.2, mirrored below a concave curve.)]

#answer("nlp-new-exam")[(a) Slopes $100 slash 10 = 10$, $120 slash 20 = 6$, $150 slash 30 = 5$: decreasing, so the cost is concave (volume discounts). (b) Variables $lambda_0, dots, lambda_3 >= 0$ (weights of the breakpoints 0, 10, 30, 60) and $y >= 0$ tons from B: $min 100 lambda_1 + 220 lambda_2 + 370 lambda_3 + 6.5 y$ s.t. $10 lambda_1 + 30 lambda_2 + 60 lambda_3 + y = 50$, $lambda_0 + lambda_1 + lambda_2 + lambda_3 = 1$, plus SOS2 on the $lambda$'s. (c) Without adjacency the LP takes $lambda_0 = 1 slash 6$, $lambda_3 = 5 slash 6$ ($x = 50$ from A) and claims a cost of $370 dot 5 slash 6 = 308.33$ €: a point on the chord from $(0, 0)$ to $(60, 370)$, which lies below the true cost (concave function, minimized). (d) With adjacency the best is still 50 t from A but at the true price $g(50) = 220 + 20 dot 5 = 320$ € ($lambda_2 = 1 slash 3$, $lambda_3 = 2 slash 3$); any split with B costs more since A's marginal price beyond 30 t (5 €) is below B's 6.5 €. Encoding: $mu_k in {0,1}$ with $lambda_k <= mu_k$; $delta_1, delta_2, delta_3 in {0,1}$, $mu_0 <= delta_1$, $mu_1 <= delta_1 + delta_2$, $mu_2 <= delta_2 + delta_3$, $mu_3 <= delta_3$, $sum delta <= 1$. Both LP values were computed exactly.]

#answer("ch9-r1")[Branch on $x_2$ ($x_2 <= 6$ / $x_2 >= 7$): 41.5 > 41, so the node may contain a better solution. If the objective is known to take only integer values at integer points, then any integer solution below is at most 41, and the node can be pruned.]

#answer("ch9-r2")[$w <= 8 x$, $w <= y$, $w >= y - 8(1 - x)$, $w >= 0$.]
