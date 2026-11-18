#import "../template.typ": *

== Chapter 16

#answer("drill")[(1) It limits $x_5$ to 3 (coefficient $-1$); it does not limit $x_1$. [Ch. 4] (2) $a <= b + c$. [5] (3) $4 + 0.5 dot 5 = 6.5$: ${4, 6}$. [13] (4) $sum_i x_i = 2$. [5] (5) $x_2 <= 2$ and $x_2 >= 3$. [8] (6) Yes, a disc. [9] (7) 90. [15] (8) The LP is infeasible. [4] (9) `dvar boolean y[I][J];` [2] (10) $z >= u_i$ for all $i$. [1] (11) Best improvement. [12] (12) ${1, 2, 4}$: 3. [14] (13) $M = 10 - 4 = 6$: $x + y <= 4 + 6(1 - delta)$. [6] (14) Optimal; not necessarily unique. [4] (15) Distance from the current city to an unvisited one, minimized. [11] (16) $o_(t+1) <= o_t$. [7] (17) A large penalty (plus the amount of violation). [15] (18) $binom(4, 2) = 6$. [3] (19) $w <= x$, $w <= y$, $w >= x + y - 1$. [6] (20) The best solution met on the path. [14]]

#answer("jun24-q3")[*Constraints:* C1 one rental plan; C2 each job inside the plan's duration and memory; C3 jobs do not overlap in time × memory. *Objective:* minimize the plan cost.

*(a) Candidates:* pairs $chevron.l k, p chevron.r$, job $k$ not yet placed and $p = ("tr", "lc")$ a *corner point*: $(0, 0)$ initially, and after placing a job at $("tr", "lc")$ the points $("tr" + h_k, "lc")$ (right of it in time) and $("tr", "lc" + w_k)$ (above it in memory). Jobs are taken in decreasing area $h_k w_k$.

*Greedy function (min):* $q(chevron.l k, p chevron.r, S)$ = cost of the cheapest plan $(i, j)$ with $H_i >=$ the latest end time and $W_j >=$ the highest memory address after placing $k$ at $p$; ties broken by the smaller area of the bounding box; $+infinity$ if $k$ at $p$ overlaps a placed job or no plan contains the result.
```
points <- {(0,0)}; S <- {}
for k in jobs sorted by h_k * w_k decreasing:
    best <- argmin over p in points of q(<k,p>, S)
    if q(best) = +infinity then return INFEASIBLE
    S <- S + {<k,best>}; points <- points - {best}
    points <- points + {(best.tr + h_k, best.lc), (best.tr, best.lc + w_k)}
plan <- cheapest plan containing the bounding box of S
return S, plan, p[plan]
```
On 120 random instances (3 jobs) it was optimal 111 times (2.4 % above the optimum on average).

*(b) Chromosome:* $|"ch"| = n$, one key per job. *Fitness:* cost of the plan found (penalty if INFEASIBLE). *Decoder:* the same greedy with the jobs sorted by decreasing $h_k w_k dot "ch"_k$ — the keys change the placement order, which is what decides the packing.]

#answer("jan25-q3")[#slidenote(deck: "Official solution", where: "June 2024, Q3(a)", says: [Candidates $chevron.l k, p = ("lc", "tr") chevron.r$; initial $S = {chevron.l j_1, (0, 0) chevron.r, chevron.l j_2, ("tr"_(j_1), 0) chevron.r}$; $q = "cost"("current") - "cost"("new")$ when the plan is upgraded.], correct: [With $p = ("lc", "tr")$, $("tr"_(j_1), 0)$ puts a time where an address goes; $j_2$ should start at time $"tr"_(j_1) + h_(j_1)$ or at address $"lc"_(j_1) + w_(j_1)$. The upgrade cost should be $"cost"("new") - "cost"("current") >= 0$ for a minimization.], why: [As written, the coordinates are swapped and the upgrade term is negative, so argmin would prefer expensive upgrades.], kind: "solution") *Constraints:* C1 each student in exactly one class; C2 class sizes in $[l, u]$; C3 good students $>= 2 times$ bad students in every class. *Objective:* maximize the minimum compatibility within classes.

*(a) Candidates:* pairs $chevron.l i, j chevron.r$ for the current student $i$ and every class $j$. Students are processed bad ones first, then good ones, then the others (bad students are the hardest to place).

*Greedy function (max):* $q(chevron.l i, j chevron.r, S) = min{C_(a b) : a < b, a, b in "class"(j) union {i}}$ (1 if the class would have one student) — the minimum compatibility of class $j$ after adding $i$. Value $-infinity$ if the class is full ($u$), or if the partial solution could no longer be completed: some class's deficit of good students ($2 |B(j)| - |G(j)|$) exceeds the good students still to place, or does not fit in its free seats, or the classes below $l$ need more students than remain.
```
order <- B, then G, then the other students
for i in order:
    j* <- argmax over classes j of q(<i,j>, S)    (ties: smaller class)
    if q(<i,j*>, S) = -infinity then return INFEASIBLE
    put i in class j*; update |G(j*)|, |B(j*)|, sizes
return S, min over classes of the within-class minimum compatibility
```
On 200 random instances (8 students, 2 classes) it always found a feasible assignment and was optimal in 95; the minimum compatibility was 0.051 lower than optimal on average.

*(b) Chromosome:* $|"ch"| = n$. *Decoder:* within each group (bad, good, others) students are processed by increasing key; the class choice is the greedy one. *Fitness:* the minimum compatibility (maximized), $-1$ if the decoder fails.]

#answer("mix-1")[#slidenote(deck: "Official solution", where: "January 2025, Q3(a)", says: [Infeasible if "$i in B$ and $|G(j)| < 2 |B(j)|$"; line 12 "if $i in G$ then $G(j) union {i}$ else $B(j) union {i}$".], correct: [A bad student may join $j$ only if $|G(j)| >= 2(|B(j)| + 1)$ at the end; and students in neither $G$ nor $B$ must not be counted as bad.], why: [With an empty class, $0 < 0$ is false, so the first bad student enters a class with no good students; and line 12 makes every neutral student "bad", tightening C3 wrongly.], kind: "solution") (a) From the two equations: $x = frac(5,3) + frac(1,3) s_1 - frac(2,3) s_2$, $y = frac(5,3) - frac(2,3) s_1 + frac(1,3) s_2$. Basic solution $x = y = 5 slash 3$; objective $-25 slash 3$. $z = -frac(25,3) + frac(4,3) s_1 + frac(1,3) s_2$: reduced costs $4 slash 3$ and $1 slash 3$, so optimal. (b) Both $x$ and $y$ are fractional: branching on $y$ gives $y <= 1$ and $y >= 2$ (or on $x$: $x <= 1$, $x >= 2$). (c) Worked example 8.2 (pruning by bound): the integer optimum is $(1, 2)$, value 8 (i.e. $-8$ here).]

#answer("mix-2")[(a) $y_j in {0, 1}$: defibrillator at site $j$. $min sum_j c_j y_j$ s.t. $sum_j a_(i j) y_j >= 1$ for all $i != h$ and $sum_j a_(h j) y_j >= 2$. (b) Let $r_i$ be the remaining coverage needed by building $i$ (1, or 2 for $h$, decreased as sites are chosen). Candidates: unchosen sites; $q(j) = c_j slash sum_i a_(i j) [r_i > 0]$, cost per unit of still-needed coverage, minimized ($+infinity$ if it covers nothing needed). Myopic: a cheap site chosen early may become redundant once later sites cover its buildings (a "remove redundant sites" local search fixes this), and the double coverage of $h$ is not anticipated.]

#answer("case-a")[
```
int nV = ...; int nD = ...;
range V = 1..nV; range D = 1..nD;
float w[V] = ...; float K[D] = ...; float price[D] = ...;
int ok[V][D] = ...;                          // 1 if latency allows v in d
dvar boolean x[V][D];
minimize sum(v in V, d in D) price[d] * w[v] * x[v][d];
subject to {
  forall (v in V) sum(d in D : ok[v][d] == 1) x[v][d] == 1;
  forall (v in V, d in D : ok[v][d] == 0) x[v][d] == 0;
  forall (d in D) sum(v in V) w[v] * x[v][d] <= K[d];
}
```
CPLEX: 32.]

#answer("case-b")[Greedy solution: DC 3 holds VMs 3 and 1 (7 of 7), DC 2 holds VM 2, DC 1 holds VMs 4 and 5; cost 36. Moves: VM 1 to DC 1: $+9 - 6 = +3$ (39). VM 2 to DC 3: overflows. VM 3 to DC 1: $+12 - 8 = +4$ (40); to DC 2: $+20 - 8$ (48). VM 4 or VM 5 to DC 2: $+10 - 6$ (40); to DC 3: overflows. No feasible move improves, so 36 is a local optimum (the same holds for swaps).]

#answer("case-c")[RCL over the DCs for the current VM: $q <= q_min + alpha (q_max - q_min)$; also randomize the order of VMs of equal or similar size. With randomization, an iteration may place VM 3 in DC 1 (its RCL is ${8, 12}$ as soon as $alpha >= 1 slash 3$), which leaves DC 3 for VMs 1, 2 and 5 — the optimum. The deterministic greedy always fills DC 3 with VMs 3 and 1 first.]

#answer("case-d")[Decoder 1 (keys as priorities): sort VMs by increasing key, then place each in the allowed DC with room minimizing $pi_d w_v$; with keys $(0.2, 0.3, 0.9, 0.8, 0.4)$ the order 1, 2, 5, 4, 3 gives 32. Decoder 2 (decreasing size, $q' = "ch"_v dot pi_d w_v$): a key per VM multiplies the cost of all DCs of that VM by the same number, so the choice of DC never changes: it always returns 36. To be useful, the keys must change either the order or the comparison between DCs (one key per pair $(v, d)$).]

#answer("mock-q1")[First equation: $x_2 = 2 - x_0 - x_3$; second: $x_1 = 2 + x_3$. (a) $x_2 = 2$, $x_1 = 2$. (b) $2 dot 2 + 2 dot 2 = 8$. (c) $z = -2 x_0 + 2(2 + x_3) + 2(2 - x_0 - x_3) + x_3 = 8 - 4 x_0 + x_3$: $d_0 = -4$, $d_3 = 1$. (d) No; ratio test: $x_2 = 2 - x_0$ gives $x_0 <= 2$, $x_1$ does not depend on $x_0$; best value *2*. (e) Yes, $d_3 = 1 >= 0$. (After the pivot the basis $(x_0, x_1)$ is optimal with value 0.)]

#answer("mock-q2")[(a) In every time slot, the total number of students sitting exams does not exceed the $S$ available seats. (b) $sum_(t=1)^m x_(e t) = 1$ for every exam $e$. (c) For every pair $e < f$ with $A_(e f) = 1$: same slot, $x_(e t) + x_(f t) <= 1$ for all $t$; consecutive slots, $x_(e t) + x_(f, t+1) <= 1$ and $x_(f t) + x_(e, t+1) <= 1$ for $t = 1, dots, m - 1$. (d) New integer variable $z$ = last slot used: $z >= t dot x_(e t)$ for all $e, t$ (or $z >= sum_t t x_(e t)$ for all $e$); objective $min z$. Checked against brute force on 60 random instances.]

#answer("mock-q3")[*Constraints:* C1 each exam once; C2 conflicting exams at least two slots apart; C3 at most $S$ students per slot. *Objective:* minimize the last slot used.

*(a) Candidates:* pairs $chevron.l e, t chevron.r$ (unscheduled exam, slot). *Choice of exam:* the most constrained one — largest number of slots already forbidden by scheduled conflicting exams (slots $t - 1$, $t$, $t + 1$ around each of them); ties: more conflicts, then more students. *Greedy function (min):* $q(chevron.l e, t chevron.r) = t$ if $t$ is allowed (no conflicting exam in $t - 1, t, t + 1$, seats available), $+infinity$ otherwise — the earliest feasible slot.
```
S <- {}
while some exam is unscheduled:
    e <- unscheduled exam with most forbidden slots (ties: more conflicts, more students)
    t <- smallest slot in 1..m with q(<e,t>) < +infinity
    if none then return INFEASIBLE
    S <- S + {<e,t>}
return S, max slot used
```
*Run.* Exam 3 (3 conflicts) → slot 1. Exams 1, 2, 4 now have 2 forbidden slots; most students: exam 1 → slot 3. Exam 2 (slots 1–4 forbidden) → slot 5. Exam 4 (slots 1–2 forbidden) → slot 3 (60 students in it). Exam 5 (slots 2–4 forbidden): slot 1 would hold 110 students → slot 5. Exam 6 (slots 4–6 forbidden) → slot 1. Last slot 5, which is optimal (exams 1, 2, 3 are pairwise in conflict, so they need slots at least two apart: 1, 3, 5). On 56 random feasible instances (5 exams) the greedy was optimal 49 times and never failed.

*(b) Chromosome:* $|"ch"| = n$. *Decoder:* the greedy with "forbidden slots $+ "ch"_e$" as the selection score (the key breaks ties and perturbs the order) — or exams sorted by key; the slot rule is unchanged. *Fitness:* the last slot used; $m + 1 +$ the number of unscheduled exams if the decoder fails.]
