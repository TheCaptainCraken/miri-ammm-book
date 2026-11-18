# From the model to the heuristic

A free study book for **Algorithmic Methods for Mathematical Models** (AMMM, MIRI – UPC):
LP/ILP modelling, the simplex, branch & bound, NLP and metaheuristics, with exercises,
past exams and worked answers. Written in [Typst](https://typst.app).

📖 **Read it:** https://thecaptaincraken.github.io/miri-ammm-book/

## Build

```sh
F="--package-path vendor --font-path vendor/local/craken/0.1.0/fonts"
typst compile $F main.typ                                  # A4
typst compile $F --input theme=lantern main.typ dark.pdf   # dark
typst compile $F --input edition=print main.typ print.pdf  # print
typst compile $F --features bundle,html --format bundle main.typ _site   # website
```

Every number in the book is checked by the scripts in `verify/` (`cd verify && python3 run_all.py`).
Each push to `main` rebuilds the PDFs and publishes them to GitHub Pages.

## Layout

`main.typ` (entry) · `template.typ` (helpers) · `chapters/` · `answers/` · `figures/` · `verify/` ·
`vendor/` ([Captain Craken template](https://github.com/TheCaptainCraken/craken-book-template), MIT; fonts under OFL)

## License

[Apache 2.0](LICENSE) © Pietro Agnoli. Course material by Prof. Enric Rodríguez-Carbonell and Prof. Luis Velasco.
