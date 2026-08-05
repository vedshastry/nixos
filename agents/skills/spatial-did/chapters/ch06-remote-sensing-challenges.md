# Chapter 6: Research Design & Remote-Sensing Data Challenges

## Core Idea
Good research design finds a treated/control pair for which parallel trends is credible (a boundary band); remotely-sensed outcomes then add two hazards — **satellite drift** (threatens identification) and **overglow** (threatens both identification and inference) — both of which a *smooth-across-space* design can largely neutralize.

## Frameworks Introduced
- **Boundary-band research design**: restrict the sample to cells within a short distance (e.g., 10 km) of a newly-drawn boundary, comparing just-inside (treated) vs. just-outside (control).
  - When to use: when a policy turns on at an administrative border created shortly before treatment (Uttarakhand split from Uttar Pradesh in 2000; policy in 2002).
  - How: the identification assumption decomposes into (1) treated/control near the boundary were on similar pre-trends, and (2) boundary *formation itself* didn't move trajectories — justify both institutionally *and* test (event study, placebo, Ch 7).

- **Satellite drift problem**: different satellites "see" different values at the same place/time; a multi-decade panel must splice across satellites (NOAA nighttime lights use 6), risking artificial series breaks. If a break coincides with treatment it can masquerade as an effect.
  - Naive fix that fails: pooling all satellites with **satellite-year fixed effects** removes only the *average* level difference; the disagreement is *not* uniform across locations, so it persists (sometimes grows) after FE.
  - Real fix: exploit **spatial smoothness** — satellite disagreement is small between nearby cells, so a *spatial* design (treated vs. control on either side of a border) differences it out even though FE cannot.

- **Overglow**: light from one cell spills into neighbors. Two harms: (1) makes nearby locations look more alike → **attenuates** boundary estimates; (2) **mechanically inflates spatial correlation** in the outcome.
  - Mitigation: the attenuation is hard to fix without auxiliary non-overglow data (be transparent that the design may *underestimate*); the inflated correlation is handled in inference by **widening the HAC bandwidth** or **clustering at a coarser level** (Ch 5).

## Key Concepts
- **Identification assumption (applied)**: cells near the new boundary would have grown at the same rate absent the policy.
- **Fishnet grid / cell**: 0.1°×0.1° lat-lon cells are the unit of analysis; boundary cells are split so light isn't mis-attributed.
- **Nighttime lights (DMSP/VIIRS)**: remotely-sensed proxy for economic activity; DMSP (NOAA, cloud-corrected) is older/coarser, VIIRS is newer/higher-resolution.
- **Satellite-year fixed effects**: control intended to absorb cross-satellite level differences — insufficient because differences are location-specific.

## Mental Models
- "Spatial smoothness saves the design": any nuisance (satellite gap, slow geographic trend) that varies *smoothly* across space is differenced out by comparing immediately-adjacent treated/control cells.
- Overglow is both a *bias* story (attenuation) and a *variance* story (extra spatial correlation) — address each in its own place (design vs. inference).
- A coincident series break is the satellite-data analog of a confounding event; rule it out the same way (institutional knowledge + placebo).

## Anti-patterns
- **"Just add satellite-year FE"**: removes only average drift; location-specific disagreement survives and can still confound.
- **Ignoring overglow's two channels**: forgetting it both attenuates the estimate *and* inflates spatial dependence (so SEs must widen).
- **Wide comparison bands**: cells far apart have no reason to share trends — pre-trends reappear (shown empirically in Ch 7).

## Worked Example
**Satellite drift in one cell (Table 1).** For a single cell, NOAA's raw readings differ sharply across overlapping satellites: in 1998 satellite F14 recorded a value >4× F12's; in 2005 F16 saw light where F15 saw darkness; and the ordering even reverses year to year (F14 > F12 in 1998, reversed in 1999). After removing satellite-year FE the gaps shrink on average but remain large and sometimes grow — proving the disagreement is location-specific, not a uniform shift. Mapping New Delhi in 1997 from F12 vs. F14 (Figure 3) shows the two agree on very dark and very bright areas but disagree in mid-range areas, and crucially the difference is *smooth across space* — so a border-band design cancels it.

## Key Takeaways
1. Pick a boundary band so the counterfactual trend is credible; decompose and defend the identification assumption.
2. Multi-satellite panels can have artificial breaks; satellite-year FE only fix the average — rely on spatial smoothness instead.
3. Overglow attenuates estimates (design problem) and inflates spatial correlation (inference problem — widen bandwidth / coarsen clusters).
4. Anything smooth across space is differenced away by adjacent treated/control comparison.

## Connects To
- **Ch 2**: this operationalizes parallel trends and the identification assumption.
- **Ch 5**: overglow is a direct reason to enlarge HAC bandwidth or cluster level.
- **Ch 7**: event-study and placebo tests that validate this design.
