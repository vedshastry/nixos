# Chapter 8: Choosing the Inference Method — Placebos & Monte Carlo

## Core Idea
Don't pick a SE method by which one gives significance. Pick it *before* seeing results using two tools: a single **placebo-in-time** test (does the method falsely reject when there's no effect?) and, definitively, a **placebo Monte Carlo** that generates many fake treatments matching the real spatial/temporal structure and reports each method's **rejection rate** — the right answer is the one closest to nominal 5%.

## Frameworks Introduced
- **Placebo-in-time test for SE size**: discard all post-treatment data and pretend an earlier year (here 1996) is treatment. Since no real treatment exists in this window, a properly-sized estimator should **fail to reject** the true null.
  - When to use: a quick, single-shot check of whether candidate SEs are adequately conservative in *your* data.
  - Limitation: one draw only — even a correctly sized test rejects 5% of the time, and an undersized test can correctly reject by luck. Suggestive, not definitive.

- **Placebo Monte Carlo (the gold standard)**: build fake treatments whose spatial/temporal correlation *matches the real design*, where the true effect is known to be zero, then estimate the rejection rate of each SE method over many simulations.
  - How (book's implementation): use an *unchanged* region (Maharashtra, borders fixed since 1960); for each of 1000 sims, pick a random point on the true boundary and designate all cells within a random radius as a placebo "new state"; restrict to cells within 10 km of the placebo boundary; pick a random treatment year; estimate Eq. 14. Expected rejection ≈ 5%.
  - Why it beats the single placebo: it samples the *distribution* of rejections, so it measures true size rather than one realization.

- **Cluster-at-unit-of-treatment rule of thumb (and its limits)**: cluster at the level where `Di` varies, if not larger. In the application this is muddy — is the unit the whole state, or the subdistrict (where industrial estates / tax breaks actually concentrated)? Because `Di` doesn't vary within the treated state, the heuristic alone can't settle it → fall back to the placebo/Monte Carlo evidence.

## Key Concepts
- **Rejection rate (size)**: fraction of placebo simulations where a method rejects the true null; nominal target = 0.05.
- **Over-sized / under-sized test**: rejects too often (SEs too small) / too rarely (SEs too conservative).
- **Conley (HAC) parameters**: the (distance km, time-lag years) thresholds; results are very sensitive to them.
- **Confounding the choice with the result**: choosing the SE method after seeing which gives significance — to be avoided; commit beforehand.

## Mental Models
- "If there's no obvious unit of clustering, run a Monte Carlo." It is the most informative way to choose, full stop.
- Read the rejection-rate table like a calibration plot: pick the method whose size sits closest to 0.05 from *above* (slightly conservative is safer than over-rejecting).
- HAC needs care: getting bandwidth/lags right is everything; let correlograms (Ch 4) set them and the Monte Carlo confirm them.

## Reference Tables
**Table 3 — Monte Carlo rejection rates (1000 sims, Maharashtra placebo; target = 0.05):**

| Method | Rejection rate |
|---|---|
| Unadjusted / default | .166 |
| Heteroskedasticity-robust | .183 |
| Conley HAC (25 km, 2 lag) | .092 |
| Conley HAC (50 km, 4 lag) | .061 |
| Clustered within Cell | .041 |
| Clustered within Subdistrict | .039 |
| Clustered within District | .063 |
| Clustered within District-Year | .300 |
| Two-way: Cell & District-Year | .068 |
| Clustered within 0.2×0.2 grid | .032 |

## Worked Example
**Reading Table 3 to choose a method.**
- *Default & HC errors* over-reject massively (.166, .183) — 3×+ the nominal size; confirms independence is untenable.
- *Subdistrict / Cell clustering* (.039, .041) and *0.2×0.2 grid* (.032) are correctly (even slightly conservatively) sized → defensible defaults; **subdistrict** is the chapter's choice.
- *District-Year clustering* is the **worst** (.300) and *Cell* clustering is fine (.041) **despite ignoring all spatial correlation** — so in this data **temporal autocorrelation is more pernicious than spatial**. District-Year allows spatial but kills temporal correlation, and fails badly.
- *Conley HAC* is oversized unless tuned (.092 at 25 km/2 lag; .061 at 50 km/4 lag) — too few time lags to handle the fixed-effects-induced temporal autocorrelation. Lesson: with HAC, parameters are decisive.
- *District clustering* slightly over-rejects (.063), likely too-few/large clusters.
- *Two-way (Cell & District-Year)* comes closest to nominal (.068, ~5%).

Cross-check with the single placebo-in-time (Table 2, col. 2): the preferred subdistrict clustering *fails to reject* (p = .25), while default/HC and several spatial-only methods reject — consistent with the Monte Carlo.

## Key Takeaways
1. Choose the SE method *before* seeing the result, by size — not by significance.
2. The placebo-in-time is a fast sanity check; the placebo Monte Carlo is the definitive size test.
3. Build placebo treatments that *match the real spatial/temporal structure* (random border segment + random radius + random year in an unchanged region).
4. In this application temporal autocorrelation dominates spatial; cell/subdistrict clustering and the lat-lon grid are well-sized; district-year is disastrous.
5. HAC is only as good as its bandwidth and lags — tune from correlograms, verify by Monte Carlo, apply the PSD fix.

## Connects To
- **Ch 4**: correlograms diagnose the dependence that the Monte Carlo then prices into rejection rates.
- **Ch 5**: this chapter ranks the very methods defined there.
- **Ch 7**: justifies the subdistrict-clustered SE on the headline β̂ = 2.209.
