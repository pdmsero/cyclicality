# Referee review: cyclicality
_Tier: A (mature manuscript). Reviewed 2026-06-19._

## Editor's decision

Both referees independently recommend Reject, and converge on the same three foundational problems, which I have spot-checked against the project's own output and confirm.

First, the structural model does not deliver its headline number as a genuine prediction. Referee 1 documents that with CRS production and a static labour FOC the value function is linear in capital, so $\tilde K$ does not fluctuate and the model cannot endogenously generate the capx-vs-R&D ranking it claims to explain. Referee 2 adds that, with TFP as the only shock and a common trend, regression (10) recovers $[0,1]$ by construction, so the simulated $\beta_1\in[0.32,0.40]$ is a function of the freely chosen curvature $\gamma$. I verified `results/model_table4.md`: the simulated coefficients are explicitly tuned to "paper targets" by sweeping $\gamma$. The headline is calibrated, not tested.

Second, identification fails on the paper's own terms: the GMM Hansen test rejects instrument validity and Table 3 is empty. This is not revisable cosmetics.

Third, the empirics contradict the thesis. The R&D/total-investment ratio is wrong-signed at the firm level (the "puzzling" positive $z|i$), and, most seriously, the IV conclusion is contradicted by the project's own pipeline: I confirmed `results/alldata_iv_summary.md` reports FE-IV coefficients of 0.45–1.76, almost all significant at the 0.1% level, whereas Table 12 claims insignificance.

The referees agree almost entirely; the only divergence is emphasis (R1 stresses the model degeneracy and SDF inconsistency, R2 the IV-vs-code contradiction). Referee 1's narrow SDF point is presentational, since the discount-factor objects coincide numerically. But the substantive defects are fatal as submitted. The contribution itself is largely an accounting identity. These are foundational, not fixable within a revision cycle at this tier.

**Decision:** Reject

## Referee 1

Confirmed: the code uses $\tilde\Lambda_{SS}=\beta/(1+(\lambda-1)P_{SS})$, while the paper (eq. after 282) states $\Lambda=\beta/(1+g)$ with $g=2.2\%$. Since $g=(\lambda-1)P_{SS}$ these coincide, but the paper writes the *un-stationarized* SDF as $\beta/(1+g)$, conflating the level and stationary discount factors. Also note the paper says $\beta=0.96$, $g=2.2\%$ giving the SS prob = 80% and $\lambda-1=2.75\%$, but $(\lambda-1)P_{SS}=0.0275\times0.8=0.022$. Consistent. I have what I need.

---

# Referee Report — "R&D Smoothing: Evidence and Some Theory"

## 1. Contribution and novelty
The paper's organizing idea — that the apparently contradictory empirical literature on R&D cyclicality reconciles once one distinguishes the *level/growth* of R&D (pro-cyclical) from *R&D ratios* (counter-cyclical), under a "smoothing" elasticity in (0,1) — is sensible and pedagogically clean. But the novelty is thin. The decomposition is close to an accounting identity: if R&D growth responds positively-but-less-than-proportionately to output, the R&D/output ratio *mechanically* falls in booms. The paper even concedes this (Sec. 5.2: "an expected result given the mechanical drop in the ratio"). The "smoothing" label is borrowed from Brown & Petersen; the three-measures framing is a reorganization, not a new mechanism. The theory section is explicitly subtitled "Some Theory" and the most interesting analytical result — the two-period model showing that opportunity cost arises only when research draws on a *fixed within-period resource* (eqs. 1–2 in the commented-out block, lines 1158–1212) — has been `\begin{comment}`-ed out of the submitted manuscript. As submitted, the gap the paper claims to fill is largely a framing gap.

## 2. Correctness — model, derivations, identification
Several problems, some serious.

- **The dynamic model is degenerate and the paper does not say so.** With CRS production and a static labour FOC, the marginal product of capital is independent of $\tilde K$ (perturbation.py is explicit: "value function $\tilde V(\tilde K,a)$ is LINEAR in $\tilde K$ and optimal $\tilde Z$ depends only on $a$"). So capital never fluctuates, the capital Euler (eq. 7) is non-binding for the R&D choice, and the entire "production asset pricing" apparatus collapses to a one-state ($a$) problem. The headline that capx is "allowed to fluctuate" more than R&D (Sec. 5.2, 6) is then *not* a property of the simulated model — in the model $\tilde K$ is constant. This undercuts the claim that the model rationalizes the R&D/total-investment ratio.

- **Inconsistent stochastic discount factor.** Footnote to eq. 6 asserts $\Lambda_{t,t+1}=\beta(C_t/C_{t+1})^\sigma$, an equilibrium object. The calibration (after line 282) then *replaces* it with a constant $\Lambda=\beta/(1+g)$. These are not the same; the asset-pricing FOCs (eqs. 7–8) are derived under a stochastic $\Lambda$ but solved under a deterministic one. The paper should either drop the consumption-CAPM language or carry $\Lambda_{t,t+1}$ through. (The code, params.py, uses $\beta/(1+(\lambda-1)P_{SS})$, i.e. the *stationary* discount factor — a third object the text never distinguishes from the level SDF.)

- **Notational/algebraic slips in the FOCs.** The markup term appears as $\frac{\epsilon-1}{\epsilon}$ in eqs. 6–7 but the code/calibration uses $\theta\equiv\frac{\epsilon-1}{\epsilon}$ inconsistently with the stationary dividend equation (line 261), where the revenue term is written $Y_t^{1/\epsilon}\tilde Y_{i,t}^{(\epsilon-1)/\epsilon}$ — fine — but the labour share then enters as $(1-\alpha)\theta$, conflating the production exponent with the markup. The reader cannot verify eq. 7 from the text as written.

- **Commented appendix derivation has an outright error.** In the two-period FOCs (line 1195), $\partial V_1/\partial z_2 = -z_2\,\mathbb E_1[\Lambda \tilde V_2]=0$ implies $z_2=0$, which is not the intended condition (second-period R&D should be governed by its own marginal value, not forced to zero). This derivation needs redoing before it can be reinstated.

- **GMM identification is admitted to fail.** The growth-equation GMM (line 304) "reject[s] [the] null of instrument validity" (Hansen test, line 328), and Table 3 (calibration summary, lines 344–349) **is empty**. The single estimated parameter ($\gamma\approx0.098$) is then used to anchor the whole calibration. A rejected over-identification test plus an empty parameter table is not an acceptable identification section for a top-5 outlet.

- **The IV exercise argues *for* its own irrelevance.** Tables 11–12 show industry output is essentially *uncorrelated* with firm R&D, and weak-instrument tests flag the NBER instruments as weak (line 773). The paper interprets near-zero, weak-IV coefficients as "consistent with the model." But a weak/null first-stage cannot adjudicate between "idiosyncratic shocks drive everything" and "the instrument has no power." This is identification by absence of evidence.

## 3. Do results support the headline claims?
Partly, and with over-reach. (i) The R&D/total-investment counter-cyclicality — one of the three pillars — *fails* at the firm level: Tables 9–10 report a **positive** coefficient on $z|i$, contradicting the theory (the paper calls it "puzzling," line 594). So one of the three measures goes the wrong way in the cleanest dataset, yet the conclusion (Sec. 7) claims the ratio "behaves counter-cyclically as well." (ii) The model does not endogenously generate the capx-vs-R&D ranking (see §2); the explanation is asserted, not simulated. (iii) The financial-constraints "null" rests on synthetic KZ/WW indices the paper itself calls unreliable (citing Hadlock–Pierce) — and KZ shows a *monotone* gradient (Table 15: 0.135→0.324), which is evidence *for* a constraints channel, not against it. "Overwhelmingly suggest" (abstract) and "negligible impact" (Sec. 6) are not supported.

## 4. Framing and exposition
The manuscript reads as a dissertation chapter, not a journal article. Title/affiliation mismatch (Warwick vs. Essex, line 26). Table 3 empty; an unfinished footnote ("Calibrating to the median of"); duplicated `\label{simultaneity}` and duplicate table captions; figure 5 `width=01\textwidth`. The literature review is a serial annotation rather than a synthesis. Significance-star thresholds differ across tables (some $*=p<0.05$, others $p<0.1$). These are not cosmetic at this tier — they signal the empirics have not been frozen.

## 5. What is required before this could be published
1. **Resolve the model degeneracy**: either introduce capital adjustment costs / decreasing returns so $\tilde K$ genuinely fluctuates and the capx/R&D split is endogenous, or stop claiming the model explains the total-investment ratio.
2. **Make the SDF internally consistent** across eqs. 6–8 and the calibration; reconcile level vs. stationary discount factors.
3. **Fix identification**: address the rejected Hansen test, populate Table 3, and either find instruments with a real first stage or reframe the IV section as descriptive.
4. **Reconcile the contradictory $z|i$ result** rather than narrating around it.
5. **Reinstate and correct** the analytical two-period result (currently commented out, with an erroneous $z_2$ FOC) — it is the paper's only genuine theoretical contribution.
6. Full editorial pass: title, empty tables, labels, broken footnotes, star conventions.

**Recommendation:** Reject — the central theoretical mechanism is degenerate (capital does not fluctuate, so the model cannot generate its own headline prediction), the GMM identification fails its own over-identification test, and a key empirical pillar reverses sign in the main dataset; these are foundational rather than fixable in revision.

## Referee 2

I now have a comprehensive picture. Let me note key cross-checks: the headline simulation FE coefficients (Table 4) range 0.32–0.40, while empirical estimates are 0.1–0.5; the IV summary file shows IV coefficients of 0.45–0.69 and even >1 (Block3/4) that are highly significant, directly contradicting the paper's claim (Table 12) that IV coefficients are insignificant. I have enough for the report.

# Referee Report — "R&D Smoothing: Evidence and Some Theory"

## 1. Contribution and novelty

The paper's organizing idea — that the apparently contradictory literature on R&D cyclicality is reconciled once one distinguishes the response of (i) R&D *growth*, (ii) the R&D/output *ratio*, and (iii) the R&D/total-investment *ratio* — is sensible and pedagogically useful. But it is not new in the way a top-5 outlet requires. The claim that R&D growth is procyclical while the R&D/output share is countercyclical is mechanically implied by an elasticity strictly between 0 and 1, a point already understood in Barlevy (2007) and Ouyang (RESTAT 2011, your `RePEc:tpr:restat:v:93`), on whose data and design Sections 3–5 are explicitly built. "If the elasticity is below one, the ratio falls" is an accounting identity, not a finding (the paper even concedes this is "an expected result given the mechanical drop in the ratio," p.~594). The genuinely novel object — the R&D/(R&D+capx) ratio — produces results that *contradict* the paper's own hypothesis (positive, see below), so the one new contribution undercuts the thesis. The "modified opportunity cost hypothesis" is a relabeling: the data show procyclical R&D everywhere; calling the share decline a vindication of Schumpeter is a semantic move, not new economics.

## 2. Correctness

**The model does not identify what the paper claims.** By the author's own repeated statement (footnotes p.~278, p.~284, p.~352, p.~372), with TFP as the *only* shock and a common stationary trend, regression (10) recovers $\boldsymbol{\beta}=[0,1]$ "by construction." The simulated $\beta_1\in[0.32,0.40]$ (Table 4) is therefore not a structural prediction of smoothing — it is a numerical artifact of the linearization plus the calibrated curvature $\gamma$. The text admits "the smoothing effect is stronger when the elasticity of R&D returns is lower," i.e. the headline number is a free choice of $\gamma$, not a result. There is no sense in which the model is tested against the data; it is tuned to land in $(0,1)$.

**Identification of the model is acknowledged to fail.** Page 328 states the "Hansen test for over-identifying restrictions rejecting null of instrument validity," and Table 3 ("Calibration of $\eta$") is *empty* (p.~344–349). The text references "Calibrating the model to the median of" — an unfinished sentence (footnote, p.~302). $\eta$ and $\lambda$ are conceded to be unidentified (p.~403). This is not submittable.

**The IV evidence contradicts the paper's central empirical claim.** The manuscript's Table 12 reports IV coefficients on sales "not statistically different from zero" and concludes firm-specific shocks drive everything (p.~796). But the project's own results file (`results/alldata_iv_summary.md`) reports FE-IV coefficients of 0.45–0.69 (Block 1–2, all `***`) and 0.89–1.76 (Block 3–4, all `***`). These are large, highly significant, and several exceed unity — the opposite of the paper's conclusion and inconsistent with smoothing. Either the table or the code output is wrong; as written, the headline "no causal industry-level effect" claim is not supported by the author's own pipeline.

**Internal inconsistencies in the tables.** Table 9: "Industries" (6469) exceeds "Firms" (313) — the row labels are evidently swapped, and this recurs in Table 10. Significance stars are defined inconsistently across tables (Table 5 uses $p<0.05/0.01/0.001$; the prose discusses 5%/1% thresholds that do not match). Table 6 header says "Standard errors" in one note and "p-values in parentheses" in another. Equation (10) has a typo ($\Delta\tilde Z_{i,tt}$). These are not cosmetic when the argument turns on coefficient magnitudes.

**The $z|i$ result is fatal to the thesis as stated.** At the firm level the R&D/total-investment ratio is *procyclical* (Tables 9, 10, 14–16), the reverse of hypothesis 2. The author's rationalization (capx adjusts more sluggishly than R&D, p.~594) is plausible but is the *opposite* of the "rising tide lifts capex more than R&D" story asserted in the Conclusion (p.~1015). The paper cannot have it both ways.

## 3. Over-claiming

The abstract says results "overwhelmingly suggest" significant smoothing "both in theory and in practice." This is too strong: the industry IV results are insignificant or wrong-signed (Tables 7–8), the firm IV results are insignificant in the paper but significant-and-large in the code, the $z|i$ ratio is wrong-signed, and the model number is calibrated rather than tested. "Overwhelmingly" should be "mixed."

## 4. Framing and exposition

The writing is discursive and frequently ungrammatical ("if true, an asymmetrical response," "out discussion," "this providing some confirmation," "a an asymmetric"). The title's "Some Theory" signals the model is underdeveloped, and the commented-out two-period model (p.~1158–1212) is more transparent about the opportunity-cost mechanism than the partial-equilibrium model that replaced it. The affiliation is internally contradictory (Warwick vs. Essex). Figure 3 spans only to 1975/1998 while claims are made for "1960–2008."

## 5. Required revisions

- Reconcile Table 12 with `alldata_iv_summary.md`; the IV conclusion must be rederived and the discrepancy explained.
- Complete Table 3 and the calibration; report the Hansen test and explain why a rejected model is informative, or respecify.
- Demonstrate that the simulated $\beta_1$ is not mechanical — e.g., add a shock that breaks the common trend so $[0,1]$ is not the construction default.
- Fix the firms/industries row swaps and harmonize all significance notes.
- Drop or fully theorize the $z|i$ measure; reconcile its procyclicality with the Conclusion.
- Sharpen the contribution relative to Barlevy and Ouyang; state precisely what is non-mechanical.

**Recommendation:** Reject — the structural result is a calibration artifact by the author's own admission, the model is unidentified with an empty calibration table, and the IV conclusion contradicts the project's own output, so the headline claims are not currently supported.
