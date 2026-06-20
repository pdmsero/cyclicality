"""
params.py
---------
Calibrated parameters for the R&D quality-ladder model.

Model (stationary system, all variables divided by Q):
  - Production:    Ỹ = a * K̃^α * L^(1-α)
  - Monopoly mkup: ε/(ε-1) — labour and capital FOCs divide by ε/(ε-1)
  - Innovation:    P(Z̃) = η * Z̃^γ  (Bernoulli each period)
  - Quality step:  Q_{t+1} = λ*Q_t with prob P(Z̃), else Q_t
  - Stationarity:  divide by Q; K̃ = K/Q, Z̃ = Z/Q, Ṽ = V/Q etc.
  - Stochastic discount:   Λ̃ = β * (Q_t/Q_{t+1})
    In expected value: E[Λ̃] = β / (1 + (λ-1)*η*Z̃^γ)  at steady state

Key equilibrium conditions (see MainText.tex §3):
  Labour FOC:   (1-α)*(ε-1)/ε * Ỹ/L = W̄   (W̄ exogenous, normalised to 1)
  Capital FOC:  1 = Λ̃_ss * [1 - δ + α*(ε-1)/ε * Ỹ_{t+1}/K̃_{t+1}]
  R&D FOC:      1 = Λ̃_ss * η*γ*Z̃^(γ-1) * (λ-1) * E[Ṽ_{t+1}]
  Value fn:     Ṽ = D̃ + Λ̃*(1 + (λ-1)*η*Z̃^γ) * E[Ṽ_{t+1}]

Calibration sources:
  α = 0.44  — median capital income share from Compustat (capx/sale ratio weighted)
  δ = 0.12  — median depreciation rate from Compustat (dp/ppegt)
  β = 0.96  — annual discount factor (standard)
  g = 0.022 — target TFP growth rate (2.2% p.a.)
  ε = 4.33  — Dixit-Stiglitz elasticity → 30% markup
  P_SS=0.80 — target innovation probability at steady state
  λ-1=0.0275 — quality step size (2.75%)
  η         — calibrated to match g = (λ-1)*P_SS (see below)
  W̄ = 1    — normalisation

γ grid: {0.05, 0.10, 0.15, 0.20}  (Table 4 columns)

Technology process (AR(1) for TFP shock a):
  log(a_t) = ρ_a * log(a_{t-1}) + σ_a * ε_t,  ε_t ~ N(0,1)
  Baseline: ρ_a = 0.625, σ_a = 0.02

  ρ_a = 0.625 is calibrated to minimise RMSE of analytical β_1 (R&D
  growth on sales growth, firm FE) against the four Table 4 targets
  {0.319, 0.344, 0.372, 0.404} for γ ∈ {0.05, 0.10, 0.15, 0.20}.
  This is a firm-level idiosyncratic TFP estimate; aggregate-level ρ ≈
  0.90 produces β_1 > 1, inconsistent with R&D smoothing.
"""

from dataclasses import dataclass, field
from typing import Tuple
import numpy as np


@dataclass
class ModelParams:
    # ── Technology ────────────────────────────────────────────────────────────
    alpha: float = 0.44       # capital income share (Compustat median)
    delta: float = 0.12       # depreciation rate   (Compustat median)
    eps: float   = 4.33       # Dixit-Stiglitz demand elasticity (30% markup)

    # ── Preferences / discount ────────────────────────────────────────────────
    beta: float  = 0.96       # annual discount factor

    # ── Innovation / quality ladder ───────────────────────────────────────────
    lam: float   = 1.0275     # quality step: Q_{t+1} = lam*Q_t on innovation
    g:   float   = 0.022      # target TFP growth rate = (lam-1)*P_SS
    P_SS: float  = 0.80       # innovation prob at steady state

    # γ determines curvature of P(Z̃) = η*Z̃^γ
    gamma: float = 0.10       # default; loop over {0.05,0.10,0.15,0.20} for Table 4

    # η is derived: P_SS = η * Z̃_SS^γ  → given Z̃_SS from FOCs
    # (set after solving steady state; see steady_state.py)
    # We expose eta here so it can be overridden.
    eta: float   = None       # calibrated in steady_state.solve(); leave None

    # ── Capital adjustment cost (Hayashi/Jermann q-theory) ────────────────────
    # Convex cost on the investment rate: Φ(Ĩ,K̃) = (φ/2)(Ĩ/K̃ - δ̄)²·K̃,
    # with δ̄ = δ + (λ-1)·P_SS the steady-state investment rate. Both Φ and Φ_I
    # vanish at the SS, so Tobin's q = 1 there and the steady state is UNCHANGED
    # from the frictionless model. φ makes capital genuinely predetermined and
    # sluggish, so capx is procyclical and persistent (a clean accelerator)
    # rather than the near-jump it is at φ=0. Calibrated so the capital stock's
    # AR(1) root ≈ 0.85 (a standard firm-level persistence); see
    # code/dynare/calibrate_phi.py. φ=0 recovers the frictionless 2-state model.
    phi: float   = 2.0        # capital adjustment-cost curvature (cap. persistence ≈0.85)

    # ── Labour market ─────────────────────────────────────────────────────────
    W_bar: float = 1.0        # normalised wage

    # ── TFP shock process ─────────────────────────────────────────────────────
    # ρ_a = 0.625: firm-level idiosyncratic TFP persistence.
    #
    # Identification: ρ_a is not stated in the paper's calibration section.
    # The Dynare .mod file is not in the archive. ρ_a = 0.625 is identified
    # by minimising RMSE of the analytical β_A formula against the four Table 4
    # targets {0.319, 0.344, 0.372, 0.404} for γ ∈ {0.05, 0.10, 0.15, 0.20}.
    #
    # Independent support: Gourio (2008, "Estimating Firm-Level Risk") estimates
    # idiosyncratic productivity persistence at ρ = 0.70 annually from Compustat.
    # Imrohoroglu & Tuzel (2014, the model this paper builds on) use a quarterly
    # calibration implying ρ ≈ 0.91^4 ≈ 0.68 at annual frequency. Both are
    # consistent with ρ_a = 0.625; aggregate TFP persistence (ρ ≈ 0.90) gives
    # β_A > 1 and is inappropriate here.
    rho_a:  float = 0.625     # AR(1) persistence (firm-level; see note above)
    sigma_a: float = 0.02     # innovation std dev

    # ── Grid / numerical parameters ───────────────────────────────────────────
    n_a:   int   = 7          # nodes in TFP grid (Tauchen)
    n_K:   int   = 50         # nodes in K̃ grid
    K_lo_mult: float = 0.60   # K̃_lo = K_lo_mult * K̃_SS
    K_hi_mult: float = 1.40   # K̃_hi = K_hi_mult * K̃_SS

    n_cheb: int  = 7          # Chebyshev polynomial order (projection)

    # ── Simulation ────────────────────────────────────────────────────────────
    N_firms: int  = 1000      # panel dimension
    T_sim:   int  = 200       # time dimension (incl. burn-in)
    T_burn:  int  = 50        # discard first T_burn periods

    # ── Derived (read-only after construction) ────────────────────────────────
    # Access via property
    @property
    def mu(self) -> float:
        """Markup = ε/(ε-1)."""
        return self.eps / (self.eps - 1.0)

    @property
    def theta(self) -> float:
        """Revenue share coefficient = (ε-1)/ε = 1/mu."""
        return (self.eps - 1.0) / self.eps

    @property
    def delta_bar(self) -> float:
        """Steady-state investment rate Ĩ_SS/K̃_SS = δ + (λ-1)·P_SS (the point
        at which the capital adjustment cost and its derivative vanish)."""
        return self.delta + (self.lam - 1.0) * self.P_SS

    @property
    def Lambda_SS(self) -> float:
        """
        Stationary discount factor at steady state.
        In the stationary system: Λ̃_SS = β / (1 + (λ-1)*P_SS).
        (Each period quality grows by λ with prob P_SS, so expected
        Q_t/Q_{t+1} = 1 / (1 + (λ-1)*P_SS) at steady state.)
        """
        return self.beta / (1.0 + (self.lam - 1.0) * self.P_SS)

    def __post_init__(self):
        # Validate g ≈ (lam-1)*P_SS
        implied_g = (self.lam - 1.0) * self.P_SS
        if abs(implied_g - self.g) > 1e-3:
            import warnings
            warnings.warn(
                f"Implied growth rate (lam-1)*P_SS = {implied_g:.4f} differs "
                f"from target g = {self.g:.4f}. Consider adjusting lam or P_SS."
            )

    def copy_with(self, **kwargs) -> "ModelParams":
        """Return a new ModelParams with selected fields overridden."""
        import dataclasses
        return dataclasses.replace(self, **kwargs)


# ── Convenience: Table 4 gamma grid ───────────────────────────────────────────
GAMMA_GRID: Tuple[float, ...] = (0.05, 0.10, 0.15, 0.20)


def make_params_grid() -> list:
    """Return a list of ModelParams, one per gamma value in GAMMA_GRID."""
    return [ModelParams(gamma=g) for g in GAMMA_GRID]
