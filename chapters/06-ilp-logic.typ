#import "../template.typ": *

= Integer models II: indicators, big-M and fixed costs

#symbols(
  ($delta in {0, 1}$, [indicator variable: 1 if an activity is "on" (an oil used, a depot open)]),
  ($U, L$, [an upper and a lower bound of a continuous variable]),
  ($M$, [a "big-M" constant: a valid bound used to switch a constraint off. When a story already uses $M$ for something else, the book calls the constant $U$]),
  ($f_j$, [fixed cost paid when activity $j$ is on, whatever its level]),
  ($z$, [the variable standing for a minimum or maximum, as in Chapter 1]),
  ($gamma$, [product variable replacing $delta_1 delta_2$]),
)

#pretest("ch6")[A depot can ship up to 70 000 tons a month, and opening it costs 12 000 £ a month. With $x$ the tons shipped from it, why is "cost $= 12 000 + 0.5 x$" not enough to model the decision to open it?]

Chapter 5 dealt with stories made only of yes/no decisions. Real stories mix them with quantities: _if_ an oil is used, _then_ at least 20 tons; _if_ a depot is open, it can ship up to its capacity, and we pay its fixed cost. The binary variable that switches an activity on or off is called an *indicator*. This chapter shows how to tie indicators to continuous variables and to whole constraints, and how to linearize the two non-linear patterns of the exams: a minimum over pairs and a product of variables.

== Indicators for quantities

Let $x >= 0$ be a quantity with a known upper bound $U$ and $delta$ an indicator. Two constraints cover all the classic sentences.

#btable(columns: (1fr, auto), header: ([sentence], [constraint]),
  [if $x > 0$ then $delta = 1$ ("$delta$ = 0 means $x$ is not used")], [$x <= U delta$],
  [if $delta = 1$ then $x >= L$ ("if used, at least $L$")], [$x >= L delta$],
  [$x$ is 0 or between $L$ and $U$ (semi-continuous)], [$L delta <= x <= U delta$],
)

#fig("/figures/bigm.svg", caption: [$x <= U delta$: with $delta = 0$ only $x = 0$ is allowed; with $delta = 1$ the constraint is harmless as long as $U$ really bounds $x$.], margin: true)Read $x <= U delta$ in both cases: $delta = 0$ forces $x = 0$; $delta = 1$ gives $x <= U$, which must already be true — that is why $U$ must be a *valid upper bound*. If you pick $U$ too small, you cut off good solutions; if you pick it huge, the model stays correct but the LP relaxation gets weak (Chapter 8), and branch & bound slows down. Take the smallest bound the story guarantees: the refining capacity, a market limit, total demand.

Once quantities have indicators, logic between activities is Chapter 5's logic on the $delta$'s: "at least three oils" is $sum_i delta_i >= 3$; "if VEG 1 is used then NON 3 is used" is $delta_1 <= delta_5$.

#think[In "if $delta = 1$ then $x >= 20$", what goes wrong if you forget $x <= U delta$?]Without $x <= U delta$ nothing stops the solver from using an oil ($x > 0$) while claiming $delta = 0$, which escapes both the 20-ton minimum and the "three oils" count. The two constraints work as a pair: one defines what $delta = 0$ means, the other what $delta = 1$ means.

#stopbox("ch6-a")[
  + Write "machine $j$ either does not run, or runs between 4 and 16 hours" with $h_j$ hours and indicator $delta_j$.
  + Which constraint makes $delta = 0$ meaningful, and which makes $delta = 1$ meaningful?
  + Why must $U$ in $x <= U delta$ be a valid upper bound, and why should it be small?
]

== Fixed costs

A fixed cost is paid if an activity happens at all, regardless of its level: opening a depot, renting a machine, starting a generator. With level $x$, unit cost $c$ and fixed cost $f$, the true cost is $0$ if $x = 0$ and $f + c x$ if $x > 0$ — a jump at zero, not a linear function. The model is
$ "cost" = f delta + c x, quad x <= U delta, quad delta in {0, 1}. $
Minimization takes care of the rest: when $x = 0$ the solver prefers $delta = 0$, saving $f$.

#revisit("ch6")["$12 000 + 0.5x$" charges the fixed cost even when the depot ships nothing, and gives no way to close it. Write $12 000 delta + 0.5 x$ with $x <= 70 000 delta$: closing ($delta = 0$) forces $x = 0$ and saves the 12 000.]

Closing an existing facility is the same thing seen from the other side: with $delta = 1$ meaning "kept open", the saving $s$ of closing it appears as $-s(1 - delta)$ in a cost objective. Both appear in the depot exercise of the sheet (Bristol and Northampton may open, Newcastle and Exeter may close).

#example[A small fixed-charge model][
  Three candidate sites $j$ for recycling centres, with monthly fixed cost $f_j$ and capacity $U_j$ tons; districts $i$ produce $w_i$ tons; sending a ton from $i$ to $j$ costs $c_(i j)$. At most two centres may be opened.

  *Variables:* $delta_j in {0,1}$, centre $j$ opened; $x_(i j) >= 0$, tons from district $i$ to centre $j$.

  *Objective:* $min sum_j f_j delta_j + sum_(i, j) c_(i j) x_(i j)$.

  *Constraints:* all waste is collected, $sum_j x_(i j) = w_i$ for all $i$; a closed centre receives nothing and an open one at most its capacity, $sum_i x_(i j) <= U_j delta_j$ for all $j$ (one constraint plays both roles); at most two centres, $sum_j delta_j <= 2$.

  The capacity constraint is the indicator constraint with $x = sum_i x_(i j)$ and $U = U_j$. Writing $x_(i j) <= U_j delta_j$ for every $i$ instead would also be correct but would not enforce the capacity on the total.
]

#yourturn("ch6-yt1")[
  A brewery may run up to three production lines. Line $k$ costs $f_k$ per week if it runs and then produces between $L_k$ and $U_k$ hectolitres; $p_k$ is the profit per hectolitre. Demand is at most $D$. Line 3 may only run if line 1 runs.
  - variables: #blank(w: 5em) $in {0,1}$ and #blank(w: 4em) $>= 0$;
  - objective: $max$ #blank(w: 10em);
  - limits of line $k$: #blank(w: 10em);
  - demand: #blank(w: 8em); $quad$ line 3 needs line 1: #blank(w: 5em).
]

== Switching a whole constraint on and off: big-M

The same idea works for any linear constraint $a^T x <= b$. To require it _only when_ $delta = 1$:
$ a^T x <= b + M (1 - delta), $
where $M$ is large enough that, when $delta = 0$, the constraint holds for every relevant $x$: $M >= max(a^T x) - b$ over the feasible region. Again, the smallest valid $M$ is best.

Disjunctions — "either constraint A or constraint B" — use one binary per alternative: A gets $M(1 - delta)$, B gets $M delta$ (or $M(1 - delta')$ with $delta + delta' >= 1$). Chapter 7 uses this for scheduling ("job $i$ before job $j$, or $j$ before $i$").

=== Maximizing a minimum over pairs

The January 2025 exam asks to maximize the *minimum compatibility* $C_(i k)$ among students in the same class. From Chapter 1, a maximin becomes "$max z$ with $z <= $ each term". But the terms are only those pairs that _end up_ in the same class, which the model decides. So switch each "$z <= C_(i k)$" on only when both students are in class $j$:
$ z <= C_(i k) + U (2 - x_(i j) - x_(k j)) quad forall j, quad forall i < k. $
When $x_(i j) = x_(k j) = 1$ the bracket is 0 and $z <= C_(i k)$. When at most one of them is in class $j$ the bracket is at least 1, and the constraint must become harmless: since $C_(i k) >= 0$ and we can add $z <= 1$ (compatibilities are at most 1), $U = 1$ suffices. That gives the official answer #side[Same thing in logic: $x_(i j) and x_(k j) -> z <= C_(i k)$. Say it this way in the exam too — the official solution does.]
$ z <= C_(i k) + 2 - x_(i j) - x_(k j), quad z <= 1. $

#stopbox("ch6-b")[
  + Write "if $delta = 1$ then $3 x_1 + 2 x_2 >= 12$", knowing $0 <= x_1, x_2 <= 4$. What is the smallest valid $M$?
  + Why is $U = 1$ enough in the maximin constraint above?
  + What happens to the constraint if you choose $M$ too small?
]

== Products of variables

*Two binaries.* $delta_1 delta_2$ is 1 exactly when both are 1 — an AND. Replace it by a new binary (or even continuous) $gamma$ with
$ gamma <= delta_1, quad gamma <= delta_2, quad gamma >= delta_1 + delta_2 - 1. $
When the product appears in a _cost_ to be minimized with a non-negative coefficient, only $gamma >= delta_1 + delta_2 - 1$ is needed: the solver keeps $gamma$ as small as allowed.

*A binary times a bounded variable.* The non-linear programming slides show the general case $w = x_1 dots x_k dot y$ with $x_j$ binary and $0 <= y <= u$:
$ w <= u x_j quad (forall j), quad w <= y, quad w >= u(x_1 + dots + x_k - k) + y, quad w >= 0. $
If some $x_j = 0$, $w = 0$; if all are 1, the last two give $w = y$.

The department-relocation exercise of the sheet is the standard application: the communication cost between departments $i$ and $k$ depends on _where both are_, i.e. on $delta_(i j) delta_(k l)$, which becomes $gamma_(i j k l)$.

== General integers and start-ups

Not every integer is binary. In the power-station exercise $n_(k t)$ is the _number_ of generators of type $k$ running in period $t$, an integer between 0 and the number available. Two patterns appear:

- *Levels per unit:* with $x_(k t)$ the total output of type $k$, "each running unit produces between its minimum and its maximum" is $m_k n_(k t) <= x_(k t) <= M_k n_(k t)$ — the indicator constraint, multiplied by a count.
- *Start-ups:* the number of units started at the beginning of period $t$ is at least the increase, $s_(k t) >= n_(k t) - n_(k, t-1)$, $s_(k t) >= 0$ integer. The start-up cost $sum s_(k t) dot "cost"$ is minimized, so $s_(k t)$ equals the increase when positive and 0 otherwise.

#summary[
  + Indicator pair: $x <= U delta$ (off means zero) and $x >= L delta$ (on means at least $L$), with $U$ a small valid bound.
  + Fixed cost: $f delta + c x$ with $x <= U delta$; closing savings: $-s(1 - delta)$.
  + Conditional constraint: $a^T x <= b + M(1 - delta)$ with $M >= max a^T x - b$.
  + Maximin over pairs chosen by the model: $z <= C_(i k) + 2 - x_(i j) - x_(k j)$ (and $z <= 1$).
  + Product of binaries: $gamma >= delta_1 + delta_2 - 1$ (plus $gamma <= delta_1, delta_2$ if needed); start-ups: $s_t >= n_t - n_(t-1)$.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch6-w1", time: 4, tier: "warm")[$x in [0, 50]$ tons. Write: (a) if $x > 0$ then $delta = 1$; (b) if $delta = 1$ then $x >= 5$; (c) $x = 0$ or $10 <= x <= 50$.]

#exercise("ch6-w2", time: 5, tier: "warm")[With $0 <= x, y <= 10$ and a binary $delta$, write "if $delta = 0$ then $x + y <= 6$" with the smallest valid big-M.]

#tier("practice")

#exercise("ilp-sheet-1", source: "ILP sheet · Ex 1", time: 20)[Take the food-manufacture LP of Chapter 1 (five oils, refining limits 200 t vegetable and 250 t non-vegetable, hardness between 3 and 6, costs 110, 120, 130, 110, 115 €/t, price 150 €/t) and add: (i) if an oil is used, at least 20 tons of it must be used; (ii) the food must contain at least three oils; (iii) if VEG 1 or VEG 2 is used, NON 3 must be used. Formulate as a MIP.]

#exercise("ilp-sheet-8", source: "ILP sheet · Ex 8", time: 25)[Factories at Liverpool (150 000 t/month) and Brighton (200 000 t) supply depots at Newcastle (throughput 70 000 t), Birmingham (50 000), London (100 000) and Exeter (40 000), and six customers C1–C6 (requirements 50, 10, 40, 35, 60, 20 thousand tons), either directly or through a depot. Costs (£/t; — = impossible):

#btable(columns: 7, align: center, header: ([to \\ from], [Liverpool], [Brighton], [Newcastle], [Birmingham], [London], [Exeter]),
  [Newcastle], [0.5], [—], [], [], [], [],
  [Birmingham], [0.5], [0.3], [], [], [], [],
  [London], [1.0], [0.5], [], [], [], [],
  [Exeter], [0.2], [0.2], [], [], [], [],
  [C1], [1.0], [2.0], [—], [1.0], [—], [—],
  [C2], [—], [—], [1.5], [0.5], [1.5], [—],
  [C3], [1.5], [—], [0.5], [0.5], [2.0], [0.2],
  [C4], [2.0], [—], [1.5], [1.0], [—], [1.5],
  [C5], [—], [—], [—], [0.5], [0.5], [0.5],
  [C6], [1.0], [—], [1.0], [—], [1.5], [1.5])

(a) Formulate the LP that minimizes the distribution cost. (b) New depots could open at Bristol (cost 12 k£/month, throughput 30 000 t) and Northampton (4 k£, 25 000 t), and Birmingham could be enlarged by 20 000 t (3 k£). At most four depots are wanted; Newcastle (saving 10 k£) or Exeter (5 k£) or both may close. Costs from Liverpool/Brighton: Bristol 0.6/0.4, Northampton 0.4/0.3; from Bristol to C1, C2, C3, C5, C6: 1.2, 0.6, 0.5, 0.3, 0.8; from Northampton to C2, C4, C5, C6: 0.4, 0.5, 0.6, 0.9. Formulate as a MIP. Could it be an LP?]

#exercise("ilp-sheet-11", source: "ILP sheet · Ex 11", time: 20)[Five departments A–E may each stay in London or move to Bristol or Brighton; no city may host more than three. Yearly benefits of moving (k€): Bristol 10, 15, 10, 20, 5; Brighton 10, 20, 15, 15, 15 (for A–E). Communication costs are $C_(i k) D_(j l)$, with $C_(i k)$ the yearly quantity between departments $i$ and $k$ (thousands of units: A–B 0, A–C 1.0, A–D 1.5, A–E 0, B–C 1.4, B–D 1.2, B–E 0, C–D 0, C–E 2.0, D–E 0.7) and $D_(j l)$ the cost per unit between cities $j$ and $l$ (€: Bristol–Bristol 5, Bristol–Brighton 14, Bristol–London 13, Brighton–London 9, London–London 10). Where should each department go to minimize the overall yearly cost? Formulate as a MIP. #slidenote(deck: "ILP sheet", where: [Ex 11, table $D_(j l)$], says: [Brighton–Brighton shown as "—".], correct: [It must be a number; in H. P. Williams' original problem it is 5 €.], why: [Two departments in the same city still communicate; a dash would mean "impossible". With 5 € the optimum is A, D → Bristol; B, C, E → Brighton.], kind: "sheet")]

#exercise("ilp-sheet-12", source: "ILP sheet · Ex 12", time: 25)[Power stations must meet the daily load: 15 000 MW from 12 p.m. to 6 a.m., 30 000 MW 6–9 a.m., 25 000 MW 9 a.m.–3 p.m., 40 000 MW 3–6 p.m., 27 000 MW 6–12 p.m. (the demand holds for the whole period). There are 12 generators of type 1, 10 of type 2 and 5 of type 3:

#btable(columns: 6, align: center, header: ([type], [min MW], [max MW], [€/h at min], [€/h per MW above min], [start-up €]),
  [1], [850], [2000], [1000], [2], [2000], [2], [1250], [1750], [2600], [1.3], [1000], [3], [1500], [4000], [3000], [3], [500])

The generators working must be able to meet a load increase of up to 15 % within their limits. Which generators should work in which periods to minimize the total cost? Construct a MIP. #slidenote(deck: "ILP sheet", where: "Ex 12", says: [“the demands are for the whole indicated period, not per hour”.], correct: [The demands are power levels (MW) that must be met at every moment of the period; hourly costs are multiplied by the period length.], why: [MW measure power, not energy. Also unstated: whether the day repeats (start-ups at 12 p.m. counted against the evening) — Williams assumes it does.], kind: "sheet")]

#tier("exam")

#exercise("jan25-q2bd", source: "Final Jan 2025 · Q2(b–d)", time: 25, tier: "exam")[The class-assignment problem of #exref("jan25-q2a") ($n$ students, $m$ classes of size between $l$ and $u$, good students $G$, bad students $B$, compatibilities $C_(i k) in [0, 1]$, binary $x_(i j)$). (b) Give linear constraints that express that the number of good students in each class is at least double the number of bad students. (c) Express the objective function as a linear function and the direction of optimization; if more variables or constraints are needed, give their meaning and formal description. (d) Are other linear constraints needed for a correct ILP model? If so, give their meaning and formal description (and any extra variables).]

#tier("review", note: [from Chapters 1–5])

#exercise("ch6-r1", source: "review of Ch. 5", time: 3, tier: "review")[Write "if $a$ and $b$ then not $c$" for binaries $a, b, c$.]

#exercise("ch6-r2", source: "review of Ch. 4", time: 5, tier: "review")[A tableau gives $z = 4 - x_2 + 3 x_5$ and the only row in which $x_2$ appears is $x_1 = 2 + x_2$. What do you conclude?]
