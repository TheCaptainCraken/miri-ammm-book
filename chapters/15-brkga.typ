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

The difficulty is the encoding. For the TSP, the natural chromosome is the tour itself, a permutation such as 124385967. Crossing two permutations naively — say exchanging positions 4–7 of 124385967 and 452187693 — gives 124187667 and 452385993, which repeat cities and miss others; they must be *repaired* (duplicates replaced by the missing cities), which the slides show as 524187693 and 412385967. A mutation such as *inversion* reverses a segment: 124385967 → 124958367. Every problem needs its own crossover, mutation and repair, and they are easy to get wrong. #think[What property should an encoding have so that _any_ crossover of two chromosomes gives a valid chromosome?]

== Random keys and the decoder

*BRKGA* (biased random-key genetic algorithm) moves all problem knowledge into one place. A chromosome is a vector of $g$ *random keys* in $[0, 1)$. Any vector of keys is a valid chromosome, so crossover and mutation are generic and never need repair. The problem-specific part is the *decoder*: a deterministic procedure that reads the keys and builds a feasible solution, returning its fitness (the objective, plus a penalty if the decoder could not reach feasibility).

The most convenient decoder for the exam is *your greedy algorithm with the keys plugged into the greedy function*: one key per candidate (or per item), and
$ q'(e, S) = "ch"_e dot q(e, S) $
(or a similar combination). Different chromosomes bend the greedy's preferences in different directions, so they build different solutions; evolution searches for the keys that make the greedy build the best one. Another classic decoder uses the keys as *priorities*: sort the items by their key and process them in that order with a simple rule.

#revisit("ch15")[The list does not describe the solution directly; the decoder does. Each key weights (or orders) one candidate of a greedy, and the greedy builds the solution. Every list of keys yields a feasible solution, so the genetic operators never break anything.]

#example[The TSP decoder of the slides][
  One key per edge (10 edges for 5 cities). The decoder multiplies each distance by its key and runs nearest neighbour from city 1 on the weighted distances. With chromosome 2 of the slides — keys 0.3, 0.7, 0.6, 0.4, 0.4, 0.7, 0.3, 0.9, 0.3, 0.65 for the edges 12, 13, 14, 15, 23, 24, 25, 34, 35, 45 — the weighted distances are 3, 8.4, 4.2, 3.6, 4.4, 11.9, 1.2, 4.5, 4.2, 5.85. From 1 the nearest is 2 (3), then 5 (1.2), then 3 (4.2), then 4 (4.5): tour 1–2–5–3–4–1, whose real length is $10 + 4 + 14 + 5 + 7 = 40$. The fitness is the _real_ length; the weights only steer the construction.
]

== Evolution in BRKGA

#fig("/figures/brkga.svg", caption: [One generation of BRKGA: the elite is copied, new random mutants are added, and the rest are children of one elite and one non-elite parent.], wide: true)

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
+ *Decoder:* "the greedy of (a) with $q'(e, S) = "ch"_e dot q(e, S)$" (adjusted so that the key matters, see below), and the lines of pseudocode that change.
+ If asked, *illustrate* with two chromosomes on a small instance, showing that they lead to different solutions.

One trap: if $q$ can be 0, multiplying by $"ch"_e$ changes nothing and all zero candidates stay tied. Use $q' = "ch"_e dot (1 + q)$, or $q' = q + "ch"_e dot epsilon$, or use the keys to break ties. Another: when maximizing, a larger key should favour the candidate in the same direction consistently (multiply the score) — say which.

#example[The neighbours problem: greedy versus decoder][
  Six neighbours, $T = (3, 2, 4, 9, 8, 9)$, and $M(1) = {1, 2}$, $M(2) = {2}$, $M(3) = {1, 3}$, $M(4) = {1, 2, 4, 5}$, $M(5) = {2, 5, 6}$, $M(6) = {5, 6}$; at least 3 neighbours must be convinced.

  *Greedy* ($q = T_i slash |M(i) without Y|$, min): ratios 1.5, 2, 2, 2.25, 2.67, 4.5 → neighbour 1, $Y = {1, 2}$. Then neighbour 3 ($4 slash 1$) and neighbour 5 ($8 slash 2$) tie at 4; the lower index wins: neighbour 3, $Y = {1, 2, 3}$. Time 7.

  *Decoder* with $"ch" = (0.9, 0.3, 0.6, 0.5, 0.7, 0.4)$ and $q' = "ch"_i dot q$: weighted ratios 1.35, 0.6, 1.2, 1.125, 1.87, 1.8 → neighbour 2, $Y = {2}$. Then neighbour 3: $0.6 dot 4 slash 2 = 1.2$ is the smallest → $Y = {1, 2, 3}$. Time $2 + 4 = 6$ — the optimum, which the plain greedy missed.
]

#yourturn("ch15-yt1")[
  Task assignment (P2). Chromosome: #blank(w: 7em) genes. Decoder: process tasks in decreasing order of #blank(w: 6em) (or of $r_t$), and choose the computer minimizing $q'(chevron.l t, c chevron.r) = $ #blank(w: 8em). Fitness: #blank(w: 8em); if a task fits nowhere, fitness $=$ #blank(w: 8em).
]

#summary[
  + GA: population, fitness, selection, crossover, mutation; permutation encodings need problem-specific operators and repair.
  + BRKGA: chromosomes are vectors of random keys in $[0, 1)$; every vector is valid; all problem knowledge is in the decoder.
  + Decoder = the greedy with keys plugged in, e.g. $q' = "ch"_e dot q$ (beware $q = 0$), or keys as priorities.
  + Next generation: copy the elite, add random mutants, fill with elite × non-elite children (gene from the elite parent with probability $rho > 0.5$).
  + Exam 3(b): $|"ch"|$ and meaning of each key; fitness (with penalty); decoder as a modification of the greedy; two-chromosome illustration if asked.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch15-w1", time: 3, tier: "warm")[With $rho = 0.7$, what is the probability that a child of a 5-gene crossover inherits all five keys from the elite parent?]

#exercise("ch15-w2", time: 4, tier: "warm")[Apply inversion of positions 2–5 to the tour 1 2 3 4 5 6 and give the result. Which edges changed?]

#tier("practice")

#exercise("ch15-p1", time: 10)[Run the slides' TSP decoder with chromosome 1, whose keys are all 1 for every edge. Which tour does it build and how long is it? Why do the two chromosomes give different tours?]

#exercise("ch15-p2", time: 10)[A colleague proposes for the ISS crew the decoder $q'(i, S) = "ch"_i dot q(i, S)$ with $q$ = added training cost. Show that at the first step it ignores the chromosome, and fix it.]

#tier("tool", note: [Lab 4, part D])

#exercise("lab4-d", source: "Lab 4 · part D", time: 15, tier: "tool")[Describe the decoder of the Python BRKGA for P2. Tune its parameters (population size, $p_e$, $p_m$, $rho$) on a few instances, then compare it with GRASP and CPLEX on the generated instances, with the same time limits.]

#tier("exam", note: [question 3(b) of three past exams; your part (a) is in Chapter 11])

#exercise("jun25-q3b", source: "Final Jun 2025 · Q3(b)", time: 12, tier: "exam")[For the "First Dates" problem and the BRKGA metaheuristic, specify the structure of the chromosome, the fitness function, and the pseudocode of the decoder tailored to the problem (avoid writing the general algorithm).]

#exercise("jan26-q3b", source: "Final Jan 2026 · Q3(b)", time: 12, tier: "exam")[The same for the solar-panel neighbours problem.]

#exercise("jun26-q3b", source: "Final Jun 2026 · Q3(b)", time: 18, tier: "exam")[For the ISS-crew problem: specify the structure of the chromosome and the pseudocode of the decoder (you may just highlight the differences with the greedy, in particular how you use the chromosome); generate two chromosomes and illustrate how the decoder builds two different solutions. (For the illustration, use the official example: $N = {1, 2, 3, 4}$; $E$ has rows $(1, 1, 1, 0)$, $(1, 1, 0, 0)$, $(1, 0, 1, 1)$, $(0, 0, 1, 1)$ ($e_(i j) = 1$ if $i, j$ collaborated); training costs $C$ with rows $(0, 0, 0, 1)$, $(0, 0, 2, 3)$, $(0, 2, 0, 0)$, $(1, 3, 0, 0)$; chromosomes $(1.0, 1.0, 1.0, 1.0)$ and $(1.0, 0.2, 1.0, 1.0)$; crew of $K = 2$.)]

#tier("review", note: [from Chapters 9, 12 and 14])

#exercise("ch15-r1", source: "review of Ch. 14", time: 3, tier: "review")[Two assignments of 6 users differ for 2 users. What is $|S plus.o S'|$ for the corresponding sets of (user, access point) pairs?]

#exercise("ch15-r2", source: "review of Ch. 9", time: 3, tier: "review")[In a minimization, which terms need an SOS2 when approximated piecewise: convex ones or concave ones?]
