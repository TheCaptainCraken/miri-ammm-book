"""Generates every figure of the book as SVG, in the Captain Craken palette (ink and paper).

Run from the book root:   python3 figures/make_figures.py
The numbers drawn here are the verified ones (see verify/)."""
import math
import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.patches import Polygon, Rectangle, FancyArrowPatch, Circle

HERE = os.path.dirname(os.path.abspath(__file__))
# Newsreader Text, the craken text face, from the installed craken package
CRAKEN_FONTS = os.path.expanduser("~/.local/share/typst/packages/local/craken/0.2.0/fonts")
for f in os.listdir(CRAKEN_FONTS):
    if f.startswith("NewsreaderText"):
        font_manager.fontManager.addfont(os.path.join(CRAKEN_FONTS, f))
K, G1, G2, G3 = "#2e221b", "#6c5849", "#cbbcaa", "#ece0cf"   # craken ink, ink-soft, a warm grey, warm paper
PAPER = "#fbf7f0"                                   # craken paper (figure background)
plt.rcParams.update({
    "font.family": ["Newsreader Text", "DejaVu Serif"], "mathtext.fontset": "stix", "font.size": 8, "axes.linewidth": 0.6,
    "xtick.major.width": 0.5, "ytick.major.width": 0.5, "svg.fonttype": "path",
    "axes.spines.top": False, "text.color": K, "axes.edgecolor": K, "axes.labelcolor": K,
    "xtick.color": K, "ytick.color": K, "figure.facecolor": PAPER, "axes.facecolor": PAPER, "savefig.facecolor": PAPER, "axes.spines.right": False, "lines.linewidth": 1.0,
})
W = 4.3                                             # inches = text column width


def save(fig, name):
    fig.savefig(os.path.join(HERE, name + ".svg"), bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)


def polygon_axes(ax, lim=(-0.3, 3.4)):
    ax.set_xlim(*lim); ax.set_ylim(*lim); ax.set_aspect("equal")
    ax.set_xlabel("$x$"); ax.set_ylabel("$y$", rotation=0)


# ---------------------------------------------------------------- LP region
def lp_region():
    fig, axs = plt.subplots(1, 2, figsize=(W * 1.35, 2.35))
    verts = [(0, 0), (2, 0), (2, 1), (1, 2), (0, 2)]
    for ax in axs:
        ax.add_patch(Polygon(verts, closed=True, fc=G3, ec=K, lw=0.8))
        polygon_axes(ax)
        xs = [-0.3, 3.4]
        ax.plot(xs, [3 - x for x in xs], color=G1, lw=0.6, ls=(0, (4, 2)))
        ax.text(2.55, 0.25, "$x+y\\leq 3$", color=G1)
        ax.text(0.05, 2.12, "$y \\leq 2$", color=G1); ax.text(2.05, 1.35, "$x\\leq 2$", color=G1)
    ax = axs[0]
    for c in [0.5, 2.5, 5]:
        ax.plot(xs, [(c - x) / 2 for x in xs], color=K, lw=0.5, ls=":")
    ax.annotate("", xy=(0.45, 0.9), xytext=(0.0, 0.0), arrowprops=dict(arrowstyle="->", lw=0.8))
    ax.text(0.5, 0.75, "grows", fontsize=7)
    ax.plot(1, 2, "o", color=K, ms=4); ax.text(1.08, 2.12, "optimum (1, 2)\n$x+2y = 5$", fontsize=7)
    ax.set_title("max $x+2y$: level lines slide outward", fontsize=8)
    ax = axs[1]
    labels = {(0, 2): "$B_1$: (y, $s_1$, $s_2$)", (1, 2): "$B_2$: (x, y, $s_2$)", (2, 1): "$B_3$: (x, y, $s_3$)",
              (2, 0): "$B_4$: (x, $s_1$, $s_3$)", (0, 0): "$B_5$: ($s_1$, $s_2$, $s_3$)"}
    off = {(0, 2): (-0.25, 0.35), (1, 2): (0.1, 0.25), (2, 1): (0.12, 0.1), (2, 0): (0.1, -0.28), (0, 0): (0.08, -0.3)}
    for v, t in labels.items():
        ax.plot(*v, "o", color=K, ms=3.5)
        ax.text(v[0] + off[v][0], v[1] + off[v][1], t, fontsize=6.5)
    ax.set_title("each vertex is a basic feasible solution", fontsize=8)
    save(fig, "lp-region")


def simplex_path():
    fig, ax = plt.subplots(figsize=(W * 0.62, 2.4))
    verts = [(0, 0), (2, 0), (2, 1), (1, 2), (0, 2)]
    ax.add_patch(Polygon(verts, closed=True, fc=G3, ec=K, lw=0.8))
    polygon_axes(ax, (-0.3, 2.8))
    pts = [(0, 0), (0, 2), (1, 2)]
    for a, b in zip(pts, pts[1:]):
        ax.add_patch(FancyArrowPatch(a, b, arrowstyle="-|>", mutation_scale=9, lw=1.4, color=K))
    for p, t in zip(pts, ["start: cost 0", "y enters: cost −4", "x enters: cost −5 (optimal)"]):
        ax.plot(*p, "o", color=K, ms=3.5)
    ax.text(0.08, -0.25, "start, cost 0", fontsize=6.5)
    ax.text(-0.25, 2.2, "y enters, cost −4", fontsize=6.5)
    ax.text(1.1, 2.2, "x enters, cost −5", fontsize=6.5)
    ax.set_title("min $-x-2y$: the simplex walks along edges", fontsize=8)
    save(fig, "simplex-path")


def phase1():
    fig, ax = plt.subplots(figsize=(W * 0.62, 2.4))
    verts = [(1, 0), (2, 0), (2, 1), (1, 2), (0, 2), (0, 1)]
    ax.add_patch(Polygon(verts, closed=True, fc=G3, ec=K, lw=0.8))
    ax.add_patch(Polygon([(0, 0), (1, 0), (0, 1)], closed=True, fc=PAPER, ec=G1, lw=0.6, hatch="////"))
    polygon_axes(ax, (-0.3, 2.8))
    ax.plot(0, 0, "o", color=K, ms=3.5); ax.text(0.05, -0.27, "(0,0): not feasible", fontsize=6.5)
    ax.plot(1, 0, "o", color=K, ms=3.5); ax.text(1.05, 0.08, "(1,0): first feasible basis", fontsize=6.5)
    ax.text(0.02, 0.62, "$x+y<1$", fontsize=6.5, color=G1)
    ax.set_title("phase I finds a feasible vertex", fontsize=8)
    save(fig, "phase1")


# ------------------------------------------------------------ branch & bound
def bb_region():
    fig, ax = plt.subplots(figsize=(W * 0.75, 2.8))
    xs = [0, 5.2]
    # feasible LP region: y >= x + 1/2 ; y <= (13 + 8x)/10 ; x,y >= 0
    pts = [(0, 0.5), (0, 1.3), (4, 4.5)]
    ax.add_patch(Polygon(pts, closed=True, fc=G3, ec=K, lw=0.8))
    for x in range(0, 6):
        for y in range(0, 6):
            feas = -2 * x + 2 * y >= 1 and -8 * x + 10 * y <= 13
            ax.plot(x, y, "o", ms=3 if feas else 1.5, color=K if feas else G2)
    ax.plot(xs, [4, 4], color=K, lw=0.7, ls="--"); ax.text(4.2, 3.75, "$y\\leq 4$ (cut)", fontsize=6.5)
    ax.plot(xs, [(12 + 8 * x) / 10 for x in xs], color=G1, lw=0.7, ls=":")
    ax.text(2.6, 2.2, "$-8x+10y\\leq 12$\n(Gomory cut)", fontsize=6.5, color=G1)
    ax.plot(4, 4.5, "s", color=K, ms=4); ax.text(3.3, 4.7, "LP optimum (4, 4.5)", fontsize=6.5)
    ax.plot(1, 2, "D", color=K, ms=4); ax.text(1.2, 1.55, "integer optimum (1, 2)", fontsize=6.5)
    ax.set_xlim(-0.3, 5.3); ax.set_ylim(-0.3, 5.3); ax.set_aspect("equal")
    ax.set_xlabel("$x$"); ax.set_ylabel("$y$", rotation=0)
    ax.set_title("max $x+y$, $-2x+2y\\geq 1$, $-8x+10y\\leq 13$", fontsize=8)
    save(fig, "bb-region")


def bb_tree():
    fig, ax = plt.subplots(figsize=(W * 1.05, 3.3))
    ax.axis("off")
    nodes = [  # (x, y, label, dead)
        (3, 6, "8.5\n(4, 4.5)", False), (4.4, 5, "infeasible", True), (2.2, 5, "7.5\n(3.5, 4)", False),
        (0.9, 4, "infeasible", True), (3.0, 4, "6.7\n(3, 3.7)", False), (4.3, 3, "infeasible", True),
        (2.3, 3, "5.5\n(2.5, 3)", False), (1.0, 2, "infeasible", True), (3.0, 2, "4.9\n(2, 2.9)", False),
        (4.3, 1, "infeasible", True), (2.3, 1, "3.5\n(1.5, 2)", False), (1.0, 0, "infeasible", True),
        (3.0, 0, "3 = (1, 2)\ninteger: optimum", False)]
    edges = [(0, 1, "y ≥ 5"), (0, 2, "y ≤ 4"), (2, 3, "x ≥ 4"), (2, 4, "x ≤ 3"), (4, 5, "y ≥ 4"), (4, 6, "y ≤ 3"),
             (6, 7, "x ≥ 3"), (6, 8, "x ≤ 2"), (8, 9, "y ≥ 3"), (8, 10, "y ≤ 2"), (10, 11, "x ≥ 2"), (10, 12, "x ≤ 1")]
    for a, b, t in edges:
        (x1, y1, *_), (x2, y2, *_) = nodes[a], nodes[b]
        ax.plot([x1, x2], [y1 - 0.25, y2 + 0.25], color=K, lw=0.6)
        ax.text((x1 + x2) / 2 + (0.08 if x2 > x1 else -0.55), (y1 + y2) / 2, t, fontsize=6.5)
    for x, y, t, dead in nodes:
        ax.text(x, y, t, ha="center", va="center", fontsize=6.5,
                bbox=dict(boxstyle="round,pad=0.25", fc=G2 if dead else "white", ec=K, lw=0.5))
    ax.set_xlim(0.3, 5); ax.set_ylim(-0.5, 6.5)
    save(fig, "bb-tree")


# --------------------------------------------------------------- NLP pictures
def convexity():
    fig, axs = plt.subplots(1, 3, figsize=(W * 1.35, 1.7))
    xs = [i / 100 for i in range(-150, 151)]
    ax = axs[0]
    ax.plot(xs, [x * x for x in xs], color=K)
    ax.fill_between(xs, [x * x for x in xs], 2.4, color=G3)
    ax.plot([-1, 1.2], [1, 1.44], color=K, lw=0.6, ls="--")
    ax.set_title("convex function", fontsize=7.5); ax.set_ylim(-0.2, 2.4)
    ax = axs[1]
    f = lambda x: x ** 4 - 1.6 * x ** 2 + 0.35 * x + 1
    ax.plot(xs, [f(x) for x in xs], color=K)
    ax.plot([-0.95, 0.85], [f(-0.95), f(0.85)], color=K, lw=0.6, ls="--")
    ax.plot(-0.94, f(-0.94), "o", color=K, ms=3); ax.text(-1.4, -0.05, "global", fontsize=6.5)
    ax.plot(0.84, f(0.84), "o", color=G1, ms=3); ax.text(0.55, 0.0, "local", fontsize=6.5)
    ax.set_title("non-convex function", fontsize=7.5); ax.set_ylim(-0.3, 2.4)
    ax = axs[2]
    ax.add_patch(Circle((0, 0), 1.6, fc=G3, ec=K, lw=0.7)); ax.add_patch(Circle((0, 0), 0.8, fc=PAPER, ec=K, lw=0.7))
    ax.plot([-1.2, 1.2], [0.2, 0.2], color=K, lw=0.6, ls="--")
    ax.set_aspect("equal"); ax.set_xlim(-1.8, 1.8); ax.set_ylim(-1.8, 1.8)
    ax.set_title("non-convex region", fontsize=7.5)
    for a in axs:
        a.set_xticks([]); a.set_yticks([])
    save(fig, "convexity")


def piecewise():
    fig, axs = plt.subplots(1, 2, figsize=(W * 1.3, 1.95))
    xs = [i / 100 for i in range(0, 201)]
    ax = axs[0]
    ax.plot(xs, [x * x for x in xs], color=G1, lw=1.6, label="$x^2$")
    ax.plot([0, 1, 2], [0, 1, 4], color=K, lw=0.9, marker="o", ms=3, label="approximation")
    ax.set_title("convex: the LP stays on the segments", fontsize=7.5); ax.legend(frameon=False, fontsize=6.5)
    ax = axs[1]
    ax.plot(xs, [x ** 3 for x in xs], color=G1, lw=1.6, label="$x^3$")
    ax.plot([0, 1, 1.5, 2], [0, 1, 3.375, 8], color=K, lw=0.9, marker="o", ms=3, label="approximation")
    ax.plot([0, 2], [0, 8], color=K, lw=0.6, ls="--", label="non-adjacent mix of $\\lambda_1,\\lambda_4$")
    ax.plot(1.5, 6, "x", color=K, ms=5); ax.text(1.55, 5.2, "(1.5, 6)", fontsize=6.5)
    ax.set_title("non-convex: without SOS2 it leaves the curve", fontsize=7.5)
    ax.legend(frameon=False, fontsize=6, loc="upper left", bbox_to_anchor=(0.0, 1.02))
    save(fig, "piecewise")


# ------------------------------------------------------------ heuristics
def landscape():
    fig, ax = plt.subplots(figsize=(W, 1.7))
    xs = [i / 200 for i in range(0, 2001)]
    f = lambda x: 2 + 0.9 * math.sin(1.3 * x) + 0.5 * math.sin(3.7 * x + 1) + 0.04 * (x - 6) ** 2
    ax.plot(xs, [f(x) for x in xs], color=K)
    loc = min(((f(x), x) for x in xs if 0.2 < x < 2.6))
    glob = min((f(x), x) for x in xs)
    ax.plot(loc[1], loc[0], "o", color=G1, ms=4); ax.text(loc[1] - 0.3, loc[0] - 0.45, "local minimum ω′", fontsize=6.5)
    ax.plot(glob[1], glob[0], "o", color=K, ms=4); ax.text(glob[1] - 0.4, glob[0] - 0.45, "global minimum ω*", fontsize=6.5)
    ax.annotate("", xy=(loc[1] + 0.05, loc[0] + 0.12), xytext=(0.15, f(0.15)), arrowprops=dict(arrowstyle="->", lw=0.6, color=G1))
    ax.text(0.0, f(0.0) + 0.25, "descent from here", fontsize=6.5, color=G1)
    ax.set_xticks([]); ax.set_yticks([]); ax.set_xlabel("solutions $\\omega \\in \\Omega$"); ax.set_ylabel("f(ω)")
    ax.set_ylim(min(f(x) for x in xs) - 0.7, max(f(x) for x in xs) + 0.5)
    save(fig, "landscape")


TSP_D = {(1, 2): 10, (1, 3): 12, (1, 4): 7, (1, 5): 9, (2, 3): 11, (2, 4): 17, (2, 5): 4, (3, 4): 5, (3, 5): 14, (4, 5): 9}
TSP_P = {1: (0, 1.0), 2: (1.3, 1.8), 3: (2.4, 0.9), 4: (1.5, 0.0), 5: (0.5, 2.2)}


def tsp():
    fig, axs = plt.subplots(1, 2, figsize=(W * 1.1, 1.8))
    tours = [([1, 4, 3, 2, 5], "nearest neighbour from 1: 36"), ([5, 2, 1, 4, 3], "nearest neighbour from 5: 40")]
    for ax, (t, title) in zip(axs, tours):
        for (a, b), d in TSP_D.items():
            ax.plot(*zip(TSP_P[a], TSP_P[b]), color=G3, lw=0.5)
        for i in range(5):
            a, b = t[i], t[(i + 1) % 5]
            ax.add_patch(FancyArrowPatch(TSP_P[a], TSP_P[b], arrowstyle="-|>", mutation_scale=7, lw=1.1, color=K,
                                         shrinkA=6, shrinkB=6))
            mx, my = (TSP_P[a][0] + TSP_P[b][0]) / 2, (TSP_P[a][1] + TSP_P[b][1]) / 2
            ax.text(mx, my, str(TSP_D[(min(a, b), max(a, b))]), fontsize=6.5, ha="center",
                    bbox=dict(fc=PAPER, ec="none", pad=0.3))
        for v, (x, y) in TSP_P.items():
            ax.text(x, y, str(v), ha="center", va="center", fontsize=7,
                    bbox=dict(boxstyle="circle,pad=0.2", fc=PAPER if v != t[0] else G2, ec=K, lw=0.6))
        ax.set_title(title, fontsize=7.5); ax.axis("off"); ax.set_aspect("equal")
    save(fig, "tsp-nn")


NP_U = {1: (1, 1), 2: (2, 3), 3: (0, 1), 4: (4, 1), 5: (1, 2), 6: (2, 2), 7: (0, 1), 8: (1, 1), 9: (3, 4), 10: (2, 4)}
NP_A = {1: (2, 3), 2: (1, 2), 3: (1, 1), 4: (0, 2), 5: (1, 3)}


def network():
    fig, axs = plt.subplots(1, 2, figsize=(W * 1.15, 2.1))
    sols = [({1: [2, 9, 10], 3: [1, 4, 5, 6, 7, 8], 4: [3]}, {1: "R3", 3: "R3", 4: "R1"}, "greedy: 180+180+100 = 460"),
            ({1: [2, 9, 10], 3: [4, 5, 6, 7, 8], 4: [1, 3]}, {1: "R3", 3: "R2", 4: "R1"}, "after local search: 180+140+100 = 420")]
    for ax, (U, R, title) in zip(axs, sols):
        for a, us in U.items():
            for u in us:
                ax.plot(*zip(NP_U[u], NP_A[a]), color=G1, lw=0.6)
        jit = {3: (-0.12, 0), 7: (0.12, 0.0), 1: (-0.12, 0), 8: (0.12, 0)}
        for u, (x, y) in NP_U.items():
            dx, dy = jit.get(u, (0, 0))
            ax.text(x + dx, y + dy - 0.28, str(u), ha="center", fontsize=6)
            ax.plot(x + dx, y + dy, "o", color=K, ms=2.5)
        for a, (x, y) in NP_A.items():
            ax.plot(x, y, "s", ms=7, mfc=PAPER if a not in R else G2, mec=K, mew=0.6)
            ax.text(x - 0.15, y + 0.2, f"a{a}" + (f" {R[a]}" if a in R else ""), fontsize=6.5, weight="semibold")
        ax.set_xlim(-0.5, 4.5); ax.set_ylim(-0.3, 4.6); ax.set_aspect("equal")
        ax.set_title(title, fontsize=7.5); ax.set_xticks(range(5)); ax.set_yticks(range(5))
    save(fig, "network-planning")


def rcl():
    fig, ax = plt.subplots(figsize=(W, 0.95))
    q = [9, 10, 11, 11, 13, 18]
    ax.plot([8.5, 18.5], [0, 0], color=K, lw=0.6)
    thr = 9 + 0.3 * (18 - 9)
    ax.axvspan(8.7, thr, color=G3)
    for i, v in enumerate(q):
        ax.plot(v, 0, "o", color=K if v <= thr else G2, ms=5)
        ax.text(v, 0.18 + (0.18 if i == 3 else 0), str(v), ha="center", fontsize=7)
    ax.plot([thr, thr], [-0.3, 0.3], color=K, lw=0.8, ls="--")
    ax.text(thr + 0.15, -0.38, "$q_{min}+\\alpha(q_{max}-q_{min}) = 11.7$ for $\\alpha=0.3$", fontsize=6.5)
    ax.text(9.0, -0.38, "RCL", fontsize=7, weight="semibold")
    ax.set_ylim(-0.5, 0.55); ax.axis("off")
    save(fig, "rcl")


def path_relinking():
    fig, ax = plt.subplots(figsize=(W * 0.8, 1.5))
    costs = [460, 420, 420, 420, 460]
    names = ["initiating", "step 1", "step 2", "step 3", "guiding"]
    ax.plot(range(5), costs, color=K, marker="o", ms=4)
    for i, c in enumerate(costs):
        ax.text(i, c + 6, str(c), ha="center", fontsize=6.5)
    ax.set_xticks(range(5)); ax.set_xticklabels(names, fontsize=6.5)
    ax.set_ylim(400, 480); ax.set_ylabel("cost")
    ax.set_title("two 460 solutions; better ones lie between them", fontsize=7.5)
    save(fig, "path-relinking")


def brkga():
    fig, ax = plt.subplots(figsize=(W * 1.05, 2.0))
    ax.axis("off")
    def col(x, title, parts, w=1.0):
        y = 0
        for h, t, shade in parts:
            ax.add_patch(Rectangle((x, y), w, h, fc=shade, ec=K, lw=0.6))
            ax.text(x + w / 2, y + h / 2, t, ha="center", va="center", fontsize=6.5)
            y += h
        ax.text(x + w / 2, y + 0.15, title, ha="center", fontsize=7, weight="semibold")
    col(0, "generation k", [(1.6, "mutants\n(random)", "white"), (2.6, "non-elite", "white"), (1.2, "elite (best)", G2)])
    col(2.4, "generation k+1", [(0.8, "new mutants", "white"), (3.4, "children:\nelite × non-elite\n(keep elite gene\nwith prob. ρ > 0.5)", G3), (1.2, "elite copied", G2)], w=1.35)
    ax.add_patch(FancyArrowPatch((1.05, 4.8), (2.35, 4.8), arrowstyle="-|>", mutation_scale=8, lw=0.8))
    ax.text(1.7, 4.95, "copy", ha="center", fontsize=6.5)
    ax.add_patch(FancyArrowPatch((1.05, 3.0), (2.35, 2.7), arrowstyle="-|>", mutation_scale=8, lw=0.8))
    ax.add_patch(FancyArrowPatch((1.05, 4.6), (2.35, 2.9), arrowstyle="-|>", mutation_scale=8, lw=0.8))
    ax.text(1.55, 3.95, "mate", ha="center", fontsize=6.5)
    ax.text(3.95, 2.6, "every chromosome →\ndecoder (greedy that\nreads the keys) →\nsolution and cost →\nsort → elite", fontsize=6.5, va="center")
    ax.set_xlim(-0.1, 5.6); ax.set_ylim(-0.1, 5.8)
    save(fig, "brkga")


def packing():
    fig, ax = plt.subplots(figsize=(W * 0.75, 1.8))
    jobs = [(0, 0, 4, 2, "job 1"), (4, 0, 2, 3, "job 2"), (0, 2, 3, 1, "job 3")]
    for t, a, h, w, name in jobs:
        ax.add_patch(Rectangle((t, a), h, w, fc=G3, ec=K, lw=0.7))
        ax.text(t + h / 2, a + w / 2, name, ha="center", va="center", fontsize=6.5)
    ax.add_patch(Rectangle((0, 0), 7, 4, fc="none", ec=K, lw=1.0, ls="--"))
    ax.text(7.05, 3.75, "$W_j$", fontsize=7); ax.text(6.6, -0.55, "$H_i$", fontsize=7)
    ax.set_xlabel("time  (job $k$ occupies $[tr_k, tr_k+h_k)$)"); ax.set_ylabel("memory address")
    ax.set_xlim(-0.2, 7.8); ax.set_ylim(-0.2, 4.6)
    ax.set_title("jobs are rectangles; no two may overlap", fontsize=7.5)
    save(fig, "packing")


def bigm():
    fig, ax = plt.subplots(figsize=(W * 0.85, 1.55))
    xs = [0, 1]
    ax.plot([0, 1], [0, 1], color=K)
    ax.fill_between([0, 1], [0, 0], [0, 1], color=G3)
    ax.text(0.55, 0.2, "allowed: $0 \\leq x \\leq u\\,\\delta$", fontsize=6.5)
    ax.plot([0], [0], "o", color=K, ms=4); ax.text(0.03, 0.05, "δ = 0 forces x = 0", fontsize=6.5)
    ax.plot([1, 1], [0, 1], color=K, lw=0.6, ls=":"); ax.text(1.02, 0.5, "δ = 1: x ≤ u\n(constraint inactive\nif u is a true bound)", fontsize=6.5)
    ax.set_xticks([0, 1]); ax.set_xticklabels(["δ = 0", "δ = 1"]); ax.set_yticks([0, 1]); ax.set_yticklabels(["0", "u"])
    ax.set_xlim(-0.1, 1.8)
    ax.set_title("big-M (here M = u, the tightest valid value)", fontsize=7.5)
    save(fig, "bigm")


def time_size():
    fig, axs = plt.subplots(1, 2, figsize=(W * 1.1, 1.6))
    xs = [i for i in range(1, 60)]
    axs[0].plot(xs, [math.exp(0.09 * x) for x in xs], color=K)
    axs[0].axhline(60, color=G1, lw=0.6, ls="--"); axs[0].text(2, 70, "time available", fontsize=6.5, color=G1)
    axs[0].set_xlabel("instance size"); axs[0].set_ylabel("time to solve")
    axs[0].set_xticks([]); axs[0].set_yticks([])
    ls = [i / 100 for i in range(5, 100)]
    axs[1].plot(ls, [1 / ((1.02 - l) * 0.5) * (1 + 3 * l) for l in ls], color=K)
    axs[1].set_xlabel("load = Σ r_t / Σ R_c"); axs[1].set_ylabel("time to solve")
    axs[1].set_xticks([0, 0.5, 1]); axs[1].set_yticks([])
    axs[0].set_title("exact solvers blow up with size", fontsize=7.5)
    axs[1].set_title("and with how tight the instance is", fontsize=7.5)
    save(fig, "time-size")


if __name__ == "__main__":
    for fn in [lp_region, simplex_path, phase1, bb_region, bb_tree, convexity, piecewise, landscape, tsp,
               network, rcl, path_relinking, brkga, packing, bigm, time_size]:
        fn()
        print("figure", fn.__name__)
