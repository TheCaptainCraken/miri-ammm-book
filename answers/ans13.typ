#import "../template.typ": *

== Chapter 13

#answer("ch13-yt1")[$q_max = 10$, $q_min = 2$. $alpha = 0.25$: threshold $10 - 0.25 dot 8 = 8$, RCL ${e_3, e_4}$. $alpha = 0.5$: threshold 6, RCL ${e_2, e_3, e_4}$. $alpha = 0$ gives the pure greedy (RCL = the best, up to ties).]

#answer("ch13-a")[(a) $q(e, S) <= q_min + alpha (q_max - q_min)$. (b) $alpha = 0$: greedy; $alpha = 1$: random construction. (c) Randomized constructions are usually not locally optimal; local search turns each into a local optimum, and the multistart explores different local optima.]

#answer("ch13-w1")[Threshold $12 + 0.2 dot 18 = 15.6$: RCL ${12, 15}$.]

#answer("ch13-w2")[Every iteration builds the same solution and local search reaches the same local optimum: the extra iterations only cost time.]

#answer("ch13-p1")[$t_2$: only $c_3$. $t_3$: threshold $0.6141 + 0.7 dot 0.0024 = 0.6158$, RCL ${c_1}$. $t_1$: only $c_2$. $t_4$: threshold $0.7288 + 0.7 dot 0.2212 = 0.8836$, RCL ${c_1, c_2}$ — the only real choice. Picking $c_2$: maximum load 0.7992; picking $c_1$: 0.8233 (and local search can then move $t_4$ to $c_2$, back to 0.7992).]

#answer("ch13-p2")[Useful sets at step 2: $p_3, p_4, p_5, p_6, p_7$, with $q = 1, 1, 1, 2, 1$. Over useful sets $q_min = 1$: threshold $2 - 0.5 = 1.5$, RCL ${p_6}$ only — deterministic. Over all sets ($q_min = 0$) the RCL is ${p_3, p_4, p_5, p_6, p_7}$. It matters: the second choice is much more random.]

#answer("lab4-c")[RCL for P2: for the current task $t$, the feasible computers whose resulting load is at most $q_min + alpha (q_max - q_min)$; pick one at random. Expected tuning curve: very small $alpha$ ≈ greedy; moderate $alpha$ (often 0.1–0.4) best; large $alpha$ wastes iterations on poor constructions. With equal time, GRASP usually beats greedy + local search (it explores many local optima) and approaches CPLEX on instances CPLEX cannot finish.]

#answer("grasp-new-exam")[(a) With $q(i, S)$ the added training cost (Chapter 11), at each step: $"RCL" = {i in cal(C) : q(i, S) <= q_min + alpha (q_max - q_min)}$, where $cal(C)$ contains only feasible astronauts (courses within $M$). $alpha = 0$: the greedy (ties broken at random, so the first pick already varies); $alpha = 1$: any feasible astronaut. (b)
```pseudo
S <- {}; courses[.] <- 0
while |S| < K:
    C <- feasible astronauts not in S
    if C = {} then return INFEASIBLE
    qmin <- min q(i,S); qmax <- max q(i,S) over C
    RCL <- { i in C : q(i,S) <= qmin + alpha (qmax - qmin) }
    i <- random element of RCL
    update courses of i and of Need(i,S); S <- S + {i}
return S
```
(c) Repeat for $k = 1..$maxIter: construction (b); if it returns INFEASIBLE, skip the iteration; local search with the *swap* neighbourhood (replace a crew member by an outsider when the total training cost decreases and C3 holds); keep the best crew.]

#answer("ch13-r1")[Reassignment (move one task to another computer) and exchange/swap (swap the computers of two tasks).]

#answer("ch13-r2")[$max z$ s.t. $z <= 1$ and $z <= C_(i k) + 2 - x_(i j) - x_(k j)$ for all teams $j$ and pairs $i < k$.]
