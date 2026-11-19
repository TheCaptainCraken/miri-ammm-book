#import "../template.typ": *

== Chapter 11

#answer("ch11-yt1")[Candidates: items not yet in the knapsack. $q(i) = v_i slash w_i$ (value per unit of weight), maximized; infeasible (value $-infinity$) if $w_i$ exceeds the residual capacity. Ratios 5, 7, 4.17, 4.8: order items 2, 1, 4, 3. Greedy takes item 2 (weight 1) and item 1 (weight 2); item 4 (weight 5) no longer fits in the remaining 4, nor item 3: value 17. The optimum, items 1 and 4, has value 34. The greedy filled the knapsack with small, efficient items and left no room for the big valuable one — myopia.]

#answer("ch11-a")[(a) Candidate set, selection (greedy) function, feasibility function, objective function, solution function. (b) $-infinity$ (or remove the candidate). (c) Because the value of adding an element depends on what is already in $S$ (residual capacity, elements already covered…).]

#answer("ch11-b")[(a) Large tasks are the hardest to place; placing them while capacity is still available avoids getting stuck with a big task at the end. (b) ${p_4, p_6}$ with cost 6; the optimum costs 5. (c) When an installed router at some access point already reaches the user and has enough spare capacity.]

#answer("ch11-w1")[Candidate set: edges from the current city to unvisited cities. Selection: shortest such edge. Feasibility: the endpoint is unvisited (no subtour). Objective: tour length. Solution: all cities visited (then close the cycle).]

#answer("ch11-w2")[2–5 (4), 5–1 (9), 1–4 (7), 4–3 (5), 3–2 (11): length 36.]

#answer("ch11-p1")[Order: $t_2, t_5, t_3, t_1, t_4$. $t_2$ → $c_3$ (only fit, 0.7992). $t_5$: $c_1$ 0.6817, $c_2$ 0.6844 → $c_1$. $t_3$: only $c_2$ fits (0.6165). $t_1$ (261.27): residuals 160.97, 193.17, 140.89 — no computer fits: the greedy returns INFEASIBLE. Here the greedy is right: the instance is infeasible (Exercise #exref("lab2-c", word: false)). In general a greedy "INFEASIBLE" only means _this greedy_ failed; a different order could succeed.]

#answer("ch11-p2")[Step 1: all ratios are 1; among them $p_4$, $p_5$, $p_6$ cover 3 new elements; lowest index $p_4$. $R = {2, 3, 4}$. Step 2: only $p_5$ (new ${5}$, ratio 3) and $p_6$ (new ${1, 5}$, ratio 1.5) cover something new: $p_6$. Result ${p_4, p_6}$, cost 6, while the optimum is 5. The cost-aware rule is better in general, but on this instance its first choice is a pure tie.]

#answer("ch11-p3")[User 1 at $(1, 1)$: access point $a_3$ is at distance 0, and the cheapest model R1 (reach 2, capacity 6) serves it ($"cr"_1 = 2$): $q = 100 - 0 = 100$ (other access points within distance 2, such as $a_2$, also give 100). User 4 at $(4, 1)$: the closest access points are $a_1$ (2.8) and $a_3$ (3.0); R1's reach 2 is too short, R2 (reach 3) works: $q = 140$ at $a_1$ (the slides choose $a_1$, the nearer one).]

#answer("lab4-b")[The pseudocode is the one of §11.3 (tasks to computers): tasks by decreasing request, each to the feasible computer that would reach the smallest load; greedy function $q(chevron.l t, c chevron.r) = ("used"(c) + r_t) slash R_c$. Expected: "random only" is fastest but its maximum load is clearly worse and it fails more often on tight instances; the greedy is almost as fast (milliseconds) and much better; both are far faster than CPLEX on large instances, while CPLEX is better (optimal or within 1 %) when it finishes.]

#answer("jun25-q3a")[*Constraints:* C1 each man and each woman has at most one date; C2 dates are man–woman; C3 as many men as women confess first; C4 at least one past participant (man in $I$ or woman in $J$) has a date. *Objective:* maximize $sum f_(i j) x_(i j) + s_(i j) y_(i j)$.

*Candidates:* triples $chevron.l i, j, r chevron.r$ with $i$ a man without a date, $j$ a woman without a date, $r in {F, S}$ ($F$: the man confesses first, $S$: second).

*Greedy function (max):* $q(chevron.l i, j, r chevron.r, S) = f_(i j)$ if $r = F$, $s_(i j)$ if $r = S$ — the score the date adds. To keep C3 reachable, only the role that restores balance is allowed: with $X$ dates of type $F$ and $Y$ of type $S$ in $S$, if $X > Y$ only $r = S$, if $Y > X$ only $r = F$, if $X = Y$ both ($q = -infinity$ for the other role).

*Pseudocode:*
```pseudo
S <- {}; FM <- men; FW <- women; X <- 0; Y <- 0
loop
    R <- {F, S} if X = Y; {S} if X > Y; {F} if Y > X
    C <- {<i,j,r> : i in FM, j in FW, r in R}
    if S = {} then                   // C4 on the first date
        C <- {<i,j,r> in C : i in I or j in J}
    if C = {} then break
    <i,j,r> <- argmax over C of q(<i,j,r>)
    // stop when no profitable pair is left
    if X = Y and S != {} and q(<i,j,r>) <= 0 then break
    S <- S + {<i,j,r>}; FM <- FM - {i}; FW <- FW - {j}
    if r = F then X <- X + 1 else Y <- Y + 1
// repair C3
while X != Y: remove the last date added to S, update X, Y
if no date in S involves I or J then return INFEASIBLE
return S, sum of the scores of S
```
*Remarks.* On 300 random instances (3–4 men and women, scores 1–20) this greedy was optimal 188 times and 3.5 % below the optimum on average. The official solution instead fixes the number of dates to the largest even number $<= min(n, m)$ and weighs scores by how many first/second confessions are still needed; that is correct when all scores are positive (then more dates never hurt), but not if some scores can be negative or zero.]

#answer("jan26-q3a")[#slidenote(deck: "Official solution", where: "June 2025, Q3", says: [“numPairs is the maximum even number lower than or equal to min(n, m)”.], correct: [Only valid if every date has a positive score; with zero or negative scores fewer dates can be better.], why: [The statement only calls the scores "profit"; the model of Q2 allows any sign (the brute-force check uses negative scores too).], kind: "solution") *Constraints:* C1 YES votes ($1 + |Y|$) exceed NO votes, i.e. $|Y| >= n slash 2$ convinced neighbours; C2 a neighbour votes YES only if a selected neighbour (possibly themself) convinces them. *Objective:* minimize the total visiting time $sum_(i in X) T_i$.

*Notation:* $M(i) = {j : M_(i j) = 1}$ (includes $i$); $X$ selected neighbours; $Y = union.big_(i in X) M(i)$ convinced neighbours.

*Candidates:* neighbours $i in.not X$.

*Greedy function (min):* $q(i, Y) = T_i slash |M(i) without Y|$ if $M(i) without Y != emptyset$, $+infinity$ otherwise — the time spent per _newly_ convinced neighbour.

*Pseudocode:*
```pseudo
X <- {}; Y <- {}
while |Y| < n/2 do
    C <- { i not in X : M(i) \ Y nonempty }
    if C = {} then return INFEASIBLE   // never: M[i][i] = 1
    i* <- argmin over C of T_i / |M(i) \ Y|
    X <- X + {i*}; Y <- Y + M(i*)
// optional clean-up
for each i in X, in the order selected:
    if |union of M(j), j in X - {i}| >= n/2 then
        X <- X - {i}
return X, sum of T_i over X
```
*Remarks.* The clean-up removes visits made redundant by later ones. It is still myopic: Chapter 15 shows a six-neighbour instance where it picks neighbours 1 and 3 (time 7) although visiting 2 and 3 (time 6) suffices, and a chromosome that leads the same greedy to the optimum. Over 300 random instances it was optimal 260 times, 4.5 % above the optimum on average.]

#answer("jun26-q3a")[*Constraints:* C1 at least $K$ crew members; C2 every two members collaborated (pair in $E$) or are trained together; C3 at most $M$ courses per astronaut. *Objective:* minimize the cost of the courses.

*Notation:* $S$ crew so far; $"courses"(j)$ courses assigned to $j$; $"Need"(i, S) = {j in S : {i, j} in.not E}$ (courses created if $i$ joins); $"deg"(i) = |{j != i : {i, j} in.not E}|$.

*Candidates:* astronauts $i in.not S$.

*Greedy function (min):* $q(i, S) = sum_(j in "Need"(i, S)) c_(i j)$, the training cost added by $i$; $+infinity$ if $|"Need"(i, S)| > M$ or some $j in "Need"(i, S)$ already has $M$ courses (C3). Ties (always at the first step, where $q = 0$) are broken by the smallest $"deg"(i)$: astronauts who worked with many others make later additions cheap.

*Pseudocode:*
```pseudo
S <- {}; courses[i] <- 0 for all i
while |S| < K do
    C <- { i not in S : |Need(i,S)| <= M and
           courses[j] < M for all j in Need(i,S) }
    if C = {} then return INFEASIBLE
    i* <- argmin over C of ( q(i,S), deg(i) )
    for j in Need(i*,S): courses[j] <- courses[j] + 1
    courses[i*] <- |Need(i*,S)|;  S <- S + {i*}
return S, sum of c_ij over the pairs trained
```
Adding more than $K$ members never helps (it can only add courses), so the loop stops at $K$. On 300 random instances (6–8 candidates) it was optimal in 260 of the 294 feasible ones and failed to find a crew in 3.]

#answer("ch11-r1")[#slidenote(deck: "Official solution", where: "June 2026, Q3(a)", says: [Line 7: “if $sum_(j in S) (1 - e_(i_"best", j)) >= M$ then continue”.], correct: [The test must be "$> M$" (exactly $M$ courses are allowed), and it must also check the course counts of the current members, who each gain one course.], why: [With "$>=$" a candidate needing exactly $M$ courses is wrongly rejected; ignoring members' counts can violate C3.], kind: "solution") $(3 + 5 + 4) slash (6 + 10) = 12 slash 16 = 0.75$.]

#answer("ch11-r2")[$s_(t-1) + sum_i x_(i t) = d_t + s_t + w_t$, with $s_0 = 0$, $0 <= s_t <= h$, $w_t >= 0$.]
