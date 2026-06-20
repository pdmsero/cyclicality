# Dynare model files

## Status: present and Blanchard–Kahn verified

The firm-level R&D model is specified here as a Dynare/aether `.mod` system, one
file per γ ∈ {0.05, 0.10, 0.15, 0.20}:

- `cyclicality_g05.mod`, `cyclicality_g10.mod`, `cyclicality_g15.mod`, `cyclicality_g20.mod`

These are **generated** by `gen_mod.py` from the project steady state
(`code/python/model/steady_state.py`), so the `.mod` steady state can never drift
from the Python steady state. Do not edit the `.mod` files by hand — edit the
generator and re-run `python3 gen_mod.py`.

## The model (2-state, K̃ and a)

CRS Cobb–Douglas production, monopolistic competition on a CES demand curve (so
perceived revenue `r̃ = Ȳ^{1/ε}·Ỹ^{(ε−1)/ε}` is concave in own output even under
CRS, making the marginal revenue product of capital decline in own K̃), plus a
Hayashi/Jermann convex **capital** adjustment cost `Φ = (φ/2)(Ĩ/K̃−δ̄)²K̃` on the
investment rate. This makes K̃ a genuine state — fixing the degeneracy the referee
flagged ("Claim C") — and makes capx a procyclical, persistent accelerator while
R&D is smoothed. The steady state is unchanged by the adjustment cost (Φ and Φ_I
vanish at δ̄ = δ+(λ−1)P_SS, so q=1).

12 endogenous variables (Y, L, rev, K, I, Z, P, Lam, V, D, q, a), one TFP shock.
States: K̃ (predetermined), a (exogenous).

## Reproducing

- **Solve in Dynare + check Blanchard–Kahn** (MATLAB, Dynare 6.5 on the path):
  ```matlab
  addpath('/Applications/Dynare/6.5-arm64/matlab'); run_dynare
  ```
  Writes `<model>_irf.csv` (IRFs to the TFP shock) for each γ. Blanchard–Kahn is
  verified for all four (2 states, 4 forward-looking, 4 explosive eigenvalues;
  capital-persistence root ≈ 0.845).

- **Cross-check the Python perturbation engine (aether-macro) against Dynare:**
  ```bash
  python3 engine_crosscheck.py
  ```
  Confirms the two engines agree on the steady state and the IRFs
  (max|diff| ≈ 5e-16 over 40 periods, all γ).

- **Calibrate the adjustment cost φ:**
  ```bash
  python3 calibrate_phi.py
  ```
  Sweeps φ and reports the moments that pin it down. Baseline φ=2.0 targets a
  capital AR(1) root ≈ 0.85.

## History

The original submission claimed a "first-order approximation in Dynare" but the
`.mod` file was absent and the implemented model was degenerate (revenue linear
in own output ⇒ value function linear in K̃ ⇒ capital frozen). These files are the
reconstructed, de-degenerated model.
