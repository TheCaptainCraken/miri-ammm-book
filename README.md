# From the model to the heuristic — sources

A study book for the AMMM final exam (MIRI, UPC), by Pietro Agnoli, written in
[Typst](https://typst.app). Course material by Prof. Enric Rodríguez-Carbonell and
Prof. Luis Velasco.

## Build

Requirements: Typst 0.15 (tested with 0.15.1) **or** the Python package `typst`
(`pip install typst`), and the Captain Craken template installed as
`@local/craken:0.1.0` (run its `install.sh` once: it installs the package and
its fonts).

```sh
# with the Typst command-line tool
typst compile main.typ                                    # A4 edition, read on screen
typst compile --input edition=print main.typ print.pdf    # 189 × 246 mm, two-sided
typst compile --input theme=lantern main.typ dark.pdf     # dark Lantern theme
typst compile logbook.typ

# or with Python
python3 build.py                # builds main.pdf and logbook.pdf
python3 build.py main.typ       # only the book
```

The book is a PDF book only: the chapters are not wrapped in craken's
`#chapter(...)`, so the website edition is not set up.

The figures are SVG files generated from Python; rebuild them after changing
`figures/make_figures.py`:

```sh
pip install matplotlib
python3 figures/make_figures.py   # writes figures/*.svg (craken ink and paper, Newsreader Text)
```

## Verify the numbers

Every number printed in the book is asserted by a script in `verify/`
(exact rational simplex, CPLEX through docplex, brute force on random
instances). Run them all with

```sh
pip install cplex docplex        # CPLEX Community Edition is enough
cd verify && python3 run_all.py  # prints ok/FAIL per script
```

| script | checks |
| --- | --- |
| `simplex_tools.py` | helpers: tableau, reduced costs, ratio test, exact LP solver |
| `v01_lp_models.py` | Chapter 1 and the LP sheet (all nine exercises, every reading) |
| `v02_labs.py` | Labs 1–3 (P1, P2, P2d, P2e, P3, P3a), model sizes |
| `v03_bases.py`, `v04_simplex*.py` | bases, simplex runs, phase I, the five exam Q1s and the new ones |
| `v05_ilp_sheet.py`, `v05_exam_models.py` | ILP sheet (12 exercises) and the five exam models vs brute force |
| `v08_bb.py`, `v09_nlp.py` | branch & bound trees, Gomory cuts, separable programming, SOS2 |
| `v11_heuristics_slides.py` | the slides' greedy, GRASP, local search, path relinking, TSP and decoder traces |
| `v16_exam_heuristics.py`, `v16_mock_case.py` | greedy algorithms of the exams, case study, mock exam |
| `v_new_numbers.py` | numbers of the new exercises |
| `gen_simplex_questions.py` | (not a check) the seeded search that produced the new simplex questions |

## Layout of the sources

```plain
main.typ              puts the book together (only #include lines)
template.typ          the book's helpers, drawn with craken's tokens (imports @local/craken)
logbook.typ           your logbook: session / exercise / mistake (all mistakes listed on page 1)
logbook-template.typ  the look of the logbook, in craken style (imported by logbook.typ)
assets/               the Captain Craken logo used on the cover
chapters/             00-cover, 00-preface, part1..3, 01..16, appendix
answers/              answers.typ + ans01..ans16 (one file per chapter)
figures/              make_figures.py and the generated SVGs
fonts/                IBM Plex (the old design; no longer used)
verify/               verification scripts (see above)
build.py              build script for the Python typst package
```

## Adding an exercise

Exercises are numbered automatically per chapter; you refer to them by a stable
id, never by number.

1. In the chapter file, under the right tier (`#tier("warm")`, `"practice"`,
   `"exam"`, `"tool"`, `"review"`):

   ```typst
   #exercise("ch6-p9", source: "Final Jan 2027 · Q2", time: 20, tier: "exam")[
     Statement of the exercise…
   ]
   ```

   `source` is optional; a source starting with `Final`, `LP sheet`, `ILP sheet`
   or `Lab` makes the exercise appear in Appendix B automatically. `time` is in
   minutes and feeds the chapter total.

2. In `answers/ansNN.typ` (same chapter), add the answer with the same id:

   ```typst
   #answer("ch6-p9")[Step-by-step solution…]
   ```

   The answer gets the exercise's number and a link back automatically.

3. Refer to it anywhere with `#exref("ch6-p9")` ("Exercise 6.9") or
   `#exref("ch6-p9", word: false)` ("6.9").

4. If the answer contains numbers, add an assertion to a script in `verify/`
   and run `python3 run_all.py`.

The same pattern works for "Your turn" boxes (`#yourturn(id)[…]`, referenced
with `#ytref(id)`), "Stop and answer" boxes (`#stopbox(id)[…]`) and pretests
(`#pretest(id)[…]` plus `#revisit(id)[…]` where it is answered); all their
answers use `#answer(id)`. An error in a slide is recorded with
`#slidenote(deck:, where:, says:, correct:, why:)`; it is not printed in the
text, and Appendix A collects them.

After a build, search the PDF for `??`: a red `??id` marks a reference to an id
that does not exist.

## Style rules kept by the template

The Captain Craken design: A4 with a margin column on the right (print: crown
quarto, margin column on the outer side), Fraunces Soft for titles and labels,
Newsreader Text for reading, DM Mono for code, STIX Two Math. Short notes
(`#side`) sit in the margin column; Your turn, Stop and answer, Pretest, Think
first and the chapter summary are craken callouts; tables with six or more
columns, `wide: true` figures and the appendix tables reach into the margin.
