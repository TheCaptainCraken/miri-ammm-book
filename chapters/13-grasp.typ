#import "../template.typ": *

= GRASP

#symbols(
  ($q_min, q_max$, [smallest and largest greedy value among the current candidates]),
  ($alpha in [0, 1]$, [greediness parameter of the RCL: 0 = pure greedy, 1 = pure random]),
  ([RCL], [restricted candidate list: the candidates good enough to be picked at random]),
  ($"maxIter"$, [number of GRASP iterations (or a time limit)]),
  ($S^*$, [best solution found over all iterations]),
)

#pretest("ch13")[A greedy algorithm always returns the same solution; local search from it always reaches the same local optimum. Suggest the simplest way to get a _different_ local optimum on every run, without giving up the greedy's intelligence.]

A deterministic greedy followed by local search gives one solution. Run it a thousand times and you get the same solution a thousand times. GRASP — *Greedy Randomized Adaptive Search Procedure* — makes each run different by letting the greedy choose at random among the _good_ candidates instead of always taking the best, and then applies local search to each constructed solution. A good bartender asked for "something with gin" does not pour the same drink every night, but never reaches for the vinegar either.

== The restricted candidate list

At each construction step, compute $q(e, S)$ for every candidate, then keep the ones close enough to the best. For a greedy function to *minimize*:
$ "RCL" = { e in cal(C) : q(e, S) <= q_min + alpha (q_max - q_min) }; $
to *maximize*:
$ "RCL" = { e in cal(C) : q(e, S) >= q_max - alpha (q_max - q_min) }. $
Pick one element of the RCL uniformly at random. With $alpha = 0$ only the best candidates are in the list (pure greedy, up to ties); with $alpha = 1$ every candidate is (pure random construction).

#fig("/figures/rcl.svg", caption: [Value-based RCL for a minimization with $alpha = 0.3$: candidates with $q <= 9 + 0.3 (18 - 9) = 11.7$ may be picked.])

An alternative is a *cardinality-based* RCL: the $k$ best candidates. The value-based one adapts better: when one candidate is far better than the rest, the list contains only it. #think[Why is the RCL recomputed at every step instead of once at the start?]

== The algorithm

```pseudo
S* <- none
for k = 1 to maxIter:                // or until a time limit
    S <- RandomizedGreedy(alpha)     // construction phase
    if S infeasible: S <- Repair(S)  // optional
    S <- LocalSearch(S)              // improvement phase
    if S* = none or f(S) < f(S*): S* <- S
return S*

RandomizedGreedy(alpha):
    S <- {}; initialize C
    while S is not complete:
        compute q(e, S) for e in C; qmin, qmax
        RCL <- { e in C :
                 q(e, S) <= qmin + alpha (qmax - qmin) }
        e <- random element of RCL
        S <- S + {e}; update C
    return S
```
Each iteration is independent (it does not learn from the previous ones — Chapter 14 adds memory), so iterations can run in parallel.

#revisit("ch13")[Randomize the greedy choice among the best few candidates (the RCL) and run construction + local search many times, keeping the best. That is GRASP.]

== The slides' examples

#example[Tasks to computers, $alpha = 0.3$][
  Tasks in the order $t_2, t_3, t_1, t_4$ as before; $q$ is the load the computer would reach (minimized).
  - $t_2$: only $c_3$ fits; RCL ${c_3}$.
  - $t_3$: $q = 0.6141$ ($c_1$), $0.6165$ ($c_2$); threshold $0.6141 + 0.3 dot 0.0024 = 0.6148$; RCL ${c_1}$.
  - $t_1$: only $c_2$ fits.
  - $t_4$: $q = 0.8233$ ($c_1$), $0.7288$ ($c_2$), $0.95$ ($c_3$); threshold $0.7288 + 0.3 (0.95 - 0.7288) approx 0.795$; RCL ${c_2}$.
  On this instance, with $alpha = 0.3$, every list has one element: GRASP reproduces the greedy (maximum load 0.7992). With $alpha = 0.7$ the last threshold is $0.8836$ and the list ${c_1, c_2}$ gives a genuine random choice. #slidenote(deck: "GRASP", where: "tasks example, iteration #4", says: [“RCL: $q <= 0.8651$ → ${c_1, c_2}$”, then $c_1$ is picked at random (final maximum load 0.8233).], correct: [With $alpha = 0.3$: $0.7288 + 0.3 dot (0.95 - 0.7288) approx 0.795$, so RCL $= {c_2}$ and the result is 0.7992.], why: [0.8651 corresponds to $alpha approx 0.62$, not 0.3; the earlier iteration (#2, threshold 0.6148) uses $alpha = 0.3$ correctly.])
]

#example[Set covering, $alpha = 0.5$, maximizing new elements][
  Step 1: $q = |p_j|$ = 2, 1, 1, 3, 3, 3, 2, 1; $q_max = 3$, $q_min = 1$, threshold $3 - 0.5 dot 2 = 2$: RCL $= {p_1, p_4, p_5, p_6, p_7}$. Random pick: $p_1$, $R = {3, 4}$.
  Step 2: new elements 0, 0, 1, 1, 1, 2, 1, 0; among sets that add something, $q_max = 2$, and the slides take $q_min = 0$ over all sets: threshold 1, RCL $= {p_3, p_4, p_5, p_6, p_7}$. Pick $p_6$, $R = {1, 3, 4, 5}$.
  Step 3: only element 2 is missing: $q = 1$ for $p_3, p_4, p_7$, else 0; threshold 0.5; RCL $= {p_3, p_4, p_7}$. Pick $p_7$. Solution ${p_1, p_6, p_7}$, cost 7.
  Local search (remove redundant sets) drops $p_1$: cost 5, optimal.
]

#side[Whether $q_min$ is taken over all sets or only over the useful ones changes the RCL. Including useless candidates ($q = 0$) lowers the threshold and makes the list larger: decide, and say which, in an exam answer.]The network-planning GRASP of the slides works the same way with $alpha = 0.5$ on the incremental costs: at the first step $q$ is 100 for most users and 140 for user 4, the threshold is $100 + 0.5 dot 40 = 120$, and the RCL contains every user except user 4.

#yourturn("ch13-yt1")[
  A maximization step has $q$ values 4, 7, 10, 10, 2 for candidates $e_1, dots, e_5$.
  - $q_max = $ #blank(), $q_min = $ #blank().
  - With $alpha = 0.25$: threshold #blank(), RCL #blank(w: 6em). With $alpha = 0.5$: threshold #blank(), RCL #blank(w: 7em).
  - Which $alpha$ gives the pure greedy (up to ties)? #blank()
]

#stopbox("ch13-a")[
  + Write the RCL condition for a minimization.
  + What do $alpha = 0$ and $alpha = 1$ give?
  + Why does GRASP apply local search to every constructed solution?
]

== Choosing $alpha$ and the number of iterations

Small $alpha$ builds good solutions that are all alike; large $alpha$ builds varied but poor ones, which local search then has to repair. The best value is found by experiment: run GRASP with $alpha in {0, 0.1, dots, 1}$ on a few instances and plot the quality of the best solution (Lab 4, part C). *Reactive GRASP* picks $alpha$ at random each iteration from a set of values, with probabilities that grow for values that produced good solutions. The stopping criterion is a number of iterations or a time limit; since iterations are independent, quality improves roughly logarithmically with time.

#summary[
  + GRASP = repeat (randomized greedy construction + local search), keep the best.
  + RCL (min): $q <= q_min + alpha (q_max - q_min)$; (max): $q >= q_max - alpha(q_max - q_min)$; pick uniformly from it.
  + $alpha = 0$ greedy, $alpha = 1$ random; tune $alpha$ by experiment (or reactively).
  + Iterations are independent (no memory) and parallelizable.
  + Slides' tasks example: with $alpha = 0.3$ the last RCL is ${c_2}$ (threshold $approx 0.795$), not ${c_1, c_2}$.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch13-w1", time: 3, tier: "warm")[Minimization, $q = (12, 15, 20, 30)$, $alpha = 0.2$. Which candidates are in the RCL?]

#exercise("ch13-w2", time: 3, tier: "warm")[Why is GRASP with $alpha = 0$ and deterministic tie-breaking pointless beyond one iteration?]

#tier("practice")

#exercise("ch13-p1", time: 10)[Run the task GRASP with $alpha = 0.7$ on the four-task instance. At which steps is there a real random choice? Give the two possible final maximum loads.]

#exercise("ch13-p2", time: 10)[Redo step 2 of the set-covering GRASP taking $q_min$ only over sets that cover at least one new element. Which RCL do you get, and does it matter here?]

#tier("tool", note: [Lab 4, part C])

#exercise("lab4-c", source: "Lab 4 · part C", time: 15, tier: "tool")[Describe the GRASP construction of the Python code for P2 (its RCL). Tune $alpha$ on two or three instances. Then compare GRASP with greedy + local search on the generated instances, giving GRASP the same time CPLEX needed (or 30 minutes).]

#tier("exam", note: [GRASP has never been asked; this is how it could be])

#exercise("grasp-new-exam", source: "new, exam style", time: 15, tier: "exam")[Turn your greedy for the ISS-crew problem (#exref("jun26-q3a")) into a GRASP. (a) Write the RCL with a parameter $alpha$ and say what happens for $alpha = 0$ and $alpha = 1$. (b) Write the pseudocode of the construction phase. (c) Write the pseudocode of the complete GRASP, naming a suitable local search.]

#tier("review", note: [from Chapters 6, 11 and 12])

#exercise("ch13-r1", source: "review of Ch. 12", time: 3, tier: "review")[Name two neighbourhoods for the task-assignment problem.]

#exercise("ch13-r2", source: "review of Ch. 6", time: 5, tier: "review")[Linearize "maximize the minimum compatibility of the pairs placed in the same team" with binaries $x_(i j)$.]
