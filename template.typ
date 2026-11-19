// =============================================================================
//  template.typ — the book's helpers, built on the Captain Craken template
//  (@local/craken:0.2.0).  Craken gives the page, the type, the colours, the
//  headings, code, tables, figures and callouts; this file only adds the
//  study-book pieces craken does not have, drawn with craken's own tokens.
//
//  Chapters never set fonts, sizes or spacing themselves.  They only call the
//  small named functions defined below:
//
//    side[..]            margin note (no number)    think[..]        "Think first" prompt
//    slidenote(..)       "On the slides" note (not printed; listed in Appendix A)
//    definition(term)[..]  example(title)[..]         yourturn(id)[..]   blank()
//    stopbox(id)[..]     pretest(id)[..]            revisit(id)[..]
//    exercise(id, ..)[..]  tier(name)               answer(id)[..]     exref(id)
//    btable(..)          fig(..)                    summary[..]        symbols(..)
//    part(intro: ..)[..]   (craken's own, used in main.typ)
//
//  Craken's own helpers (tip, try-this, question, note, dfn, lede, sbreak,
//  code, listing) are re-exported and can be used too.  Craken's numbered
//  `exercise` is replaced by the book's id-based one below.
//
//  Exercises are identified by a stable string id (e.g. "jun24-q1").  Numbers
//  ("4.7") are generated from the position of the exercise in the book, so you
//  can reorder exercises freely: answers, cross-references and the past-exam
//  table in Appendix B follow automatically.
// =============================================================================

#import "@local/craken:0.2.0" as ck
#import "@local/craken:0.2.0": (
  palette, palettes, theme, fonts, type-size, line-height, spacing, radii, page-grid, edition,
  label-text, sucker, sbreak, dfn, lede, tip, try-this, question, note, code, listing,
)

#let _print = edition == "print"
// HTML element for the website edition (target() is "html" or "bundle" there)
#let _el(tag, class: none, body) = html.elem(tag, attrs: if class != none { (class: class) } else { (:) }, body)
#let _lead(size, height) = height - size

// ------------------------------------------------- names used by the chapters
#let serif = fonts.text
#let sans = fonts.label
#let mono = fonts.mono
#let mathfont = fonts.math
#let grey = palette.ink-soft     // secondary text
#let light = palette.rule        // hairlines
#let body-size = type-size.body
#let text-w = page-grid.measure
// how far a wide block may reach into the margin column
#let wide-extra = page-grid.gutter + page-grid.margin-column

// a small label, as craken sets every element name
#let lab(s, fill: palette.rust) = label-text(fill: fill, s)

// a block in craken's callout shape: paper-warm, rounded, coloured label
#let _panel(color, head, body, breakable: true) = context if target() != "paged" {
  let kind = if color == palette.amber { "tip" } else if color == palette.moss { "try" } else { "question" }
  _el("aside", class: "ck-callout ck-callout--" + kind, {
    _el("p", class: "ck-callout__label label", [#head])
    body
  })
} else { block(
  width: 100%, above: spacing.s8, below: spacing.s8, inset: spacing.s6,
  fill: palette.paper-warm, radius: radii.m, breakable: breakable,
  {
    // the label never stays behind at the foot of a page
    block(below: spacing.s2, sticky: true, label-text(fill: color)[#sucker(color: color) #h(spacing.s2) #head])
    body
  },
) }

// small grey text after a label ("answer on p. 12")
#let _aside(body) = context if target() != "paged" { _el("span", class: "bk-aside", body) } else {
  text(font: fonts.text, weight: 400, size: type-size.caption, fill: palette.ink-soft, body)
}

// a word space on the web, a wider gap in the PDF
#let _gap = context if target() == "paged" { h(spacing.s4) } else [ ]

// a coloured label; on the web a <span> that web/book.css styles
#let _tone(fill) = if fill == palette.moss { "moss" } else if fill == palette.amber { "amber" } else if fill == palette.ink-soft { "soft" } else { "rust" }
#let _label(fill: palette.rust, body) = context if target() != "paged" {
  _el("span", class: "label bk-label bk-label--" + _tone(fill), body)
} else { label-text(fill: fill, body) }

// page of the first element with a label, or "?"
#let _page-of(lbl) = {
  let a = query(lbl)
  if target() != "paged" { return if a.len() > 0 { link(a.first().location())[↗] } else { "?" } }
  if a.len() > 0 [on p. #link(a.first().location(), str(a.first().location().page()))] else { "?" }
}

// Wide content: reaches into the margin column (outer side in print).
#let _wide-block(body) = context if target() != "paged" { body } else {
  let recto = not _print or calc.odd(here().page())
  let p = if recto { (right: -wide-extra) } else { (left: -wide-extra) }
  pad(..p, block(width: 100%, body))
}
#let wide = _wide-block


// ================================================================== notes ===
// A short note in the margin column, beside the line that calls it.  It has
// no number (unlike craken's #note) and shares craken's stacking, so notes of
// both kinds never overlap.  (`dy` shifts it down by hand when needed.)
#let side(body, dy: 0pt) = context if target() != "paged" {
  _el("span", class: "ck-note margin-note", body)
} else {
  let pos = here().position()
  let recto = not _print or calc.odd(pos.page)
  let x = if recto { page-grid.inside + page-grid.measure + page-grid.gutter } else { page-grid.edge }
  let content = block(width: page-grid.margin-column, inset: (left: spacing.s2), stroke: (left: 0.6pt + palette.coral), {
    set text(size: type-size.note, fill: palette.ink-soft, hyphenate: false)
    set par(leading: _lead(type-size.note, line-height.note), justify: false, spacing: spacing.s2)
    body
  })
  let height = measure(content).height
  let y0 = pos.y - 0.8 * type-size.note + dy
  let prev = ck.note-state.get()
  if prev.page == pos.page and y0 < prev.y + spacing.s2 { y0 = prev.y + spacing.s2 }
  // never below the text area: a note near the foot of the page moves up
  let floor = page-grid.height - page-grid.bottom - height
  if y0 > floor { y0 = floor }
  ck.note-state.update((page: pos.page, y: y0 + height))
  box(width: 0pt, place(top + left, dx: x - pos.x, dy: y0 - pos.y, content))
}

// "Think first": stop and explain before reading on.
#let think(body) = _panel(palette.rust, [Think first], body, breakable: false)

// "On the slides" note.  `deck`/`where` say which slide, `says` what the slide
// says, `correct` what is correct and `why` the reason.  `kind` may be
// "slides" (default), "solution" (official exam solutions), "sheet" or "lab".
#let slidenote(deck: "", where: "", says: [], correct: [], why: [], kind: "slides") = {
  // only recorded for Appendix A; nothing is printed in the text
  [#metadata((kind: kind, deck: deck, where: where, says: says, correct: correct, why: why))<slidenote>]
}

// ================================================================ blocks ====
#let label-line(name, extra: none, fill: palette.rust) = context if target() != "paged" {
  _el("p", class: "bk-labelline", { _label(fill: fill, name); if extra != none { [ ]; _aside(extra) } })
} else { block(above: spacing.s8, below: spacing.s4, sticky: true, {
  label-text(fill: fill, name)
  if extra != none { h(spacing.s4); _aside(extra) }
}) }

#let definition(term, body) = context if target() != "paged" {
  _el("div", class: "bk-definition", [#_label(fill: palette.moss)[Definition] #dfn(term). #body])
} else { block(
  above: spacing.s8, below: spacing.s8, inset: (left: spacing.s6), stroke: (left: 1.2pt + palette.moss),
  [#label-text(fill: palette.moss)[Definition] #h(spacing.s2) #dfn(term). #body],
) }

#let excounter = counter("worked")
#let example(title, body) = {
  excounter.step()
  context if target() != "paged" {
    let n = str(counter(heading).get().first()) + "." + str(excounter.get().first())
    _el("div", class: "bk-example", {
      _el("p", class: "bk-labelline", [#_label[Worked example #n] #_el("em", class: "bk-example__title", title)])
      body
    })
  } else { block(above: spacing.s12, below: spacing.s8, breakable: true, {
    context label-line(
      "Worked example " + str(counter(heading).get().first()) + "." + str(excounter.get().first()),
      extra: text(style: "italic", size: type-size.body, fill: palette.ink, title),
    )
    body
    h(1fr)
    sucker(color: palette.ink-soft, filled: false, d: 6pt, stroke: 0.75pt)
  }) }
}

// faded examples: blanks to fill in
#let blank(w: 2.2em) = box(width: w, stroke: (bottom: 0.6pt + palette.ink-soft), outset: (bottom: 1.5pt), height: 0.9em)

#let ytcounter = counter("yourturn")
#let yourturn(id, body) = {
  ytcounter.step()
  context {
    let n = str(counter(heading).get().first()) + "." + str(ytcounter.get().first())
    _panel(palette.moss, [Your turn #n#metadata((id: id, n: n))#label("yt-" + id) #_gap #_aside[answer #_page-of(label("ans-" + id))]], body, breakable: false)
  }
}

// "Stop and answer" retrieval boxes at the end of sections.
#let stopcounter = counter("stop")
#let stopbox(id, body) = {
  stopcounter.step()
  context {
    let n = str(counter(heading).get().first()) + "." + str(stopcounter.get().first())
    _panel(palette.rust, [Stop and answer #n#metadata((id: id, n: n))#label("st-" + id) #_gap #_aside[from memory; answers #_page-of(label("ans-" + id))]], {
      set enum(numbering: "(a)")
      body
    }, breakable: false)
  }
}

// Pretest at the start of a chapter, revisited later in the text.
#let pretest(id, body) = _panel(palette.amber, [Pretest #_gap #_aside[Try before reading, no cheating! Explained #context _page-of(label("rev-" + id)).]], emph(body), breakable: false)

#let revisit(id, body) = context if target() != "paged" {
  _el("div", class: "bk-revisit", [#_label(fill: palette.amber)[Pretest, revisited] #body #label("rev-" + id)])
} else { block(above: spacing.s8, below: spacing.s8, inset: (left: spacing.s6), stroke: (left: 1.2pt + palette.amber),
  [#label-text(fill: palette.amber)[Pretest, revisited] #h(spacing.s2) #body #label("rev-" + id)]) }

// ============================================================== exercises ===
// tier is one of: "warm", "practice", "exam", "tool", "review"
#let tier-names = (
  warm: "Warm-up",
  practice: "Practice",
  exam: "Exam level",
  tool: "CPLEX / OPL",
  review: "Spaced review",
)
#let tier(t, note: none) = context if target() != "paged" {
  _el("h3", class: "bk-tier", { tier-names.at(t); if note != none { [ ]; _aside(note) } })
} else { block(above: spacing.s12, below: spacing.s4, sticky: true, {
  text(font: fonts.label, weight: 600, size: type-size.subsection, tier-names.at(t))
  if note != none { h(spacing.s4); _aside(note) }
}) }

#let exnum = counter("exercise")
#let exercise(id, source: none, time: 10, tier: "practice", body) = {
  exnum.step()
  // the heading line: number, then source and time in grey
  let head = context {
    let ch = counter(heading).get().first()
    let n = str(ch) + "." + str(exnum.get().first())
    [#metadata((id: id, n: n, source: source, time: time, tier: tier, chapter: ch))#label("ex-" + id)]
    _label[Exercise #n]
    if target() == "paged" { h(spacing.s4) } else [ ]
    _aside[#if source != none [#source · ]≈#time min]
  }
  context if target() != "paged" {
    _el("section", class: "bk-exercise", {
      _el("p", class: "bk-exercise__head", head)
      _el("div", class: "bk-exercise__body", body)
    })
  } else {
    // separated by space alone; the heading line stays with the statement
    block(width: 100%, above: spacing.s8, below: spacing.s8, breakable: true, {
      block(below: spacing.s2, sticky: true, head)
      body
    })
  }
}

// Reference to an exercise by id: "Exercise 4.7".
#let exref(id, word: true) = context {
  let q = query(label("ex-" + id))
  if q.len() == 0 { text(fill: red)[??#id] } else {
    let m = q.first().value
    link(q.first().location())[#if word [Exercise ]#m.n]
  }
}
#let ytref(id) = context {
  let q = query(label("yt-" + id))
  if q.len() == 0 { text(fill: red)[??#id] } else { link(q.first().location())[Your turn #q.first().value.n] }
}

// All exercises whose source starts with `prefix` (e.g. "Final Jun 2024"),
// as metadata elements in book order.  Used by the appendix.
#let exercises-with(prefix) = query(metadata).filter(m => (
  type(m.value) == dictionary
    and "source" in m.value
    and type(m.value.source) == str
    and m.value.source.starts-with(prefix)
))

// "Exercises 4.7, 7.7, 16.2" for a source prefix, with links.
#let exercises-from(prefix) = context {
  let q = exercises-with(prefix)
  [Exercise#if q.len() > 1 [s] #q.map(m => link(m.location(), m.value.n)).join(", ")]
}

// Total exercise time of the current chapter (shown at the start of the exercises).
#let chapter-time() = context {
  let ch = counter(heading).get().first()
  let all = query(metadata).filter(m => (
    type(m.value) == dictionary and "time" in m.value and m.value.at("chapter", default: -1) == ch
  ))
  let total = all.map(m => m.value.time).sum(default: 0)
  [#all.len() exercises, about #calc.round(total / 60, digits: 1) hours in total]
}

// Answers at the back.  `id` may be an exercise, a "your turn" or a stop box.
#let answer(id, body) = {
  let head = context {
    let e = query(label("ex-" + id))
    let y = query(label("yt-" + id))
    let s = query(label("st-" + id))
    let head = if e.len() > 0 {
      let m = e.first().value
      [#link(e.first().location())[#m.n]#if m.source != none [#_gap#_aside(m.source)]]
    } else if y.len() > 0 { link(y.first().location())[Your turn #y.first().value.n] } else if s.len() > 0 {
      link(s.first().location())[Stop #s.first().value.n]
    } else { text(fill: red)[??#id] }
    [#metadata(id)#label("ans-" + id)]
    _label(fill: palette.moss, head)
    if target() == "paged" { h(spacing.s4) }
  }
  context if target() != "paged" {
    _el("div", class: "bk-answer", { _el("p", class: "bk-answer__head", head); body })
  } else {
    block(above: spacing.s6, below: spacing.s6, breakable: true, { head; body })
  }
}

// ================================================================= tables ===
// Book-style table in craken's hairlines (the rules come from craken).
#let btable(columns: auto, align: left, header: (), size: 0.88em, ..cells) = {
  set text(size: size)
  set par(justify: false)
  let t = table(
    columns: columns,
    align: align,
    table.header(..header),
    ..cells,
  )
  // tables with many columns borrow the margin column
  let n = if type(columns) == array { columns.len() } else if type(columns) == int { columns } else { header.len() }
  if n >= 6 { _wide-block(t) } else { t }
}

// ================================================================ figures ===
// `wide: true` reaches into the margin column; `margin: true` gives a small
// figure in the text.
#let fig(path, caption: none, width: auto, wide: false, margin: false) = {
  let w = if width != auto { width } else if margin { 60% } else { 100% }
  let f = figure(block(width: 100%, align(center, image(path, width: w))), caption: caption)
  if wide { _wide-block(f) } else { f }
}

// ============================================================== summaries ===
#let summary(body) = _panel(palette.amber, [The chapter in five lines], {
  set enum(numbering: "1")
  body
}, breakable: false)

// Chapter symbol list: pairs (symbol, meaning).
// On the web a definition list, laid out by web/book.css; no rules, only space.
#let symbols(..pairs) = context if target() != "paged" {
  _el("section", class: "bk-symbols", {
    _el("p", class: "label bk-symbols__title")[Symbols in this chapter]
    _el("dl", pairs.pos().map(p => _el("dt", p.at(0)) + _el("dd", p.at(1))).join())
  })
} else { block(above: spacing.s8, below: spacing.s12, width: 100%, {
  label-text[Symbols in this chapter]
  v(spacing.s2, weak: true)
  set text(size: type-size.caption)
  set par(leading: _lead(type-size.caption, line-height.caption), justify: false)
  grid(
    columns: (auto, 1fr), column-gutter: spacing.s8, row-gutter: spacing.s4,
    ..pairs.pos().map(p => (p.at(0), p.at(1))).flatten()
  )
}) }

// ================================================================== parts ===
// Parts are craken's own #part (put in main.typ, between chapters).
#let part = ck.part

// Table of contents with parts, chapters and page numbers.
#let contents() = context {
  let items = query(selector(heading.where(level: 1)).or(figure.where(kind: "craken-part")))
  for it in items {
    if it.func() == figure {
      block(above: spacing.s12, below: spacing.s4, sticky: true, link(it.location(),
        label-text(fill: palette.rust)[Part #numbering(it.numbering, ..it.counter.at(it.location())) #h(spacing.s4) #it.caption.body]))
    } else {
      let num = if it.numbering != none { str(counter(heading).at(it.location()).first()) } else { "" }
      block(above: spacing.s4, below: spacing.s4, link(it.location(), {
        show link: set text(fill: palette.ink)
        grid(
          columns: (2.4em, 1fr, auto), column-gutter: spacing.s4,
          text(font: fonts.display, weight: 500, fill: palette.coral, num),
          text(fill: palette.ink, it.body),
          label-text(str(it.location().page())),
        )
      }))
    }
  }
}

// The book's own counters restart with every chapter (craken resets its own).
#let _reset-counters() = {
  exnum.update(0)
  excounter.update(0)
  ytcounter.update(0)
  stopcounter.update(0)
}

// One page of the website (slug.html); in the PDF just the body.  Each page
// carries the book's stylesheet, web/book.css, inline.
#let chapter(slug, body) = ck.chapter(slug, {
  context if target() != "paged" { html.elem("style", read("web/book.css")) }
  body
})

// Unnumbered chapter-like section (preface, answers, appendices).
#let unnumbered(title) = heading(level: 1, numbering: none, title)

// =========================================================== the document ===
// Code languages craken does not know: OPL, CPLEX's LP format, pseudocode.
#let _syntaxes = ("syntax/opl.sublime-syntax", "syntax/lp.sublime-syntax", "syntax/pseudo.sublime-syntax")

#let book(title: "", subtitle: "", author: "", body, ..web) = context if target() != "paged" {
  // Website: craken's own site (home page, one page per chapter()).
  set raw(syntaxes: _syntaxes)
  show: ck.book.with(title: title, subtitle: subtitle, author: author, ..web)
  show heading.where(level: 1): it => { _reset-counters(); it }
  body
} else {
  set document(title: title, author: author)
  set raw(syntaxes: _syntaxes)
  // The book has its own cover and contents page, so craken's are switched off.
  show: ck.book.with(title: none, author: author, contents: false)

  // Running head as craken's, but not on the cover, the contents or part pages.
  set page(header: context {
    let p = here().page()
    // craken counts part pages as blank too
    if p <= 2 or ck._is-blank(p) { return }
    let chapters = query(heading.where(level: 1))
    if chapters.any(ch => ch.location().page() == p) { return }
    let before = chapters.filter(ch => ch.location().page() < p)
    if before.len() == 0 { return }
    let ch = before.last()
    let head = label-text({
      if ch.numbering != none { str(counter(heading).at(ch.location()).first()); h(0.6em) }
      ch.body
    })
    align(if not _print or calc.odd(p) { right } else { left }, head)
  })

  show heading.where(level: 1): it => { _reset-counters(); it }

  // Long inline code may break across lines; short code stays in craken's box.
  show raw.where(block: false): it => if it.text.len() <= 32 { it } else {
    text(font: fonts.mono, size: 0.86 * type-size.body, fill: palette.ink, hyphenate: false,
      highlight(fill: palette.paper-warm, extent: 1.5pt, top-edge: 0.8em, bottom-edge: -0.25em, it.text))
  }

  // Display equations wider than the column use the margin column, or are
  // scaled down when even that is not enough.
  show math.equation.where(block: true): it => layout(size => {
    let inline = box(math.equation(math.display(it.body), block: false))
    let w = measure(inline).width
    if w <= size.width { it } else if w <= size.width + wide-extra - spacing.s6 {
      // a little too wide: borrow the margin column
      _wide-block(it)
    } else {
      block(above: spacing.s6, below: spacing.s6, width: 100%,
        align(center, scale(size.width / w * 100%, reflow: true, inline)))
    }
  })

  // Code blocks with lines too long for the column borrow the margin column.
  show raw.where(block: true): it => if it.lines.any(l => l.text.len() > 56) { _wide-block(it) } else { it }

  set list(spacing: spacing.s4)
  set enum(spacing: spacing.s4)

  body
}
