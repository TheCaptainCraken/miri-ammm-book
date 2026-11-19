#import "../template.typ": *

= Intensification, diversification and path relinking

#symbols(
  ($A plus.o B$, [symmetric difference $(A union B) without (A inter B)$: elements in exactly one of the two]),
  ($d(S, S') = |S plus.o S'|$, [distance between two solutions seen as sets of elements]),
  ([ES], [elite set: a small pool of good and diverse solutions]),
  ($d(S, "ES")$, [$min{|S plus.o S'| : S' in "ES"}$, distance from $S$ to the pool]),
  ($d("ES")$, [$min{|S' plus.o S''| : S', S'' in "ES"}$, diversity of the pool]),
  ($a, b$, [initiating and guiding solutions of path relinking]),
)

#pretest("ch14")[Two different solutions have the same cost, 460. Could a solution "halfway between them" be better than both? What would "halfway" even mean for an assignment of users to access points?]

GRASP has no memory: iteration 500 knows nothing of iterations 1 to 499. The ideas of this chapter use what the search has already seen. *Intensification* looks harder where good solutions were found; *diversification* pushes the search where it has not been. *Path relinking* does both at once by exploring the space _between_ good solutions.

== Two opposite needs

*Intensification.* Portions of the search space that look promising deserve a more thorough search, to make sure their best solutions are found. From time to time the normal search is paused for an intensification phase, guided by an *intermediate-term memory* — for instance, how many consecutive iterations each solution component (a task on a computer, a user on an access point) has been present in good solutions. Components that keep appearing can be fixed while the rest is searched more finely. Intensification is not always needed: often the normal search is enough.

*Diversification.* Local-search methods tend to stay "local": they spend most of their time in a small region. Diversification forces the search into unexplored areas using *long-term memory* — the total number of iterations each component has been present in the current solution or involved in moves. Rarely used components can be forced into the current solution before restarting, or frequency can be added as a penalty to the cost so that overused components become less attractive. #think[GRASP's $alpha$ and local search: which one intensifies, which one diversifies?]

== Distances between solutions

To speak of "similar" and "different" solutions we need a distance. Seeing a solution as a set of elements, the slides use the size of the *symmetric difference*:
$ d(S, S') = |S plus.o S'| = |(S union S') without (S inter S')|. $
For assignment problems the elements are pairs (user, access point): if two assignments differ for $k$ users, $|S plus.o S'| = 2k$ (each differing user contributes one pair to each side). Counting "users assigned differently" ($k$) is the same distance up to a factor 2.

== Path relinking

Given two good solutions, an *initiating* solution $a$ and a *guiding* solution $b$, path relinking builds a path from $a$ to $b$: at each step it adds to the current solution one element of $b$ that it does not have yet (removing what becomes incompatible), choosing the element that gives the best cost. The best solution met along the path is returned.

```pseudo
f* <- min{f(a), f(b)};  x* <- argmin{f(a), f(b)}
x <- a
while x != b:
    // best step towards b
    u* <- argmin { f(x + u) : u in b \ x }
    x <- x + {u*}  // (remove v in x \ b to keep x feasible)
    if f(x) < f*: f* <- f(x); x* <- x
return x*
```

Most intermediate solutions of a path between two good solutions are infeasible or poor, but some are better than both ends: good solutions share structure, and mixing them combines their good parts. Relinking can go forward ($a -> b$), backward ($b -> a$), or both; the slides' plots show that the two directions explore different solutions. #fig("/figures/path-relinking.svg", caption: [The slides' path between two network plans of cost 460: the three intermediate plans cost 420.], margin: true)

#example[Path relinking in network planning][
  Users 1–10 (capacity demands 2, 3, 4, 1, 2, 2, 1, 2, 3, 4), the instance of Chapter 11. Assignments (access point of each user):

  initiating $a = (3, 1, 3, 3, 3, 1, 1, 5, 1, 5)$: $a_1$ serves ${2, 6, 7, 9}$ (R3), $a_3$ ${1, 3, 4, 5}$ (R3), $a_5$ ${8, 10}$ (R1) — cost 460;

  guiding $b = (3, 1, 3, 3, 1, 3, 3, 1, 1, 5)$ — cost 460.

  They differ for users 5, 6, 7, 8. The best first step moves user 7 to $a_3$: $a_1$ (users 2, 6, 9, demand 8) downgrades to R2, cost 420. Then user 5 to $a_1$ (420) and user 6 to $a_3$ (420). The last step, user 8 to $a_1$, reaches $b$ (460). The best solution on the path costs 420, better than both ends.
]

#revisit("ch14")[Yes: between two 460-cost plans the path passes three plans of cost 420. "Halfway" means: change, one user at a time, the access points where the two solutions disagree.]

#stopbox("ch14-a")[
  + Define $|A plus.o B|$ and compute it for $A = {1, 2, 3}$, $B = {2, 3, 4, 5}$.
  + In path relinking, which elements can be added at each step?
  + What does path relinking return?
]

== The elite set

Path relinking needs pairs of good solutions; they are kept in an *elite set* (ES), small (say 5–10) and diverse. A new solution $S$ enters if

- it is better than the best of ES: $f(S) < f("best"_"ES")$; or
- it is better than the worst of ES _and_ far enough from all of them: $f(S) < f("worst"_"ES")$ and $d(S, "ES") >= d("ES")$.

When $S$ enters, the solution that leaves is the closest $S'$ to $S$ among those with $f(S') >= f(S)$. The rule keeps the pool good (quality condition) and spread out (distance condition), so that relinking pairs from it explores different regions.

#yourturn("ch14-yt1")[
  ES $= {A = {1,2,3} "(cost 10)", B = {1,4,5} "(12)", C = {2,4,6} "(15)"}$, minimization.
  - $d("ES") = $ #blank(): $|A plus.o B| = $ #blank(), $|A plus.o C| = $ #blank(), $|B plus.o C| = $ #blank().
  - $S = {1, 2, 6}$, cost 11: $d(S, "ES") = $ #blank(). Enters? #blank(w: 3em), because #blank(w: 10em).
  - $S = {3, 5, 6}$, cost 14: $d(S, "ES") = $ #blank(). Enters? #blank(w: 3em). Which solution leaves? #blank()
]

== GRASP with path relinking, and other hybrids

Heuristics combine well. *GRASP + PR*: each GRASP iteration builds and improves a solution; then, with some probability, it is relinked with a random elite solution, and the best solution of the path is offered to the elite set. GRASP supplies diversification, PR intensification. The slides' last example is a *multi-greedy + PR*: three different randomized constructions (one fast, two slower but better) feed a local search and a shared elite set; the fast greedy gives feasible solutions within 20–50 ms, the others close the optimality gap given more time — the kind of trade-off the network applications of Chapter 10 need.

```pseudo
ES <- {}; best <- none
for it = 1 to maxIter:
    S <- LocalSearch(RandomizedGreedy(alpha))
    if ES is not empty and random() < pPR:
        S' <- random element of ES
        S <- best of PathRelinking(S, S')
             (and/or PathRelinking(S', S))
    UpdateES(S); if S better than best: best <- S
return best
```

#stopbox("ch14-b")[
  + State the two conditions under which a solution enters the elite set.
  + Which solution leaves the elite set?
  + In GRASP + PR, which part intensifies and which diversifies?
]

#summary[
  + Intensification searches good regions more thoroughly (intermediate-term memory); diversification sends the search to unexplored regions (long-term memory, frequency penalties).
  + Distance between solutions: $|S plus.o S'|$, the symmetric difference.
  + Path relinking walks from an initiating to a guiding solution, adding the best missing element each step, and returns the best solution on the path.
  + Elite set: enter if better than the best, or better than the worst and at distance $>= d("ES")$; the closest not-better member leaves.
  + Hybrids such as GRASP + PR or multi-greedy + PR combine diversification and intensification.
]

== Exercises

#chapter-time()

#tier("warm")

#exercise("ch14-w1", time: 3, tier: "warm")[Compute $|S plus.o S'|$ for the task assignments $(c_1, c_3, c_2, c_1)$ and $(c_2, c_3, c_1, c_1)$, seen as sets of pairs (task, computer).]

#exercise("ch14-w2", time: 3, tier: "warm")[Give one intensification and one diversification mechanism based on the frequency with which "task $t$ on computer $c$" appears in solutions.]

#tier("practice")

#exercise("ch14-p1", time: 12)[In the network-planning path relinking, compute the cost of the four possible first steps from $a$ (moving user 5 to $a_1$, user 6 to $a_3$, user 7 to $a_3$ or user 8 to $a_1$). Use the router models R1 (100 €, capacity 6, reach 2), R2 (140 €, 8, 3), R3 (180 €, 10, 4) and the distances of the instance. Which step does PR take?]

#exercise("ch14-p2", time: 8)[Why does the elite-set rule require $d(S, "ES") >= d("ES")$ only when $S$ is not better than the best? What could go wrong if every solution better than the worst entered?]

#tier("exam", note: [never asked so far; exam-style])

#exercise("pr-new-exam", source: "new, exam style", time: 15, tier: "exam")[For the task-assignment problem P2 (solutions = computer of each task): (a) define the distance between two solutions; (b) write the path-relinking procedure from $S_a$ to $S_b$, including what to do when an intermediate solution violates a capacity; (c) explain how you would combine it with your GRASP.]

#tier("review", note: [from Chapters 7, 12 and 13])

#exercise("ch14-r1", source: "review of Ch. 13", time: 3, tier: "review")[Maximization, $q = (5, 9, 9, 1)$, $alpha = 0.5$. RCL?]

#exercise("ch14-r2", source: "review of Ch. 7", time: 4, tier: "review")[Write "a mine worked in year $t$ must be open, and once closed it stays closed".]
