// main.typ — only puts the book together.  The look comes from the Captain Craken
// template (@local/craken), through the helpers in template.typ.
#import "template.typ": *

#show: book.with(
  title: "Algorithmic Methods for Mathematical Models",
  author: "Pietro Agnoli",
)

#include "chapters/00-cover.typ"
#include "chapters/00-preface.typ"

#include "chapters/part1.typ"
#include "chapters/01-lp-modelling.typ"
#include "chapters/02-opl-cplex.typ"
#include "chapters/03-bases.typ"
#include "chapters/04-simplex.typ"
#include "chapters/05-ilp-binary.typ"
#include "chapters/06-ilp-logic.typ"
#include "chapters/07-ilp-time.typ"
#include "chapters/08-branch-bound.typ"
#include "chapters/09-nlp.typ"

#include "chapters/part2.typ"
#include "chapters/10-heuristics-intro.typ"
#include "chapters/11-greedy.typ"
#include "chapters/12-local-search.typ"
#include "chapters/13-grasp.typ"
#include "chapters/14-intensification.typ"
#include "chapters/15-brkga.typ"

#include "chapters/part3.typ"
#include "chapters/16-exam-training.typ"

#include "answers/answers.typ"
#include "chapters/appendix.typ"
