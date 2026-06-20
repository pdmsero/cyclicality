"""
calibrate_phi.py
----------------
Sweep the capital adjustment-cost curvature φ and report the moments that pin it
down, so it is chosen on evidence rather than guessed.

For each φ (at γ=0.10) we regenerate the .mod in a scratch dir, solve it with
aether, simulate the 1000×200 panel, and report:
  - impact responses of capx (Ĩ) and R&D (Z̃) to a +2% TFP shock, and their ratio
  - the capital eigenvalue (capital persistence)
  - panel std(Δlog I)/std(Δlog Y)   (firm investment is ~2-3× as volatile as sales)
  - panel β_capx (Δlog I ~ Δlog PY) and β_R&D (Δlog Z ~ Δlog PY)

φ=0 recovers the frictionless near-jump model (β_capx < 0). We want the smallest
φ that makes capx procyclical (β_capx > 0, and > β_R&D) with a realistic capx
volatility.
"""

from __future__ import annotations
import os, sys, tempfile
from pathlib import Path
import numpy as np

HERE = Path(__file__).resolve().parent
PYDIR = HERE.parent / "python"
sys.path.insert(0, str(PYDIR))
_AETHER = os.environ.get("AETHER_HOME", str(Path.home() / "Documents/Projects/personal/aether-macro"))
sys.path.insert(0, _AETHER)

import aether
from aether.parsers.dynare import parse_mod_file
from aether.solvers.klein import linear_irf

from model.params import ModelParams
from model.steady_state import solve as solve_ss
from model.perturbation import PerturbationSolution
from model.simulation import simulate_from_perturbation
from model.estimation import estimate_table4
import gen_mod  # the generator (template + formatting)


def build_solution(gamma: float, phi: float, scratch: Path) -> PerturbationSolution:
    p = ModelParams(gamma=gamma, phi=phi)
    ss = solve_ss(p)
    I_ss = ss.K_tilde * p.delta_bar
    txt = gen_mod.MODEL_BLOCK.format(
        gamma=f"{gamma:.10g}", alpha=f"{p.alpha:.10g}", delta=f"{p.delta:.10g}",
        beta=f"{p.beta:.10g}", eps=f"{p.eps:.10g}", lam=f"{p.lam:.10g}",
        rho_a=f"{p.rho_a:.10g}", eta=f"{p.eta:.12g}", theta=f"{p.theta:.12g}",
        Ybar=f"{ss.Y_tilde:.12g}", Wbar=f"{ss.W_bar:.12g}",
        phi=f"{phi:.10g}", dbar=f"{p.delta_bar:.12g}", sigma_a=f"{p.sigma_a:.10g}",
        Y=f"{ss.Y_tilde:.12g}", L=f"{ss.L:.12g}", rev=f"{ss.Y_tilde:.12g}",
        K=f"{ss.K_tilde:.12g}", I=f"{I_ss:.12g}", Z=f"{ss.Z_tilde:.12g}",
        P=f"{ss.P:.12g}", Lam=f"{ss.Lambda:.12g}", V=f"{ss.V_tilde:.12g}",
        D=f"{ss.D_tilde:.12g}",
    )
    modp = scratch / f"cal_g{int(round(gamma*100)):02d}_phi{phi:g}.mod"
    modp.write_text(txt)
    sir = parse_mod_file(str(modp), name=modp.stem)
    rep = aether.solve(sir)
    assert rep.ok, f"aether failed (φ={phi}): {rep.failed_stage} {rep.error}"
    names = [v.name for v in sir.variables if v.kind == "endogenous"]
    idx = {nm: i for i, nm in enumerate(names)}
    return PerturbationSolution(
        ss=ss, p=p, names=names, idx=idx, y_ss=np.asarray(rep.y_ss, float),
        P=np.asarray(rep.klein.P, float), Q=np.asarray(rep.klein.Q, float),
        klein=rep.klein, n_stable=int(rep.klein.n_stable))


def cap_eig(sol) -> float:
    """Largest stable real eigenvalue excluding the TFP root ρ_a (≈ capital persistence)."""
    ev = np.real(np.asarray(sol.klein.eigenvalues))
    ev = ev[np.isfinite(ev)]
    ev = ev[(ev > 1e-8) & (ev < 1 - 1e-9)]
    ev = ev[np.abs(ev - sol.p.rho_a) > 1e-4]   # drop the TFP root
    return float(ev.max()) if len(ev) else 0.0


def main():
    gamma = 0.10
    print(f"Capital adjustment-cost calibration sweep (γ={gamma}, N=1000×200)")
    from model.estimation import run_fe_regression
    print(f"{'phi':>5} {'capx%':>7} {'R&D%':>6} {'capx/R&D':>8} {'cap_eig':>7} "
          f"{'sd(dI)/sd(dY)':>13} {'beta_capx':>9} {'beta_R&D':>8} {'z|i slope':>9} {'i/k slope':>9}")
    with tempfile.TemporaryDirectory() as td:
        scratch = Path(td)
        for phi in [0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0]:
            sol = build_solution(gamma, phi, scratch)
            eps = np.zeros((40, 1)); eps[0, 0] = sol.p.sigma_a
            irf = linear_irf(sol.klein, eps)
            pc = lambda v: irf[0, sol.idx[v]] / sol.y_ss[sol.idx[v]] * 100
            capx_i, rnd_i = pc("I"), pc("Z")
            panel = simulate_from_perturbation(sol, seed=42)
            res = estimate_table4(panel, gamma=gamma, method="perturbation")
            df = panel.df.sort_values(["firm", "year"]).copy()
            sdI = df.groupby("firm")["I"].apply(lambda s: np.log(s.clip(lower=1e-9)).diff().std()).mean()
            sdY = df.groupby("firm")["Y"].apply(lambda s: np.log(s).diff().std()).mean()
            # z|i = R&D / total investment, and investment rate i/k, on Δlog sales
            df["zi"] = df["Z"] / (df["I"].clip(lower=1e-9) + df["Z"])
            df["ik"] = df["I_tilde"] / df["K_tilde"]
            df["dlog_PY"] = df.groupby("firm")["Y"].transform(lambda s: np.log(s).diff())
            d = df.replace([np.inf, -np.inf], np.nan)
            zi = run_fe_regression(d.dropna(subset=["zi", "dlog_PY"]).rename(columns={"zi": "dep"}),
                                   dep_var="dep", indep_var="dlog_PY")["beta"]
            ik = run_fe_regression(d.dropna(subset=["ik", "dlog_PY"]).rename(columns={"ik": "dep"}),
                                   dep_var="dep", indep_var="dlog_PY")["beta"]
            print(f"{phi:>5.1f} {capx_i:>7.2f} {rnd_i:>6.2f} {capx_i/rnd_i:>8.1f} "
                  f"{cap_eig(sol):>7.3f} {sdI/sdY:>13.2f} {res['beta_capx']:>9.3f} "
                  f"{res['beta_A']:>8.3f} {zi:>9.4f} {ik:>9.4f}")


if __name__ == "__main__":
    main()
