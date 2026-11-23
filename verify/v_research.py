"""Appendix C: the numbers quoted from Prof. Velasco's application slides.

The values are read from the slides; this script checks that the
percentages, ratios and counts the appendix derives from them are right."""
from statistics import mean

# Restoration on a GPU (slide 8): iterations in ~100 ms, speed-up per ms
for cpu, gpu, speedup in [(120, 990, 8.4), (90, 590, 6.7)]:
    assert round((gpu / 98) / (cpu / 100), 1) == speedup

# ELFADO (slide 13): savings against the fixed placement
fixed = 6048
for cost, saving in [(5374, 11.1), (5912, 2.3), (2867, 52.6), (3376, 44.2)]:
    # 2.3 % comes from the unrounded total (6048 - 5911 = 2.27 %)
    assert abs(100 * (fixed - cost) / fixed - saving) < 0.06
# totals are energy + communication, up to the slides' rounding of each term
assert abs(5374 + 537 - 5912) <= 1 and abs(2867 + 508 - 3376) <= 1

# VENTURE, Phase III example (slide 41): an existing vlink costs 1, a new one 100
assert 1 + 100 == 101 and 1 + 1 + 1 == 3 and 100 - 15 == 85

# VENTURE numerical study (slide 46): B&B 4 h vs heuristics 60 s.
# (bitrate, type): best bound, B&B best integer, Basic, GRASP, ILS, printed gaps (%)
T = {
    ("high", "A"): (455.44, 484, 484.14, 488.25, 480.99, (6.27, 6.30, 7.20, 5.61)),
    ("high", "B"): (721.24, 745, 746.06, 749.59, 745.81, (3.29, 3.44, 3.93, 3.41)),
    ("high", "C"): (590.00, 618, 618.98, 624.15, 616.65, (4.75, 4.91, 5.79, 4.52)),
    ("high", "D"): (426.22, 457, 457.26, 460.89, 453.56, (7.22, 7.28, 8.13, 6.41)),
    ("average", "A"): (230.74, 250, 250.81, 255.46, 249.23, (8.35, 8.70, 10.71, 8.01)),
    ("average", "B"): (357.80, 377, 376.92, 379.77, 377.70, (5.37, 5.34, 6.14, 5.56)),
    ("average", "C"): (291.07, 315, 314.57, 320.24, 313.55, (8.22, 8.07, 10.02, 7.72)),
    ("average", "D"): (217.08, 235, 235.53, 237.83, 233.53, (8.26, 8.50, 9.56, 7.58)),
    ("low", "A"): (142.00, 165, 167.37, 164.91, 165.63, (16.20, 17.87, 16.13, 16.64)),
    ("low", "B"): (190.75, 212, 212.08, 214.40, 213.25, (11.14, 11.18, 12.40, 11.80)),
    ("low", "C"): (166.69, 187, 187.56, 186.50, 187.42, (12.18, 12.52, 11.88, 12.44)),
    ("low", "D"): (136.10, 148, 157.98, 153.81, 154.28, (8.74, 16.08, 13.01, 13.36)),
}
# every printed gap is (value - bound) / bound
for bound, *values, gaps in T.values():
    for v, g in zip(values, gaps):
        assert abs(100 * (v - bound) / bound - g) < 0.006, (v, bound, g)
# the worked line: first row
assert round(100 * (484 - 455.44) / 455.44, 2) == 6.27 and round(100 * (480.99 - 455.44) / 455.44, 2) == 5.61

heur = {k: v[2:5] for k, v in T.items()}
# the best heuristic in 60 s beats B&B's 4-hour solution on 9 of 12; ILS alone on 6
assert sum(min(h) < T[k][1] for k, h in heur.items()) == 9
assert sum(h[2] < T[k][1] for k, h in heur.items()) == 6
# average gaps: all heuristics 9.1 %; Basic 9.2, GRASP 9.6, ILS 8.6; ILS on high bitrate 5.0
gaps = {k: v[5] for k, v in T.items()}
assert round(mean(g for gs in gaps.values() for g in gs[1:]), 1) == 9.1
assert [round(mean(gs[j] for gs in gaps.values()), 1) for j in (1, 2, 3)] == [9.2, 9.6, 8.6]
assert round(mean(gs[3] for k, gs in gaps.items() if k[0] == "high"), 1) == 5.0
# ILS is the best heuristic on 7 of the 8 high- and average-bitrate instances
assert sum(h[2] == min(h) for k, h in heur.items() if k[0] != "low") == 7
# on the low-bitrate instances B&B has the smallest average gap; its own gaps run 8-16 %
low = [gs for k, gs in gaps.items() if k[0] == "low"]
assert min(range(4), key=lambda j: mean(gs[j] for gs in low)) == 0
assert min(gs[0] for gs in low) == 8.74 and max(gs[0] for gs in low) == 16.20
print("RESEARCH APPENDIX OK")
