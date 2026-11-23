#import "../template.typ": *

= Genetic algorithms and BRKGA

#symbols(
  ([chromosome], [the encoding of one individual; in BRKGA, a vector of keys]),
  ($"ch" = ("ch"_1, dots, "ch"_g)$, [a random-key chromosome, each key in $[0, 1)$]),
  ($g = |"ch"|$, [number of genes]),
  ($p$, [population size]),
  ($p_e, p_m$, [fractions of elite individuals and of mutants in the population]),
  ($rho$, [inheritance probability: chance that a child takes a gene from its elite parent, $rho > 0.5$]),
  ([decoder], [deterministic algorithm that turns a chromosome into a solution and its fitness]),
)

#pretest("ch15")[A BRKGA chromosome is just a list of numbers between 0 and 1, the same for every problem. How can such a list possibly describe a solution of _your_ problem (a crew, an assignment, a tour)?]

Question 3(b) of every exam asks for a BRKGA: "the structure of the chromosome, the fitness, and the pseudocode of the decoder — you can just highlight the differences with respect to the greedy". If your greedy of part (a) is good, part (b) takes ten minutes: the greedy is the house recipe, and the chromosome is only the customer's note on the order slip — "a little less ice, a little more lime". This chapter explains why, starting from the classic genetic algorithm.

== Genetic algorithms

Genetic algorithms imitate natural selection on a population of solutions. Each individual is encoded by a *chromosome*; its quality is its *fitness*. Each generation:

+ *evaluate* the fitness of every individual;
+ *select* parents, favouring fit ones;
+ *recombine* pairs of parents into children (crossover);
+ *mutate* some children slightly;
+ form the *next generation* (often keeping the best few unchanged: elitism).

The difficulty is the encoding. For the TSP, the natural chromosome is the tour itself, a permutation such as 124385967. Crossing two permutations naively — say exchanging positions 4–7 of 124385967 and 452187693 — gives 124187667 and 452385993, which repeat cities and miss others; they must be *repaired* (duplicates replaced by the missing cities), which the slides show as 524187693 and 412385967. A mutation such as *inversion* reverses a segment: 124385967 → 124958367. Every problem needs its own crossover, mutation and repair, and they are easy to get wrong. #question(label: [Think first])[What property should an encoding have so that _any_ crossover of two chromosomes gives a valid chromosome?]

== Random keys and the decoder

*BRKGA* (biased random-key genetic algorithm) answers that question by moving all problem knowledge into one place. A chromosome is a vector of $g$ *random keys* in $[0, 1)$: the same kind of object for every problem, so crossover and mutation are generic, and any vector they produce is a valid chromosome. The problem-specific part is the *decoder*, a procedure that reads the keys, builds a solution and returns its fitness. Evolution never sees a solution: it sees only keys, and the fitness the decoder reports for them.

A decoder must meet three requirements:
- it accepts _every_ vector of keys and returns a solution — if it can get stuck, it still returns, with a penalized fitness;
- it is _deterministic_: the same keys always give the same solution, so the fitness belongs to the chromosome and selecting the fittest makes sense;
- the keys _matter_: different keys lead to different solutions, or evolution has nothing to choose between.

There are two ways to build one.

=== Keys as priorities

The simplest decoder sorts. For the TSP, give one key to each city except the start, and visit the cities in increasing order of key. On the five cities of Chapter 11, keys $(0.7, 0.4, 0.1, 0.9)$ for cities 2–5 sort to 4, 3, 2, 5: the tour 1–4–3–2–5–1, of length 36. Cross this chromosome with $(0.2, 0.8, 0.5, 0.3)$, taking the keys of cities 2 and 5 from the first parent and those of cities 3 and 4 from the second: the child $(0.7, 0.8, 0.5, 0.9)$ sorts to 4, 2, 3, 5, the tour 1–4–2–3–5–1. It is a poor tour (58), but it is a tour: sorting cannot repeat a city or miss one, so no child ever needs repair. That is the property the "Think first" question asked for — the repair has moved into the decoder, where it is automatic.

Sorting knows nothing about the problem, though: a random chromosome is a random tour, and evolution has to discover every good edge by itself. Better decoders put problem knowledge into the construction — and you already have a construction full of it.

=== Keys inside the greedy

The decoder to use in the exam is *your greedy of part (a), with one key per candidate and one line changed*:

```pseudo
initialize the candidate set C
S <- {}
while S is not a solution:
    // was: argmin { q(e, S) : e in C }
    e_best <- argmin { ch[e] * q(e, S) : e in C }
    S <- S + {e_best}
    update C: remove e_best and every candidate
              that became infeasible
return S, f(S)     // fitness: the real objective
```

In other words, the greedy function becomes
$ q'(e, S) = "ch"_e dot q(e, S) $
(or a similar combination, see below). Everything else is the greedy's, and that is what makes the decoder work:
- *Feasibility is inherited.* The candidate set and its updates are untouched, so the decoder only picks candidates the greedy would also accept. The keys change _which_ feasible candidate wins, never _whether_ it is feasible. If the greedy has an INFEASIBLE exit, so does the decoder, and there the fitness gets a penalty.
- *The keys bend the preferences.* When minimizing, a key near 0 makes a candidate look cheap, so it is chosen earlier; a key near 1 leaves its cost as it is. (When maximizing a score, multiplying works too: a large key favours.) With all keys equal, $q'$ is proportional to $q$ and the decoder _is_ the greedy: the greedy's solution is one of those BRKGA can reach, and the keys explore the solutions around it.
- *The fitness is the real objective.* $q'$ only steers the construction; the decoded solution is judged by $f(S)$, plus the penalty if any — never by the sum of the weighted values.

In the words of the introduction, the greedy is the house recipe and the keys are the note on the order slip: they change how the dish turns out, but the kitchen still cooks only what is on the menu. Compare GRASP (Chapter 13), which perturbs the greedy with fresh random choices in every construction and forgets them afterwards. BRKGA writes the perturbation down, as keys, so the perturbations that led to good solutions are inherited by the next generation.

#example[The TSP decoder of the slides][
  The greedy is nearest neighbour from city 1, with one key per edge (10 edges for 5 cities): $q'$ is the distance of an edge times its key. Chromosome 2 of the slides gives these weighted distances:

  #table(columns: (auto,) + (1fr,) * 10, align: center,
    table.header([edge], [12], [13], [14], [15], [23], [24], [25], [34], [35], [45]),
    [$d$], [10], [12], [7], [9], [11], [17], [4], [5], [14], [9],
    [$"ch"$], [0.3], [0.7], [0.6], [0.4], [0.4], [0.7], [0.3], [0.9], [0.3], [0.65],
    [$"ch" dot d$], [3], [8.4], [4.2], [3.6], [4.4], [11.9], [1.2], [4.5], [4.2], [5.85],
  )

  From 1 the smallest weighted edge goes to 2 (3), from 2 to 5 (1.2), from 5 to 3 (4.2), from 3 to 4 (4.5), then back to 1: tour 1–2–5–3–4–1. Its fitness is the _real_ length $10 + 4 + 14 + 5 + 7 = 40$, not the sum of the weighted distances. The same greedy, steered by other keys, built another tour — here a worse one than plain nearest neighbour; evolution's job is to find the keys that steer it somewhere better.
]

#revisit("ch15")[The list does not describe the solution directly; the decoder does. Each key orders or weights one city, item or candidate, and a construction — a sort, or your greedy — builds the solution from them. Every list of keys yields a solution, so the genetic operators never break anything.]

=== When the keys do nothing

A decoder fails the third requirement when many chromosomes decode to the same solution. Two traps:
- *A greedy value of zero.* If $q(e, S) = 0$, then $"ch"_e dot q(e, S) = 0$ too, so all the candidates with $q = 0$ stay tied whatever their keys — typically at the first step, when $S$ is empty and nothing has been added yet. Use $q' = "ch"_e dot (1 + q)$, or $q' = q + epsilon "ch"_e$, or let the keys break the ties.
- *One key per item, while the greedy chooses a place for that item.* If the greedy takes the items in a fixed order and puts each where it costs least (a task on a computer, a VM in a datacentre), a key per item multiplies the cost of _all_ the places of that item by the same number: the argmin does not move, and every chromosome decodes to the greedy's solution. Use one key per pair $chevron.l "item", "place" chevron.r$, or use the item keys for the processing order — keys as priorities again, with the greedy's rule choosing the place. The Python BRKGA of Lab 4 does the latter: tasks in decreasing order of $"ch"_t dot r_t$, each on the computer the greedy would choose.

The rule behind both: a key must be able to change the outcome of a comparison the greedy actually makes.

== Evolution in BRKGA

#figure(image("/figures/brkga.svg"), caption: [One generation of BRKGA: the elite is copied, new random mutants are added, and the rest are children of one elite and one non-elite parent.])

The population of $p$ chromosomes is sorted by fitness and split into an *elite* set (the best $p_e dot p$) and the rest. The next generation consists of
- the elite, copied unchanged;
- $p_m dot p$ *mutants*: brand-new random chromosomes (diversification);
- children filling the rest, each from one *elite* and one *non-elite* parent by *parametrized uniform crossover*: gene by gene, the child takes the elite parent's key with probability $rho > 0.5$, the other parent's otherwise.

The slides' example: elite parent $a = (0.25, 0.19, 0.67, 0.05, 0.89)$, other parent $b = (0.63, 0.90, 0.76, 0.93, 0.08)$; with random draws that pick $a, b, b, a, a$, the child is $(0.25, 0.90, 0.76, 0.05, 0.89)$. Because children lean toward elite parents and elite individuals survive, good keys spread; mutants keep the search from collapsing. Typical settings are small elite fractions (10–25 %), a mutant fraction of 10–30 % and $rho approx 0.7$, tuned on a few instances (Lab 4, part D).

#stopbox("ch15-a")[
  + Why does BRKGA need no repair after crossover?
  + What does the decoder return?
  + Describe the three groups that form the next generation.
]

== Answering question 3(b)

+ *Chromosome:* "$|"ch"| = $ (number of candidates or items)", with one key per what.
+ *Fitness:* the objective of the decoded solution; if the decoder may fail, add a large penalty times the violation so infeasible individuals rank last.
+ *Decoder:* "the greedy of (a) with $q'(e, S) = "ch"_e dot q(e, S)$", and the lines of pseudocode that change. Check it against _When the keys do nothing_: $q = 0$, and a key per item when the greedy chooses a place for the item.
+ If asked, *illustrate* with two chromosomes on a small instance, showing that they lead to different solutions.

#example[The neighbours problem: greedy versus decoder][
  Six neighbours, $T = (3, 2, 4, 9, 8, 9)$, and $M(1) = {1, 2}$, $M(2) = {2}$, $M(3) = {1, 3}$, $M(4) = {1, 2, 4, 5}$, $M(5) = {2, 5, 6}$, $M(6) = {5, 6}$; at least 3 neighbours must be convinced.

  *Greedy* ($q = T_i slash |M(i) without Y|$, min): ratios 1.5, 2, 2, 2.25, 2.67, 4.5 → neighbour 1, $Y = {1, 2}$. Then neighbour 3 ($4 slash 1$) and neighbour 5 ($8 slash 2$) tie at 4; the lower index wins: neighbour 3, $Y = {1, 2, 3}$. Time 7.

  *Decoder* with $"ch" = (0.9, 0.3, 0.6, 0.5, 0.7, 0.4)$ and $q' = "ch"_i dot q$: weighted ratios 1.35, 0.6, 1.2, 1.125, 1.87, 1.8 → neighbour 2, $Y = {2}$. Then neighbour 3: $0.6 dot 4 slash 2 = 1.2$ is the smallest → $Y = {1, 2, 3}$. Time $2 + 4 = 6$ — the optimum, which the plain greedy missed.
]

#yourturn("ch15-yt1")[
  Task assignment (P2). Chromosome: #blank(w: 7em) genes. Decoder: process tasks in decreasing order of #blank(w: 6em) (or of $r_t$), and choose the computer minimizing $q'(chevron.l t, c chevron.r) = $ #blank(w: 8em). Fitness: #blank(w: 8em); if a task fits nowhere, fitness $=$ #blank(w: 8em).
]

#tip(label: [The chapter in five lines])[
  + GA: population, fitness, selection, crossover, mutation; permutation encodings need problem-specific operators and repair.
  + BRKGA: chromosomes are vectors of random keys in $[0, 1)$; every vector is valid; all problem knowledge is in the decoder.
  + Decoder: keys as priorities (sort), or your greedy with $q' = "ch"_e dot q$ — feasible because the greedy is; fitness = the real objective; make sure a key can change a choice ($q = 0$, key per item).
  + Next generation: copy the elite, add random mutants, fill with elite × non-elite children (gene from the elite parent with probability $rho > 0.5$).
  + Exam 3(b): $|"ch"|$ and meaning of each key; fitness (with penalty); decoder as a modification of the greedy; two-chromosome illustration if asked.
]

== Exercises

#chapter-time()

=== Warm-up

#exercise("ch15-w1", time: 3, tier: "warm")[With $rho = 0.7$, what is the probability that a child of a 5-gene crossover inherits all five keys from the elite parent?]

#exercise("ch15-w2", time: 4, tier: "warm")[Apply inversion of positions 2–5 to the tour 1 2 3 4 5 6 and give the result. Which edges changed?]

=== Practice

#exercise("ch15-p1", time: 10)[Run the slides' TSP decoder with chromosome 1, whose keys are all 1 for every edge. Which tour does it build and how long is it? Why do the two chromosomes give different tours?]

#exercise("ch15-p2", time: 10)[A colleague proposes for the ISS crew the decoder $q'(i, S) = "ch"_i dot q(i, S)$ with $q$ = added training cost. Show that at the first step it ignores the chromosome, and fix it.]

=== CPLEX / OPL

_Lab 4, part D._

#exercise("lab4-d", source: "Lab 4 · part D", time: 15, tier: "tool")[Describe the decoder of the Python BRKGA for P2. Tune its parameters (population size, $p_e$, $p_m$, $rho$) on a few instances, then compare it with GRASP and CPLEX on the generated instances, with the same time limits.]

=== Exam level

_Question 3(b) of three past exams; your part (a) is in Chapter 11._

#exercise("jun25-q3b", source: "Final Jun 2025 · Q3(b)", time: 12, tier: "exam")[For the "First Dates" problem and the BRKGA metaheuristic, specify the structure of the chromosome, the fitness function, and the pseudocode of the decoder tailored to the problem (avoid writing the general algorithm).]

#exercise("jan26-q3b", source: "Final Jan 2026 · Q3(b)", time: 12, tier: "exam")[The same for the solar-panel neighbours problem.]

#exercise("jun26-q3b", source: "Final Jun 2026 · Q3(b)", time: 18, tier: "exam")[For the ISS-crew problem: specify the structure of the chromosome and the pseudocode of the decoder (you may just highlight the differences with the greedy, in particular how you use the chromosome); generate two chromosomes and illustrate how the decoder builds two different solutions. (For the illustration, use the official example: $N = {1, 2, 3, 4}$; $E$ has rows $(1, 1, 1, 0)$, $(1, 1, 0, 0)$, $(1, 0, 1, 1)$, $(0, 0, 1, 1)$ ($e_(i j) = 1$ if $i, j$ collaborated); training costs $C$ with rows $(0, 0, 0, 1)$, $(0, 0, 2, 3)$, $(0, 2, 0, 0)$, $(1, 3, 0, 0)$; chromosomes $(1.0, 1.0, 1.0, 1.0)$ and $(1.0, 0.2, 1.0, 1.0)$; crew of $K = 2$.)]

=== Spaced review

_From Chapters 9, 12 and 14._

#exercise("ch15-r1", source: "review of Ch. 14", time: 3, tier: "review")[Two assignments of 6 users differ for 2 users. What is $|S plus.o S'|$ for the corresponding sets of (user, access point) pairs?]

#exercise("ch15-r2", source: "review of Ch. 9", time: 3, tier: "review")[In a minimization, which terms need an SOS2 when approximated piecewise: convex ones or concave ones?]
