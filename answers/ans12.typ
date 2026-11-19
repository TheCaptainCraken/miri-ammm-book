#import "../template.typ": *

== Chapter 12

#answer("ch12-yt1")[Within ${p_4, p_6}$, elements 2 and 3 are covered only by $p_4$. After removing $p_4$ we need a set covering ${2, 3}$: $p_7$ (cost 2) alone, or $p_4$ again. Best exchange $p_4 -> p_7$, new cost $3 + 2 = 5$ (optimal).]

#answer("ch12-a")[(a) A solution such that no neighbour (one move away) is better. (b) $|T| (|C| - 1)$. (c) Advantage: better local optima (more improving moves are visible). Drawback: each step costs more evaluations.]

#answer("ch12-b")[(a) First improvement accepts the first better neighbour found during the scan; best improvement evaluates all neighbours and moves to the best. (b) A move changes few parts of the solution; recomputing the objective from scratch for every neighbour wastes time, which limits how many moves can be tried. (c) Most moves do not change the maximum (they do not touch the most loaded computer): every neighbour looks equally good, and strict improvement fails.]

#answer("ch12-w1")[Choose two non-adjacent edges of the $n$ edges: $n(n - 3) slash 2$ (5 for $n = 5$).]

#answer("ch12-w2")[Yes for both. Removing any set uncovers an element (each covers one element no other chosen set covers). Exchanges cannot improve because the cost 5 is optimal.]

#answer("ch12-p1")[Removing $(5,2),(1,4)$: 5–1–2–4–3, 55. $(5,2),(4,3)$: 5–4–1–2–3, 51. $(2,1),(4,3)$: 5–2–4–1–3, 54. $(2,1),(3,5)$: 5–2–3–4–1, 36. $(1,4),(3,5)$: 5–2–1–3–4, 40. Best improvement chooses 5–2–3–4–1–5, length 36.]

#answer("ch12-p2")[Swap: pick two tasks on different computers and exchange their computers. The greedy solution has loads $(0.6141, 0.7288, 0.7992)$; the maximum comes from $t_2$ alone on $c_3$. Any swap involving $t_2$ sends 560.89 to $c_1$ or $c_2$, which exceed their capacity; swaps not involving $t_2$ leave $c_3$ at 0.7992. No improving swap — and the solution is optimal anyway.]

#answer("ch12-p3")[Only the old and the new access point of the user change their set of users; every other router stays the same. $Delta = [f(m^*(U_"new"(a')), a') - f(m^*(U(a')), a')] + [f(m^*(U(a) without {u}), a) - f(m^*(U(a)), a)]$, where $m^*(U, a)$ is the cheapest model serving $U$ from $a$ (no router if $U = emptyset$; $+infinity$ if none can). Accept if $Delta < 0$.]

#answer("lab4-b2")[Reassignment: for each task and each other computer, try moving it; exchange: for each pair of tasks on different computers, try swapping. Each candidate is feasible if both capacities hold; evaluate the new maximum load from the two changed loads. First improvement applies the first improving move and restarts the scan; best improvement applies the best move of the full scan. Typical outcome: local search improves the greedy noticeably on tight instances; exchange finds improvements reassignment cannot (when every computer is nearly full); first improvement is usually faster per iteration, best improvement needs fewer iterations; all of them remain far faster than CPLEX.]

#answer("ls-new-exam")[(a) *Drop* a selected neighbour $i in X$ if the others still convince at least $n slash 2$ ($|union.big_(j in X without {i}) M(j)| >= n slash 2$) — always improving when feasible. *Swap* $i in X$ for $k in.not X$ when $T_k < T_i$ and $|union.big_(j in X without {i}) M(j) union M(k)| >= n slash 2$. Infeasible moves (fewer than $n slash 2$ convinced) are discarded. (b) Keep a counter $"cnt"(j)$ = number of selected neighbours that convince $j$. Dropping $i$ loses the $j in M(i)$ with $"cnt"(j) = 1$; adding $k$ gains the $j in M(k)$ with $"cnt"(j) = 0$. The cost change is $-T_i$ or $T_k - T_i$. (c)
```pseudo
repeat
    best <- none; bestDelta <- 0
    for i in X:
        if drop(i) feasible and -T_i < bestDelta:
            best <- drop(i); bestDelta <- -T_i
        for k not in X:
            if swap(i,k) feasible and T_k - T_i < bestDelta:
                best <- swap(i,k); bestDelta <- T_k - T_i
    if best != none: apply best; update cnt
until best = none
return X
```]

#answer("ch12-r1")[Because argmax picks the largest value: $+infinity$ would make the infeasible candidate the winner.]

#answer("ch12-r2")[$x_0 = 2 - x_1$, $x_3 = 1 - x_1 + x_2$. Basic solution $x_0 = 2$, $x_3 = 1$; objective 1. $z = x_1 + 1 - x_1 + x_2 = 1 + 0 dot x_1 + x_2$: $d_1 = 0$, $d_2 = 1$. Optimal (both $>= 0$); $d_1 = 0$ hints at alternative optima.]
