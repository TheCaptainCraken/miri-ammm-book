// refs.typ — the few pieces both the chapters and the answer files use.
// The answer files import this, not template.typ: template.typ reads them
// (to hand each answer to its exercise), so they can't import it back.

// One answer, recorded for template.typ under the id of its exercise, Your
// turn or Stop box.  It is never printed here: craken prints it where the
// edition wants it (see template.typ).
#let answer(id, body) = metadata((id: id, body: body))

// "On the slides" note.  `deck`/`where` say which slide, `says` what the slide
// says, `correct` what is correct and `why` the reason.  `kind` may be
// "slides" (default), "solution" (official exam solutions), "sheet" or "lab".
// Only recorded for Appendix A; nothing is printed in the text.
#let slidenote(deck: "", where: "", says: [], correct: [], why: [], kind: "slides") = {
  [#metadata((kind: kind, deck: deck, where: where, says: says, correct: correct, why: why))<slidenote>]
}

// Reference to an exercise by id: "Exercise 4.7".  The label sits on
// craken's exercise, numbered per chapter.
#let exref(id, word: true) = context {
  let q = query(label("ex-" + id))
  if q.len() == 0 { text(fill: red)[??#id] } else {
    let at = q.first().location()
    let n = str(counter(heading).at(at).first()) + "." + str(counter(figure.where(kind: "exercise")).at(at).first())
    link(at)[#if word [Exercise ]#n]
  }
}

// Reference to a Your turn by id: "Your turn 4.1".
#let ytref(id) = context {
  let q = query(label("yt-" + id))
  if q.len() == 0 { text(fill: red)[??#id] } else { link(q.first().location())[Your turn #q.first().value.n] }
}
