#import "../template.typ": *

= Integer models III: time, sequences and several periods

#symbols(
  ($t = 1, dots, T$, [time periods (months, years)]),
  ($s_t$, [stock carried from period $t$ to $t + 1$ ($s_0$ given, usually 0)]),
  ($o_t, w_t$, [binary "open" and "working" in period $t$]),
  ($S_i, p_i$, [start time and duration of task $i$]),
  ($o_(i j)$, [order binary: 1 if task $i$ is before task $j$]),
  ($H$, [a horizon, used as big-M in scheduling: no task ends after $H$]),
)

#pretest("ch7")[Two inspections of 3 and 5 hours must both be done by the same person, starting at times $S_1, S_2 >= 0$, without overlapping. Write "they do not overlap" as linear constraints. How many binary variables do you need?]

Time enters a model in two ways. Either the horizon is cut into *periods*, and every variable gets an index $t$ (how much to make in March, whether the mine is open in year 3); or time is a *continuous quantity* that the model decides (when does job $k$ start?). The first gives multi-period models held together by balance equations; the second gives scheduling models held together by disjunctions. The June 2024 exam is a scheduling model in two dimensions at once.

== Several periods: balances carry the story forward

#example[Three months of one product][
  Demand is 40, 70, 50 units in months 1–3; the plant makes at most 60 units a month at 10 € each; storing a unit for a month costs 2 €; no initial stock, at most 30 units in store.

  *Variables:* $m_t >= 0$ made in month $t$; $s_t >= 0$ in store at the end of month $t$.

  *Balance:* stock in + production = demand + stock out, for each month:
  $ s_(t-1) + m_t = d_t + s_t quad (t = 1, 2, 3), quad s_0 = 0. $
  *Limits:* $m_t <= 60$, $s_t <= 30$. *Objective:* $min sum_t (10 m_t + 2 s_t)$.

  Month 2 needs 70 > 60, so 10 units must be made in month 1 and stored: $m = (50, 60, 50)$, $s = (10, 0, 0)$, cost $1600 + 20 = 1620$ €.
]

Everything else about multi-period models is the single-period model of Chapters 1, 5 and 6 repeated with an index $t$ and glued by the balance. Write the balance first, then the initial and final conditions (the factory planning exercise wants 50 units of each product in stock at the end of June), then the per-period limits. Think of a ship's log: one line per watch, and every line starts from the position the previous one recorded.

=== Decisions that cannot be undone

Some yes/no decisions are monotone in time. A mine that is closed for good cannot reopen; royalties are payable as long as it is kept open:
$ o_(t+1) & <= o_t quad ("once closed, closed"), \
  w_t & <= o_t quad ("only open mines work"). $
Royalties are $sum_t "roy" dot o_t$, and the solver will close a mine as soon as it is not needed any more. A machine that must be down once in six months is the opposite: $sum_t d_t = 1$ with $d_t$ binary, or an integer count for a group of identical machines.

#yourturn("ch7-yt1")[
  A warehouse may be rented in each of 4 quarters; once the contract is cancelled it cannot be renewed. Let $r_t in {0,1}$ mean "rented in quarter $t$" and $q_t >= 0$ the goods stored there (capacity 500).
  - cannot be renewed after cancelling: #blank(w: 8em) for $t = 1, 2, 3$;
  - goods only in a rented warehouse: #blank(w: 8em);
  - rent of 2000 € per quarter rented, in the objective: #blank(w: 8em).
]

#stopbox("ch7-a")[
  + Write the stock balance of product $p$ in month $t$ with production $M_(p t)$, sales $S_(p t)$ and stock $H_(p t)$.
  + How do you express "the stock at the end of the horizon must be 50"?
  + Write "a mine that is worked in year $t$ must be open in year $t$, and a closed mine stays closed".
]

== Sequencing: either before or after

Two tasks on one resource must not overlap: either $i$ ends before $j$ starts, or $j$ ends before $i$ starts:
$ S_i + p_i <= S_j quad or quad S_j + p_j <= S_i. $
An "or" between two constraints is a disjunction; one binary $o_(i j)$ ("$i$ before $j$") and a big-M switch them:
$ S_i + p_i <= S_j + H (1 - o_(i j)), quad S_j + p_j <= S_i + H o_(i j). $
With $o_(i j) = 1$ the first constraint is active and the second is relaxed by $H$; with $o_(i j) = 0$ the reverse. The constant $H$ must make a relaxed constraint always true: a *horizon* (an upper bound on any end time, such as the sum of all durations and waiting times) works.

#revisit("ch7")[One binary $o$: $S_1 + 3 <= S_2 + H(1 - o)$ and $S_2 + 5 <= S_1 + H o$, with $H$ at least the latest possible end, e.g. $H = 8$ if nothing else forces idle time. In general $n$ tasks need one binary per pair, $binom(n, 2)$. #question(label: [Think first])[Why is one binary per _unordered_ pair enough, while the June 2024 exam uses one per _ordered_ pair?] In one dimension, "$i$ before $j$" and "$j$ before $i$" are complementary, so one binary per pair suffices. In two dimensions (time _and_ memory) there are four ways for two rectangles to be apart — left, right, below, above — and at least one must hold. Then it is convenient to have a binary per ordered pair and per dimension and to require their sum to be at least 1. That is the June 2024 model. #figure(image("/figures/packing.svg", width: 60%), caption: [June 2024: each job is a rectangle (duration × memory) inside the rented box $H_i times W_j$; two jobs are compatible if one is entirely after the other in time or entirely above it in memory.])]

#example[Packing jobs in time and memory (June 2024, the idea)][
  For jobs $k != k'$ define binaries $a_(k k')$ = "$k$ runs after $k'$ has finished" and $l_(k k')$ = "$k$'s memory block lies above $k'$'s". Link each to its meaning with a big-M that is valid by the bounds $0 <= "tr"_k <= H_r - h_k$ (the longest rental):
  $ "tr"_k >= "tr"_(k') + h_(k') - H_r (1 - a_(k k')), quad "lc"_k >= "lc"_(k') + w_(k') - W_s (1 - l_(k k')). $
  Then forbid overlap: for every pair $k < k'$,
  $ a_(k k') + a_(k' k) + l_(k k') + l_(k' k) >= 1. $
  The official solution writes the link as $"tr"_k - "tr"_(k') - h_(k') >= (1 - a_(k k'))(1 - H_r - h_(k'))$: the same constraint with a slightly different (also valid) big-M. Any valid constant earns the points; say why it is valid.
]

#stopbox("ch7-b")[
  + Write "job 1 (2 h) and job 2 (4 h) do not overlap" with horizon 10.
  + What must a big-M satisfy in a disjunction, and what is wrong with $M = 10^9$?
  + How many order binaries does a schedule of 6 tasks on one machine need?
]

== Pairs of activities, travel and waiting

Two smaller patterns complete the toolbox.

*Pairs done by the same agent.* If a team may investigate two outbreaks and then must travel between them, the travel time depends on _which two_ it gets — a product of assignment binaries. Use a pair variable as in Chapter 6: $y_(i a b) >= x_(i a) + x_(i b) - 1$, and add $d_(a b) y_(i a b)$ to the team's total time. The objective "time until all investigations are finished" is a min-max: $z >= $ each team's total.

*Waiting windows.* "After examining patient $i$, wait between $l_i$ and $u_i$ minutes before the check-up" is a pair of linear constraints between two start times, $l_i <= B_i - (A_i + p_i) <= u_i$. The disjunctions then forbid overlaps among _all_ examination and check-up tasks.

*Minimum purchases.* "If you buy from supplier $i$ in month $t$, buy at least $ell_i$" is the semi-continuous pattern of Chapter 6 with a period index; surplus that cannot be stored can be thrown away, which is just a waste variable $w_t >= 0$ in the balance.

#tip(label: [The chapter in five lines])[
  + Multi-period: index by $t$; glue periods with balances $s_(t-1) + "in"_t = "out"_t + s_t$; add initial and final conditions.
  + Irreversible decisions: $o_(t+1) <= o_t$; activity only when open: $w_t <= o_t$.
  + Non-overlap of $i$ and $j$: one order binary and two big-M constraints, $M$ = a valid horizon.
  + Two dimensions (June 2024): four relative positions, one binary each, sum $>= 1$.
  + Pairs handled by the same agent: pair variable $y >= x_a + x_b - 1$; "finish everything as soon as possible": min-max.
]

== Exercises

#chapter-time()

=== Warm-up

#exercise("ch7-w1", time: 4, tier: "warm")[In the three-month example, write the model in OPL-like notation with `forall (t in 1..3)`, taking care of $s_0$.]

#exercise("ch7-w2", time: 4, tier: "warm")[Three tasks share one machine. List the order binaries and write the two constraints for the pair (1, 3).]

=== Practice

#exercise("ilp-sheet-6", source: "ILP sheet · Ex 6", time: 15)[A medical company buys a drug from a set $M$ of suppliers. It needs $d_t$ units in month $t = 1, dots, T$ (entirely consumed). One unit from supplier $i$ in month $t$ costs $c_(i t)$ €, but if it buys from $i$ in a month it must buy at least $ell_i$ units that month. Surplus can be stored, at most $h$ units from one month to the next; beyond that it can be thrown away. Minimize the purchasing cost. Formulate as a MIP.]

#exercise("ilp-sheet-7", source: "ILP sheet · Ex 7", time: 20)[A nurse has a set $N$ of patients. Patient $i$ needs an examination of $p_i$ minutes, then, after waiting between $l_i$ and $u_i$ minutes, a check-up of $q_i$ minutes. The nurse cannot be in two places at once; walking between rooms takes no time. Minimize the total time needed to tend to all patients. Formulate as a MIP.]

#exercise("ilp-sheet-4", source: "ILP sheet · Ex 4", time: 15)[An outbreak is observed in $N$ locations and $M$ teams can investigate. Team $i$ needs $t_(i j)$ hours for location $j$. A team investigates zero, one or two outbreaks; with two, it travels from one location to the other in $d_(j_1 j_2)$ hours (symmetric). Each outbreak is investigated by one team. Minimize the time until all locations are investigated. Formulate as a MIP.]

#exercise("ilp-sheet-10", source: "ILP sheet · Ex 10", time: 20)[A mining company plans five years for four mines; at most three can operate in a year. A mine not operated in a year must still be kept open (royalties paid) if it will be operated later; once closed it cannot reopen. Yearly royalties: 5, 4, 4, 5 M€. Yearly extraction limits: 2, 2.5, 1.3, 3 million tons. Ore qualities: 1.0, 0.7, 1.5, 0.5; a blend has the weighted average quality, and each year the total output must be blended to exactly 0.9, 0.8, 1.2, 0.6, 1.0 (years 1–5). Blended ore sells at 10 €/ton. Which mines should operate each year, and how much should they produce? Formulate as a MIP. #slidenote(deck: "ILP sheet", where: "Ex 10", says: [extraction limits "2 × 10⁶ tons €".], correct: [The limits are in tons; "€" is a typo. (Williams' original also discounts future profits by 10 % a year; the sheet drops that.)], why: [A quantity of ore cannot be measured in euros.], kind: "sheet")]

#exercise("ilp-sheet-9", source: "ILP sheet · Ex 9", time: 25)[A factory makes seven products on four grinders, two vertical drills, three horizontal drills, a borer and a planer. Profit (€/unit) and hours per unit:

#table(columns: (auto,) + (1fr,) * 7, align: center, table.header([], [P1], [P2], [P3], [P4], [P5], [P6], [P7]),
  [profit], [10], [6], [8], [4], [11], [9], [3],
  [grinding], [0.5], [0.7], [—], [—], [0.3], [0.2], [0.5],
  [vert. drilling], [0.1], [0.2], [—], [0.3], [—], [0.6], [—],
  [horiz. drilling], [0.2], [—], [0.8], [—], [—], [—], [0.6],
  [boring], [0.05], [0.03], [—], [0.07], [0.1], [—], [0.08],
  [planing], [—], [—], [0.01], [—], [0.05], [—], [0.05])

Machines down for maintenance: January 1 grinder; February 2 horizontal drills; March the borer; April 1 vertical drill; May 1 grinder and 1 vertical drill; June the planer and 1 horizontal drill. Market limits per month (P1–P7): Jan 500, 1000, 300, 300, 800, 200, 100; Feb 600, 500, 200, 0, 400, 300, 150; Mar 300, 600, 0, 0, 500, 400, 100; Apr 200, 300, 400, 500, 200, 0, 100; May 0, 100, 500, 100, 1000, 300, 0; Jun 500, 500, 100, 300, 1100, 500, 60. Up to 100 units of each product can be stored at 0.5 € per unit per month; no initial stock; 50 of each wanted at the end of June. A month has 24 days of two 8-hour shifts. (a) When and what should be made to maximize profit? Formulate as an LP. (b) Instead of the given maintenance plan, choose the best month for each machine to be down: each machine once in the six months, except that only two of the four grinders need maintenance. Extend the model. Can it be an LP?]

=== Exam level

#exercise("jun24-q2bd", source: "Final Jun 2024 · Q2(b–d)", time: 25, tier: "exam")[The rental problem of #exref("jun24-q2a") (jobs with memory $w_k$ and duration $h_k$; rental durations $H_1 < dots < H_r$, capacities $W_1 < dots < W_s$, costs $p_(i j)$; variables $c_(i j)$, $"tr"_k$, $"lc"_k$). (b) Give a linear constraint expressing that exactly one rental plan is chosen. (c) Express the objective function as a linear function and its direction. (d) Are other linear constraints needed to obtain a correct ILP model? If so, give their meaning and formal description; if more variables are needed, give their meaning.]

=== Spaced review

_From Chapters 3–6._

#exercise("ch7-r1", source: "review of Ch. 6", time: 4, tier: "review")[Write the fixed-charge cost of a line that produces $x <= 800$ units at 3 € each plus 500 € if it runs.]

#exercise("ch7-r2", source: "review of Ch. 3", time: 4, tier: "review")[Which pairs of $(x_0, x_1, x_2)$ are bases of $x_0 + x_1 + x_2 = 4$, $x_0 - x_1 = 0$? Which are feasible?]
