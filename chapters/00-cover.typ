#import "../template.typ": *

// Cover, set like craken's title page: the logo, the title, the author,
// and the credits at the foot.
#page(header: none, footer: none, {
  set par(justify: false)
  set text(hyphenate: false)
  v(1fr)
  {
    let mark = box(width: if edition == "print" { 44mm } else { 54mm }, image("/assets/captain-craken.png"))
    if theme == "lantern" {
      mark = circle(radius: 28mm, fill: palettes.paper.paper, inset: 0pt, align(center + horizon, mark))
    }
    mark
  }
  v(spacing.s12)
  label-text(fill: palette.rust)[Algorithmic Methods for Mathematical Models]
  v(spacing.s4)
  text(font: fonts.display, weight: 600, size: if edition == "print" { 34pt } else { 40pt })[From the model\ to the heuristic]
  v(spacing.s4)
  text(size: type-size.lede, fill: palette.ink-soft, style: "italic")[A study book for the AMMM exam]
  v(spacing.s12)
  label-text(fill: palette.ink)[Pietro Agnoli]
  v(2fr)
  block({
    set text(size: type-size.caption, fill: palette.ink-soft)
    set par(leading: 14.5pt - type-size.caption, spacing: spacing.s4)
    [Course material by *Prof. Enric Rodríguez-Carbonell* (linear, integer and non-linear programming) and *Prof. Luis Velasco* (heuristics and metaheuristics), Algorithmic Methods for Mathematical Models, Master in Innovation and Research in Informatics, Facultat d'Informàtica de Barcelona, *Universitat Politècnica de Catalunya (UPC)*. Slides, lab statements, exercise sheets and past exams are theirs.

      Textbooks: H. P. Williams, _Model Building in Mathematical Programming_ (Wiley, 2013); D. G. Luenberger and Y. Ye, _Linear and Nonlinear Programming_ (Springer, 2021); F. Glover and G. A. Kochenberger (eds.), _Handbook of Metaheuristics_ (Kluwer, 2003).

      Edition of November 2026.
    ]
  })
})
