// logbook-template.typ — the look of the logbook, in the Captain Craken design
// (@local/craken).  You write in logbook.typ, not here.
//
// Exports:  logbook (the page setup + the mistakes list on page one, used as #show: logbook),
//           session, exercise, mistake (explained at the top of logbook.typ).

#import "@local/craken:0.1.0": palette, palettes, theme, fonts, type-size, line-height, spacing, radii, label-text, sucker

#let _lead(size, height) = height - size
#let now = state("now", (date: "", id: ""))   // current session date and exercise id

// One spacing scale (craken's), so every gap is a multiple of the same step.
// Closer things belong together: id→answer < answer→mistake < exercise→exercise < session.
#let sp = (xs: spacing.s2, s: spacing.s4, m: spacing.s8, l: spacing.s12 + spacing.s8)
#let tag = 4.2em   // width of the small labels, so every text column lines up

#let small(s, fill: palette.ink-soft) = label-text(fill: fill, s)

// ---- the three functions --------------------------------------------------

#let session(date) = {
  now.update(n => (..n, date: date))
  block(above: sp.l, below: sp.m, sticky: true, width: 100%,
    stroke: (bottom: 0.5pt + palette.rule), inset: (bottom: spacing.s4), {
    small(fill: palette.rust)[#sucker() #h(spacing.s2) Session]
    v(spacing.s2, weak: true)
    text(font: fonts.display, weight: 600, size: type-size.section, date)
  })
}

#let exercise(id, body) = {
  now.update(n => (..n, id: id))
  block(above: sp.m, below: sp.m, width: 100%, {
    block(below: spacing.s4, sticky: true,
      box(fill: palette.paper-warm, radius: radii.s, inset: (x: 3pt), outset: (y: 2.5pt),
        text(font: fonts.mono, size: type-size.code - 1pt, fill: palette.ink-soft, id)))
    body
  })
}

#let mistake(did, should) = context {
  let n = now.get()
  [#metadata((id: n.id, date: n.date, did: did, should: should))<mistake>]
  // craken's callout shape, in rust: what I did, then what I should have done
  block(above: sp.s, below: sp.xs, width: 100%, inset: spacing.s6, fill: palette.paper-warm, radius: radii.m, {
    set text(size: type-size.caption)
    set par(leading: _lead(type-size.caption, line-height.caption), spacing: spacing.s2, hanging-indent: tag, justify: false)
    [#box(width: tag, small(fill: palette.rust)[Did])#text(fill: palette.rust, did)]
    parbreak()
    [#box(width: tag, small(fill: palette.moss)[Should])#should]
  })
}

// ---- page one: every mistake, automatically --------------------------------

#let mistakes-page() = {
  small(fill: palette.rust)[Algorithmic Methods for Mathematical Models]
  v(spacing.s2, weak: true)
  block(below: spacing.s4, text(font: fonts.display, weight: 600, size: type-size.chapter-title)[AMMM logbook])
  block(below: spacing.s12, text(size: type-size.lede, fill: palette.ink-soft, style: "italic")[
    Every mistake so far. Start each session here: pick two or three and redo them from scratch.
  ])
  context {
    let all = query(<mistake>)
    if all.len() == 0 [_Nothing here yet. Get working!_]
    for m in all {
      block(above: 0pt, below: sp.m, breakable: false, width: 100%,
        inset: (top: spacing.s4), stroke: (top: 0.5pt + palette.rule), grid(
        columns: (32mm, 1fr),
        column-gutter: spacing.s6,
        stack(spacing: spacing.s4,
          link(m.location(), text(font: fonts.mono, size: type-size.code - 1pt, fill: palette.rust, m.value.id)),
          small(m.value.date)),
        {
          set par(leading: _lead(type-size.caption, line-height.caption), spacing: spacing.s2, justify: false)
          set text(size: type-size.caption)
          text(fill: palette.rust, m.value.did)
          parbreak()
          m.value.should
        },
      ))
    }
  }
  pagebreak()
}

// ---- the whole document ----------------------------------------------------

#let logbook(body) = {
  set document(title: "AMMM logbook")
  // A notebook: one centred column of about 70 characters on craken paper.
  set page(paper: "a4", fill: palette.paper, margin: (x: 30mm, top: 26mm, bottom: 30mm),
    footer: context align(right, label-text(counter(page).display())))
  set text(font: fonts.text, size: type-size.body, fill: palette.ink, lang: "en",
    top-edge: 0.8em, bottom-edge: -0.2em)
  set par(justify: false, leading: _lead(type-size.body, line-height.body), spacing: spacing.s4)
  show strong: set text(weight: 600)
  show link: set text(fill: palette.rust)
  set list(marker: text(fill: palette.ink-soft)[–], indent: 0pt, body-indent: spacing.s4, spacing: spacing.s4)
  set enum(indent: 0pt, body-indent: spacing.s4, spacing: spacing.s4)
  show math.equation: set text(font: fonts.math, size: 1.06em)
  show math.equation.where(block: true): set block(above: spacing.s6, below: spacing.s6)
  show raw: set text(font: fonts.mono, size: type-size.code, hyphenate: false)
  show raw.where(block: false): it => box(fill: palette.paper-warm, radius: radii.s, inset: (x: 1.5pt), outset: (y: 2pt), it)

  mistakes-page()
  body
}
