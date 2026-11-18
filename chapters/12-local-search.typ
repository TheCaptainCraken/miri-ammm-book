#import "../template.typ": *

= Local search

#symbols(
  ($N(S)$, [neighbourhood of solution $S$: the solutions reachable by one move]),
  ([move], [a small change that turns $S$ into a neighbour (remove, insert, exchange, reassign…)]),
  ($S'$, [a neighbour, $S' in N(S)$]),
  ($f(S)$, [objective, minimized]),
  ([first / best improvement], [the two ways of choosing which improving neighbour to accept]),
)

#pretest("ch12")[The greedy assigned four tasks with a maximum load of 0.95. You may move _one_ task to another computer at a time, and only accept moves that lower the maximum load. Can you end up worse than the optimum while no single move helps any more?]

The greedy never looks back: a decision made at step 2 stays even when step 7 shows it was poor. Local search is the second phase of a heuristic: take a complete solution and keep improving it by small changes until no small change helps. It is simple, it is fast, and it is the engine inside GRASP and path relinking. Picture a boat in fog: it sees only the water a few metres around the hull, so it moves while some nearby spot looks better and drops anchor when none does — not necessarily in the best bay of the coast.

== Neighbourhoods and local optima

#definition[Neighbourhood][A neighbourhood $N$ assigns to each solution $S$ a set $N(S)$ of solutions obtained by one *move* — a small, well-defined change. A solution is a *local optimum* with respect to $N$ if no $S' in N(S)$ is better.]

The choice of moves _is_ the design. The slides list the usual ones for subset problems: *remove* one element of $S$; *exchange* one element of $S$ with one outside; exchange two elements of $S$ for one outside. For assignment problems: *reassign* one item to another place, or *swap* the places of two items. For the TSP: *2-opt*, remove two edges and reconnect the two paths the other way.

#think[Why must a move keep the solution feasible, or at least be checked for feasibility?]A neighbourhood trades power against cost. A larger neighbourhood (exchange two-for-one instead of one-for-one) contains more improvements and gives better local optima, but each step examines more neighbours. A local optimum for one neighbourhood need not be one for another — which is why combining neighbourhoods helps.

#stopbox("ch12-a")[
  + Define a local optimum with respect to a neighbourhood.
  + How many neighbours does the "reassign one task" neighbourhood have, with $|T|$ tasks and $|C|$ computers (ignoring feasibility)?
  + Give one advantage and one drawback of a larger neighbourhood.
]

== First improvement and best improvement

```
S <- initial solution (e.g. from the greedy)
repeat
    improved <- false
    for each S' in N(S):                       // in some fixed order
        if S' is feasible and f(S') < f(S):
            S <- S'; improved <- true
            break                              // FIRST improvement: take it now
until not improved
return S
```
*First improvement* accepts the first improving neighbour found; *best improvement* scans the whole neighbourhood and takes the best one (remove the `break`, remember the best). First improvement makes cheaper steps; best improvement makes larger ones. Neither dominates. In both, the scanning order matters, and randomizing it is a cheap way to diversify.

Evaluating $f(S')$ from scratch is often wasteful: a move changes few things. For the maximum load, a reassignment changes two computers' loads only; for set covering, removing $p_j$ only affects the elements of $p_j$. *Incremental evaluation* makes local search fast.

#example[Reassignment local search for the tasks][
  Start from $t_1 -> c_1$, $t_2 -> c_3$, $t_3 -> c_2$, $t_4 -> c_3$: loads $(0.5167, 0.6165, 0.95)$, maximum 0.95. Feasible reassignments: $t_4 -> c_1$ gives loads $(0.7259, 0.6165, 0.7992)$, maximum 0.7992; $t_4 -> c_2$ gives maximum 0.8265; every other move overflows a computer. Best improvement takes $t_4 -> c_1$ (first improvement too, scanning $t_1, dots, t_4$ and $c_1, c_2, c_3$). From there no move lowers 0.7992 — $t_2$, alone on $c_3$, cannot move — so it is a local optimum, here also the global one.
]

#revisit("ch12")[Yes in general: a local optimum for "reassign one task" can be worse than the global optimum, because reaching the optimum may need two simultaneous changes (a swap). In the example above the local optimum happens to be global (0.7992).]

The objective "maximum load" has a trap: many moves leave the maximum unchanged (they touch only non-critical computers), so local search sees a plateau and stops. A common fix is a secondary criterion — for instance, among solutions with equal maximum, prefer the smaller sum of squared loads — that rewards progress on the other computers.

== Examples from the slides

*Set covering.* From a GRASP solution ${p_1, p_6, p_7}$ (cost 7), the neighbourhood "remove one set that is redundant" finds that $p_1$ covers ${3, 4}$, which $p_7$ and $p_6$ already cover: remove it, cost 5 — the optimum. From the greedy solution ${p_4, p_6}$ (cost 6) no set is redundant; the exchange neighbourhood finds $p_4 -> p_7$ (${2, 3}$ is enough once $p_6$ covers 1, 4, 5), cost 5.

*Network planning.* Neighbourhood: reassign one user to another access point (routers are then re-dimensioned: each access point gets the cheapest model that serves its users). From the greedy's 460, moving user 1 from $a_3$ to $a_4$ lets $a_3$ downgrade from R3 to R2 (its remaining users need capacity 8 and reach 3) while $a_4$'s R1 still has room: cost 420 (Figure 12.1).

#fig("/figures/network-planning.svg", caption: [Network planning on the slides' instance. Moving user 1 from $a_3$ to $a_4$ lets $a_3$ downgrade from R3 to R2: 460 → 420.], wide: true)

*TSP, 2-opt.* The nearest-neighbour tour 5–2–1–4–3–5 (length 40) has a 2-opt neighbour obtained by removing edges $(2, 1)$ and $(3, 5)$ and reconnecting: 5–2–3–4–1–5, length 36, optimal.

#yourturn("ch12-yt1")[
  Set covering, current solution ${p_4, p_6}$ (cost 6). Neighbourhood: exchange one chosen set for one unchosen set.
  - Elements covered only by $p_4$: #blank(w: 5em). After removing $p_4$ we need a set covering #blank(w: 5em).
  - Candidates and their costs: #blank(w: 10em). Best exchange: #blank(w: 5em), new cost #blank().
]

#stopbox("ch12-b")[
  + What is the difference between first and best improvement?
  + Why is incremental evaluation important?
  + Why can the "maximum load" objective make local search stall?
]

#summary[
  + Local search improves a complete solution by moves until no neighbour is better: a local optimum for that neighbourhood.
  + Neighbourhoods: remove, insert, exchange, reassign, swap, 2-opt; bigger is stronger but slower.
  + First improvement takes the first better neighbour; best improvement scans all and takes the best.
  + Evaluate moves incrementally; check feasibility; beware plateaus of max-type objectives.
  + On the slides' instances: set covering 7 → 5, network planning 460 → 420, TSP 40 → 36.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch12-w1", time: 3, tier: "warm")[How many 2-opt neighbours does a tour of $n$ cities have?]

#exercise("ch12-w2", time: 3, tier: "warm")[Is ${p_2, p_3, p_6}$ a local optimum of set covering for the "remove one set" neighbourhood? For "exchange one set"?]

#tier("practice")

#exercise("ch12-p1", time: 10)[List all 2-opt neighbours of the tour 5–2–1–4–3–5 with their lengths (distances of Figure 11.1). Which one does best improvement choose?]

#exercise("ch12-p2", time: 10)[Define the *swap* neighbourhood for tasks (exchange the computers of two tasks). Starting from the greedy solution of §11.3, tasks to computers ($t_1 -> c_2$, $t_2 -> c_3$, $t_3 -> c_1$, $t_4 -> c_2$), is there an improving swap?]

#exercise("ch12-p3", time: 10)[In network planning, why is "reassign one user" evaluated by re-dimensioning only two access points? Write the change in cost of a move as a formula.]

#tier("tool", note: [Lab 4, part B])

#exercise("lab4-b2", source: "Lab 4 · part B (b)", time: 15, tier: "tool")[Describe in pseudocode the local search of the Python code for P2 (neighbourhoods "reassignment" and "exchange", policies first and best improvement). Then compare on the generated instances: greedy alone, greedy + local search with each neighbourhood and policy — quality and time.]

#tier("exam", note: [local search has never been asked; this is how it could be])

#exercise("ls-new-exam", source: "new, exam style", time: 20, tier: "exam")[For the neighbours problem (#exref("jan26-q2")) and a solution $X$ from your greedy: (a) propose two neighbourhoods and say which moves keep the solution feasible; (b) explain how to evaluate a move without recomputing everything; (c) write the pseudocode of a local search with best improvement using both neighbourhoods.]

#tier("review", note: [from Chapters 4, 8 and 11])

#exercise("ch12-r1", source: "review of Ch. 11", time: 4, tier: "review")[In a greedy that maximizes $q$, why must infeasible candidates receive $-infinity$ and not $+infinity$?]

#exercise("ch12-r2", source: "review of Ch. 4", time: 6, tier: "review")[$min x_1 + x_3$ s.t. $x_0 + x_1 = 2$, $x_1 - x_2 + x_3 = 1$, basis $(x_0, x_3)$. Basic solution, objective, reduced costs, optimal?]
