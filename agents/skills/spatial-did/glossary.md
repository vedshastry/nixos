# Glossary — Spatial Difference-in-Differences

**ATT (Average Treatment effect on the Treated)** — `E[Yit1(1) − Yit1(0) | Di=1]`; the estimand DID targets (Ch 2).

**Bandwidth (h)** — distance threshold in spatial HAC; pairs closer than `h` get nonzero weight. Plug-in `h = n^{1/4}` or correlogram-driven (Ch 5).

**Boundary-band design** — restricting the sample to cells within a short distance (e.g., 10 km) of a border, comparing just-inside vs. just-outside (Ch 6).

**Cluster** — set of observations allowed to be mutually correlated; cross-cluster independence is assumed (Ch 5).

**Cluster-robust SE** — sandwich SE with `wit,js = 1` within-cluster, 0 otherwise (Ch 4–5).

**Comparison window** — distance band defining the sample; 10 km (main) vs. 35–45 km (far-apart falsification) (Ch 7).

**Confounding treatment** — an event coinciding with treatment (e.g., new-state formation) mistakable for the effect (Ch 7).

**Conley SE** — spatial HAC standard errors (Conley 1999); reported with (distance km, time lag) parameters (Ch 5, 8).

**Correlogram / autocorrelation plot** — residual correlation vs. time-lag (years) or distance-lag (km); used to pick HAC/cluster parameters (Ch 4).

**DID regression** — `Yit = α + DiQt·β + Σφj·Pji + Σδs·Pst + εit` (Ch 3).

**Diff-in-discontinuities** — RD × DID hybrid for adjacent treated/control geographies (Ch 9).

**Donor pool** — candidate controls combined into a synthetic control (Ch 9).

**Effective sample size** — information content after accounting for correlation; for cluster SEs ≈ number of clusters (Ch 4–5).

**Event study** — plot of `{β̂_s}` with CIs vs. year relative to a reference year (Eq. 15); tests pre-trends (Ch 7).

**Far-apart falsification** — event study on a distant band where pre-trends should reappear if the design relies on proximity (Ch 7).

**Fishnet grid / cell** — 0.1°×0.1° lat-lon cells; the unit of analysis (Ch 6).

**Forbidden comparison** — TWFE contrast using already-treated units as controls; negative-weight source under staggered timing (Ch 9).

**Goodman-Bacon closed form** — β̂ as a difference of treated-vs-control average trends (Ch 3).

**Group** — level at which `Di` varies (e.g., state); candidate clustering level (Ch 5).

**HAC (Heteroskedasticity & Autocorrelation Consistent)** — variance estimator allowing correlation that decays with distance/time (Ch 5).

**Heteroskedasticity-robust (HC) SE** — robust to non-constant variance but assumes independence; invalid under spatial/temporal correlation (Ch 4).

**Identification assumption** — conditions making parallel trends hold in a given setting (Ch 6).

**Nighttime lights (DMSP/VIIRS)** — remotely-sensed proxy for economic activity (Ch 6).

**One-way clustering** — clustering in a single dimension (e.g., by unit, allowing serial correlation) (Ch 5).

**Overglow** — light spilling from one cell into neighbors; attenuates estimates and inflates spatial correlation (Ch 6).

**Parallel trends (PTA)** — treated counterfactual trend = control observed trend; core identifying assumption (Ch 2).

**Placebo-in-time test** — pretend an earlier year is treatment; a well-sized SE should not reject (Ch 8).

**Placebo Monte Carlo** — many fake treatments matching real spatial/temporal structure; reports each method's rejection rate (Ch 8).

**Placebo test (state)** — apply the estimation to a setting with treatment's circumstances but not its substance (e.g., Jharkhand) (Ch 7).

**Potential outcomes** — `Yit(1)`, `Yit(0)`; only one is observed per unit (Ch 2).

**PSD correction** — eigen-fix for non-positive-semidefinite spatial HAC: zero negative eigenvalues → `QΛ⁺Q'` (Ch 5).

**Reference / omitted year** — baseline period in an event study (coefficient = 0 by construction) (Ch 7).

**Rejection rate (size)** — fraction of placebo sims rejecting the true null; target 0.05 (Ch 8).

**reghdfe** — high-dimensional FE estimator (Correia 2016) used for the regressions (Ch 7).

**Sandwich variance** — `Var(θ̂|X) = Λ⁻¹ΣΛ⁻¹`; methods differ in how they estimate Σ (Ch 4).

**Satellite drift** — different satellites read different values at the same place/time; satellite-year FE only remove the average gap (Ch 6).

**Spatial dependence** — correlation in outcomes/errors between nearby units (Ch 1, 4).

**Spatial first differences** — absorb FE in cross-sections by differencing against a neighbor (Druckenmiller–Hsiang) (Ch 9).

**Staggered DID** — varying treatment timing; plain TWFE yields possibly negative weights (Ch 9).

**Strong parallel trends** — `Zi` (unit trend in potential outcomes) i.i.d. over i; underpins permutation tests (Ch 2, 5).

**SUTVA / no-spillover** — treatment doesn't affect controls; needed to read β as the ATT (Ch 2).

**Spillover effects** — indirect transmission to controls; positive → underestimate, negative → overestimate (Ch 2).

**Synthetic control (SC) / synthetic DID** — donor-pool match to the pre-trend; for few treated units / shaky PTA (Ch 9).

**Test inversion** — building a CI from the β* grid not rejected (used with bootstrap/randomization p-values) (Ch 5).

**Two-way clustering** — correlated if sharing a spatial *or* temporal cluster (Ch 5).

**TWFE (two-way fixed effects)** — `Yit = DiQt·β + φi + δt + εit` (Ch 2).

**Unit of treatment** — level at which `Di` varies; the rule-of-thumb minimum clustering level (Ch 5, 8).

**Wild (cluster) bootstrap** — ±1 residual resampling for few clusters (≥5); yields a p-value, needs within-cluster treatment variation (Ch 5).
