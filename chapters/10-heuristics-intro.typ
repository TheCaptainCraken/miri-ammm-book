#import "../template.typ": *

= Why heuristics

#symbols(
  ($Omega$, [solution space: all feasible solutions of a combinatorial problem]),
  ($f : Omega -> RR$, [objective function on solutions (minimized unless said otherwise)]),
  ($omega, omega^*$, [a solution; an optimal solution, $f(omega^*) <= f(omega)$ for all $omega in Omega$]),
  ($omega'$, [a local minimum: no _neighbouring_ solution is better]),
  ($"load"$, [$sum_t r_t slash sum_c R_c$: total request over total capacity of an instance]),
  ([size], [number of variables × number of constraints of a model instance]),
)

#pretest("ch10")[Lab 2's MILP for 4 tasks and 3 computers solves in a blink. Guess what happens to the solving time if you keep 3 computers' worth of capacity per task but go to 400 tasks and 300 computers — and what happens if the instance gets "tighter" (total request close to total capacity).]

Part I ended with a solver that, given time, finds and proves the optimum of any MILP we can write. Part II starts from the uncomfortable word: _given time_. The network-planning work in the last slide deck has to re-optimize a live optical network in milliseconds; a branch & bound tree that needs an hour is useless there. A heuristic trades the guarantee for speed: a good solution now instead of the best one later. Fair winds are nice, but sometimes the tide decides when you leave the port.

== The general methodology

The slides draw one flowchart for the whole course:

+ *Problem statement*: given (sets and parameters), output (what we want from the solution), objective (min or max), constraints.
+ *Mathematical model* (Part I).
+ *Solve the instances.* Can they be solved in the required time? If yes — done.
+ If not: *revisit the model* (tighter formulation, fewer symmetries), apply *large-scale optimization techniques* (decomposition), or *design heuristic algorithms*.

The statement format matters for the exam: the official answers to question 3 open by listing the constraints and the objective of the story — "C1: each participant has at most one date; C2: …; Objective: maximize the total score" — before designing the greedy. Do the same: it takes two minutes and the rest of the answer refers to it.

== Instances, size and load

A *problem instance* is the model plus data. Its *size* is roughly the number of variables times the number of constraints (the size of the matrix $A$): P1 with 4 tasks and 3 computers has 13 variables and 10 constraints. Size grows fast: P2 has $|T| |C| + 1$ variables, so 400 tasks and 300 computers give 120 001 binaries.

#fig("/figures/time-size.svg", caption: [Schematic: the time to solve an integer model grows explosively with the size of the instance and with its load.], wide: true)

Solving time grows with size — explosively for integer models, since branch & bound may explore exponentially many nodes. It also grows with how *tight* the instance is. For the task-assignment problem the slides define
$ "load" = (sum_(t in T) r_t) / (sum_(c in C) R_c). $
With load 0.1 almost any assignment fits and the solver finishes immediately; with load close to 1 the solver must search hard to find even a feasible assignment, or to prove there is none (Lab 2's five-task instance has load 0.9252 and is infeasible). When "time to solve ≫ time a solution is needed", we need another approach.

#revisit("ch10")[Both changes hurt, and they compound: 400 × 300 means 120 000 binaries instead of 12, and a tight instance (load near 1) makes even feasibility hard. Expect seconds to become hours — exactly the regime where Lab 4 compares CPLEX (stopped after 30 minutes or at 1 % gap) with heuristics.]

=== Generating instances

Labs 3 and 4 start by generating instances "of increasing size". A useful generator controls three things: the *size* (number of tasks and computers), the *load* (so that instances are neither trivial nor hopeless) and the *seed* (so that experiments can be repeated). A sketch for the task problem:

```python
def generate(n_tasks, n_cpus, load, seed):
    rng = random.Random(seed)
    # capacities, and the total request we want
    rc = [rng.uniform(400, 800) for _ in range(n_cpus)]
    total = load * sum(rc)
    # requests: random weights, scaled to that total
    w = [rng.uniform(0.5, 1.5) for _ in range(n_tasks)]
    rt = [total * wi / sum(w) for wi in w]
    # optional: reject the instance if some task
    # exceeds every capacity
    return rt, rc         # write them as a .dat file
```
Scaling the random weights to the target total fixes the load exactly. For a feasibility check before calling the solver, test the necessary conditions: total request $<=$ total capacity, and every task fits in at least one computer.

#stopbox("ch10-a")[
  + What are the four parts of a problem statement?
  + Compute the load of Lab 1's instance and of Lab 2's five-task instance.
  + Why fix the random seed in an instance generator?
]

== Local and global optima

For a differentiable function of real variables, calculus finds candidates for extrema: by Fermat's theorem they occur where the derivative is zero, and the second derivative tells minima from maxima. *Gradient descent* moves step by step against the gradient; it reaches a *local* minimum, and which one depends on where it starts.

#fig("/figures/landscape.svg", caption: [Descent from the left stops in the local minimum $omega'$; the global minimum $omega^*$ lies elsewhere.])

Combinatorial problems have no derivatives, but the picture survives. The slides formalize it: a solution space $Omega$, an objective $f: Omega -> RR$, and the goal of finding $omega^* in Omega$ with $f(omega^*) <= f(omega)$ for all $omega in Omega$. Moving from a solution to a "nearby" one (a small change: reassign one task) is the combinatorial analogue of a small step, and a solution that no small change improves is a *local minimum* $omega'$.

== Heuristics

#definition[Heuristic][An approximate method: it returns a feasible (ideally good) solution quickly, without a guarantee of optimality.]

Heuristics are as old as operations research. When complexity theory showed in the early 1970s that most of these combinatorial problems are NP-hard — that efficient exact algorithms are unlikely to exist — heuristics became the standard way to tackle the large instances of real applications, NP-hard or not. They usually have two phases:

+ a *constructive phase* that builds a solution, typically with a greedy algorithm (Chapter 11);
+ a *local search* that improves it by small changes until a local optimum (Chapter 12).

Meta-heuristics (Chapters 13–15) add randomness and memory on top, to escape local optima.

The application slides show the pattern in research problems: restoring connections after a fibre cut in an optical network (route and spectrum for each demand, within milliseconds), placing virtual machines in federated datacenters to use green energy, placing datacentres for live-TV distribution, sizing C-RAN equipment. In each, the paper states the problem as _Given / Output / Objective_ and solves it with a greedy that is repeated with randomized orders (for instance "sort the demands randomly, then route each one greedily, keep the best of `maxIter` runs") — the ideas of the next chapters, at work.

#stopbox("ch10-b")[
  + Name the two phases of a typical heuristic.
  + What is a local minimum in a combinatorial problem?
  + Why does NP-hardness make heuristics important?
]

#summary[
  + Methodology: statement → model → solve; if too slow, reformulate, decompose or use heuristics.
  + Instance = model + data; size ≈ variables × constraints; solving time explodes with size and with load.
  + Generators should control size, load and seed; check simple feasibility conditions first.
  + A local optimum cannot be improved by small changes; descent methods get stuck there.
  + Heuristic = fast, no guarantee; constructive phase (greedy) + local search; meta-heuristics add randomness and memory.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch10-w1", time: 4, tier: "warm")[Write the problem statement (Given / Output / Objective / Constraints) of Lab 2's P2.]

#exercise("ch10-w2", time: 3, tier: "warm")[How many variables and constraints does P2 have with $|T| = 50$ and $|C| = 10$?]

#tier("practice")

#exercise("ch10-p1", time: 8)[For the instance $r = (261.27, 560.89, 310.51, 105.80)$, $R = (505.67, 503.68, 701.78)$, compute the load. By how much could every request be scaled up (keeping the capacities) before P1 becomes infeasible?]

#exercise("ch10-p2", time: 10)[Complete the instance generator of §10.2 so that it rejects instances where some task fits in no computer, and explain why it would be a mistake to simply discard large tasks instead.]

#tier("tool", note: [Lab 3 (b) and Lab 4, part A])

#exercise("lab4-a", source: "Lab 4 · part A; Lab 3 · task (b)", time: 20, tier: "tool")[Generate instances of increasing size (for example 10, 20, 40, 80 and 160 tasks, with $|C| = |T| slash 4$ and load 0.7) and solve them with the P2 model in CPLEX, stopping after 30 minutes or at a 1 % gap. Which OPL statements set these limits? Plot (or tabulate) the time to solve against the size. What do you expect to see as the load approaches 1?]

#tier("exam", note: [the opening of every question 3])

#exercise("ch10-e1", source: "new, exam style", time: 8, tier: "exam")[For the ISS-crew story of #exref("jun26-q2"), write the list of constraints C1, C2, … and the objective in words, as the official solutions do before designing a greedy. Then say what a candidate could be for a constructive algorithm.]

#tier("review", note: [from Chapters 5 and 8])

#exercise("ch10-r1", source: "review of Ch. 8", time: 4, tier: "review")[Explain why a branch & bound run can be stopped at "1 % gap" with a guarantee, while a heuristic gives no such guarantee.]

#exercise("ch10-r2", source: "review of Ch. 5", time: 3, tier: "review")[Write "each task runs on exactly one computer, and at most two tasks share a computer" for binaries $x_(t c)$.]
