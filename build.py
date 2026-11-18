"""Build the book and the logbook with the Typst Python package.

    python3 build.py            # main.pdf + logbook.pdf
    python3 build.py dev.typ    # any other entry point
Equivalent CLI:  typst compile main.typ        (needs @local/craken:0.1.0 installed)
"""
import os
import sys
import typst

# the craken package ships its own fonts (Fraunces Soft, Newsreader, DM Mono, STIX Two Math)
CRAKEN_FONTS = os.path.expanduser("~/.local/share/typst/packages/local/craken/0.1.0/fonts")

targets = sys.argv[1:] or ["main.typ", "logbook.typ"]
for t in targets:
    out = t.replace(".typ", ".pdf")
    typst.compile(t, output=out, font_paths=[CRAKEN_FONTS], root=".")
    print("built", out)
