# Paper model simulation

This directory contains a separate Dynare implementation of the **partial-equilibrium firm model in `paper/main.tex`**. It has only firm-specific TFP shocks. Aggregate output is fixed at one, wages and the stochastic discount factor are fixed at their calibrated steady-state values, and there are no aggregate-clearing equations, capital adjustment costs, or endogenous aggregate feedback.

The innovation process uses two illustrative calibration anchors: long-run quality growth `g=0.022` and a steady-state Bernoulli event probability `p=0.450164`. The latter is anchored to the observed share of R&D-positive manufacturing Compustat firm-years with at least one matched patent application that was eventually granted: 36,457 of 80,986 observations from 1976–2014. This is a heavily stylized model: patent incidence does not directly measure its latent event hazard or map one-to-one to a quality jump. The pooled patent rate is a normalization anchor, not a structural estimate; it also reflects patenting propensity, grant lags, and match coverage. Rates by subperiod are 37.4% (1976–1989), 44.5% (1990–1999), and 51.0% (2000–2014), underscoring that the constant probability is an approximation. The patent match is from [Dyèvre and Seager (2023)](https://github.com/arnauddyevre/compustat-patents), pinned in `estimate_patent_target.py`.

The two anchors imply `lambda = 1 + g/p = 1.04887` (a 4.89% step). For each `gamma`, the generator solves the steady state and chooses `eta` so `eta * Z_ss**gamma = 0.450164` while satisfying the model's research first-order condition. This produces `eta` values 0.577, 0.691, 0.808, and 0.932. `eta` and the event probability are not interchangeable: the probability is `eta * Z**gamma`. Because patent incidence is only a proxy anchor, alternative event-probability assumptions should be read as calibration sensitivity, not competing estimates of a directly observed structural parameter.

The generator also uses Imrohoroglu and Tuzel's annual firm TFP calibration (`rho=0.70`, `sigma=0.268`), capital share `alpha=0.22`, and depreciation `delta=0.08`; it uses the paper's annual `beta=0.96` and markup elasticity `epsilon=4.333...`. The cited source is [Imrohoroglu and Tuzel (2014)](https://pubsonline.informs.org/doi/10.1287/mnsc.2013.1852). The paper's Table 3 is empty, so this parameter mapping is recorded here rather than inferred from the later reconstructed model.

Generate the four Dynare files:

```sh
python3 code/paper_simulation/generate_dynare.py
```

This implements the paper's partial-equilibrium stationary firm system with the two empirical targets above. The first-order Dynare solution is loglinear so simulated research and innovation probabilities stay positive. It does not tune any simulated regression coefficient to the paper's reported result.

`run_panel.m` draws independent firm-level shocks, runs the first-order Dynare decision rules for 1,000 firms × 200 periods, applies the paper's Bernoulli quality-ladder process from `Q_0=1`, and writes 200,000 actual model rows per calibration. No burn-in is added; the paper specifies 200 periods and does not mention one. `make_growth_panel.py` converts those rows into the 199,000 adjacent-period growth pairs used for a plot. It stops if the linearized paths leave the feasible research or probability domain; it does not clip values or substitute points.

Run the panel and derive its plotted points:

```sh
matlab -batch "addpath('code/paper_simulation'); run_panel"
python3 code/paper_simulation/make_growth_panel.py
python3 code/paper_simulation/render_simulation.py
```

The renderer replaces `paper/figures/simulation.jpeg` with the four-panel scatter plot and exports every paired growth observation to `generated/research-cyclicality-float32.bin`. Each panel contains all 199,000 observations. With seed `20261005`, the new panels produce growth-on-sales slopes 0.304, 0.328, 0.356, and 0.386 for the four gamma values. These are computed from the generated model observations, not set to the paper's reported 0.319, 0.344, 0.372, and 0.404. The original Dynare file, random seed, and simulated panel are not preserved, so this rebuild does not claim point-for-point recovery of the published figure.

`render_model_data_comparison.py` builds the website's two-panel comparison from the recalibrated `gamma=0.10` model panel and every complete Compustat growth observation in `processed_alldata_stage3` (`d_gdp_sale`, `d_gdp_xrd`; 105,334 rows, 1951–2014). To match sample sizes, it selects 105,334 actual model observations without replacement, stratified evenly across all 199 simulation periods and the 1,000-firm cross-section; it does not fabricate or resample values. It writes `paper/figures/modelvsdata.jpeg`, two equal-length binary point arrays, and observation/year metadata under `generated/`. The plotted OLS slopes are calculated from those exact arrays: 0.329 for the matched model sample and 0.206 for Compustat. The old website image's 0.398/0.401 labels are not carried forward.
