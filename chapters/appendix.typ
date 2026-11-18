// Appendices.  Both tables are generated from the book itself:
//  A collects every #slidenote (label <slidenote>),
//  B every exercise whose source names an exam, a sheet or a lab.
// Nothing here needs editing when a note or an exercise is added.
#import "../template.typ": *

// tables in the appendices also use the margin column (`wide` comes from template.typ)

#let page-of(loc) = link(loc, str(loc.page()))
#let answer-page(id) = {
  let a = query(label("ans-" + id))
  if a.len() > 0 { page-of(a.first().location()) } else { text(fill: red)[??] }
}

#set heading(numbering: none)

#unnumbered[Appendix A · On the slides]

Every correction "On the slides" (and its variants for the official solutions, the exercise sheets and the lab statements), in book order. _Says_ is what the source says; _correct_ is what the book uses instead, with the reason.

#context {
  let notes = query(<slidenote>)
  let kinds = (slides: "slides", solution: "official solution", sheet: "exercise sheet", lab: "lab statement")
  wide(btable(columns: (auto, 0.8fr, 1fr, 1.5fr), size: 0.8em,
    header: ([p.], [where], [says], [correct, and why]),
    ..notes.map(n => {
      let v = n.value
      (page-of(n.location()),
       [#v.deck, #v.where \ #text(fill: grey, size: 0.9em)[#kinds.at(v.kind)]],
       v.says,
       [#v.correct #text(fill: grey)[— #v.why]])
    }).flatten()))
  [#notes.len() notes in total.]
}

#unnumbered[Appendix B · Where each exercise of the course is]

Every question of the five past finals, every exercise of the two homework sheets and every lab task, with its place in the book and the page of its answer.

#let source-table(prefixes) = context {
  let rows = ()
  for p in prefixes {
    // natural order inside each source: Q1 before Q2(a), Ex 2 before Ex 10
    let key(m) = m.value.source.replace("tasks", "task").replace(regex("\\d+"), d => "0000".slice(d.text.len()) + d.text)
    for m in exercises-with(p).sorted(key: key) {
      rows.push((m.value.source, link(m.location(), m.value.n), page-of(m.location()), answer-page(m.value.id)))
    }
  }
  wide(btable(columns: (1fr, auto, auto, auto), size: 0.85em, align: (left, right, right, right),
    header: ([source], [exercise], [page], [answer]), ..rows.flatten()))
}

== Past finals

#source-table(("Final Jun 2024", "Final Jan 2025", "Final Jun 2025", "Final Jan 2026", "Final Jun 2026"))

== Homework sheets

#source-table(("LP sheet", "ILP sheet"))

== Labs

#source-table(("Lab 1", "Lab 2", "Lab 3", "Lab 4"))

#unnumbered[Bibliography]

#set par(hanging-indent: 1.2em)

The course material: slides, lab statements, exercise sheets and past exams (June 2024 to June 2026) with their solutions, by E. Rodríguez-Carbonell and L. Velasco, Algorithmic Methods for Mathematical Models, Universitat Politècnica de Catalunya, 2024–2026.

H. P. Williams. _Model Building in Mathematical Programming_, 5th ed. Wiley, 2013.

D. G. Luenberger and Y. Ye. _Linear and Nonlinear Programming_, 5th ed. Springer, 2021.

F. Glover and G. A. Kochenberger (eds.). _Handbook of Metaheuristics_. Kluwer, 2003.

S. P. Bradley, A. C. Hax and T. L. Magnanti. _Applied Mathematical Programming_. Addison-Wesley, 1977.

Z. Michalewicz and D. B. Fogel. _How to Solve It: Modern Heuristics_, 2nd ed. Springer, 2004.

M. G. C. Resende and C. C. Ribeiro. _Optimization by GRASP_. Springer, 2016.

J. F. Gonçalves and M. G. C. Resende. Biased random-key genetic algorithms for combinatorial optimization. _Journal of Heuristics_ 17:487–525, 2011.

IBM ILOG CPLEX Optimization Studio, _OPL Language User's Manual_ and _CPLEX User's Manual_, version 22.1.
