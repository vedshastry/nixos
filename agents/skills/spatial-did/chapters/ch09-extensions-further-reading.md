# Chapter 9: Extensions & Further Reading

## Core Idea
The chapter covers the *canonical* DID (one treatment group, common timing). Real applications often need extensions: staggered timing (beware negative weights / forbidden comparisons), spatial diff-in-discontinuities, spatial first differences for cross-sections, and synthetic-control methods when parallel trends fails.

## Frameworks Introduced
- **Staggered DID**: when treatment timing *varies* across units, the plain TWFE estimator is a weighted average of treatment effects with possibly **negative weights** → the estimand can flip sign even if every unit-level effect is positive.
  - Why: TWFE makes "forbidden comparisons" of already-treated units against later-treated units, not just treated-vs-untreated ("clean") comparisons.
  - What to do: use modern staggered estimators and reformulate parallel trends (de Chaisemartin & d'Haultfœuille, 2023; Roth et al., 2023).

- **Spatial difference-in-discontinuities**: a hybrid of regression discontinuity and DID, natural when treated/control are geographically adjacent. Typically requires *weaker* assumptions than either design alone (see Ch. 14 of the book; Shenoy 2018).

- **Spatial first differences (Druckenmiller & Hsiang, 2018)**: for purely cross-sectional spatial data, eliminate fixed effects by subtracting each observation's value from that of a *spatially adjacent* observation (proximate units share similar fixed effects).

- **Synthetic control (SC) & synthetic DID**:
  - **SC** (Abadie & Gardeazabal, 2003; Abadie 2021): use a donor pool of controls to construct a weighted "synthetic" control matching the treated unit's *pre-treatment trend*; compare post-treatment. Best when there are few treated units and parallel trends is *unlikely* to hold.
  - **Synthetic DID** (Arkhangelsky et al., 2021): matches the pre-trend *up to an additive shift* — a different, often more flexible, kind of match.

## Key Concepts
- **Forbidden comparison**: a TWFE contrast using already-treated units as controls; source of negative-weight bias under staggered timing.
- **Clean comparison**: treated vs. never/not-yet-treated — the only contrasts you want.
- **Donor pool**: candidate control units combined into a synthetic control.
- **Diff-in-discontinuities**: RD × DID hybrid for adjacent treated/control geographies.

## Mental Models
- Staggered timing ≠ "just add more periods" — the *weights* change and can mislead; switch estimators rather than trusting TWFE.
- When parallel trends is implausible but you have a long pre-period and few treated units, reach for synthetic control instead of forcing DID.
- For cross-sections with no time dimension, "difference against your neighbor" (spatial first differences) is the spatial analog of differencing out fixed effects over time.

## Anti-patterns
- **Using plain TWFE with staggered adoption**: negative weights can reverse the sign of the estimate.
- **Forcing DID when pre-trends clearly diverge**: a synthetic-control match may be the honest choice.

## Key Takeaways
1. With staggered timing, avoid plain TWFE; use de Chaisemartin–d'Haultfœuille / Roth et al. estimators and a reformulated PTA.
2. Adjacent treated/control geographies → consider spatial diff-in-discontinuities (weaker assumptions).
3. Cross-sectional spatial data → spatial first differences to absorb fixed effects.
4. Few treated units and shaky parallel trends → synthetic control or synthetic DID.

## Connects To
- **Ch 2**: parallel trends must be *reformulated* under staggered timing.
- **Ch 6**: diff-in-discontinuities builds on the same boundary-band geography.
- **Spillovers (Ch 2)**: Xu (2025) treats DID with interference, relevant when SUTVA fails.
