"""
steady_state.py
---------------
Solve the deterministic steady state of the stationary R&D model.

Normalisation
-------------
Because production is CRS in (K̃, L), levels are indeterminate.
We normalise K̃_SS = 1 and treat the wage W̄ as *endogenously determined*
from the capital Euler + labour FOC.

Step 1: From the capital Euler, compute the steady-state Ỹ/K̃ ratio:
          YK* = [1/Λ̃_SS - 1 + δ] / (α*θ)
        Then with K̃_SS=1: Ỹ_SS = YK*.

Step 2: From Ỹ = a_SS*K̃^α*L^(1-α) and K̃_SS=1:
          L_SS = (Ỹ_SS / a_SS)^(1/(1-α))

Step 3: W̄ is then pinned by the labour FOC:
          W̄ = (1-α)*θ*Ỹ_SS / L_SS

Step 4: Base dividends (before Z̃):
          base_D = θ*Ỹ_SS - W̄*L_SS - δ*K̃_SS = α*θ*Ỹ_SS - δ

Step 5: Solve R&D FOC (with η calibrated to match P_SS) for Z̃_SS:
          D̃ = base_D - Z̃
          Ṽ  = D̃/(1-β)
          FOC: 1 = Λ̃*η*γ*Z̃^(γ-1)*(λ-1)*Ṽ
          η = P_SS / Z̃^γ  → FOC becomes: 1 = Λ̃*P_SS*γ/Z̃*(λ-1)*Ṽ

Note: the wage W̄ is stored in the SteadyState but NOT written back to params,
since it varies with γ only through Z̃ (which doesn't affect W̄). In practice
W̄ is the same for all γ. Simulation code must use ss.W_bar, not p.W_bar.
"""

from __future__ import annotations
import numpy as np
from scipy.optimize import brentq
from dataclasses import dataclass, field
from .params import ModelParams


@dataclass
class SteadyState:
    """Container for steady-state values."""
    K_tilde: float   # K̃_SS  = 1 by normalisation
    L:        float  # L_SS
    Z_tilde: float   # Z̃_SS
    Y_tilde: float   # Ỹ_SS
    D_tilde: float   # D̃_SS
    V_tilde: float   # Ṽ_SS
    eta:      float  # calibrated η = P_SS / Z̃^γ
    P:        float  # innovation prob at SS (≡ P_SS)
    Lambda:   float  # Λ̃_SS
    W_bar:    float  # endogenous wage


def solve(p: ModelParams, a_SS: float = 1.0, verbose: bool = False) -> SteadyState:
    """
    Solve the deterministic steady state.

    Parameters
    ----------
    p      : ModelParams
    a_SS   : normalised TFP level (default 1.0)
    verbose: print intermediate results

    Returns
    -------
    SteadyState; also sets p.eta in-place.
    """
    alpha = p.alpha; delta = p.delta; beta = p.beta
    theta = p.theta; lam = p.lam; gamma = p.gamma; P_SS = p.P_SS
    Lam   = p.Lambda_SS   # β/(1+(λ-1)*P_SS)

    # ── Step 1: YK ratio from capital Euler ────────────────────────────────────
    # 1 = Λ̃*[1-δ + α*θ*Ỹ/K̃]  →  Ỹ/K̃ = [1/Λ̃ - 1 + δ]/(α*θ)
    YK_ratio = (1.0/Lam - 1.0 + delta) / (alpha * theta)

    # ── Step 2: Level K̃=1, compute L and Y ────────────────────────────────────
    K_tilde_SS = 1.0
    Y_tilde_SS = YK_ratio * K_tilde_SS   # = YK_ratio with K̃=1
    # Ỹ = a*K̃^α*L^(1-α) → L = (Ỹ/(a*K̃^α))^(1/(1-α))
    L_SS = (Y_tilde_SS / (a_SS * K_tilde_SS**alpha))**(1.0/(1.0-alpha))

    # ── Step 3: Wage from labour FOC ───────────────────────────────────────────
    # W̄ = (1-α)*θ*Ỹ/L
    W_bar_SS = (1.0-alpha)*theta*Y_tilde_SS / L_SS

    # ── Step 4: Base dividends ─────────────────────────────────────────────────
    # From paper (stationary system, eq after eq.288):
    #   D̃ = θ*Ỹ - W̃*L - Ĩ - Z̃
    # where Ĩ = (1+(λ-1)*P_SS)*K̃' - (1-δ)*K̃  (investment identity)
    # At SS: K̃' = K̃ = K̃_SS, so:
    #   Ĩ_SS = K̃_SS*(δ + (λ-1)*P_SS)
    # base_D = θ*Ỹ - W̃*L - Ĩ_SS  (before subtracting Z̃)
    I_SS = K_tilde_SS * (delta + (lam - 1.0) * P_SS)
    base_D = theta*Y_tilde_SS - W_bar_SS*L_SS - I_SS

    if verbose:
        print(f"\n  Steady-state (K̃=1 normalisation, γ={gamma}):")
        print(f"  Λ̃_SS   = {Lam:.6f}")
        print(f"  Ỹ/K̃    = {YK_ratio:.6f}")
        print(f"  K̃_SS   = {K_tilde_SS:.6f}")
        print(f"  L_SS   = {L_SS:.6f}")
        print(f"  Ỹ_SS   = {Y_tilde_SS:.6f}")
        print(f"  W̄_SS  = {W_bar_SS:.6f}")
        print(f"  base_D = {base_D:.6f}  (should be >0)")
        euler_check = Lam*(1 - delta + alpha*theta*Y_tilde_SS/K_tilde_SS)
        print(f"  Euler check Λ̃*(1-δ+α*θ*YK) = {euler_check:.6f} (target 1)")

    if base_D <= 0:
        raise ValueError(
            f"base_D = {base_D:.4f} ≤ 0. Capital cost exceeds net revenues. "
            f"Check: α={alpha}, δ={delta}, θ={theta:.4f}, Λ̃={Lam:.4f}."
        )

    # ── Step 5: Solve R&D FOC for Z̃_SS ────────────────────────────────────────
    # η calibrated: P_SS = η*Z̃^γ → η = P_SS/Z̃^γ
    # FOC: 1 = Λ̃*(P_SS/Z̃^γ)*γ*Z̃^(γ-1)*(λ-1)*Ṽ(Z̃)
    #        = Λ̃*P_SS*γ/Z̃*(λ-1)*Ṽ(Z̃)
    # Ṽ(Z̃) = (base_D - Z̃)/(1-β)
    # Bracket: Z̃ ∈ (0, base_D)
    #   at Z̃→0: Ṽ→base_D/(1-β) large, rhs→+∞ → res<0
    #   at Z̃→base_D: Ṽ→0, rhs→0 → res>0

    def rnd_foc_residual(Z_tilde: float) -> float:
        D_tilde = base_D - Z_tilde
        if D_tilde <= 0:
            return 1.0
        V_tilde = D_tilde / (1.0 - beta)
        rhs = Lam * P_SS * gamma / Z_tilde * (lam - 1.0) * V_tilde
        return 1.0 - rhs

    Z_lo = 1e-10
    Z_hi = base_D * (1.0 - 1e-6)

    f_lo = rnd_foc_residual(Z_lo)
    f_hi = rnd_foc_residual(Z_hi)

    if f_lo * f_hi > 0:
        raise ValueError(
            f"R&D FOC: cannot bracket root. "
            f"f({Z_lo:.2e})={f_lo:.4f}, f({Z_hi:.4f})={f_hi:.4f}. "
            f"base_D={base_D:.6f}, Lam={Lam:.6f}, gamma={gamma}, "
            f"P_SS={P_SS}, lam={lam}, beta={beta}."
        )

    Z_tilde_SS = brentq(rnd_foc_residual, Z_lo, Z_hi, xtol=1e-12, rtol=1e-12)
    D_tilde_SS = base_D - Z_tilde_SS
    V_tilde_SS = D_tilde_SS / (1.0 - beta)
    eta_SS     = P_SS / Z_tilde_SS**gamma

    if verbose:
        print(f"  Z̃_SS  = {Z_tilde_SS:.6f}")
        print(f"  D̃_SS  = {D_tilde_SS:.6f}")
        print(f"  Ṽ_SS  = {V_tilde_SS:.6f}")
        print(f"  η_SS  = {eta_SS:.6f}")
        P_check = eta_SS * Z_tilde_SS**gamma
        print(f"  P(Z̃_SS) = {P_check:.6f} (target {P_SS})")
        foc_ok = Lam * eta_SS*gamma*Z_tilde_SS**(gamma-1)*(lam-1)*V_tilde_SS
        print(f"  R&D FOC = {foc_ok:.6f} (target 1)")

    # Store η in params for use by simulation/perturbation/VFI
    p.eta = eta_SS
    # Store W̄ in params (overwrite the placeholder 1.0)
    p.W_bar = W_bar_SS

    return SteadyState(
        K_tilde = K_tilde_SS,
        L       = L_SS,
        Z_tilde = Z_tilde_SS,
        Y_tilde = Y_tilde_SS,
        D_tilde = D_tilde_SS,
        V_tilde = V_tilde_SS,
        eta     = eta_SS,
        P       = P_SS,
        Lambda  = Lam,
        W_bar   = W_bar_SS,
    )


def check_ss(ss: SteadyState, p: ModelParams, tol: float = 1e-6) -> dict:
    """
    Verify all steady-state conditions.
    Returns dict of residuals; raises if any > tol.
    """
    alpha = p.alpha; delta = p.delta; beta = p.beta
    theta = p.theta; lam = p.lam; gamma = p.gamma

    K = ss.K_tilde; L = ss.L; Z = ss.Z_tilde
    Y = ss.Y_tilde; D = ss.D_tilde; V = ss.V_tilde
    Lam = ss.Lambda; eta = ss.eta; W_bar = ss.W_bar

    # (1) Production (a_SS=1)
    r1 = abs(Y - K**alpha * L**(1-alpha))

    # (2) Labour FOC
    r2 = abs(W_bar - (1-alpha)*theta*Y/L)

    # (3) Capital Euler
    r3 = abs(1.0 - Lam*(1 - delta + alpha*theta*Y/K))

    # (4) R&D FOC
    r4 = abs(1.0 - Lam*eta*gamma*Z**(gamma-1)*(lam-1)*V)

    # (5) Value function
    r5 = abs(V*(1-beta) - D)

    # (6) Dividends: D̃ = θỸ - W̄L - Z̃ - Ĩ, where Ĩ = (δ+(λ-1)*P_SS)*K̃
    I_SS = K * (delta + (lam - 1.0) * ss.P)
    r6 = abs(D - (theta*Y - W_bar*L - Z - I_SS))

    residuals = {"production": r1, "labour_foc": r2, "capital_euler": r3,
                 "rnd_foc": r4, "value_fn": r5, "dividends": r6}

    for name, resid in residuals.items():
        assert resid < tol, (
            f"SS check FAILED — {name}: residual = {resid:.3e} > tol={tol:.1e}. "
            f"(gamma={gamma}, K̃={K:.4f}, L={L:.4f}, Z̃={Z:.4f}, Ỹ={Y:.4f})"
        )
    return residuals
