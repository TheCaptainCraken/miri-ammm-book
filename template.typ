// =============================================================================
//  template.typ — the study book in the Captain Craken template
//  (@local/craken:0.2.0).  Craken does all the styling: title page, contents,
//  parts, chapters, headings, callouts, margin notes, code, tables, figures,
//  exercises and solutions.  This file adds no styling of its own: it only
//  gives names to the book's recurring pieces, each one made of craken's.
//
//    pretest(id)[..]     amber callout before the chapter; revisit(id)[..] answers it
//    yourturn(id)[..]    moss callout with blanks to fill (blank()), answer attached
//    stopbox(id)[..]     rust callout of questions (a), (b)…, answer attached
//    example(title)[..]  "Worked example 4.1", a subsection
//    definition(term)[..]  a paragraph that opens with the term (craken's dfn)
//    symbols(..)         "Symbols in this chapter", a term list
//    exercise(id, ..)[..]  craken's exercise, its solution attached
//    chapter-time(), exref(id), slidenote(..)
//
//  Everything else in the chapters is craken's own (tip, try-this, question,
//  note, dfn, code, figure, table…) or plain Typst.
//
//  Answers live in answers/ansNN.typ as #answer(id)[..].  They are read here
//  by id and handed to craken: an exercise's answer becomes its solution; a
//  Your turn's or a Stop box's becomes the answer of its callout.  Craken puts
//  each one where the edition wants it: in the "Solutions" at the end of the
//  chapter (A4), upside-down under its question (print), or behind a toggle
//  (web).
//
//  Exercises are identified by a stable string id (e.g. "jun24-q1").  Numbers
//  ("4.7") come from the exercise's place in the book, so exercises can be
//  reordered freely: answers, cross-references and the past-exam table in
//  Appendix B follow.
// =============================================================================

#import "@local/craken:0.2.0" as ck
#import "@local/craken:0.2.0": (
  palette, fonts, edition, theme, sbreak, dfn, lede, tip, try-this, question, note, code, listing, part,
)
#import "refs.typ": answer, slidenote, exref, ytref

// ================================================================ answers ===
// Every #answer in answers/, by id.  answers/answers.typ includes the files.
#let _metadata-in(c) = if c.func() == metadata { (c,) } else if c.has("children") {
  c.children.map(_metadata-in).flatten()
} else if c.has("child") { _metadata-in(c.child) } else { () }

#let _answers = {
  let found = (:)
  for m in _metadata-in(include "answers/answers.typ") {
    let v = m.value
    if type(v) != dictionary or "id" not in v or "body" not in v { continue }
    assert(v.id not in found, message: "answer \"" + v.id + "\" is given twice")
    found.insert(v.id, v.body)
  }
  found
}
#let _answer-of(id) = _answers.at(id, default: none)

// "4.2": the chapter's number, then the counter's
#let _num(c) = str(counter(heading).get().first()) + "." + str(c.get().first())

// ============================================================== callouts ===
// Pretest at the start of a chapter, revisited later in the text.
#let pretest(id, body) = tip(label: [Pretest], {
  emph(body)
  parbreak()
  context {
    let r = query(label("rev-" + id))
    [Try it before reading on: ]
    if r.len() == 0 [the chapter comes back to it.] else if target() == "paged" [
      the chapter comes back to it #link(r.first().location())[on page #r.first().location().page()].
    ] else [the chapter #link(r.first().location())[comes back to it].]
  }
})

#let revisit(id, body) = tip(label: [Pretest, revisited], [#metadata(id)#label("rev-" + id)#body])

// "Your turn": a worked example with blanks; its answer comes with it.
#let ytcounter = counter("yourturn")
#let yourturn(id, body) = {
  ytcounter.step()
  context {
    let n = _num(ytcounter)
    // craken's "try this" callout, which takes an answer like a question does
    ck._callout(body, "try", [Your turn #n#metadata((id: id, n: n))#label("yt-" + id)], palette.moss, answer: _answer-of(id))
  }
}

// a blank to fill in, in a Your turn
#let blank(w: 2.2em) = box(width: w, stroke: (bottom: 0.6pt + palette.ink-soft), outset: (bottom: 1.5pt), height: 0.9em)

// "Stop and answer": retrieval questions at the end of sections.
#let stopcounter = counter("stop")
#let stopbox(id, body) = {
  stopcounter.step()
  context {
    let n = _num(stopcounter)
    question(
      label: [Stop and answer #n#metadata((id: id, n: n))#label("st-" + id)],
      answer: _answer-of(id),
      { set enum(numbering: "(a)"); body },
    )
  }
}

// ================================================================== text ====
#let definition(term, body) = [#dfn(term). #body]

#let excounter = counter("worked")
#let example(title, body) = {
  excounter.step()
  heading(level: 3, numbering: none, outlined: false)[Worked example #context _num(excounter): #title]
  body
}

#let symbols(..pairs) = {
  heading(level: 3, numbering: none, outlined: false)[Symbols in this chapter]
  terms(..pairs.pos().map(p => terms.item(p.at(0), p.at(1))))
}

// ============================================================== exercises ===
// Craken rates exercises from one to three suckers; the book rates them by
// their time, unless `difficulty` says otherwise.
#let _difficulty(time) = if time <= 5 { 1 } else if time <= 12 { 2 } else { 3 }

// Craken's exercise, labelled <ex-ID> (as craken's own <ex:name> labels), with
// the book's record of it (<exercise-info>) and its source and time.
#let exercise(id, source: none, time: 10, tier: "practice", difficulty: auto, body) = {
  let solution = _answer-of(id)
  [#ck.exercise(
    difficulty: if difficulty == auto { _difficulty(time) } else { difficulty },
    // the anchor gives Appendix B the solution's page
    solution: if solution != none [#metadata(id)#label("ans-" + id)#solution],
    {
      [#metadata((id: id, source: source, time: time, tier: tier))<exercise-info>]
      emph[#if source != none [#source · ]about #time min]
      parbreak()
      body
    },
  )#label("ex-" + id)]
}

// Every exercise, in book order: its record plus its number ("4.7"), its
// chapter and the location of the exercise itself.
#let all-exercises() = query(<exercise-info>).map(m => {
  let ch = counter(heading).at(m.location()).first()
  let n = str(ch) + "." + str(ck.exercise-counter.at(m.location()).first())
  (..m.value, n: n, chapter: ch, location: query(label("ex-" + m.value.id)).first().location())
})

// The exercises whose source starts with `prefix` (e.g. "Final Jun 2024").
// Used by the appendix.
#let exercises-with(prefix) = all-exercises().filter(e => type(e.source) == str and e.source.starts-with(prefix))

// Total exercise time of the current chapter (shown at the start of the exercises).
#let chapter-time() = context {
  let ch = counter(heading).get().first()
  let all = all-exercises().filter(e => e.chapter == ch)
  let total = all.map(e => e.time).sum(default: 0)
  [#all.len() exercises, about #calc.round(total / 60, digits: 1) hours in total.]
}

// =========================================================== the document ===
// The book's own counters restart with every chapter (craken resets its own).
#let _reset-counters() = {
  excounter.update(0)
  ytcounter.update(0)
  stopcounter.update(0)
}

// One page of the website (slug.html); in the PDF just the body.  Every
// chapter ends with craken's solutions (PDF only, and only if it has any).
#let chapter(slug, body) = ck.chapter(slug, { body; ck.solutions() })

// The letter on the website's home page: craken's, told with the book's own
// callouts.  Only the site shows it.
#let _letter(description) = context if target() != "paged" {
  let rating(n) = html.elem("span", attrs: (class: "ck-exercise__difficulty"), range(3).map(i => ck._sucker-web(filled: i < n)).join())
  if description != none { html.elem("div", attrs: (class: "ck-letter__description"), description) }
  par[
    The book talks to you in a few ways. A #ck._mark("tip", [Pretest]) opens each chapter: a question to answer before you read, which the text comes back to later.
    #ck._mark("try", [Your turn]) follows a worked example, with blanks to fill in on paper.
    #ck._mark("question", [Stop and answer]) closes a section: answer from memory, then open the answer.
    Each chapter ends with exercises, from warm-ups to past exam questions, rated from #rating(1) to #rating(3), and every solution hides under its exercise.
  ]
  par[Answer everything in a logbook, and write down every mistake: the preface explains how.]
}

// Code languages craken doesn't know: OPL, CPLEX's LP format, pseudocode.
#let _syntaxes = ("syntax/opl.sublime-syntax", "syntax/lp.sublime-syntax", "syntax/pseudo.sublime-syntax")

// The book: craken's own book(), with the same settings.  The site's letter
// is the book's own unless `note` says otherwise.
#let book(body, ..settings) = {
  let settings = settings.named()
  if "note" not in settings { settings.insert("note", _letter(settings.at("description", default: none))) }
  set raw(syntaxes: _syntaxes)
  show: ck.book.with(..settings)
  show heading.where(level: 1): it => { _reset-counters(); it }
  body
}
