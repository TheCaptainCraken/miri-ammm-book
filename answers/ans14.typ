#import "../template.typ": *

== Chapter 14

#answer("ch14-yt1")[$|A plus.o B| = |{2, 3, 4, 5}| = 4$, $|A plus.o C| = |{1, 3, 4, 6}| = 4$, $|B plus.o C| = |{1, 2, 5, 6}| = 4$: $d("ES") = 4$. $S = {1, 2, 6}$: distances 2, 4, 2, so $d(S, "ES") = 2$; cost 11 is not below the best (10), and although $11 < 15$ the solution is too close ($2 < 4$): it does not enter. $S = {3, 5, 6}$: distances 4, 4, 4, $d(S, "ES") = 4 >= 4$ and $14 < 15$: it enters. Members with cost $>= 14$: only $C$, so $C$ leaves.]

#answer("ch14-a")[(a) Elements in exactly one of the two sets; here ${1, 4, 5}$, size 3. (b) Elements of the guiding solution that the current solution does not have yet. (c) The best solution met along the path (possibly one of the ends).]

#answer("ch14-b")[(a) Better than the best member; or better than the worst member and at distance at least $d("ES")$ from the pool. (b) Among members with cost $>=$ the new one, the closest to it. (c) PR intensifies (searches between good solutions); GRASP's randomized constructions diversify.]

#answer("ch14-w1")[They differ for tasks 1 and 3: $S plus.o S' = {(1, c_1), (3, c_2), (1, c_2), (3, c_1)}$, size 4.]

#answer("ch14-w2")[Intensification: fix pairs (task, computer) present in most elite solutions and search the rest. Diversification: add to $q$ a penalty proportional to how often the pair has been used, so rarely used pairs get a chance.]

#answer("ch14-p1")[Moving user 5 to $a_1$ gives $a_1$ the users ${2, 5, 6, 7, 9}$ with total demand 11 > 10: no model fits, infeasible. User 6 to $a_3$: $a_3$ gets ${1, 3, 4, 5, 6}$, demand 11, infeasible. User 8 to $a_1$: ${2, 6, 7, 8, 9}$, demand 11, infeasible. User 7 to $a_3$: $a_1$ keeps ${2, 6, 9}$ (demand 8, farthest user 9 at 1.41) → R2; $a_3$ gets ${1, 3, 4, 5, 7}$ (demand 10, farthest user 4 at 3.0) → R3; $a_5$ R1: cost $140 + 180 + 100 = 420$. PR takes the only feasible step, user 7 — as the slides warn, most intermediate solutions are infeasible.]

#answer("ch14-p2")[A solution better than the best is always worth keeping, even if similar. Otherwise, without the distance condition the pool would fill with near-copies of one good solution; relinking near-copies explores almost nothing.]

#answer("pr-new-exam")[(a) $d(S_a, S_b)$ = number of tasks assigned to different computers (or $|S_a plus.o S_b|$ of the pairs, twice that number). (b)
```pseudo
x <- S_a; best <- better of S_a, S_b
while x != S_b:
    D <- { t : x(t) != S_b(t) }
    t* <- argmin over t in D of maxLoad(x, t -> S_b(t)),
          where a move that overflows a computer costs +inf
    if every move overflows:
        move t* anyway, then repair: move the smallest task
        of the overflowing computer to the least-loaded
        computer where it fits (or skip it if impossible)
    x <- x with t* moved to S_b(t*)
    if x feasible and maxLoad(x) < maxLoad(best): best <- x
return best
```
(c) Keep an elite set of GRASP solutions; after each GRASP iteration relink the new local optimum with a random elite solution (both directions if time allows), apply local search to the best path solution, and update the elite set.]

#answer("ch14-r1")[Threshold $9 - 0.5 dot 8 = 5$: RCL = candidates 1, 2, 3 ($q = 5, 9, 9$).]

#answer("ch14-r2")[$w_t <= o_t$ and $o_(t+1) <= o_t$.]
