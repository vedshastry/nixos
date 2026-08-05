# Chapter 3: The DID Regression & OLS Estimator

## Core Idea
Replacing the fixed effects with unit and time *indicator* variables turns the DID model into a single OLS regression on the `Di·Qt` interaction; the OLS β̂ has a closed form that is literally a difference of treated-vs-control *trends*, and is unbiased under the regression form of parallel trends.

## Frameworks Introduced
- **DID regression (indicator form)**: `Yit = α + DiQt·β + Σ φj·Pji + Σ δs·Pst + εit`, where `Pji = 1{j=i}` (unit dummies) and `Pst = 1{s=t}` (time dummies). Run this to get β̂ *and* convenient SEs from standard packages.
  - When to use: the practical workhorse — fixed effects via dummies (or an FE command like `reghdfe`) with T possibly > 2.
  - How: regress `Y` on the treatment interaction + unit indicators + time indicators; the coefficient on `Di·Qt` is the treatment effect.

- **Closed-form β̂ (Goodman-Bacon, 2021)**: β̂ is the treated group's average (post-mean − pre-mean) minus the control group's average (post-mean − pre-mean):
  - the inner term `(1/T1)Σ_{t≥t*} Yit − (1/T0)Σ_{t<t*} Yit` is unit *i*'s **trend** (post-minus-pre average);
  - β̂ contrasts treated vs. control average trends. With T=2 it reduces to the four-means DID.
  - Why it matters: makes transparent that DID is "difference of trends," and shows β̂ = β + (difference of average error trends), so unbiasedness rests entirely on the error condition.

## Key Concepts
- **N1, N0**: counts of treated and control units; **T1 = T − t***, **T0 = t* − 1**: post- and pre-treatment period counts.
- **Trend (unit-level)**: difference between a unit's average post- and pre-treatment outcome.
- **Regression PTA**: `E[εit | Di, Qt, φi, δt] = 0` ⇒ `E[β̂] = β` (unbiased).
- **Absorbing the level**: `Di` alone is collinear with the unit FE and drops out; only the `Di·Qt` interaction is identified.

## Mental Models
- Read β̂ as "how much faster did treated units' average level rise from pre to post, relative to controls."
- Estimating four sample means and running the regression give the *same* point estimate (T=2); use the regression mainly because packages hand you standard errors — but those default SEs are the thing you must fix (Ch 4–5).

## Anti-patterns
- **Including the bare `Di` term with unit FE**: it is mechanically collinear and will be dropped; only the interaction carries the effect.
- **Trusting package default SEs from this regression**: the point estimate is fine, but default SEs assume i.i.d. errors — invalid here.

## Worked Example
**Decomposition of bias.** Substituting model (1) into the closed form:
`β̂ = β + [ (1/N1)Σ_{treated}(ε-trend_i) ] − [ (1/N0)Σ_{control}(ε-trend_i) ]`,
where each `ε-trend_i = (1/T1)Σ_{t≥t*} εit − (1/T0)Σ_{t<t*} εit`. Under regression PTA the bracketed error-trend difference has mean zero, so `E[β̂] = β`. The same brackets, when errors are *correlated*, are exactly what inflates `Var(β̂)` — motivating Ch 4.

## Key Takeaways
1. Use the indicator/FE regression for estimation; the `Di·Qt` coefficient is the treatment effect.
2. β̂ is a difference of treated-vs-control *trends* (Goodman-Bacon closed form).
3. Unbiasedness depends only on the mean-zero error condition; **variance** depends on error correlation, handled separately.
4. The point estimate equals the four-sample-means DID when T=2.

## Connects To
- **Ch 2**: this is the operational form of the TWFE model and its identifying assumption.
- **Ch 4**: the error-trend brackets here are what spatial/temporal correlation inflates.
- **Ch 7**: Equation (14) — the empirical specification — collapses the time dummies into a single post dummy `Qt`.
