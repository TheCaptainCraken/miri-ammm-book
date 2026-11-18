#import "../template.typ": *

= Greedy algorithms

#symbols(
  ($N$, [ground set of elements (items, edges, task–computer pairs…)]),
  ($cal(C)$, [candidate set: elements that may still be added. The slides write $C$, which in the labs is also the set of computers; the book uses $cal(C)$]),
  ($e$, [a candidate (element)]),
  ($S$, [the partial solution built so far (a set of chosen elements)]),
  ($q(e, S)$, [greedy function: how good it is to add $e$ to $S$ — maximized or minimized, as declared]),
  ($f(S)$, [objective value of a (complete) solution]),
  ($R$, [in set covering: elements already covered (not the non-basic matrix of Part I)]),
)

#pretest("ch11")[Five cities; you always drive to the nearest city not yet visited. Can this produce the shortest tour? Can it produce a bad one? Guess before looking at Figure 11.1.]

Question 3(a) of every exam asks for the same three things: the *set of candidates*, the *greedy function* $q(dot)$ "using mathematical notation and a short descriptive text", and the *pseudocode tailored to the problem*. That is a design task, but a very regular one: once you have seen the four examples of the slides, the exam problems are variations. This chapter goes through them and then designs greedy algorithms for three past exams.

== Combinatorial optimization

A *combinatorial optimization problem* has a finite ground set $N$ of elements with costs $c_i$, and a family $Omega$ of feasible subsets; the goal is the feasible subset of minimum (or maximum) total cost. Binary variables $x_i$, one per element, turn it into an ILP — this is how Part I modelled everything.

Two examples from the slides. In the *knapsack* problem, items have weights $a_i$ and values $c_i$, and we choose items of total weight at most $b$ maximizing value: $max sum c_i x_i$, $sum a_i x_i <= b$, $x in {0,1}^n$. In the *travelling salesman problem* (TSP), cities are vertices of a graph with distances; the elements are the edges, and a feasible set is a Hamiltonian cycle (a tour visiting each city once). With $n$ cities there are $(n-1)! slash 2$ tours: 12 for 5 cities, 181 440 for 10, about $6.08 times 10^16$ for 20. Enumerating them is hopeless beyond toy sizes.

The ILP of the TSP (Dantzig–Fulkerson–Johnson) uses $x_e in {0,1}$ for each edge:
$ min sum_e c_e x_e quad "s.t." quad sum_(e in delta(v)) x_e = 2 quad forall v in V, quad sum_(e in E(U)) x_e <= |U| - 1 quad forall U subset V, 2 <= |U| <= |V| - 1, $
where $delta(v)$ are the edges at $v$ and $E(U)$ the edges inside $U$. The second family forbids subtours — one constraint per subset of cities, exponentially many. #slidenote(deck: "Greedy algorithms", where: "slide 7 (DFJ)", says: [Sub-tour elimination "$sum_(e in S) x_e = |S| - 1$ for all $S subset E$, $|S| < N$", and "$x_e = 0.1$".], correct: [$sum_(e in E(U)) x_e <= |U| - 1$ for all vertex subsets $U subset V$ with $2 <= |U| <= |V| - 1$; and $x_e in {0, 1}$.], why: [With "$=$" every subset would have to contain a path, which is impossible; the subsets are of cities, not edges; "0.1" is a typo for "0, 1".])

== The greedy scheme

A greedy algorithm builds a solution one element at a time, always adding the candidate that looks best right now. The slides list its five pillars:

+ a *candidate set* $cal(C)$ from which the solution is built;
+ a *selection function*, the greedy function $q(e, S)$, choosing the best candidate;
+ a *feasibility function*: can $e$ be added to $S$?
+ an *objective function* $f(S)$;
+ a *solution function*: is $S$ complete?

```
initialize the candidate set C
S <- {}
while S is not a solution:
    evaluate q(e, S) for every e in C
    e_best <- argmax { q(e, S) : e in C }     (or argmin, for a cost)
    S <- S + {e_best}
    update C  (remove e_best; remove candidates that became infeasible)
return f(S), S
```

The greedy function is often a _ratio_ "value added / cost", maximized, or an _incremental cost_, minimized. Infeasible candidates must never be selected: give them $-infinity$ when maximizing or $+infinity$ when minimizing, or remove them from $cal(C)$.

#slidenote(deck: "Greedy algorithms", where: "slide 9", says: [$q(c, S) = "value"/"cost"$, or $infinity$ if $S union {c}$ is infeasible, and then $c_"best" <- "argmax" q(c, S)$.], correct: [With argmax the infeasible value must be $-infinity$ (or the candidate removed); $+infinity$ fits argmin of a cost.], why: [As written, argmax would pick exactly the infeasible candidates.])The word "adaptive" matters: $q(e, S)$ depends on $S$, so it must be *re-evaluated after every insertion*. A greedy that sorts all candidates once and never updates is a weaker, static version (sometimes fine, as in task assignment, where sorting the tasks is only the _order_ and the computer is still chosen adaptively).

#stopbox("ch11-a")[
  + List the five pillars of a greedy algorithm.
  + Maximizing $q$, what value should an infeasible candidate receive?
  + Why must $q(e, S)$ be re-evaluated after each insertion?
]

== Four examples from the slides

=== Nearest neighbour for the TSP

Candidates are the edges $(u, v)$ from the last city $u$ of the partial tour to an unvisited city $v$; $q$ is the distance, minimized. Start anywhere, repeat until all cities are visited, close the tour.

#fig("/figures/tsp-nn.svg", caption: [Nearest neighbour on the slides' five cities. From city 1 it finds a tour of length 36 (optimal here); from city 5 it is trapped into a 14-km edge and returns 40.], wide: true)

#example[Nearest neighbour from city 1][
  Distances: $d_(12) = 10$, $d_(13) = 12$, $d_(14) = 7$, $d_(15) = 9$, $d_(23) = 11$, $d_(24) = 17$, $d_(25) = 4$, $d_(34) = 5$, $d_(35) = 14$, $d_(45) = 9$. From 1 the nearest is 4 (7); from 4, city 3 (5); from 3, city 2 (11); from 2, city 5 (4); back to 1 (9). Tour 1–4–3–2–5–1, length 36 — the optimum. Starting from 5 instead: 5–2 (4), 2–1 (10), 1–4 (7), 4–3 (5), 3–5 (14): length 40. The last edge is forced and long. That is *myopia*: each step is locally best, and the price is paid at the end.
]

#revisit("ch11")[It can find the optimum (from city 1: 36) and it can be fooled (from city 5: 40). On random points in the plane, nearest neighbour is about 25 % above the optimum on average. Better constructions exist: nearest insertion grows a cycle, and Christofides' algorithm (minimum spanning tree + matching of odd vertices + Eulerian tour + shortcuts) guarantees at most 1.5 times the optimum.]

=== Assigning tasks to computers (Labs 2 and 4)

Candidates are pairs $chevron.l t, c chevron.r$. Tasks are processed in decreasing order of request (big rocks first), and for each task the computer is chosen by
$ q(chevron.l t, c chevron.r, S) = ("usedCapacity"(c, S) + r_t) / R_c quad "(the load of " c " if " t " goes there)", $
minimized over the computers where $t$ still fits.

```
S <- {} ; for each c: used[c] <- 0
for each t in T sorted by r_t decreasing:
    C(t) <- { c : used[c] + r_t <= R_c }          // feasible computers
    if C(t) = {} then return INFEASIBLE
    c_best <- argmin { (used[c] + r_t) / R_c : c in C(t) }
    used[c_best] <- used[c_best] + r_t ; S <- S + {<t, c_best>}
return S, max_c used[c] / R_c
```

#example[The slides' trace][
  Requests $r = (261.27, 560.89, 310.51, 105.80)$, capacities $R = (505.67, 503.68, 701.78)$. Order: $t_2, t_3, t_1, t_4$.
  - $t_2$ (560.89) fits only $c_3$: load 0.7992.
  - $t_3$ (310.51): $c_1$ gives 0.6141, $c_2$ gives 0.6165 → $c_1$.
  - $t_1$ (261.27): only $c_2$ has room (residuals 195.16, 503.68, 140.89) → $c_2$, load 0.5187.
  - $t_4$ (105.80): loads 0.8233, 0.7288, 0.95 → $c_2$.
  Final maximum load 0.7992 — equal to the ILP optimum of Lab 2. Greedy is not always optimal, but on easy instances it often is. #slidenote(deck: "Greedy examples", where: "slide 5, iteration #2", says: [“C(t2) c1 c2” while processing task t3.], correct: [C(t3).], why: [Typo: the candidate list belongs to the task being placed.])
]

=== Set covering

Elements $M = {1, dots, 5}$ must be covered by subsets $p_1, dots, p_8$ with costs:

#btable(columns: 9, align: center, header: ([], [$p_1$], [$p_2$], [$p_3$], [$p_4$], [$p_5$], [$p_6$], [$p_7$], [$p_8$]),
  [covers], [3, 4], [3], [2], [2, 3, 4], [3, 4, 5], [1, 4, 5], [2, 3], [4],
  [cost], [2], [1], [1], [3], [3], [3], [2], [1])

The ILP is $min sum_j c_j x_j$ with $sum_j a_(i j) x_j >= 1$ for each element $i$. The optimal cost is 5 (${p_6, p_7}$ or ${p_2, p_3, p_6}$). With $R$ the covered elements, the slides' greedy maximizes the number of newly covered elements, $q(p_j, R) = |p_j without R|$: it takes $p_4$ (3 new), then $p_6$ (2 new), cost 6. The cost-aware version minimizes $c_j slash |p_j without R|$, the cost per new element. #side[On this instance the costs equal the sizes $|p_j|$, so every ratio is 1 at the first step: the cost-aware greedy depends entirely on tie-breaking (lowest index gives $p_1, p_3, p_6$, cost 6).]

=== Network planning

Users $u$ (with capacity demand $"cr"_u$) must connect to access points $a$ where routers are installed; router models $m$ have cost $f_m$, capacity $k_m$ and reach $d_m$; minimize the total router cost. The greedy candidate is a user; $q(u, S) = min_a q(chevron.l u, a chevron.r, S)$ with the *incremental cost* of serving $u$ from $a$:
$ q(chevron.l u, a chevron.r, S) = cases(
  0 & "if the router at" a "already reaches" u "and has spare capacity",
  f_m - f_a & "if" a "must be upgraded to the cheapest model" m "that can serve" u,
  infinity & "if no model can serve" u "from" a) $
(with $f_a = 0$ when $a$ has no router yet). The user with the smallest incremental cost is connected first. On the slides' instance (Figure 12.1) the greedy installs two R3 and one R1: cost 460. #slidenote(deck: "Greedy examples", where: "network planning, slides 15–19", says: [Several users tie on $q$; the trace picks one without stating why; from iteration #7 the row "cr" shows user 1 with 4.], correct: [The trace is reproduced by breaking ties by smallest distance $d(u, a)$, then smallest index; $"cr"_1 = 2$ throughout.], why: [Recomputed with `v11_heuristics_slides.py`: with these rules every iteration and the final cost 460 match.])

#stopbox("ch11-b")[
  + In the task greedy, why are tasks sorted by decreasing request?
  + On the set-covering instance, what does the cardinality greedy return, and what is the optimum?
  + When is the incremental cost of a network-planning candidate equal to 0?
]

== Answering question 3(a)

Every exam asks: "specify the set of candidates; the greedy function $q(dot)$, using mathematical notation and a short descriptive text; the pseudocode of the algorithm tailored to the problem (please avoid writing the general algorithm)". A complete answer has this shape:

+ *Constraints and objective* restated in one line each (C1, C2, …).
+ *Notation* for the sets the pseudocode uses (selected, covered, residual capacities…).
+ *Candidates*: what one greedy step adds (an item, a pair $chevron.l i, j chevron.r$, a triple).
+ *Greedy function*: formula, direction (max/min), its value for infeasible candidates, and one sentence of intuition ("time per newly convinced neighbour").
+ *Pseudocode*: initialization, the loop condition (the solution function), feasibility, the argmin/argmax, the update of the data structures, the INFEASIBLE exit, and what is returned.
+ (Optional, one line) the weakness: where the greedy is myopic.

#example[A complete answer for P2 (tasks to computers)][
  *Constraints:* C1 each task on exactly one computer; C2 capacity. *Objective:* minimize the maximum load.
  *Candidates:* pairs $chevron.l t, c chevron.r$; tasks are taken in decreasing order of $r_t$, so in each step the candidates are $chevron.l t, c chevron.r$ for the current task $t$.
  *Greedy function (min):* $q(chevron.l t, c chevron.r, S) = ("used"(c) + r_t) slash R_c$ if $"used"(c) + r_t <= R_c$, and $+infinity$ otherwise — the load that computer $c$ would reach; choosing the smallest keeps the maximum load low.
  *Pseudocode:* the one of §11.3 (tasks to computers). Weakness: decisions are never revised; a big task placed early can block a better arrangement (local search will fix some of this).
]

#yourturn("ch11-yt1")[
  Knapsack: values $(10, 7, 25, 24)$, weights $(2, 1, 6, 5)$, capacity 7.
  - Candidates: #blank(w: 10em). Greedy function (max): $q(i) = $ #blank(w: 5em); infeasible if #blank(w: 9em).
  - Order of the ratios: items #blank(w: 8em). Greedy picks items #blank(w: 5em), value #blank().
  - The optimum is items 1 and 4 with value #blank(). Why did the greedy miss it? #blank(w: 12em)
]

#summary[
  + Greedy = candidate set, greedy function, feasibility, objective, solution test; add the best candidate, update, repeat.
  + The greedy function is usually a value/cost ratio (max) or an incremental cost (min); infeasible candidates get the worst value.
  + "Adaptive": re-evaluate $q(e, S)$ after each insertion.
  + Greedy is fast and myopic: nearest neighbour 36 or 40 on the same five cities; set covering 6 instead of 5.
  + Exam 3(a): constraints, notation, candidates, $q$ with formula + sentence, tailored pseudocode with INFEASIBLE exit.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch11-w1", time: 3, tier: "warm")[In nearest neighbour for the TSP, identify the five pillars.]

#exercise("ch11-w2", time: 4, tier: "warm")[Run nearest neighbour from city 2 on the five cities of Figure 11.1. Length?]

#tier("practice")

#exercise("ch11-p1", time: 10)[Run the task greedy on Lab 2's five-task instance ($r = (261.27, 560.89, 310.51, 105.80, 344.7)$, same computers). What happens? Is the instance really infeasible?]

#exercise("ch11-p2", time: 10)[Run the cost-aware set-covering greedy ($min c_j slash |p_j without R|$) on the instance of §11.3 (set covering), breaking ties by the _largest_ number of new elements, then lowest index. Compare with the optimum.]

#exercise("ch11-p3", time: 12)[Network planning (instance of the slides, Figure 12.1): with no routers installed, compute $q(u, emptyset)$ for users 1 and 4, explaining which access point and model give the minimum.]

#tier("tool", note: [Lab 4, part B])

#exercise("lab4-b", source: "Lab 4 · part B (a), (c)", time: 15, tier: "tool")[Write the pseudocode of the greedy of the Python code for P2 and specify its greedy function. Then: solve the generated instances with "random only" (each task to a random computer where it fits) and with the greedy function. What do you expect to see in quality and in time, compared with CPLEX?]

#tier("exam", note: [question 3(a) of three past exams; part (b) is in Chapter 15])

#exercise("jun25-q3a", source: "Final Jun 2025 · Q3(a)", time: 25, tier: "exam")[We want a heuristic for the "First Dates" problem (#exref("jun25-q2a"), #exref("jun25-q2be")), including its objective function. For a Greedy algorithm specify: the set of candidates; the greedy function $q(dot)$, using mathematical notation and a short descriptive text; the pseudocode of the algorithm tailored to the problem (avoid writing the general algorithm).]

#exercise("jan26-q3a", source: "Final Jan 2026 · Q3(a)", time: 25, tier: "exam")[The same for the solar-panel neighbours problem (#exref("jan26-q2")).]

#exercise("jun26-q3a", source: "Final Jun 2026 · Q3(a)", time: 25, tier: "exam")[The same for the ISS-crew problem (#exref("jun26-q2")).]

#tier("review", note: [from Chapters 6, 7 and 10])

#exercise("ch11-r1", source: "review of Ch. 10", time: 3, tier: "review")[What is the load of an instance with requests $(3, 5, 4)$ and capacities $(6, 10)$?]

#exercise("ch11-r2", source: "review of Ch. 7", time: 5, tier: "review")[Write the stock balance of a drug with purchases $x_(i t)$ from suppliers $i$, demand $d_t$, stock $s_t$ and waste $w_t$.]
