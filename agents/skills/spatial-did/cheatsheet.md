# Cheatsheet — Spatial DID (decisions, thresholds, tells)

## Is this even a "spatial" DID? (do I need special inference?)
- Spatial DID **iff** (1) outcome is spatially dependent **AND** (2) sample is tightly clustered. Both → use clustered/HAC/randomization SEs. Place-based policies almost always qualify.
- One criterion only (e.g., national random sample) → standard DID inference is usually fine.

## Which standard-error method? (decision rules)
- **Default rule**: cluster at the **unit of treatment, if not larger**.
- Many groups, clear clustering level → **cluster** (one-way for serial corr.; two-way for spatial+temporal).
- Believe correlation **decays with distance** (not hard boundaries) → **spatial HAC (Conley)**; tune `h` from correlogram.
- **Few clusters (<50 either dim)** → stop trusting cluster SEs:
  - ≥5 clusters → **wild cluster bootstrap** (need within-cluster treatment variation; pair treated/control subregions).
  - ≥8 clusters, heterogeneous → **approximate randomization** (Canay-Romano-Shaikh).
  - want finite-sample validity, homogeneous effects → **permutation inference** (permute group membership; aggregate to cluster means if spatially correlated).
- **No obvious clustering level** → run a **placebo Monte Carlo** and pick the method nearest 5%.

## Choosing it honestly
- Decide the method **before** seeing results (or at least not conditioned on the p-value it yields).
- Prefer **slightly conservative** (size just above 0.05) over over-rejecting.
- Never report plain "robust" (HC) SEs as if they handle clustering — they assume independence.

## Thresholds & defaults
| Quantity | Default / rule |
|---|---|
| Comparison band (main) | ~10 km from boundary |
| Far-apart falsification band | ~35–45 km |
| HAC bandwidth `h` (plug-in) | `n^{1/4}`; better: smallest lag where correlogram ≈ 0 |
| Cluster diameter | ≥ distance lag where spatial corr ≈ 0 |
| "Few clusters" danger zone | <50 in either dimension |
| Wild bootstrap floor | works at ~5 clusters |
| Approx. randomization floor | ~8 clusters |
| Nominal test size target | 0.05 |
| Group-cluster effective n | = number of clusters |

## Monte Carlo size results (this application, target 0.05) — what to copy as priors
| Method | Rej. rate | Verdict |
|---|---|---|
| Default / HC | .166 / .183 | over-reject badly — never |
| Conley (25 km,2 lag) | .092 | oversized — too few time lags |
| Conley (50 km,4 lag) | .061 | ok if tuned |
| Cell | .041 | well-sized (ignores space!) |
| Subdistrict | .039 | **chapter's choice** |
| District | .063 | mildly over (few clusters) |
| District-Year | .300 | **worst** — kills temporal corr. |
| Two-way Cell×District-Year | .068 | ≈ nominal |
| 0.2×0.2 grid | .032 | well-sized |

## Tells & smells
- Default/HC SEs reject but cluster/HAC don't → you have real autocorrelation; trust the adjusted ones.
- Event study with **significant pre-trends** → parallel trends suspect; don't claim causality.
- Far-apart band shows pre-trends but near band doesn't → design works only near the boundary (good).
- Cell clustering fine but district-year clustering over-rejects → **temporal** autocorrelation dominates spatial here.
- Negative variance from spatial HAC → apply PSD eigen-fix (`QΛ⁺Q'`).
- Adding sample size makes over-rejection worse, not better → undiagnosed positive correlation.
- Multi-satellite outcome with a break at treatment → suspect satellite drift, not an effect (satellite-year FE won't fully fix it).

## Remote-sensing gotchas
- **Satellite drift**: satellite-year FE remove only the *average* gap; rely on spatial smoothness (border design differences it out).
- **Overglow**: attenuates β (design problem, hard to fix) **and** inflates spatial correlation → widen HAC bandwidth / coarsen clusters (inference fix).

## Spillover (SUTVA) quick test
- Redefine border-adjacent *control* cells as "treated" vs. slightly-farther control cells → nonzero estimate reveals spillover sign. Positive spillover ⇒ you **under**estimate; negative ⇒ you **over**estimate.

## Staggered timing red flag
- Varying treatment timing + plain TWFE → negative weights / forbidden comparisons can flip the sign. Switch to de Chaisemartin-d'Haultfœuille / Roth et al. estimators.
