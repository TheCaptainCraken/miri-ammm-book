// main.typ — only puts the book together.  The look comes from the Captain Craken
// template (@local/craken), through the helpers in template.typ.
// Each chapter(slug, …) is one page of the website (slug.html); in the PDF it does nothing.
#import "template.typ": *

#show: book.with(
  title: "From the model to the heuristic",
  subtitle: "A study book for Algorithmic Methods for Mathematical Models (AMMM, MIRI–UPC)",
  author: "Pietro Agnoli",
  logo: read("assets/captain-craken.png", encoding: none),
  pdf: "ammm-book.pdf",
  series: [Algorithmic Methods for Mathematical Models],
  description: [LP and ILP modelling, the simplex method, branch & bound, non-linear programming and metaheuristics, with exercises, past exams and worked answers. Course material by Prof. Enric Rodríguez-Carbonell and Prof. Luis Velasco (UPC).],
)

#context if target() == "paged" { include "chapters/00-cover.typ" }
#chapter("preface", include "chapters/00-preface.typ")

#part(intro: [Chapters 1-9 follow Prof. Rodríguez-Carbonell's lectures and the first three labs: how to turn a story into a linear model, how to write it in OPL, how the simplex method and branch & bound solve it, and what changes when the model is not linear. At the end of this part you'll be able to solve questions 1 & 2 in the final.])[Linear and integer programming]
#chapter("lp-modelling", include "chapters/01-lp-modelling.typ")
#chapter("opl-cplex", include "chapters/02-opl-cplex.typ")
#chapter("bases", include "chapters/03-bases.typ")
#chapter("simplex", include "chapters/04-simplex.typ")
#chapter("ilp-binary", include "chapters/05-ilp-binary.typ")
#chapter("ilp-logic", include "chapters/06-ilp-logic.typ")
#chapter("ilp-time", include "chapters/07-ilp-time.typ")
#chapter("branch-bound", include "chapters/08-branch-bound.typ")
#chapter("nlp", include "chapters/09-nlp.typ")

#part(intro: [Chapters 10–15 follow Prof. Velasco's lectures and Lab 4: what to do when the exact model is too slow — greedy construction, local search, GRASP, path relinking and BRKGA. Exam question 3 lives here.])[Heuristics]
#chapter("heuristics", include "chapters/10-heuristics-intro.typ")
#chapter("greedy", include "chapters/11-greedy.typ")
#chapter("local-search", include "chapters/12-local-search.typ")
#chapter("grasp", include "chapters/13-grasp.typ")
#chapter("intensification", include "chapters/14-intensification.typ")
#chapter("brkga", include "chapters/15-brkga.typ")

#part(intro: [One chapter that mixes everything: how to spend the three hours, a quick-fire drill, interleaved problems, a case study and a full mock exam with solutions.])[Exam training]
#chapter("exam-training", include "chapters/16-exam-training.typ")

#chapter("answers", include "answers/answers.typ")
#chapter("appendix", include "chapters/appendix.typ")
