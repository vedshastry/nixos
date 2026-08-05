# Patterns & Techniques — Spatial DID

## Boundary-Band Research Design
**When to use**: a policy switches on at an administrative boundary created shortly before treatment.
**How**: restrict the sample to cells within a short distance (e.g., 10 km) of the boundary; treated = just inside, control = just outside; split boundary cells so outcomes aren't mis-attributed. Decompose the identification assumption into (i) similar pre-trends near the boundary and (ii) boundary formation itself was inert; defend both institutionally and test empirically.
**Trade-offs**: narrow band → credible parallel trends but smaller sample; wide band → pre-trends reappear (selection bias returns).

## Event Study (Eq. 15)
**When to use**: any DID with >2 periods.
**How**: regress on cell FE, year dummies, and `Di×year` interactions with one year omitted (reference, e.g., year before treatment); plot `{β̂_s}` ± 95% CI vs. year.
**Trade-offs**: needs ≥3 periods; flat-pre/jump-post is persuasive but not proof of identification.

## Far-Apart Falsification
**When to use**: to show the design depends on proximity.
**How**: rerun the event study on a distant band (e.g., 35–45 km). Significant pre-trends there → design only works near the boundary; far samples don't fix selection bias.
**Trade-offs**: a *negative* test — it demonstrates a failure mode, not a result.

## Placebo-State Test
**When to use**: to rule out a confounding treatment (e.g., new-state formation).
**How**: apply the identical estimation to a setting with treatment's *circumstances but not substance* (Jharkhand: new state, no policy). No effect there → the policy, not the circumstance, drives the result.
**Trade-offs**: needs a genuine same-circumstances comparator; random placebos don't satisfy this (they aid inference instead).

## Cluster-Robust SEs
**When to use**: default first resort for correlated errors.
**How**: cluster at/above the unit of treatment; one-way by unit (serial correlation), or two-way on cell & district-year (both dimensions). Set `wit,js = 1` within cluster.
**Trade-offs**: higher aggregation = more robust, less precise; effective n = #clusters; <50 clusters → unreliable.

## Spatial HAC (Conley)
**When to use**: you believe correlation *decays* with distance rather than stopping at a cluster edge.
**How**: choose bandwidth `h` (uniform kernel: `wit,js = 1` iff distance < `h`); set `h` from a correlogram/variogram (smallest lag where correlation ≈ 0) or `h = n^{1/4}`. Include enough *time* lags too. Apply PSD eigen-correction if variance is negative.
**Trade-offs**: very sensitive to `h` (bias–variance); too few time lags badly oversizes the test.

## Wild Cluster Bootstrap
**When to use**: few clusters (≥5).
**How**: impose the null, regress restricted outcome on FE, multiply cluster residuals by random ±1 over M draws, p-value = share of bootstrap stats exceeding observed; invert over a β grid for a CI. Needs within-cluster treatment variation (pair treated/control subregions) and cluster homogeneity.
**Trade-offs**: gives a p-value not an SE; breaks under heterogeneous clusters with controls.

## Approximate Randomization Test
**When to use**: few clusters (≥8) with heterogeneity.
**How**: estimate β per cluster → `Zℓ = √n(β̂ℓ − β*)`, build a t-stat, get a p-value by random sign flips of `Zℓ`.
**Trade-offs**: robust to heterogeneity; assumes homogeneous effects.

## Permutation / Randomization Inference
**When to use**: finite-sample valid test of `β=0`, even with few treated clusters.
**How**: re-permute group memberships, recompute β̂_b many times, p-value = share of `|β̂_b|` > `|β̂|`. Valid under strong PTA (`Zi` i.i.d. over i); if dependence is cluster-like, aggregate to cluster means and permute clusters.
**Trade-offs**: needs homogeneous effects and low cross-cluster heterogeneity; violated by spatial correlation unless aggregated.

## Placebo Monte Carlo for SE Selection
**When to use**: no obvious clustering level; to choose an inference method by *size*.
**How**: in an unchanged region, generate many fake treatments matching the real spatial/temporal structure (random boundary point + random radius + random year), estimate the rejection rate of each candidate SE; choose the one nearest nominal 5% (slightly conservative preferred).
**Trade-offs**: computationally heavy; the definitive way to choose. (Caveat: a placebo that permutes/destroys the real spatial structure can't test spatial correlation.)

## Spillover / SUTVA Border Test
**When to use**: to probe whether treatment affects controls.
**How**: redefine control-state cells nearest the border as "treated" and slightly-farther control-state cells as control; a nonzero estimate signals spillovers and reveals their sign (positive → underestimate; negative → overestimate the true effect).
**Trade-offs**: indicative of direction, not a full correction.
