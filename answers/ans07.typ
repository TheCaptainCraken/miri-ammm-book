#import "../refs.typ": answer, exref, slidenote

#answer("ch7-yt1")[$r_(t+1) <= r_t$; $q_t <= 500 r_t$; $2000 sum_(t=1)^4 r_t$ (added to a cost to be minimized).]

#answer("ch7-a")[(a) $H_(p, t-1) + M_(p t) - S_(p t) = H_(p t)$ (with $H_(p 0)$ the initial stock). (b) $H_(p T) = 50$ for every product. (c) $w_(i t) <= o_(i t)$ and $o_(i, t+1) <= o_(i t)$.]

#answer("ch7-b")[(a) $S_1 + 2 <= S_2 + 10(1 - o)$, $S_2 + 4 <= S_1 + 10 o$. (b) It must make the relaxed constraint true for every feasible schedule (here: every end time $<= H$). $10^9$ is valid but makes the LP relaxation almost useless and invites numerical trouble; take the smallest valid horizon. (c) $binom(6, 2) = 15$.]

#answer("ch7-w1")[
```opl
dvar float+ m[1..3] in 0..60;
dvar float+ s[0..3] in 0..30;
minimize sum(t in 1..3) (10*m[t] + 2*s[t]);
subject to {
  s[0] == 0;
  forall (t in 1..3) s[t-1] + m[t] == d[t] + s[t];
}
```
Declaring `s` on `0..3` and fixing `s[0]` avoids a special case for $t = 1$.]

#answer("ch7-w2")[Binaries $o_(12), o_(13), o_(23)$. Pair (1, 3): $S_1 + p_1 <= S_3 + H(1 - o_(13))$ and $S_3 + p_3 <= S_1 + H o_(13)$.]

#answer("ilp-sheet-6")[*Variables:* $x_(i t) >= 0$ units bought from $i$ in month $t$; $delta_(i t) in {0,1}$ "buy from $i$ in $t$"; $s_t in [0, h]$ units carried to $t+1$; $w_t >= 0$ units thrown away. *Balance:* $s_(t-1) + sum_i x_(i t) = d_t + s_t + w_t$ with $s_0 = 0$. *Minimum purchase:* $ell_i delta_(i t) <= x_(i t) <= U delta_(i t)$ with a valid $U$, for instance $U = max(ell_i, sum_(t' >= t) d_(t') )$ — no reason to buy more than the remaining demand unless forced by $ell_i$. *Objective:* $min sum_(i, t) c_(i t) x_(i t)$. Checked against brute force on random small instances.]

#answer("ilp-sheet-7")[*Variables:* $A_i, B_i >= 0$ start of examination and of check-up of patient $i$; $C >= 0$ end of the last task; for every pair of tasks (examinations and check-ups together, $2|N|$ tasks) an order binary. *Constraints:* waiting window $A_i + p_i + l_i <= B_i <= A_i + p_i + u_i$; end $C >= B_i + q_i$; for each pair of tasks $(u, v)$ with starts $S_u, S_v$ and durations $P_u, P_v$: $S_u + P_u <= S_v + H(1 - o_(u v))$ and $S_v + P_v <= S_u + H o_(u v)$, with $H = sum_i (p_i + u_i + q_i)$ (a schedule doing patients one after the other ends before $H$). *Objective:* $min C$. Note that the examination and check-up of the _same_ patient are already ordered by the window, but including them in the pairs does no harm. Checked against brute force on small integer instances.]

#answer("ilp-sheet-4")[*Variables:* $x_(i j) in {0,1}$ team $i$ investigates location $j$; $y_(i a b) in {0, 1}$ ($a < b$) team $i$ does both $a$ and $b$; $z >= 0$ completion time. *Constraints:* each outbreak once, $sum_i x_(i j) = 1$; at most two per team, $sum_j x_(i j) <= 2$; pairs, $y_(i a b) >= x_(i a) + x_(i b) - 1$; completion, $z >= sum_j t_(i j) x_(i j) + sum_(a < b) d_(a b) y_(i a b)$ for each team. *Objective:* $min z$. ($y$ only needs the "$>=$" direction because it only adds time.) Checked against brute force on random instances (3 teams, 4 locations).]

#answer("ilp-sheet-10")[*Variables:* for mine $i$ and year $t$: $o_(i t) in {0,1}$ open (royalties paid), $w_(i t) in {0,1}$ worked, $q_(i t) >= 0$ million tons extracted. *Constraints:* at most three worked, $sum_i w_(i t) <= 3$; worked ⇒ open, $w_(i t) <= o_(i t)$; closed for good, $o_(i, t+1) <= o_(i t)$; capacity, $q_(i t) <= "cap"_i w_(i t)$; quality, $sum_i "qual"_i q_(i t) = "target"_t sum_i q_(i t)$ (ratio cleared). *Objective:* $max sum_(i, t) 10 q_(i t) - sum_(i, t) "roy"_i o_(i t)$ (M€). Optimum 175.917 M€. One optimal plan keeps mines 1–3 open all five years and closes mine 4 after year 4 (royalties 85 M€); year 3 produces only 3.25 Mt because the target 1.2 can only be reached by blending mines 1 and 3.]

#answer("ilp-sheet-9")[(a) *Variables:* $M_(p t)$ made, $S_(p t)$ sold, $H_(p t)$ held at the end of month $t$, all $>= 0$. *Constraints:* $H_(p, t-1) + M_(p t) - S_(p t) = H_(p t)$ with $H_(p 0) = 0$; $H_(p 6) = 50$; $S_(p t) <= "market"_(p t)$; $H_(p t) <= 100$; for each machine type $g$ and month $t$, $sum_p "hours"_(g p) M_(p t) <= 384 (N_g - "down"_(g t))$ (24 days × 16 h = 384 h per machine). *Objective:* $max sum_(p, t) ("profit"_p S_(p t) - 0.5 H_(p t))$. Optimum 93 715.18. (b) Replace $"down"_(g t)$ by integer variables $D_(g t) >= 0$ with $sum_t D_(g t) = N_g$ for every type except grinders, where $sum_t D_(g t) = 2$, and $D_(g t) <= N_g$. Optimum 108 855 — choosing the maintenance months is worth 15 140. It is not an LP: $D_(g t)$ counts machines, and a fractional machine down for maintenance is meaningless (the LP relaxation would spread maintenance thinly over all months).]

#answer("jun24-q2bd")[(b) $sum_(i=1)^r sum_(j=1)^s c_(i j) = 1$. (c) $min sum_(i, j) p_(i j) c_(i j)$. (d) Yes: jobs must not overlap in time _and_ memory simultaneously. For ordered pairs $k != k'$ introduce binaries $a_(k k')$ ("$k$ runs after $k'$ has finished") and $l_(k k')$ ("$k$'s block is above $k'$'s block"). Link them: $"tr"_k - "tr"_(k') - h_(k') >= (1 - a_(k k'))(1 - H_r - h_(k'))$ and $"lc"_k - "lc"_(k') - w_(k') >= (1 - l_(k k'))(1 - W_s - w_(k'))$ — with value 1 they give $"tr"_k >= "tr"_(k') + h_(k')$ (resp. memory); with 0 the right side is at most the smallest possible left side ($-H_r$, resp. $-W_s$, because $h_(k') >= 1$), so nothing is imposed. Then no overlap: $a_(k k') + a_(k' k) + l_(k k') + l_(k' k) >= 1$ for $k < k'$. An equally valid link is $"tr"_k >= "tr"_(k') + h_(k') - H_r(1 - a_(k k'))$. The official model was checked against brute-force packing on 25 random instances.]

#answer("ch7-r1")[$3x + 500 delta$ with $x <= 800 delta$, $delta in {0,1}$.]

#answer("ch7-r2")[$(x_0, x_1)$: $x_0 = x_1 = 2$, feasible. $(x_0, x_2)$: $x_0 = 0$, $x_2 = 4$, feasible and degenerate. $(x_1, x_2)$: $x_1 = 0$, $x_2 = 4$, feasible and degenerate. All three pairs are bases.]
