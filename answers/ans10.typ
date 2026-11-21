#import "../refs.typ": answer, exref, slidenote

#answer("ch10-a")[(a) Given (sets and parameters), output, objective (direction), constraints. (b) Lab 1: $1238.47 slash 1711.13 = 0.7238$. Five tasks: $1583.17 slash 1711.13 = 0.9252$. (c) To regenerate exactly the same instances, so that experiments (and other people) can be repeated and methods compared on the same data.]

#answer("ch10-b")[(a) Constructive phase (e.g. greedy) and local search. (b) A solution that no move of the chosen neighbourhood improves. (c) For NP-hard problems no polynomial exact algorithm is expected, so large instances must be tackled approximately.]

#answer("ch10-w1")[*Given:* tasks $T$ with requests $r_t$; computers $C$ with capacities $R_c$. *Output:* the computer of each task. *Objective:* minimize the load of the most loaded computer. *Constraints:* each task on exactly one computer; capacities not exceeded.]

#answer("ch10-w2")[$50 dot 10 = 500$ binaries plus $z$: 501 variables. Constraints: 50 (assignment) + 10 (capacity) + 10 ($z$) = 70.]

#answer("ch10-p1")[Load $= 0.7238$. P1 (splitting allowed) stays feasible as long as total request $<=$ total capacity, so the requests can be multiplied by $1 slash 0.7238 = 1.3816$, i.e. increased by 38.16 %. (Compare: the capacities could shrink by 27.62 % — the same condition seen from the other side.)]

#answer("ch10-p2")[After computing `rt`, test `max(rt) <= max(rc)`; if it fails, draw again (new seed or new weights). Discarding large tasks would silently change the requested load and bias the instances toward easier ones — the experiment would no longer measure what it claims.]

#answer("lab4-a")[In a `main` block, `cplex.tilim = 1800; cplex.epgap = 0.01;` (or the settings file: General → time limit; Mixed Integer Programming → Tolerances → relative gap). Expected: small instances are solved to optimality in seconds; as size grows the time rises sharply and the larger ones stop at the time limit with a gap above 1 %. Raising the load toward 1 makes feasibility itself hard, so times grow further and some instances become infeasible.]

#answer("ch10-e1")[C1: the crew has at least $K$ members. C2: any two crew members have collaborated (pair in $E$) or are trained together. C3: each astronaut follows at most $M$ courses. Objective: minimize the total cost of the training courses. A candidate can be an astronaut not yet in the crew (adding him or her creates the courses with all current members not in $E$); alternatively a pair to train, but candidates as astronauts give a simpler algorithm.]

#answer("ch10-r1")[Branch & bound keeps a bound (the best relaxation value among pending nodes); the incumbent is provably within the gap of the optimum. A heuristic has no bound: it does not know how far its solution is from the optimum.]

#answer("ch10-r2")[$sum_(c in C) x_(t c) = 1$ for all $t$; $sum_(t in T) x_(t c) <= 2$ for all $c$.]
