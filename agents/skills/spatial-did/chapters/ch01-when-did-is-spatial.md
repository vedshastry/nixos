# Chapter 1: Introduction — When a DID is "Spatial"

## Core Idea
A difference-in-differences (DID) becomes a *spatial* DID — with its own special inference problems — only when (1) the outcome has high spatial dependence **and** (2) the sample is tightly clustered in space. Place-based policies almost always meet both by construction.

## Frameworks Introduced
- **The two-criteria test for "spatial DID"**: You face a spatial DID (and must adjust inference) when **both** hold:
  1. The outcome has high spatial dependence (nearby units have correlated outcomes).
  2. The sampled population is tightly clustered in space.
  - When to use: at the very start, to decide whether standard (non-spatial) DID inference is adequate or whether you need clustered/HAC/randomization methods.
  - How: ask "are my treated and control units packed around a boundary?" and "is my outcome (GDP, lights, disease, traffic) spatially correlated?" If yes to both → spatial DID.
  - Why it matters: a national program sampled randomly across a country fails criterion 2, so standard DID suffices; the *same* program targeted to specific neighborhoods meets both, so naive SEs mislead.

- **DID intuition (level vs. trend)**: Treated and control areas may differ in the *level* of the outcome (that's often *why* they were treated), but can plausibly share the same *trend* absent treatment. A break in the common trend right at treatment signals an effect.
  - When to use: framing any DID, especially when treated units were selected on unobservables (poorer, slower-growing).

## Key Concepts
- **Place-based policy**: investment/subsidy/tax policy targeted at an underdeveloped geographic region; the canonical spatial-DID application.
- **Spatial dependence**: correlation in outcomes (or errors) between geographically near units.
- **Tight clustering**: the sample is geographically concentrated (e.g., a band around a border), which amplifies the consequences of spatial dependence.
- **Selection on unobservables**: treated areas differ on factors you cannot measure or control for; motivates DID over cross-sectional comparison.

## Mental Models
- Think of "spatial" not as "the data has coordinates" (everything does) but as "the *design* concentrates the sample where outcomes are correlated."
- Use a **boundary-band design** when you want treated/control units that plausibly share a counterfactual trend: just-inside vs. just-outside a new border.
- The very feature that buys you parallel trends (proximity) is what creates the inference problem (spatial correlation) and the SUTVA problem (spillovers) — see [[ch02-model-causal-interpretation]] and [[ch05-methods-for-inference]].

## Anti-patterns
- **Treating a tightly-clustered place-based study with default SEs**: spatial + temporal correlation makes default SEs far too small → massive over-rejection.
- **Assuming "it has a map, so it's spatial"**: the label is about design-induced dependence, not the mere presence of geography.

## Worked Example
**Job-training program, two designs:**
- *Design A* — program offered to a random 1% of the unemployed nationwide. Sample is spread across the country; outcomes barely correlated across sampled people. Standard DID inference is fine.
- *Design B* — program targeted to specific low-opportunity neighborhoods; sample drawn from those plus nearby comparison neighborhoods. Sample is tightly clustered, and economic opportunity is itself spatially clustered → standard inference understates SEs and misleads.

The running book example (Uttarakhand): treatment = place-based policy inside a newly created state; treated cells just inside, control cells just outside; entire sample clustered around the new boundary; outcome = nighttime lights (spatially correlated, especially with satellite data). Meets both criteria almost by construction.

## Key Takeaways
1. Run the two-criteria test before choosing an inference method.
2. Place-based policies are spatial DID by design — plan for clustered/HAC/randomization SEs from the outset.
3. DID identifies off *trends*, tolerating level differences that come from selection on unobservables.
4. Other spatial-DID settings: contagious-disease spread, road closures and traffic, groundwater depletion and crop yields.

## Connects To
- **Ch 2**: formalizes the model, ATT, parallel trends, and SUTVA.
- **Ch 4–5**: why proximity breaks inference and how to fix it.
- **Ch 6**: why remotely-sensed outcomes (lights) are especially spatially correlated (overglow).
