# Chapter 4: Why Inference Breaks — Spatial & Temporal Correlation

## Core Idea
Positive correlation among observations (across space and time) adds positive covariance terms to the true variance that i.i.d. formulas ignore; this makes default and heteroskedasticity-robust SEs too small, confidence intervals too narrow, and t-tests over-reject — sometimes catastrophically.

## Frameworks Introduced
- **The covariance term C**: with dependence, `Var(μ̂) = σ²/n + C`, where `C = n⁻²ΣΣ_{i≠j} Cov(Yi,Yj)`. If data are positively correlated, `C > 0`, so the i.i.d. formula `σ²/n` understates variance and overstates precision.
  - When to use: the core diagnostic intuition for *why* you need clustered/HAC SEs.
  - How to reason: positive correlation shrinks the **effective sample size** — in the extreme of perfect correlation, `μ̂ = Y1` with variance `σ²`, so adding observations buys nothing (effective n = 1).

- **The general sandwich variance**: `Var(θ̂|X) = Λ⁻¹ΣΛ⁻¹`, with `Λ = (1/nT)Σ Xit Xit'` and `Σ = (nT)⁻²Var(Σ Xit εit | X)`. The "true SE" of β̂ is the square root of the treatment diagonal of this matrix; all inference methods differ only in how they estimate **Σ**.
  - When to use: the unifying frame — clustering, HAC, etc. are all choices of how to estimate Σ.

- **Σ has two parts**: a variance part `(nT)⁻²Σ E[ε²it|Xit]Xit Xit'` plus a **covariance part** over all distinct pairs `(it),(js)`. With i.i.d. errors the covariance part is zero and Σ̂ reduces to the heteroskedasticity-robust `Σ̂_HC = (nT)⁻²Σ ε̂²it Xit Xit'`. When errors are correlated, the omitted covariance terms make HC SEs too small.

## Key Concepts
- **Effective sample size**: the information content of the sample after accounting for correlation; far below n when dependence is high.
- **Heteroskedasticity-robust (HC) variance**: `Λ⁻¹Σ̂_HC Λ⁻¹` — robust to non-constant variance but still assumes *independence*; invalid under spatial/temporal correlation.
- **Temporal autocorrelation**: correlation between a unit's residuals across years (`ε̂it`, `ε̂i,t+k`).
- **Spatial autocorrelation**: correlation between residuals of different units at a given lag distance (km).
- **Correlogram / autocorrelation plot**: residual correlation as a function of time-lag (years) or distance-lag (km); used to *see* the dependence and to pick HAC/cluster parameters.

## Mental Models
- "Correlation reduces precision by shrinking the effective amount of information." More rows ≠ more information when rows move together.
- Treat the residual correlograms as the empirical fingerprint of your dependence: read off the lag at which correlation hits ~0 and let it drive your bandwidth/cluster size (see Ch 5).
- Both dimensions matter, but their relative severity is an *empirical* question for your data (in the book's application, temporal turned out worse than spatial — see Ch 8).

## Anti-patterns
- **Reporting HC ("robust") SEs as if they handle clustering**: they only fix heteroskedasticity; they assume independence and badly understate SEs here.
- **Assuming bigger n cures the problem**: with positive correlation, larger samples can make over-rejection *worse* (MacKinnon, 2023), not better.

## Worked Example
**The Bertrand–Duflo–Mullainathan (2004) placebo demonstration.** Using state-level wage data, they randomly assign fake treatment states and years (true effect = 0) and run t-tests with independence-assuming SEs. A correctly sized 5% test should reject ~5% of the time; instead they find rejection rates **as high as 45%**. Cause: serial (temporal) correlation makes the covariance terms in Σ positive, so the assumed SEs are far below the truth. Barrios et al. (2012) show the analogous result for *spatial* correlation in US Census earnings/education/hours across PUMAs and states.

In the book's own application, the residual correlograms (Figure 2) show strong positive **temporal** correlation below ~5-year lags and substantial **spatial** correlation below ~10 km — concrete evidence both adjustments are needed.

## Key Takeaways
1. Positive dependence adds `C > 0` to the variance; i.i.d./HC SEs omit it and are too small.
2. All valid methods are just different estimators of Σ in the `Λ⁻¹ΣΛ⁻¹` sandwich.
3. Think in *effective* sample size, not raw n.
4. Use residual correlograms to quantify temporal (years) and spatial (km) dependence before choosing a method.

## Connects To
- **Ch 5**: the menu of Σ estimators (clustering, spatial HAC, randomization) that restore valid inference.
- **Ch 7–8**: the application's correlograms and the Monte Carlo that ranks methods by rejection rate.
