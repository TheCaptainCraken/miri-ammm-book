#import "../template.typ": *

== Chapter 15

#answer("ch15-yt1")[$|T|$ genes, one key per task (or $|T| dot |C|$, one per pair). Process tasks in decreasing order of $"ch"_t dot r_t$ (keys perturb the order), and choose $c$ minimizing $q' = "ch"_t dot ("used"(c) + r_t) slash R_c$ — or, with one key per pair, $"ch"_(t c) dot ("used"(c) + r_t) slash R_c$. Fitness: the maximum load of the decoded assignment; if a task fits nowhere, a penalty such as $1000 +$ the unassigned request.]

#answer("ch15-a")[(a) Every vector of keys in $[0, 1)$ is a valid chromosome; feasibility is ensured by the decoder. (b) A feasible solution and its fitness (objective, possibly penalized). (c) The elite copied unchanged; new random mutants; children of an elite and a non-elite parent with gene-wise inheritance probability $rho$ from the elite parent.]

#answer("ch15-w1")[$0.7^5 = 0.168$.]

#answer("ch15-w2")[1 5 4 3 2 6. The edges $(1, 2)$ and $(5, 6)$ are replaced by $(1, 5)$ and $(2, 6)$; the edges inside the segment are the same, traversed backwards. Inversion is a 2-opt move.]

#answer("ch15-p1")[All keys 1: the weighted distances are the real ones, so the decoder is plain nearest neighbour from 1: tour 1–4–3–2–5–1, length 36. Chromosome 2 made edge 25 very cheap (1.2) and edge 34 relatively dear, so the construction went 1–2–5 first and ended with 3–4–1: length 40. Different keys, different constructions.]

#answer("ch15-p2")[At the first step $S = emptyset$, so $q(i, emptyset) = 0$ for everybody and $"ch"_i dot 0 = 0$: all candidates tie and the chromosome plays no role (the same holds later whenever a candidate adds no cost). Fix: $q'(i, S) = "ch"_i dot (1 + q(i, S))$, or use the keys to break ties ($q' = (q, "ch"_i)$ lexicographically), or take the official first-step rule ($q = $ number of non-colleagues) times $"ch"_i$.]

#answer("lab4-d")[Typical decoder for P2: one key per task; tasks are processed in decreasing order of $r_t$ (or by key) and each goes to the feasible computer with the smallest $"ch"_t dot$ (resulting load); fitness = maximum load, with a penalty for unassigned tasks. Tuning usually shows that a population of a few times the number of genes, $p_e approx 0.1$–$0.2$, $p_m approx 0.1$–$0.2$, $rho approx 0.7$ work well. BRKGA is slower per solution than GRASP but improves steadily with time; on large instances both beat CPLEX within the time limit.]

#answer("jun25-q3b")[*Chromosome:* $|"ch"| = n dot m$, one key per couple $chevron.l i, j chevron.r$. *Fitness:* the total score of the decoded dates; if the decoder cannot satisfy C4 (no past participant), a large penalty. *Decoder:* the greedy of #exref("jun25-q3a", word: false) with $q'(chevron.l i, j, r chevron.r) = "ch"_(i j) dot f_(i j)$ if $r = F$, $"ch"_(i j) dot s_(i j)$ if $r = S$ (maximized; positive scores assumed — with negative scores use $"ch"_(i j) dot |dot|$ or add the key instead). Only the line computing $q$ changes. Variant: $2 n m$ keys, one per couple and role.]

#answer("jan26-q3b")[*Chromosome:* $|"ch"| = n$, one key per neighbour. *Fitness:* $sum_(i in X) T_i$ of the decoded selection (it is always feasible since $M_(i i) = 1$). *Decoder:* the greedy of #exref("jan26-q3a", word: false) with $q'(i, Y) = "ch"_i dot T_i slash |M(i) without Y|$ (minimized), then the same clean-up. Worked example 15.2 shows a chromosome that turns a greedy result of 7 into the optimum 6.]

#answer("jun26-q3b")[*Chromosome:* $|"ch"| = N$, one key per astronaut. *Fitness:* total training cost; $+$ a large penalty if the decoder returns INFEASIBLE. *Decoder:* the greedy of #exref("jun26-q3a", word: false) with $q'(i, S) = "ch"_i dot (1 + q(i, S))$ (the $+1$ keeps the key effective when $q = 0$), ties still broken by fewer non-colleagues.

*Illustration ($K = 2$, at most $M = 1$ course).* Non-colleague counts: $"deg" = (1, 2, 1, 2)$. Chromosome $(1, 1, 1, 1)$: at $S = emptyset$ every $q' = 1$; ties → member 1 (deg 1, lowest index). $S = {1}$: member 2 adds 0 (they collaborated), member 3 adds 0, member 4 adds $c_(14) = 1$: $q' = (1, 1, 2)$; tie between 2 and 3 broken by deg → member 3. Crew ${1, 3}$, cost 0. Chromosome $(1, 0.2, 1, 1)$: $q' = (1, 0.2, 1, 1)$ → member 2. $S = {2}$: member 1 adds 0, member 3 adds $c_(23) = 2$, member 4 adds $c_(24) = 3$: $q' = (1, 3, 4)$ → member 1. Crew ${1, 2}$, cost 0. Two chromosomes, two crews.

*The official example.* Its greedy function (eq. 1) sums $c_(i j)(1 - e_(i j))$ over $j in S$, but the numbers shown ($q = [-, 5, 2, 4]$ after $S = {1}$) are row sums over _all_ $j != i$. Under the row-sum reading the official decoder builds ${1, 3}$ and ${2, 1}$, as printed. Under eq. 1 as written, $q = [-, 0, 0, 1]$ after $S = {1}$ and both chromosomes build ${1, 2}$ — the illustration would fail to show two different solutions.]

#answer("ch15-r1")[#slidenote(deck: "Official solution", where: "June 2026, Q3(b) example", says: [After $S = {1}$: "$q = [-, 5.0, 2.0, 4.0]$; crew member 3 is selected".], correct: [By eq. 1 ($sum_(j in S)$) the values are $[-, 0, 0, 1]$; 5, 2, 4 are the row sums $sum_(j != i) c_(i j)(1 - e_(i j))$.], why: [The formula and the example disagree; both readings are solved in the answer to #exref("jun26-q3b", word: false).], kind: "solution") 4 (two pairs on each side).]

#answer("ch15-r2")[Concave ones (minimizing a concave term would otherwise take chords below the curve).]
