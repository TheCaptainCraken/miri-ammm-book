// Appendices.  Both tables are generated from the book itself:
//  A collects every #slidenote (label <slidenote>),
//  B every exercise whose source names an exam, a sheet or a lab.
// Nothing here needs editing when a note or an exercise is added.
#import "../template.typ": *

#let page-of(loc) = if target() != "paged" { link(loc)[↗] } else { link(loc, str(loc.page())) }
#let answer-page(id) = {
  let a = query(label("ans-" + id))
  if a.len() > 0 { page-of(a.first().location()) } else { text(fill: red)[??] }
}

#set heading(numbering: none)

= Appendix A · On the slides

Every correction "On the slides" (and its variants for the official solutions, the exercise sheets and the lab statements), in book order. _Says_ is what the source says; _correct_ is what the book uses instead, then the reason.

#context {
  let notes = query(<slidenote>)
  let kinds = (slides: "slides", solution: "official solution", sheet: "exercise sheet", lab: "lab statement")
  for n in notes {
    let v = n.value
    [*#v.deck, #v.where* (#kinds.at(v.kind), page #page-of(n.location())). _Says:_ #v.says _Correct:_ #v.correct — #v.why]
    parbreak()
  }
  [#notes.len() notes in total.]
}

= Appendix B · Where each exercise of the course is

Every question of the five past finals, every exercise of the two homework sheets and every lab task, with its place in the book and the page of its solution.

#let source-table(prefixes) = context {
  let rows = ()
  for p in prefixes {
    // natural order inside each source: Q1 before Q2(a), Ex 2 before Ex 10
    let key(e) = e.source.replace("tasks", "task").replace(regex("\\d+"), d => "0000".slice(d.text.len()) + d.text)
    for e in exercises-with(p).sorted(key: key) {
      rows.push((e.source, link(e.location, e.n), page-of(e.location), answer-page(e.id)))
    }
  }
  table(columns: (1fr, auto, auto, auto),
    table.header([source], [exercise], [page], [solution]), ..rows.flatten())
}

== Past finals

#source-table(("Final Jun 2024", "Final Jan 2025", "Final Jun 2025", "Final Jan 2026", "Final Jun 2026"))

== Homework sheets

#source-table(("LP sheet", "ILP sheet"))

== Labs

#source-table(("Lab 1", "Lab 2", "Lab 3", "Lab 4"))

= Appendix C · Prof. Velasco's research

The last deck of the course, _Some Applications_, is not exam material. It is a tour of Prof. Luis Velasco's own research on optical networks, datacentres and the telecom cloud, and it is worth an hour anyway: every problem in it is stated the way Part II states problems and solved with the tools of Part II, on networks that carry real traffic. This appendix goes through the deck problem by problem and says, for each one, what is optimized and which chapter its method comes from. It ends with the deck's last part, where a network watches itself and reconfigures itself, and with VENTURE, the algorithm that does the reconfiguring.

A few words of networking are enough for the slides:

/ Optical network: nodes joined by fibre links. A connection (a _lightpath_) follows a route and occupies a band of the fibre's spectrum on every link of it. In a _flexgrid_ network the spectrum is cut into narrow _slices_ and a connection takes as many contiguous slices as its bitrate needs. Choosing the route and the slices is the _RSA_ problem (routing and spectrum allocation).
/ Transponder: the device at each end of an optical connection, turning bits into light and back. Transponders are expensive and use energy, so many objectives count them.
/ Datacentre (DC), virtual machine (VM): the computing side. A VM can be _migrated_ from one DC to another over the network.
/ VNT, vlink: the _virtual network topology_ is the IP layer on top of the optical one: routers, and virtual links between them. Each vlink is an optical connection, with a transponder at each end.
/ OD pair: an origin–destination pair of routers and the bitrate it sends. The traffic matrix lists them all.

== One method, many problems

Every problem of the deck is presented in three parts: _Given_ (the sets and parameters), _Output_ (what a solution says) and _Objective_. That is the problem statement of Chapter 10, the way every exam question 3 opens. Every one is then solved the way Part II teaches: a greedy construction (Chapter 11), usually repeated with randomness (Chapter 13), sometimes improved by local search (Chapter 12). And the reason for not simply calling CPLEX is always the one of Chapter 10: the answer is needed sooner than an exact solver can give it.

== Re-optimizing a network while it runs

A network used to be planned off-line: once a year a team forecast the traffic, designed the network to minimize its total cost of ownership, and had weeks to compare scenarios. _In-operation planning_ (Velasco et al., 2014a) adds a second, fast loop to that life cycle: the network is reconfigured and re-optimized _while it carries traffic_, so a good-enough answer is needed in milliseconds. In the architecture of the slides, the path computation element (PCE) that serves ordinary connection requests hands the heavy re-optimizations to a back-end PCE with CPUs and GPUs.

The example is *restoration* after a failure.
- _Given:_ the network $G(N, E)$, the set $S$ of slices of every link, and the demands $D$ to route, each with a source $s_d$, a target $t_d$ and a number $n_d$ of slices.
- _Output:_ a route and its slices for each demand.
- _Objective:_ minimize the spectrum used and the demands left blocked.

The heuristic of the slides:
```pseudo
bestS <- {}
for i = 1 to maxIter:
    S <- {}; G' <- G
    sort(D, random)              // a new random order
    for each d in D:
        <k, ck> <- getRSA(G', d) // greedy RSA
        if k = none: continue    // d stays blocked
        allocate(G', d, <k, ck>); S <- S + {d}
    if Phi(S) > Phi(bestS): bestS <- S
return bestS
```
It is a greedy (Chapter 11) restarted `maxIter` times, whose only randomness is the order of the demands: a multi-start in the spirit of GRASP (Chapter 13), with the random order in the role of the RCL. Chapter 13 noted that GRASP iterations are independent and can run in parallel. Here they do, on a GPU. In about 100 ms the GPU completes 990 iterations where the CPU completes 120, 8.4 times as many per millisecond, and the probability of reaching the target solution rises from 78.5 % to 91.5 %. On a second network the figures are 590 iterations against 90, and 85.9 % against 55.8 %. For a multi-start heuristic, speed _is_ quality.

== Datacentre federations

Datacentres can federate and move VMs among themselves: towards the users of the next hours, and towards cheap renewable ("green") energy wherever it is available. The ELFADO problem (Velasco et al., 2014b) decides the placement for the next period.
- _Given:_ the DCs $D$; the optical connections $E$ that can join them; the VMs $V(d)$ in each DC; the users of each location $l$; the price of brown energy and the green energy $g_d$ available in each DC; the data volume $k_v$ of each VM; the performance $p_(l d)$ seen from location $l$ when served from DC $d$; and the performance threshold $"th"_v$ of each VM.
- _Output:_ the DC of each VM.
- _Objective:_ minimize the energy and communication cost while every service meets its threshold.

The slides solve it in two ways. The *distributed* algorithm runs in each DC, for its own VMs: for each VM it lists the DCs that meet the threshold with their cost (including the migration's communication if the DC is another one), sorts the list, and takes the first DC whose connection still has room for the VM's data. It is the greedy scheme of Chapter 11, with a sorted candidate list and "first feasible" as the choice. The *centralized* algorithm sees the whole federation: it moves first the VMs whose current placement misses the threshold, then the others, each to a DC with enough spare green energy at the least communication cost; what is left runs on brown energy. Over a day, with DCs in Taiwan, India, Spain, Illinois and California:

#table(columns: (1fr, auto, auto, auto, auto), align: (left, right, right, right, right),
  table.header([placement], [energy], [communication], [total], [saving]),
  [fixed], [6,048 €], [—], [6,048 €], [—],
  [distributed], [5,374 €], [537 €], [5,912 €], [2.3 %],
  [centralized], [2,867 €], [508 €], [3,376 €], [44.2 %],
)

Same greedy idea, very different results: the centralized greedy knows where the green energy is, each distributed one knows only its own DC. A greedy is only as good as the information its greedy function looks at. (The case study of Chapter 16 is a toy version of this problem, worked from the statement to a BRKGA.)

The deck then looks at the connections between DCs. Synchronizing a database or migrating a batch of VMs is a _transfer_: a volume of data with a deadline, carried by a connection whose bitrate can change while it runs (Velasco et al., 2013). When a new transfer does not fit, the RSSA problem (routing and scheduled spectrum allocation; Asensio and Velasco, 2014) makes room by rescheduling transfers already in progress, with the objective of rescheduling as few of them as possible. The algorithm computes the smallest bitrate that meets the new deadline and tries a plain RSA; if that fails, it goes through the $k$ shortest paths and, on each, through the free bands of spectrum from the widest down, looking for neighbouring transfers that can be moved aside. The first combination that works is applied: a greedy again, which tries its candidates in order of promise. At 1 % of unserved bitrate, it lets the three national networks of the study carry 12 %, 18 % and 31 % more load than plain RSA.

== Planning for CAPEX: live TV and mobile networks

Two planning problems, where the cost is equipment bought once (CAPEX).

*Live-TV distribution* (Asensio et al., 2015). Uncompressed video leaves a primary DC; compressed streams must reach the metro switches near the users. Should all the processing happen in one place (centralized), or in $n$ secondary DCs closer to the users (distributed)?
- _Given:_ the primary location $p$; the metro locations $M$; the subset $D subset.eq M$ of locations that can host a secondary DC; the optical network $G$ between them; the costs of core switches and transponders; the video streams.
- _Output:_ the locations $D^* subset.eq D$ of the secondary DCs, the configuration of every core switch, and the optical connections to set up.
- _Objective:_ minimize CAPEX when $n$ secondary DCs are equipped.

The planning procedure of the slides takes a candidate set $D'$ of locations and builds everything else greedily: a connection from $p$ to each secondary DC; each metro location served by its own DC, or else by the nearest one; then, in each DC, the transponders and the cheapest switch that can hold them. It returns the CAPEX. This is an *evaluation function*: the hard decision (where the DCs go) is separated from everything that follows from it, which a greedy builds. It is the split of a BRKGA decoder (Chapter 15), and what a local search over sets of locations (Chapter 12: add, remove or swap a location) would call to compare neighbours. On Telefónica's Spanish network (five regional networks of 30 nodes and a core of 21), the distributed architecture needs 27.7 % less CAPEX than the centralized one in 2015, and 32.1 % less in 2018, as viewers move to HD and UHD.

*Cloud RAN* (Asensio et al., 2016). A mobile base station can be split into a radio head (RRH) at the antenna and a baseband unit (BBU) that runs as a VM in a central office (CO). The CRAM problem chooses the equipment of each main CO (VMs for the BBU pools, an IP/MPLS router, line cards, transponders) to serve about 200 RRHs at minimum cost. Every piece of equipment has a price, a capacity and a number of slots for the next piece: a model of indicators, fixed costs and modular capacities, the material of Chapters 5–7. With 100 MHz of radio bandwidth, the cheapest solution equips 7 of the 9 main COs.

== Autonomic infrastructures

The last part of the deck moves from planning a network to letting it run itself. A telecom cloud, the datacentres and the optical network between them operated as one infrastructure, is watched continuously; the data is analysed; and the network is reconfigured according to what the analysis says, without waiting for an operator or for next year's plan.

=== VENTURE

The usual way to adapt a VNT to its traffic is a *threshold*: monitor the use of every vlink and add capacity when it passes, say, 90 %. That is reactive (it acts once the vlink is already busy) and it sees only vlinks, not where the traffic is going. On the slides, the traffic from R6 to R7 grows; the threshold rule upgrades both vlinks of its path, R6–R1 and R1–R7, from 100 to 200 Gb/s. VENTURE (Morales et al., 2017) works from a prediction of the near-future OD traffic instead: it sees that the growth is R6 → R7, and opens one direct vlink R6–R7 of 100 Gb/s.
- _Given:_ the current VNT $G(N, E')$, with $E' subset.eq E$, the set of all possible vlinks; the transponders $P$ of the routers, each of capacity $B$; the current traffic matrix $D$ and the predicted one, $"OD"$. Each OD pair $o$ is served on a single path, unless its bitrate $b_o$ fills transponders above a usage boundary $"tbu"$; then it may be split into two flows on different paths.
- _Output:_ the new VNT $G^*(N, E^*)$, with $E^* subset.eq E$, and the paths of the traffic on it.
- _Objective:_ serve the current and the predicted traffic while using as few transponders as possible.

The problem is formulated as a MILP (Part I), but large instances cannot be solved to optimality in the time available, so VENTURE is a heuristic in three steps:
+ split the bitrate of every OD pair into a high part, worth whole transponders, and a low remainder;
+ route the high parts on direct vlinks (Phases I and II);
+ route the low parts over the VNT, using as few transponders as possible (Phase III).

Phase III is where the course's heuristics are. The slides solve it in three ways.

*Basic VENTURE: randomized greedy and local search.* The OD pairs with unserved bitrate are sorted in a greedy-randomized order, $"order"(o) prop b_o dot "Unif"(0, 1)$: large pairs tend to go first, but not always. Each pair, in that order, takes its shortest path, where the cost of a vlink depends on its free capacity and on $b_o$: 1 if the pair fits in an existing vlink, 100 if a new vlink, with new transponders, must be opened. The whole matrix is processed for several random seeds, and the best solution is returned. On the slides, a 15 Gb/s pair from R1 to R3 finds room on R1–R2 (cost 1) but no way on to R3, and opens a new vlink R2–R3: shortest-path cost $1 + 100 = 101$. The next pair, 10 Gb/s from R1 to R5, uses the new vlink, which still has 85 Gb/s free, at cost 1: shortest-path cost 3. #slidenote(deck: "Some Applications", where: "slide 41", says: [The table lists the first OD pair as R2 → R3, 15 Gb/s.], correct: [The drawing routes it from R1 to R3: over R1–R2 (whose use goes from 75 to 90) and the new vlink R2–R3, cost $1 + 100 = 101$.], why: [An R2 → R3 pair would take the new vlink alone, at cost 100, and would not load R1–R2.]) The costs change after every allocation: the greedy is _adaptive_, the A of GRASP.

Two things link it to the rest of the book. First, the order $b_o dot "Unif"(0, 1)$ is a greedy value times a random number, like a BRKGA decoder that uses its keys as priorities (Chapter 15). Here the numbers are drawn afresh on every run, which makes a multi-start; storing them in chromosomes and evolving them would make a BRKGA. Second, the *local search* that follows each construction is Chapter 12's scheme. The move removes one vlink (the slides pick the one with the highest transponder activation) and reroutes its paths over the remaining vlinks, largest bitrate first. The move is accepted only if the rerouting costs nothing, that is, needs no new vlink; it then releases the transponders of the removed vlink (two, in the slides' example). When no vlink can be removed at zero cost, the solution is a local optimum and the search stops.

*GRASP-based VENTURE.* The candidate list is the unserved OD traffic matrix, the greedy cost function (GCF) of an OD pair is the cost of its shortest path, and $alpha in [0, 1]$:
```pseudo
for k = 1 to maxIter:
    S <- current VNT; CL <- unserved OD pairs
    while CL != {}:
        for o in CL: evaluate GCF(o)  // on S, now
        u <- max GCF(o); l <- min GCF(o)
        RCL <- { o in CL : GCF(o) <= l + alpha (u - l) }
        o <- random element of RCL
        allocate o on its shortest path in S
        CL <- CL - {o}
    S <- LocalSearch(S)
    keep S if it is the best so far
return the best S
```
Put it next to the algorithm of Chapter 13: it is the same, line by line. The slides write the list as $"RCL"(alpha) = "GCF"^(-1)([l, l + alpha (u - l)])$, the pairs whose cost falls in the lowest part of the range: the RCL of a minimization. And the GCF is evaluated again at every step because the cost of every path changes as vlinks fill up, which is the answer to Chapter 13's _Think first_.

*ILS-based VENTURE.* The third version uses a metaheuristic the course does not otherwise cover, *iterated local search* (ILS). Instead of building every solution from scratch, as GRASP does, it restarts from a _kicked_ copy of the current local optimum:
```pseudo
s' <- LocalSearch(BasicVENTURE())  // one iteration
while not stop:
    s <- Perturb(s', rho)   // remove n ~ rho vlinks at
                            // random, reroute greedily
    s'' <- LocalSearch(s)
    s' <- the better of s', s''
return s'
```
The slides' flowchart leaves the acceptance rule implicit; keeping the better of the two is the usual choice. The *strength* $rho in [0, 1]$ sets how many vlinks a perturbation removes ($n prop rho$), and it is the dial of Chapter 14 between intensification and diversification. A weak kick keeps most of a good solution, and local search may fall straight back into $s'$; a strong one keeps almost nothing, and ILS turns into random restarts. The study on the slides shows the second end clearly: the optimality gap of every instance type gets much worse at $rho = 0.9$.

=== A minute against four hours

The study compares the three versions, 60 seconds each, with branch & bound given 4 hours, on twelve instances. The OD bitrates are high (about 130 Gb/s per pair, for vlinks of 100 Gb/s), average (about 100) or low (about 70), and the traffic follows four patterns, A to D. The table gives the objective values (lower is better):

#table(columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr), align: (left, center, right, right, right, right, right),
  table.header([OD bitrate], [type], [B&B bound], [B&B best], [Basic], [GRASP], [ILS]),
  [high], [A], [455.44], [484], [484.14], [488.25], [480.99],
  [], [B], [721.24], [745], [746.06], [749.59], [745.81],
  [], [C], [590.00], [618], [618.98], [624.15], [616.65],
  [], [D], [426.22], [457], [457.26], [460.89], [453.56],
  [average], [A], [230.74], [250], [250.81], [255.46], [249.23],
  [], [B], [357.80], [377], [376.92], [379.77], [377.70],
  [], [C], [291.07], [315], [314.57], [320.24], [313.55],
  [], [D], [217.08], [235], [235.53], [237.83], [233.53],
  [low], [A], [142.00], [165], [167.37], [164.91], [165.63],
  [], [B], [190.75], [212], [212.08], [214.40], [213.25],
  [], [C], [166.69], [187], [187.56], [186.50], [187.42],
  [], [D], [136.10], [148], [157.98], [153.81], [154.28],
)

The gap is measured as in Chapter 8, against the best *bound* of branch & bound: $("value" - "bound") slash "bound"$. In the first row, branch & bound's own solution has a gap of $(484 - 455.44) slash 455.44 = 6.27 %$, and ILS's $(480.99 - 455.44) slash 455.44 = 5.61 %$. Four things to read in the table:
- *A minute beats four hours.* On 9 of the 12 instances the best heuristic finds, in 60 seconds, a better solution than branch & bound in 4 hours. ILS alone does it on 6.
- *The heuristics stay within about 9 % of the bound* on average (Basic 9.2 %, GRASP 9.6 %, ILS 8.6 %), and ILS within 5 % on the high-bitrate instances.
- *ILS is the best of the three* on 7 of the 8 high- and average-bitrate instances. On the low-bitrate ones no version dominates, and branch & bound keeps the smallest average gap.
- *A gap to the bound is an upper bound on the gap to the optimum.* The optimum lies somewhere between the bound and the best solution known. Where branch & bound itself stops at 8–16 %, as on the low-bitrate instances, nobody knows how much of the heuristics' gap is real.

== What to take from it

VENTURE is the whole course in one paper: a story told as Given, Output and Objective (Chapter 10); a MILP (Chapters 5–7) that branch & bound cannot finish on large instances (Chapter 8); a randomized, adaptive greedy (Chapters 11 and 13); a local search with a well-chosen move (Chapter 12); a perturbation strength that trades intensification for diversification (Chapter 14); and an honest comparison against the bound of the exact method. The other problems of the deck use smaller parts of the same toolbox:

#table(columns: (auto, 1fr), align: left,
  table.header([problem], [method on the slides, and where it is in the book]),
  [restoration], [greedy in random orders, restarted; the iterations run in parallel on a GPU (Chapters 11, 13)],
  [ELFADO], [greedy over sorted candidates, run in each DC or over the whole federation (Chapters 11, 16)],
  [RSSA], [greedy that tries paths and spectrum bands in order of promise (Chapter 11)],
  [live TV], [choose the DC locations, build the rest greedily, return its cost (Chapters 11, 12, 15)],
  [CRAM], [equipment with fixed costs and modular capacities (Chapters 5–7)],
  [VENTURE], [MILP; randomized greedy and local search; GRASP; ILS; gap to the bound of branch & bound (Chapters 5–8, 10–14)],
)

If question 3 of the exam ever feels artificial, this is where its kind of answer ends up: in the planning tool of a network that re-optimizes itself every hour. A pirate would call it trimming the sails without stopping the ship.

== The papers on the slides

#[
#set par(hanging-indent: 1.2em)

L. Velasco et al. Cross-stratum orchestration and flexgrid optical networks for datacenter federations. _IEEE Network_ 27:23–30, 2013.

L. Velasco et al. In-operation network planning. _IEEE Communications Magazine_ 52:52–60, 2014a.

L. Velasco et al. Elastic operations in federated datacenters for performance and cost optimization. _Computer Communications_ 50:142–151, 2014b.

Ll. Gifre et al. Experimental assessment of a high performance back-end PCE for flexgrid optical network re-optimization. _Optical Fiber Communication Conference (OFC)_, 2014.

A. Asensio and L. Velasco. Managing transfer-based datacenter connections. _Journal of Optical Communications and Networking_ 6:660–669, 2014.

A. Asensio et al. Scalability of telecom cloud architectures for live-TV distribution. _Optical Fiber Communication Conference (OFC)_, 2015.

A. Asensio et al. Study of the centralization level of optical network-supported cloud RAN. _Optical Network Design and Modeling (ONDM)_, 2016.

F. Morales et al. Virtual network topology adaptability based on data analytics for traffic prediction. _Journal of Optical Communications and Networking_ 9:A35–A45, 2017.

L. Velasco and M. Ruiz. _Provisioning, Recovery, and In-Operation Planning in Elastic Optical Networks_. Wiley, 2017. The book on the deck's last slides: these problems, and many more, from the operator's side.

The full list of Prof. Velasco's publications is on his web page, #link("http://people.ac.upc.edu/lvelasco/")[people.ac.upc.edu/lvelasco].
]

= Bibliography

#set par(hanging-indent: 1.2em)

The course material: slides, lab statements, exercise sheets and past exams (June 2024 to June 2026) with their solutions, by E. Rodríguez-Carbonell and L. Velasco, Algorithmic Methods for Mathematical Models, Universitat Politècnica de Catalunya, 2024–2026.

H. P. Williams. _Model Building in Mathematical Programming_, 5th ed. Wiley, 2013.

D. G. Luenberger and Y. Ye. _Linear and Nonlinear Programming_, 5th ed. Springer, 2021.

F. Glover and G. A. Kochenberger (eds.). _Handbook of Metaheuristics_. Kluwer, 2003.

S. P. Bradley, A. C. Hax and T. L. Magnanti. _Applied Mathematical Programming_. Addison-Wesley, 1977.

Z. Michalewicz and D. B. Fogel. _How to Solve It: Modern Heuristics_, 2nd ed. Springer, 2004.

M. G. C. Resende and C. C. Ribeiro. _Optimization by GRASP_. Springer, 2016.

J. F. Gonçalves and M. G. C. Resende. Biased random-key genetic algorithms for combinatorial optimization. _Journal of Heuristics_ 17:487–525, 2011.

IBM ILOG CPLEX Optimization Studio, _OPL Language User's Manual_ and _CPLEX User's Manual_, version 22.1.
