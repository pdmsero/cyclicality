"""
40_simulate_model.py
--------------------
Master script: solve the R&D quality-ladder model and reproduce Table 4.

Three solution methods (pedagogical comparison):
  1. First-order perturbation (MUC — Method of Undetermined Coefficients)
  2. Value function iteration (VFI, 1D on TFP grid)
  3. Chebyshev polynomial projection (1D on TFP support)

For each method × γ ∈ {0.05, 0.10, 0.15, 0.20}:
  - Solve the model
  - Simulate N=1000 firms × T=200 periods
  - Run FE regressions: Δlog(Z) ~ Δlog(PY), Z/PY ~ Δlog(PY)
  - Compare to paper Table 4 targets

Outputs:
  results/model_table4.xlsx / .md  — Table 4 equivalents
  results/figures/model_*.png      — policy function and beta-vs-gamma plots
"""

import sys, os, time, warnings
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from pathlib import Path

# ── Path setup ─────────────────────────────────────────────────────────────────
SCRIPT_DIR  = Path(__file__).parent
PROJECT_DIR = SCRIPT_DIR.parent.parent
RESULTS_DIR = PROJECT_DIR / "results"
FIGURES_DIR = RESULTS_DIR / "figures"

RESULTS_DIR.mkdir(exist_ok=True)
FIGURES_DIR.mkdir(exist_ok=True)

sys.path.insert(0, str(SCRIPT_DIR))

from model.params       import ModelParams
from model.steady_state import solve as solve_ss, check_ss
from model              import perturbation, vfi, projection
from model.simulation   import (simulate_from_perturbation,
                                 simulate_from_vfi,
                                 simulate_from_projection)
from model.estimation   import (estimate_table4, format_table4,
                                 compare_to_targets, TABLE4_TARGETS)

GAMMA_GRID = [0.05, 0.10, 0.15, 0.20]


def log(msg: str):
    ts = time.strftime("%H:%M:%S")
    print(f"[{ts}] {msg}", flush=True)


# ══════════════════════════════════════════════════════════════════════════════
# 1. Steady-state verification
# ══════════════════════════════════════════════════════════════════════════════
log("=" * 65)
log("Step 1: Steady-state verification")
log("=" * 65)

for gamma in GAMMA_GRID:
    p   = ModelParams(gamma=gamma)
    ss  = solve_ss(p)
    res = check_ss(ss, p, tol=1e-6)
    max_resid = max(res.values())
    log(f"  γ={gamma:.2f} | K̃={ss.K_tilde:.3f} Z̃={ss.Z_tilde:.5f} "
        f"Ṽ={ss.V_tilde:.4f} η={ss.eta:.4f} | "
        f"max_resid={max_resid:.2e} {'✓' if max_resid < 1e-5 else '⚠'}")


# ══════════════════════════════════════════════════════════════════════════════
# 2. Solve all three methods for each gamma
# ══════════════════════════════════════════════════════════════════════════════
log("\n" + "=" * 65)
log("Step 2: Solving model (3 methods × 4 gamma values)")
log("=" * 65)

solutions = {"perturbation": {}, "vfi": {}, "projection": {}}

for gamma in GAMMA_GRID:
    p = ModelParams(gamma=gamma)
    log(f"\n  γ = {gamma:.2f}")

    # ── 2a. Perturbation ───────────────────────────────────────────────────
    t0 = time.time()
    try:
        sol = perturbation.solve(p, verbose=False)
        log(f"    Perturbation: c_Za={sol.c_Za:.4f}, c_Va={sol.c_Va:.4f} "
            f"({time.time()-t0:.1f}s)")
        solutions["perturbation"][gamma] = sol
    except Exception as e:
        log(f"    Perturbation FAILED: {e}")
        solutions["perturbation"][gamma] = None

    # ── 2b. VFI ────────────────────────────────────────────────────────────
    t0 = time.time()
    try:
        sol = vfi.solve(p, tol=1e-8, max_iter=3000, verbose=False)
        log(f"    VFI: Z̃(a_SS)={sol.pol_Z[p.n_a//2]:.5f} "
            f"(target {sol.ss.Z_tilde:.5f}) ({time.time()-t0:.1f}s)")
        solutions["vfi"][gamma] = sol
    except Exception as e:
        log(f"    VFI FAILED: {e}")
        solutions["vfi"][gamma] = None

    # ── 2c. Projection ─────────────────────────────────────────────────────
    t0 = time.time()
    try:
        sol = projection.solve(p, n_proj=12, tol=1e-8, max_iter=3000,
                               verbose=False)
        log(f"    Projection: eval_Z(1.0)={sol.eval_Z(1.0):.5f} "
            f"(target {sol.ss.Z_tilde:.5f}) ({time.time()-t0:.1f}s)")
        solutions["projection"][gamma] = sol
    except Exception as e:
        log(f"    Projection FAILED: {e}")
        solutions["projection"][gamma] = None


# ══════════════════════════════════════════════════════════════════════════════
# 3. Policy function comparison (Z̃ vs a)
# ══════════════════════════════════════════════════════════════════════════════
log("\n" + "=" * 65)
log("Step 3: Policy function plots")
log("=" * 65)

for gamma in GAMMA_GRID:
    sol_p = solutions["perturbation"].get(gamma)
    sol_v = solutions["vfi"].get(gamma)
    sol_r = solutions["projection"].get(gamma)
    if sol_p is None or sol_v is None:
        continue

    a_plot = np.linspace(sol_v.a_grid[0] * 1.01, sol_v.a_grid[-1] * 0.99, 200)

    # Perturbation: Z̃ = Z̃_SS * exp(c_Za * log a)
    Z_pert = sol_p.ss.Z_tilde * np.exp(sol_p.c_Za * np.log(a_plot))

    # VFI: interpolate on log scale
    Z_vfi = np.exp(np.interp(np.log(a_plot),
                              np.log(sol_v.a_grid),
                              np.log(np.maximum(sol_v.pol_Z, 1e-20))))

    # Projection: Chebyshev eval
    Z_proj = np.array([sol_r.eval_Z(a) for a in a_plot]) if sol_r else None

    fig, ax = plt.subplots(figsize=(7, 4))
    ax.plot(a_plot, Z_pert * 1000, label="Perturbation", lw=2, color="#1f77b4", ls="--")
    ax.plot(a_plot, Z_vfi  * 1000, label="VFI",          lw=2, color="#2ca02c")
    if Z_proj is not None:
        ax.plot(a_plot, Z_proj * 1000, label="Projection",   lw=2, color="#d62728", ls=":")
    ax.axvline(1.0, color="k", lw=0.8, ls=":", alpha=0.5)
    ax.set_xlabel("TFP level a", fontsize=11)
    ax.set_ylabel("R&D policy Z̃ (×1000)", fontsize=11)
    ax.set_title(f"R&D policy Z̃(a): three methods, γ={gamma}", fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    fig.savefig(FIGURES_DIR / f"model_policy_gamma{int(gamma*100):02d}.png", dpi=150)
    plt.close(fig)

log(f"  Saved policy function plots to {FIGURES_DIR}")


# ══════════════════════════════════════════════════════════════════════════════
# 4. Simulate and estimate Table 4
# ══════════════════════════════════════════════════════════════════════════════
log("\n" + "=" * 65)
log("Step 4: Simulation and estimation")
log("=" * 65)

all_results = []

SIM_FUNCS = {
    "perturbation": simulate_from_perturbation,
    "vfi":          simulate_from_vfi,
    "projection":   simulate_from_projection,
}

for method, sim_func in SIM_FUNCS.items():
    log(f"\n  Method: {method}")
    for gamma in GAMMA_GRID:
        sol = solutions[method].get(gamma)
        if sol is None:
            log(f"    γ={gamma:.2f}: skipped (no solution)")
            continue
        t0 = time.time()
        try:
            panel = sim_func(sol, seed=42)
            res   = estimate_table4(panel, gamma=gamma, method=method)
            all_results.append(res)
            tgt_A = TABLE4_TARGETS.get(gamma, {}).get("beta_A", float("nan"))
            tgt_B = TABLE4_TARGETS.get(gamma, {}).get("beta_B", float("nan"))
            log(f"    γ={gamma:.2f}: β_A={res['beta_A']:.3f} "
                f"(target {tgt_A:.3f}, diff {res['beta_A']-tgt_A:+.3f}) | "
                f"β_B={res['beta_B']:.4f} "
                f"(target {tgt_B:.4f}) "
                f"[{time.time()-t0:.1f}s, N={panel.N}×{panel.T}]")
        except Exception as e:
            log(f"    γ={gamma:.2f}: FAILED — {e}")
            import traceback; traceback.print_exc()


# ══════════════════════════════════════════════════════════════════════════════
# 5. Save results
# ══════════════════════════════════════════════════════════════════════════════
log("\n" + "=" * 65)
log("Step 5: Saving results")
log("=" * 65)

if all_results:
    table4_df     = format_table4(all_results)
    comparison_df = compare_to_targets(all_results)

    # Excel
    out_xlsx = RESULTS_DIR / "model_table4.xlsx"
    with pd.ExcelWriter(out_xlsx, engine="openpyxl") as writer:
        table4_df.to_excel(writer, sheet_name="Table4", index=False)
        comparison_df.to_excel(writer, sheet_name="vs_targets", index=False)
        for method in ["perturbation", "vfi", "projection"]:
            sub = table4_df[table4_df["method"] == method]
            if not sub.empty:
                sub.to_excel(writer, sheet_name=method[:15], index=False)
    log(f"  Saved: {out_xlsx}")

    # Markdown
    out_md = RESULTS_DIR / "model_table4.md"
    with open(out_md, "w") as f:
        f.write("# Model simulation — Table 4 equivalents\n\n")
        f.write("## Regression results\n\n")
        f.write(table4_df.to_markdown(index=False))
        f.write("\n\n## Comparison to paper targets\n\n")
        f.write(comparison_df.to_markdown(index=False))
        f.write("\n\n### Paper targets\n\n")
        tgt_rows = [{"gamma": g, "beta_A": v["beta_A"], "beta_B": v["beta_B"]}
                    for g, v in TABLE4_TARGETS.items()]
        f.write(pd.DataFrame(tgt_rows).to_markdown(index=False))
    log(f"  Saved: {out_md}")

    # Print
    log("\nTable 4:")
    print(table4_df.to_string(index=False))
    log("\nComparison to targets:")
    print(comparison_df.to_string(index=False))


# ══════════════════════════════════════════════════════════════════════════════
# 6. Beta vs gamma plot
# ══════════════════════════════════════════════════════════════════════════════
if all_results:
    fig, ax = plt.subplots(figsize=(7, 4))
    colors  = {"perturbation": "#1f77b4", "vfi": "#2ca02c", "projection": "#d62728"}
    markers = {"perturbation": "o", "vfi": "s", "projection": "^"}

    for method in ["perturbation", "vfi", "projection"]:
        sub = [r for r in all_results if r["method"] == method and
               not np.isnan(r["beta_A"])]
        if not sub:
            continue
        gammas = [r["gamma"] for r in sub]
        betas  = [r["beta_A"] for r in sub]
        ax.plot(gammas, betas,
                color=colors[method], marker=markers[method],
                label=method.capitalize(), lw=2, ms=8)

    tgt_g = sorted(TABLE4_TARGETS.keys())
    tgt_b = [TABLE4_TARGETS[g]["beta_A"] for g in tgt_g]
    ax.plot(tgt_g, tgt_b, "k--", label="Paper target", lw=1.5, ms=6, marker="D")

    ax.set_xlabel("γ (R&D curvature)", fontsize=11)
    ax.set_ylabel("β₁ (Δlog Z ~ Δlog PY)", fontsize=11)
    ax.set_title("R&D pro-cyclicality vs γ: model vs paper", fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    fig.savefig(FIGURES_DIR / "model_beta_vs_gamma.png", dpi=150)
    plt.close(fig)
    log(f"  Saved: {FIGURES_DIR / 'model_beta_vs_gamma.png'}")


log("\n" + "=" * 65)
log("DONE")
log("=" * 65)
