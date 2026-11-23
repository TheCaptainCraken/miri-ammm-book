#import "../template.typ": *

#set heading(numbering: none)
= Preface

This book prepares you for the final exam of Algorithmic Methods for Mathematical Models (AMMM), in the Advanced Computing specialization of the Master in Innovation and Research in Informatics at UPC. It follows the course in its order:

1. Linear programming
2. Integer programming
3. Non-linear programming
4. Heuristics
5. Metaheuristics

It is meant to be enough on its own: every idea is explained from the ground up, every exercise of the homework sheets and every question of the five past finals is solved, and every number has been checked by a script.

It is not a summary. A summary helps you recognize the material; the exam asks you to _produce_ it, with no notes, in three hours. So each chapter explains why each formula is what it is, works through concrete cases before stating the general rule, shows the usual ways things go wrong, and then makes you practise until the method is yours.

== How to use this book

*One chapter, one afternoon.* Each chapter takes two to four hours, reading and exercises included; the start of each exercise list says how long its exercises take in total. Chapter 16 is the exception: its mock exam is a separate three-hour sitting.

*Every chapter has the same parts:*
- A list of the *symbols* it uses, and a *pretest*: a question to answer before reading. Try to guess! A wrong guess makes the right answer stick. Each pretest is revisited in the text (the page is given).
- Sections that start from a *concrete example*, give the picture and the intuition, and only then the definition or formula.
- *Worked examples*, followed by *Your turn* versions with blanks to fill in. Fill them in on paper before checking the answers.
- *Think first* prompts: stop and explain the point to yourself before reading on.
- *Stop and answer* boxes at the end of sections: answer from memory, then check. This is the single most effective thing in the book! Do not skip them.
- *The chapter in five lines*: the summary to put on flashcards.
- *Exercises* in tiers: *Warm-up* (a few minutes each to get you going), *Practice* (one technique at a time), *Exam level* (past exam questions and look-alikes that mix techniques), *CPLEX/OPL* (lab work), and *Spaced review* (questions from earlier chapters). Each exercise shows its source and an estimated time, and is rated from one to three suckers by that time.

*Keep a logbook* (see below). *Answers are at the end of each chapter*, under Solutions; each Your turn and Stop box links to its answer and back. On the website every answer hides under its question instead. Past exam questions are tagged with their source ("Final Jun 2024 - Q1"); Appendix B lists where each of them is in the book.

*Margin notes "On the slides"* mark places where a slide (or an official solution, or an exercise sheet) contains an error, a misleading shortcut or a convention different from the book's. Each says what the slide says, what is correct and why. Appendix A collects all of them.

*Appendix C* is not for the exam. It follows Prof. Velasco's research through the course's last deck, _Some Applications_, and shows the heuristics of Part II at work on real networks.

== The logbook

Answer everything! Pretests, Your turn, Stop boxes, exercises. Do it in one place, by date: the logbook. Its real job is to keep your *mistakes*. A mistake you have written down, in your own words, next to what you should have done, is the most useful page you will have before the exam. A mistake you only noticed is forgotten by the next session.

The sources include a ready logbook, `logbook.typ`, with three functions:

```typ
// a study session, by date
#session("12 Nov")
// one item, with the id printed in the book
#exercise("ch4-p3")[my answer ...]
// inside an exercise
#mistake[what I did][what I should have done]
```

A mistake is shown in red inside its exercise and is listed, with its id and date, on the *first page* of the logbook. The routine:

+ *Start every session on page one.* Read the mistakes list, pick two or three, and redo those exercises from scratch without looking at the old answer.
+ *Then study* the new material, writing each answer under today's session.
+ *Check against the solutions at the end of the chapter* and write a `#mistake` for every slip, however small: a sign, a forgotten index, a wrong direction of the objective. "I did … / should …", one line each.

The last week before the exam, the list on page one is your revision plan.

== The exam

Three hours, closed book, three questions.
- *Q1* (2.1 points): a small LP in canonical form and a feasible basis. Compute the basic solution, the objective value, the reduced costs, and either the ratio test (June sessions) or the branching subproblems (January sessions). Chapters 3, 4 and 8.
- *Q2* (3.9 points): an integer linear model for a story: explain a piece of OPL, then write variables, constraints and objective. Chapters 2, 5, 6 and 7.
- *Q3* (4 points): a greedy algorithm and a BRKGA for the same story. Chapters 11 and 15, with chapters 12 to 14 behind them.

The final counts for 60 % of the course mark. The project for the other 40 %.

== Notation used throughout

#table(align: left, 
  columns: (auto, 1fr, auto),
  table.header([symbol], [meaning], [chapters]),
  [$x_j$],
  [decision variable; $x >= 0$ unless declared free],
  [all],
  [$c, A, b$],
  [costs, constraint matrix ($m times n$), right-hand side],
  [1–4, 8],
  [$B, R$],
  [basis and non-basic columns; $x_B, x_R$ basic and non-basic variables],
  [3, 4],
  [$beta_i$],
  [value of the $i$-th basic variable in the basic solution],
  [4, 8],
  [$d_j$],
  [reduced cost of non-basic $x_j$ (the slides give it no letter)],
  [4, 8],
  [$s_i$],
  [slack variable of constraint $i$],
  [3, 4, 8],
  [$z$],
  [the objective's value, or an auxiliary variable for a max/min (said each time)],
  [1, 4, 6],
  [$delta$],
  [indicator (binary) variable],
  [6, 9],
  [$M$, $U$],
  [big-M constant; $U$ when the story already uses $M$],
  [6, 7],
  [$T, C$; $r_t, R_c$],
  [tasks, computers; request of task $t$, capacity of computer $c$ (the labs write $r_c$)],
  [1, 2, 10–15],
  [$Omega$, $f$, $omega$],
  [solution space, objective, a solution],
  [10],
  [$cal(C)$, $e$, $S$],
  [candidate set (slides: $C$), a candidate, the partial solution],
  [11–15],
  [$q(e, S)$],
  [greedy function (direction always stated)],
  [11, 13, 15],
  [$alpha$],
  [RCL parameter of GRASP],
  [13],
  [$A plus.o B$],
  [symmetric difference],
  [14],
  [$"ch"$, $p_e$, $p_m$, $rho$],
  [chromosome of random keys; elite and mutant fractions; inheritance probability],
  [15],
)

Where the slides use one letter for several things, the book keeps the meanings apart. *$C$* is the set of computers in the labs and the candidate set in the greedy slides: the book writes $cal(C)$ for candidates. *$r$* is both a task's request and a computer's capacity in Lab 1: the book writes $r_t$ and $R_c$. *$R$* is the non-basic part of a basis in Part I and the set of covered elements in set covering: the meaning is restated where it is used. *$M$* is a big-M constant but also a matrix (January 2026) and a course limit (June 2026): in those stories the constant is called $U$. Linear programs are written in the slides' canonical form, $min c^T x$ with $A x = b$ and $x >= 0$, and a "maximization" is converted when needed.

== Credits

The course slides, lab statements, exercise sheets, past exams and their solutions are by Prof. *Enric Rodríguez-Carbonell* (linear, integer and non-linear programming) and Prof. *Luis Velasco* (heuristics and metaheuristics), Universitat Politècnica de Catalunya (UPC), Facultat d'Informàtica de Barcelona. Many modelling exercises come from H. P. Williams, _Model Building in Mathematical Programming_ (Wiley); the theory follows D. G. Luenberger and Y. Ye, _Linear and Nonlinear Programming_ (Springer), and the metaheuristics F. Glover and G. A. Kochenberger (eds.), _Handbook of Metaheuristics_ (Kluwer), and the work of M. G. C. Resende and C. C. Ribeiro on GRASP and BRKGA.

The numbers in the text and the answers were verified with exact rational arithmetic (simplex, branch & bound, separable programming), with IBM CPLEX (every LP and MILP of the sheets and labs, solved through its Python interface) and by brute force on random instances (every exam model and every greedy algorithm). The scripts are in the `verify/` folder of the sources.

This edition: November 2026.
