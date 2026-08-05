# Chapter 5: Methods for Inference

## Core Idea
Every valid SE method is a choice of non-negative weights `wit,js` in the generic estimator `Σ̂` that decide *which pairs of observations are allowed to be correlated*. The menu — one/two-way clustering, spatial HAC, wild bootstrap, randomization/permutation — trades robustness (allowing more correlation) against precision (effective sample size).

## Frameworks Introduced
- **Generic weighted Σ̂**: `Σ̂ = (nT)⁻²Σ ε̂²it Xit Xit' + (nT)⁻²ΣΣ_{(js)≠(it)} wit,js·ε̂it ε̂js Xit Xjs'`, `wit,js ≥ 0`. Set `wit,js = 0` → HC. Choosing the weights *is* choosing the dependence model.

- **Cluster-robust SEs**: set `wit,js = 1` iff observations `it` and `js` share a cluster, else 0; SE = √(treatment diagonal of `Λ⁻¹Σ̂Λ⁻¹`).
  - **One-way (unit) clustering** — cluster by unit `i`: allows arbitrary *temporal* correlation within a unit's time series, assumes no cross-unit (spatial) correlation. Recommended by Bertrand et al. (2004) for serial correlation.
  - **Two-way clustering** — observations correlated if they share *either* a spatial cluster *or* a temporal cluster. Use when both spatial and temporal dependence are present (e.g., cluster on cell **and** district-year).
  - When to use: the default first resort; cluster at (or above) the **unit of treatment** if possible.

- **Group-level clustering rule & its two failure modes**: clustering at the **group** level (the level at which `Di` varies, e.g., state) is valid for *arbitrary* error correlation (Barrios et al. 2012) — **but** (1) treatments are often spatially correlated *across* groups, violating across-cluster independence; and (2) groups are often *few*, and the effective sample size for cluster SEs is the *number of clusters* (Hansen & Lee, 2019) — Card–Krueger has only 2 groups, leaving no power. Resolution: cluster at a *finer* administrative level (county/subdistrict/tract) chosen as the highest aggregation at which cross-cluster units are plausibly independent.

- **Spatial HAC (Conley)**: model correlation as *decaying* with distance rather than stopping at a cluster boundary. Uniform-kernel version: pick bandwidth `h`, set `wit,js = 1` iff distance(i,j) < h.
  - When to use: when the "arbitrary-within / zero-at-boundary" cluster assumption feels arbitrary; you believe correlation fades smoothly with distance.
  - How to pick `h`: plug-in `h = n^{1/4}` (Kelejian–Prucha), or data-driven via variogram/correlogram of first-period residuals — choose the smallest lag at which correlation ≈ 0. Bias–variance: larger `h` = less bias (more covariance captured) but a noisier, unstable variance estimate.
  - Pitfall & fix: spatial HAC isn't guaranteed positive-semidefinite (can give negative variances); fix by eigendecomposing `Σ̂ = QΛQ'`, zeroing negative eigenvalues → `Λ⁺`, and using `QΛ⁺Q'` (Cameron–Miller, 2015).

- **Wild (cluster) bootstrap (Cameron–Gelbach–Miller, 2008)**: for **few clusters** (works with as few as ~5). Imposes the null `β = β*`, regresses the restricted outcome on FE, then repeatedly multiplies cluster residuals by random ±1 (Rademacher) to build the null distribution of the test statistic; p-value = share of bootstrap stats exceeding the observed. Yields a *p-value*, not an SE → build CIs by **test inversion**.
  - Validity conditions (Canay–Santos–Shaikh, 2021): need treatment **variation within cluster** (so groups can't be the clusters — pair treated/control subregions, e.g., match each Uttarakhand district with a control-state district), and cluster **homogeneity** (controls can break this if covariate distributions differ across clusters — Ibragimov–Müller, 2016).

- **Approximate randomization test (Canay–Romano–Shaikh, 2017)**: robust to cluster *heterogeneity*. Estimate β separately in each cluster → `β̂ℓ`, form `Zℓ = √n(β̂ℓ − β*)`, build a t-statistic from `{Zℓ}`, and get a p-value by randomly flipping signs `πm,ℓ·Zℓ`. Works with as few as ~8 clusters (Cai et al., 2023).

- **Permutation / randomization inference (MacKinnon–Webb, 2020)**: under homogeneous effects, test `β=0` by re-permuting *group memberships* and recomputing β̂ many times; p-value = share of `|β̂b|` exceeding `|β̂|`. Finite-sample valid (any n) if `β̂b` shares β̂'s distribution — which holds under the **strong PTA**: `Zi = (1/T1)Σ Yit(1) − (1/T0)Σ Yit(0)` is i.i.d. over i. Spatial correlation violates i.i.d.; if dependence is cluster-like, **aggregate to cluster means** and permute clusters (valid under cluster-level parallel trends, plausible only with low cross-cluster heterogeneity).

## Key Concepts
- **Cluster**: a set of observations allowed to be mutually correlated; everything across clusters assumed independent.
- **Unit of treatment**: the level at which `Di` varies; the rule-of-thumb minimum clustering level.
- **Bandwidth `h`**: distance threshold beyond which spatial HAC sets correlation to zero.
- **Effective # clusters**: governs cluster-SE reliability; <50 in either dimension is the "few clusters" danger zone.
- **Test inversion**: building a CI by collecting all `β*` values not rejected across a grid.

## Mental Models
- "Higher aggregation = more robust but less precise." Choose the **highest** level of spatial aggregation at which cross-cluster units are reasonably independent.
- Clusters say "arbitrary correlation inside, zero outside"; HAC says "correlation decays smoothly with distance." Pick the story you actually believe.
- Few clusters? Stop trusting cluster SEs; move to wild bootstrap (≥5), approximate randomization (≥8, heterogeneity-robust), or permutation inference (finite-sample valid but needs strong homogeneity).

## Anti-patterns
- **Clustering at the group level with very few groups**: effective n = #groups; overly conservative, no power (Card–Krueger = 2).
- **Using groups as wild-bootstrap clusters**: no within-cluster treatment variation → invalid; pair treated/control subregions instead.
- **Picking HAC `h` arbitrarily**: SEs are very sensitive to `h`; always justify it from a correlogram/variogram.
- **Ignoring negative HAC variances**: apply the eigenvalue (PSD) correction rather than reporting a negative variance.

## Worked Example
**Choosing clusters from a correlogram.** Residual correlograms show spatial correlation vanishing by ~10 km. To cluster: choose spatial clusters whose *diameter is at least* that 10 km lag, so each cluster internalizes the dependence. The same ~10 km lag is a defensible data-driven `h` for a spatial-HAC bandwidth. For temporal dependence (correlated below ~5-year lags), cluster by unit (allows arbitrary serial correlation) or use a HAC time-lag of at least 5 years.

**Few-clusters fix (wild bootstrap).** With treatment varying only at the state level, you cannot cluster on states for the bootstrap. Pair each treated-state district with a distinct control-state district to form clusters that *contain* treatment variation, impose `β=0`, flip district residual signs ±1 over M draws, and read the p-value; invert over a β grid for the CI.

## Key Takeaways
1. All methods = choices of `wit,js`; decide *which pairs may be correlated* based on what you believe.
2. Cluster at/above the unit of treatment, but step down to a finer level when groups are few — robustness vs. precision.
3. Spatial HAC replaces hard cluster boundaries with smooth distance decay; `h` is consequential and correlogram-driven; apply the PSD fix.
4. With <50 clusters: wild bootstrap (≥5), approximate randomization (≥8, heterogeneity-robust), or permutation/randomization inference (finite-sample valid, needs homogeneity).
5. Don't pick by which method gives significance — pick by Monte Carlo size (Ch 8).

## Connects To
- **Ch 4**: defines the Σ these methods estimate and the over-rejection they cure.
- **Ch 8**: a placebo Monte Carlo that ranks all these methods by actual rejection rate in the application.
- **Ch 2**: the strong-PTA i.i.d. condition `Zi` that permutation tests rely on.
