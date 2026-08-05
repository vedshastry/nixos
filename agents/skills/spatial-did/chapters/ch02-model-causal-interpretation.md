# Chapter 2: The Spatial DID Model & Causal Interpretation

## Core Idea
The spatial DID is the canonical two-way fixed-effects model `Yit = DiQt·β + φi + δt + εit`; β identifies the ATT only under **parallel trends** (for unbiasedness) plus **SUTVA / no-spillover** (to interpret β as a treatment effect rather than partly a harm to controls).

## Frameworks Introduced
- **Two-way fixed-effects (TWFE) outcome model**: `Yit = DiQt·β + φi + δt + εit`.
  - `Di` = treatment-group indicator (e.g., cell inside the new state); `Qt` = post-period indicator (`t ≥ t*`); `φi` = unit FE (time-constant geography/politics/endowments); `δt` = time FE (region-wide shocks); `β` = treatment effect on the treated cells post-policy.
  - When to use: the default estimator whenever a policy turns on at a known date `t*` for a fixed treated group.
  - How: regress outcome on the `Di·Qt` interaction plus unit and time dummies; identifying condition `E[εit | Di, Qt, φi, δt] = 0` (local shocks unrelated to the policy).

- **ATT estimand**: `ATT = E[Yit1(1) − Yit1(0) | Di = 1]` — average effect on treated units in the post period. Identified as a contrast of an observed quantity and an unobservable counterfactual.

- **Parallel trends assumption (PTA)**: `E[Yit1(0) − Yit0(0) | Di=1] = E[Yit1(0) − Yit0(0) | Di=0]` — the counterfactual trend of treated units equals the observed trend of controls.
  - When to use: the central identifying assumption; everything in research design (Ch 6) and the event-study/placebo tests (Ch 7) exists to defend it.
  - How it pays off: rearranging PTA recovers the unobserved counterfactual, so `ATT = E[ΔY|D=1] − E[ΔY|D=0]` — a difference in differences estimable from four sample means.
  - Failure mode: any factor that systematically hits treated units at `t*` other than the policy (e.g., coincident local policies) breaks PTA — trends diverge even absent treatment.

- **SUTVA / no-spillover**: treatment must not affect the control group. Needed to read β as the ATT (and as the benefit of applying the policy elsewhere).
  - Two parts (Uttarakhand): (1) no direct policy change in the control state; (2) no indirect economic spillover onto controls.
  - Failure mode: positive spillovers (commuting jobs, reduced infection nearby) shrink the treated–control gap → **underestimate**; negative spillovers (firms relocate to treated side, harming controls) inflate the gap → **overestimate**.

## Key Concepts
- **Potential outcomes**: `Yit(1)`, `Yit(0)`; observed `Yit = DiQt·Yit(1) + (1−DiQt)·Yit(0)`; causal effect = `Yit(1) − Yit(0) = β` under model (1).
- **Fundamental problem of causal inference**: only one potential outcome is ever observed per unit; forces focus on averages (ATT).
- **Unit FE φi**: absorbs the un-interacted `Di` (a cell is permanently in/out of the treated state).
- **Spillover effects**: indirect transmission of treatment to controls via pre-existing economic/social ties.

## Mental Models
- Think of PTA as "the green (control) line is parallel to the red (treated counterfactual) line"; the observed blue (treated factual) line = red + treatment effect.
- Use the **extreme-policy thought experiment** to test SUTVA: imagine a policy that only *harms* controls and gives nothing to treated — you'd still estimate β > 0. If your setting admits such transmission, β ≠ ATT.
- Proximity is a double-edged sword: it buys parallel trends but, via neighborly ties, also raises spillover risk.

## Anti-patterns
- **Claiming the ATT when spillovers are plausible**: with border-band designs spillovers are likely; report a spillover test rather than asserting SUTVA.
- **Defending PTA by assertion only**: PTA needs both institutional argument *and* data tests (event study, placebo).

## Worked Example
**Recovering the counterfactual under PTA.** Two periods `t0 < t1`, policy at `t1`.
- Want `E[Yt1(0)|D=1]` (treated counterfactual, unobserved).
- PTA says treated and control share the *change* absent treatment, so:
  `E[Yt1(0)|D=1] = E[Yt0|D=1] + E[Yt1 − Yt0 | D=0]` — all terms observed.
- Therefore `ATT = E[Yt1 − Yt0 | D=1] − E[Yt1 − Yt0 | D=0]` = the difference of two trends = four sample means (treated/control × pre/post).

**SUTVA stress test (firm relocation):** if Uttarakhand's tax breaks pull firms across the border, control cells lose activity, the treated–control gap widens, and β overstates the true effect. The book's border-distance test (compare control cells just inside the border vs. control cells slightly farther) probes which spillover dominates.

## Key Takeaways
1. β = ATT requires *both* PTA (unbiasedness) and SUTVA (interpretability).
2. PTA is about trends, not levels; it converts the ATT into four estimable means.
3. Positive spillovers bias β down; negative spillovers bias β up; border designs invite both.
4. Always pair institutional justification of PTA with data-based diagnostics.

## Connects To
- **Ch 3**: the regression form and closed-form β̂ that operationalize this model.
- **Ch 5 (randomization)**: a *strong* PTA (`Zi` i.i.d. over i) underpins permutation tests.
- **Ch 7**: event-study and placebo tests that defend PTA and SUTVA empirically.
