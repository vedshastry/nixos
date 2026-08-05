---
name: spatial-did
description: "Knowledge base from \"Spatial Difference-in-Differences\" by Martinez-Iriarte, Leung & Shenoy (2026). Use when applying their frameworks for spatial DID design, parallel trends, clustered/Conley spatial-HAC standard errors, placebo & Monte Carlo inference, event studies, or remote-sensing (nighttime lights) outcomes."
---

<!-- argument-hint: [topic, framework name, or chapter number] -->

# Spatial Difference-in-Differences
**Authors**: Julian Martinez-Iriarte, Michael Pak-shing Leung, Ajay Shenoy (UC Santa Cruz) | **Pages**: ~36 | **Chapters**: 9 (section-derived) | **Generated**: 2026-06-18

## How to Use This Skill

- **Without arguments** — load the core frameworks below for reference.
- **With a topic** — ask about `parallel trends`, `Conley SE`, `clustering`, `event study`, `placebo Monte Carlo`, `overglow`; I read the relevant chapter.
- **With a chapter** — ask for `ch05`; I load that file.
- **Browse** — ask "what chapters do you have?" for the index.

When you ask about a topic not in Core Frameworks below, I read the relevant chapter file before answering. See also `cheatsheet.md` (decision rules + Monte Carlo size table), `patterns.md` (techniques), `glossary.md` (terms).

---

## Core Frameworks & Mental Models

**Two-criteria test for "spatial DID"** — you must adjust inference when **both**: (1) the outcome has high spatial dependence, and (2) the sample is tightly clustered in space. Place-based policies meet both by construction. One criterion only (e.g., a nationwide random sample) → standard DID inference usually suffices. (Ch 1)

**TWFE model & estimand** — `Yit = Di·Qt·β + φi + δt + εit`. `Di` = treated group, `Qt` = post indicator (`t ≥ t*`), `φi`/`δt` = unit/time FE. β targets the **ATT** = `E[Yit1(1) − Yit1(0) | Di=1]`. β̂ (Goodman-Bacon closed form) is a **difference of treated-vs-control trends**. (Ch 2–3)

**Parallel trends (PTA)** — `E[ΔYit(0)|D=1] = E[ΔYit(0)|D=0]`: treated counterfactual trend = control observed trend. Gives unbiasedness and turns the ATT into four sample means. Defend institutionally **and** test (event study, placebo). (Ch 2)

**SUTVA / spillovers** — to read β as the ATT, treatment must not affect controls. **Positive spillovers** (commuting jobs, herd immunity) shrink the gap → *underestimate*; **negative spillovers** (firms relocate to treated side) inflate it → *overestimate*. Border designs invite both — run the spillover border test. (Ch 2)

**Why inference breaks** — positive correlation adds `C>0` to the true variance that i.i.d./HC formulas omit, so default SEs are too small and t-tests over-reject (Bertrand et al.: up to 45% rejection of a true null). Think in **effective sample size**, not raw n. All valid methods are choices of how to estimate Σ in the sandwich `Λ⁻¹ΣΛ⁻¹` — i.e., **which pairs of observations may be correlated**. (Ch 4)

**Inference method menu** (choose by belief, then verify by Monte Carlo): (Ch 5)
- **Cluster** at/above the unit of treatment; one-way (serial corr.) or two-way (space+time). Higher aggregation = more robust, less precise; effective n = #clusters.
- **Spatial HAC (Conley)** when correlation *decays with distance*; pick bandwidth `h` from a correlogram (smallest lag where corr ≈ 0); apply the PSD eigen-fix for negative variances. Very sensitive to `h` and to having enough *time* lags.
- **Few clusters (<50)**: wild cluster bootstrap (≥5, needs within-cluster treatment variation), approximate randomization (≥8, heterogeneity-robust), or permutation inference (finite-sample valid, needs homogeneity).

**Choose SEs by size, not significance** — decide *before* seeing results. Quick check: **placebo-in-time** (pretend an earlier year is treatment; a good SE should not reject). Definitive: **placebo Monte Carlo** — generate many fake treatments matching the real spatial/temporal structure, pick the method whose rejection rate is nearest 5% (slightly conservative preferred). In the book's application, **temporal autocorrelation dominated spatial**: cell/subdistrict clustering well-sized (~.04), district-year disastrous (.30). (Ch 8)

**Remote-sensing hazards** — **satellite drift** (satellite-year FE remove only the average gap; rely on spatial smoothness/border differencing) and **overglow** (attenuates β *and* inflates spatial correlation → widen HAC bandwidth / coarsen clusters). (Ch 6)

**Empirical workflow** — collapsed-period DID (Eq. 14) on a ~10 km boundary band → **event study** (flat pre, jump post, vs. a reference year) → **far-apart falsification** (pre-trends should reappear) → **placebo-state test** (new state, no policy → no effect rules out confounders). (Ch 7)

**Extensions** — staggered timing breaks plain TWFE (negative weights / forbidden comparisons → use modern estimators); spatial diff-in-discontinuities; spatial first differences (cross-sections); synthetic control when PTA is implausible. (Ch 9)

---

## Chapter Index

| # | Title | Key Frameworks |
|---|-------|----------------|
| [ch01](chapters/ch01-when-did-is-spatial.md) | When a DID is "Spatial" | two-criteria test, place-based policy, level-vs-trend |
| [ch02](chapters/ch02-model-causal-interpretation.md) | Model & Causal Interpretation | TWFE, ATT, parallel trends, SUTVA/spillovers |
| [ch03](chapters/ch03-did-regression-estimator.md) | The DID Regression & OLS Estimator | indicator regression, Goodman-Bacon closed form, bias decomposition |
| [ch04](chapters/ch04-why-inference-breaks.md) | Why Inference Breaks | covariance term C, effective sample size, sandwich Σ, correlograms |
| [ch05](chapters/ch05-methods-for-inference.md) | Methods for Inference | clustering, spatial HAC/Conley, wild bootstrap, randomization, permutation |
| [ch06](chapters/ch06-remote-sensing-challenges.md) | Research Design & Remote-Sensing | boundary band, satellite drift, overglow, spatial smoothness |
| [ch07](chapters/ch07-empirical-application.md) | Empirical Application | Eq.14/15, event study, far-apart falsification, placebo state |
| [ch08](chapters/ch08-choosing-inference-monte-carlo.md) | Choosing Inference: Placebos & MC | placebo-in-time, placebo Monte Carlo, rejection-rate table |
| [ch09](chapters/ch09-extensions-further-reading.md) | Extensions & Further Reading | staggered DID, diff-in-discontinuities, spatial first differences, synthetic control |

## Topic Index

- **ATT / estimand** → ch02
- **Bandwidth selection (h)** → ch05, ch08
- **Boundary-band design** → ch06, ch07
- **Clustered standard errors** → ch04, ch05, ch08
- **Conley / spatial HAC** → ch05, ch08
- **Correlograms / autocorrelation** → ch04, ch05
- **Effective sample size** → ch04, ch05
- **Event study** → ch07
- **Few clusters** → ch05
- **Goodman-Bacon decomposition** → ch03
- **Identification assumption** → ch06, ch02
- **Monte Carlo / rejection rates** → ch08
- **Nighttime lights / satellites** → ch06
- **Overglow** → ch06
- **Parallel trends** → ch02, ch07
- **Placebo tests** → ch07, ch08
- **PSD correction (HAC)** → ch05
- **Randomization / permutation inference** → ch05
- **Remote sensing** → ch06
- **Sandwich variance / Σ** → ch04, ch05
- **Spatial first differences** → ch09
- **Spillovers / SUTVA** → ch02
- **Staggered DID** → ch09
- **Synthetic control** → ch09
- **TWFE model** → ch02, ch03
- **Two-way clustering** → ch05, ch08
- **Unit of treatment** → ch05, ch08
- **Wild cluster bootstrap** → ch05

## Supporting Files

- [glossary.md](glossary.md) — all key terms with definitions and chapter pointers
- [patterns.md](patterns.md) — the design & inference techniques as reusable recipes
- [cheatsheet.md](cheatsheet.md) — decision rules, thresholds, the Monte Carlo size table, tells & smells

---

## Scope & Limits

Covers the book chapter only (canonical, common-timing spatial DID and its inference). For staggered-timing estimators, synthetic control, or diff-in-discontinuities, this skill points to the literature but does not implement them. For hands-on estimation in your own Stata/Python pipeline, combine with project-specific tools (e.g., `reghdfe`, `acreg` for Conley SEs).
