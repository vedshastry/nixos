# Chapter 7: Empirical Application — Estimation, Event Studies & Placebos

## Core Idea
The Uttarakhand application shows the full workflow: estimate a collapsed-period DID (Eq. 14), then defend it with three graphical tests — an event study (parallel pre-trends), a *far-apart* falsification (pre-trends reappear), and a *placebo-state* test (state formation alone has no effect).

## Frameworks Introduced
- **Main specification (Eq. 14)**: `Yit = Σ φj·Pji + α·Qt + β·DiQt + εit`, sample = cells within 10 km of the boundary, `Qt = 1{t ≥ 2002}`.
  - Collapses all year dummies into a single post indicator `Qt` (two-period DID); `Di` is absorbed by the cell FE. β = average differential change in lights in the treated state after 2002.
  - Good-practice check: verify that using full yearly dummies (Eq. 1) doesn't change results.

- **Event-study specification (Eq. 15)**: `Yit = Σ φj·Pji + Σ_s α_s·Pst + Σ_{s≠2001} β_s·Di·Pst + εit`. Plot `{β̂_s}` with 95% CIs against year, relative to an omitted **reference year** (2001).
  - When to use: almost mandatory for any DID with >2 periods — reveals pre-trends and whether the break aligns with treatment.
  - How to read: pre-treatment β̂_s ≈ 0 (CIs include 0) → parallel trends; post-treatment β̂_s jump and grow → effect appears only after treatment.
  - Why a reference year: the full interaction set is collinear with cell FE + year dummies; omitting one `s` (year before treatment, or first year) sets the baseline. 2001's coefficient is 0 by construction.

- **Far-apart falsification test**: re-estimate the event study on cells in a *distant* band (e.g., 35–45 km from the boundary), where parallel trends has no reason to hold.
  - Purpose: if significant *pre-trends* appear here, it confirms the design depends on proximity — and that a far sample does **not** solve selection bias.

- **Placebo-treatment test**: apply the identical estimation to a setting with treatment's *circumstances but not its substance*.
  - Three requirements: (1) mimics the real estimation, (2) actual treatment is absent, (3) the confounding circumstances (how the group was selected, coincident events) are still present. A purely random placebo fails requirement 3 (though randomness helps *inference* — see Ch 5/8).

## Key Concepts
- **Reference / omitted year**: the period against which all event-study coefficients are measured (here 2001, the year before treatment).
- **Confounding treatment**: an event coinciding with treatment (e.g., new-state *formation*) that could be mistaken for the policy's effect.
- **Comparison window**: distance band defining the sample (10 km = main; 35–45 km = far-apart falsification).
- **reghdfe / Correia (2016)**: the high-dimensional FE estimator used for the regressions.

## Mental Models
- The event study is the single most persuasive DID exhibit — flat pre-trends + a sharp post jump is more convincing (and more communicable to policymakers) than any table.
- A good placebo isolates *one* alternative explanation; here Jharkhand isolates "does merely creating a new state move lights?"
- Use the far-apart test as a deliberate *failure* demonstration: it shows your design only works near the boundary.

## Worked Example
**The three diagnostics in Uttarakhand:**
1. *Event study (Figure 4, 10 km band):* pre-2002 coefficients ≈ 0 with CIs covering zero (parallel trends); post-2002 coefficients turn positive immediately and keep growing → effect appears only after the policy.
2. *Far-apart (Figure 5, 35–45 km band):* several pre-treatment coefficients are significant and negative (treated areas were poorer relative to 2001) — i.e., trends already diverged before treatment. Conclusion: a far sample does *not* fix selection bias.
3. *Placebo state (Figure 6, Jharkhand):* Jharkhand was carved from Bihar within weeks of Uttarakhand but received *no* place-based policy. Running the same event study shows essentially no impact at 2002 (a few small, insignificant positives a decade later) — nothing like Uttarakhand's immediate, large jump. This rules out "new-state formation" as the driver.

**Headline result (Table 2, col. 1):** β̂ = 2.209*** (SE 0.604, clustered within subdistrict) — a large, significant increase in nighttime lights in treated cells after 2002.

## Key Takeaways
1. Estimate the collapsed-period DID (Eq. 14) on a tight (10 km) boundary band; confirm robustness to full yearly dummies.
2. Always show an event study (Eq. 15) with CIs relative to a reference year — flat pre, jump post.
3. Use a far-apart sample as a falsification: pre-trends should *reappear* there.
4. Use a same-circumstances placebo (new state, no policy) to rule out confounding treatments; random placebos don't serve this purpose.

## Connects To
- **Ch 2**: event study and placebos are the empirical defense of PTA and against confounders.
- **Ch 6**: the 10 km band and cell FE come from the remote-sensing design.
- **Ch 8**: how the SE for that β̂ (and the choice of subdistrict clustering) is justified.
