#import "../template.typ": *

= Exam training

#symbols(
  ([Q1, Q2, Q3], [the three questions of the final: simplex (2.1 points), ILP modelling (3.9), heuristics (4.0)]),
  ($x_(e t)$, [mock exam: 1 if exam $e$ is held in time slot $t$]),
  ($x_(v d)$, [case study: 1 if virtual machine $v$ is placed in datacenter $d$]),
)

#pretest("ch16")[You have 3 hours for 10 points: 2.1 for Q1, 3.9 for Q2 and 4 for Q3. How many minutes would you plan for each, and in which order would you answer them?]

Everything in this chapter mixes topics on purpose. Practising one technique at a time builds skill; practising a _mixture_ trains the part the exam actually tests — recognizing which technique a question needs. The chapter is meant for two sittings: the first four sections in one afternoon (about three hours), the mock exam on another day, in three uninterrupted hours, without notes.

== The exam

#btable(columns: (auto, auto, 1fr), header: ([question], [points], [what it always asks]),
  [Q1], [2.1], [A $2 times 4$ LP in canonical form and a feasible basis: basic values, objective, reduced costs, optimality of each non-basic variable with the ratio test (June); or optimality proof plus "do we need to branch?" (January). Answered in the gaps of the statement.],
  [Q2], [3.9], [A story. (a) explain an OPL fragment; then variables (if not given), constraints with meaning, objective with direction; "are other constraints needed?".],
  [Q3], [4.0], [Same story. (a) greedy: candidates, $q(dot)$ with formula and text, tailored pseudocode. (b) BRKGA: chromosome, fitness, decoder (as a change of the greedy), sometimes a two-chromosome illustration.],
)

The exam lasts 3 hours; Q2 and Q3 go on separate answer sheets. No notes are allowed: every formula in this book that you need has to be in your head, which is why each chapter ended with retrieval boxes and a five-line summary.

== Exam-day playbook

*Time.* Plan 25 minutes for Q1, 65 for Q2, 70 for Q3 and keep 20 for checking. Start with Q1: it is mechanical, it settles nerves and it is fast points. If Q1 is not finished after 30 minutes, leave the last gap and come back. The exam room is no place to learn new knots: answer in the order you used in the mock exam.

*Partial credit.* Graders score parts, not the whole. In Q2, a variable with a clear meaning and a constraint described in words earn points even if the formula has a slip; a formula without meaning may not. In Q3, the candidates and the greedy function are worth points on their own: write them first, then the pseudocode. Never leave a part blank: "the remaining constraint is each student in exactly one class: $sum_j x_(i j) = 1$" can be one line.

*Checking conditions, per question.*
- Q1: plug the basic solution into both equations; check that the objective constant equals $c^T x$ at the basic solution; the ratio test only uses rows with negative coefficient; "$+infinity$" when there are none; branching candidates are the fractional values, with $floor$ and $ceil$.
- Q2: every "for all" has its index range; units match; each sentence of the story is used once; the objective direction is written; extreme cases (nothing selected, an empty class, a single job) behave.
- Q3: $q$ has a direction and a value for infeasible candidates; the loop terminates; there is an INFEASIBLE exit; the data structures are updated after each insertion; the decoder changes the greedy in a way that _matters_ (no key multiplied by 0); the fitness says what happens to infeasible decodings.

#revisit("ch16")[About 25 / 65 / 70 minutes plus 20 of checking, in the order Q1, Q2, Q3. Points per minute are similar for all three; Q1 first because it is the most mechanical.]

== Quick-fire drill

#exercise("drill", time: 20, tier: "practice")[Answer each in one line, without looking back. Then mark which chapter each comes from — that is the skill being trained.
+ The tableau row of $x_4$ is $x_4 = 3 + 2 x_1 - x_5$. Which non-basic variable does it limit, and to what value?
+ Linearize "if $a$ then $b$ or $c$".
+ RCL threshold, minimization, $q in {4, 6, 9}$, $alpha = 0.5$?
+ Write "exactly two of $x_1, dots, x_5$".
+ The LP optimum has $x_2 = 7 slash 3$. Branching subproblems?
+ Is $x^2 + y^2 <= 4$ convex?
+ Number of genes for a BRKGA with one key per (student, class) pair, 30 students, 3 classes?
+ Phase I ended with value 0.5. Conclusion?
+ In OPL, the declaration of a binary matrix `y` over `I` × `J`.
+ What makes $z$ equal to $max_i u_i$ in a minimization?
+ First or best improvement: which scans the whole neighbourhood?
+ $|{1, 2, 3} plus.o {3, 4}|$?
+ Big-M for "if $delta = 1$ then $x + y <= 4$" with $0 <= x, y <= 5$?
+ All reduced costs are $>= 0$, one is 0. Optimal? Unique?
+ The greedy function of nearest neighbour?
+ "Once closed, stays closed" with $o_t$?
+ The fitness of an infeasible decoded chromosome?
+ Maximum number of bases of a $2 times 4$ system?
+ Linearize $w = x y$, $x, y$ binary.
+ In path relinking, what is returned?]

== Interleaved problems

#exercise("jun24-q3", source: "Final Jun 2024 · Q3", time: 35)[For the rental problem of #exref("jun24-q2a") (jobs as rectangles of duration $h_k$ and memory $w_k$, rental plans $H_i times W_j$ with cost $p_(i j)$), develop a heuristic including the objective function. (a) Greedy: set of candidates, greedy function $q(dot)$ with mathematical notation and a short text, tailored pseudocode. (b) BRKGA: structure of the chromosome, fitness function, pseudocode of the decoder tailored to the problem.]

#exercise("jan25-q3", source: "Final Jan 2025 · Q3", time: 35)[The same for the class-assignment problem of #exref("jan25-q2a").]

#exercise("mix-1", source: "new, mixed", time: 12)[$min -2x - 3y$ s.t. $x + 2y + s_1 = 5$, $2x + y + s_2 = 5$, all variables $>= 0$. (a) For the basis $(x, y)$ give the basic solution, the objective and the reduced costs. Is it optimal? (b) If $x, y$ must be integer, which subproblems does branch & bound create first? (c) Which chapter's example is this?]

#exercise("mix-2", source: "new, mixed", time: 15)[The university wants defibrillators in some of its sites $j in J$ (cost $c_j$). Building $i in I$ is covered by site $j$ if $a_(i j) = 1$. Every building must be covered at least once, and the sports hall $h$ at least twice. (a) Write the ILP. (b) Give a greedy function for a constructive heuristic, and say what is myopic about it.]

== A case study: placing virtual machines

The application slides describe placing virtual machines (VMs) in a federation of datacenters (DCs) to use cheap, green energy while keeping users close. Here is a toy version, worked from statement to BRKGA. Try each step before reading on; the questions are #exref("case-a") to #exref("case-d").

*Story.* Five VMs must be placed in three DCs. VM $v$ needs $w_v$ units of capacity: $w = (3, 2, 4, 2, 2)$. DC $d$ offers capacity $K_d$: $(10, 8, 7)$ and energy at price $pi_d$ per unit: $(3, 5, 2)$. Latency limits allow VM 1 only in DCs 1 or 3, VM 2 only in DCs 2 or 3, the others anywhere. Minimize the energy cost $sum_v pi_(d(v)) w_v$.

*Model.* Binary $x_(v d)$ for allowed pairs; $sum_d x_(v d) = 1$ for each VM; $sum_v w_v x_(v d) <= K_d$ for each DC; minimize $sum pi_d w_v x_(v d)$. The optimum costs 32: VMs 1, 2, 5 in DC 3 (exactly full, 7 units at price 2) and VMs 3, 4 in DC 1.

*Greedy.* Candidates $chevron.l v, d chevron.r$; VMs by decreasing size; $q = pi_d w_v$ (min) over allowed DCs with room. VM 3: DC 3 (8). VM 1: DC 3 (6) — DC 3 now holds 7 units, full. VM 2: only DC 2 is left (10). VMs 4 and 5: DC 1 (6 each). Cost 36.

*Local search.* No single move and no swap improves 36: DC 3 is full, and any exchange either overflows it or costs more. The greedy result is a local optimum of both neighbourhoods — the improvement needs three simultaneous changes (VM 3 out of DC 3, VMs 2 and 5 in).

*GRASP and BRKGA.* Randomizing the order of the VMs helps. A random-key decoder that processes VMs by increasing key and then applies the same greedy choice, with keys $(0.2, 0.3, 0.9, 0.8, 0.4)$, places VMs 1, 2, 5 first — all in DC 3 — and then VMs 4 and 3 in DC 1: cost 32, optimal.

#exercise("case-a", source: "case study", time: 8)[Write the ILP of the case study in OPL, with the allowed pairs given as a 0–1 matrix `ok[v][d]`.]

#exercise("case-b", source: "case study", time: 8)[Show that the greedy result is a local optimum of the "move one VM" neighbourhood by listing the feasible moves and their costs.]

#exercise("case-c", source: "case study", time: 6)[Propose a GRASP RCL for the case-study greedy and explain why GRASP has a chance to find 32 although the greedy does not.]

#exercise("case-d", source: "case study", time: 8)[Write the decoder sketched above (keys as priorities) and a second decoder that multiplies $q$ by a key per VM. Which one can reach 32 on this instance?]

== Mock exam

Three hours, no notes, answers on paper. The solutions are with the other answers at the back.

#exercise("mock-q1", source: "Mock exam · Q1 (2.1 pts.)", time: 25, tier: "exam")[Consider the LP
$ min -2 x_0 + 2 x_1 + 2 x_2 + x_3 quad "s.t." quad x_0 + x_2 + x_3 = 2, quad -x_1 + x_3 = -2, quad x_i >= 0. $
The variables $(x_2, x_1)$ form a feasible basis. (a) Give the values of the basic variables. (b) Give the objective value at the basic solution. (c) Give the reduced costs of $x_0$ and $x_3$. (d) Does $x_0$ satisfy the optimality conditions? If not, give the best value it can be assigned according to the ratio test ($+infinity$ if none). (e) The same for $x_3$.]

#exercise("mock-q2", source: "Mock exam · Q2 (3.9 pts.)", time: 65, tier: "exam")[The faculty schedules the $n$ final exams of a semester into $m$ consecutive time slots $1, dots, m$. Exam $e$ has $s_e$ students; at most $S$ students can sit exams in the same slot. $A$ is an $n times n$ symmetric 0–1 matrix with $A_(e f) = 1$ if exams $e$ and $f$ share at least one student. Two exams that share a student cannot be in the same slot, nor in consecutive slots. The faculty wants the exam period to end as early as possible. Binary variables $x_(e t)$: "exam $e$ is held in slot $t$".
(a) (0.6) Give an informal description of the meaning of: `forall (t in 1..m) sum (e in 1..n) s[e] * x[e][t] <= S;`
(b) (0.8) Give linear constraints expressing that every exam is held exactly once.
(c) (1.3) Give linear constraints for the conflicts (same and consecutive slots).
(d) (1.2) Express the objective as a linear function with its direction; add variables and constraints if needed, with type and meaning.]

#exercise("mock-q3", source: "Mock exam · Q3 (4 pts.)", time: 70, tier: "exam")[For the timetabling problem of the previous question, develop a heuristic including the objective function. (a) Greedy: the set of candidates, the greedy function $q(dot)$ (notation and a short text), and the tailored pseudocode. Run it on: 6 exams with $s = (40, 30, 50, 20, 60, 30)$, $S = 100$, conflicts 1–2, 1–3, 2–3, 3–4, 4–5, 5–6, and $m = 8$. (b) BRKGA: chromosome, fitness and decoder.]

#summary[
  + Q1 25 min, Q2 65, Q3 70, checking 20; start with Q1.
  + Partial credit: meanings and the greedy function earn points even when a formula slips.
  + Check Q1 by substitution, Q2 by extreme cases and units, Q3 by direction, infeasible value, termination and INFEASIBLE exit.
  + Mixed practice trains recognition: name the technique before solving.
  + A greedy can be stuck at a local optimum that moves and swaps cannot leave; randomized orders (GRASP, BRKGA keys) escape it.
]
