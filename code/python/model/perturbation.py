"""
perturbation.py
---------------
First-order perturbation (linear approximation) around the deterministic
steady state. Uses the Method of Undetermined Coefficients (MUC) rather
than the generalised Schur (QZ) decomposition.

Why not Klein (2000) QZ?
------------------------
With CRS production and endogenous labour (static labour FOC), the
capital–output ratio Ỹ/K̃ is determined entirely by the TFP shock a:

    Ỹ/K̃ = a * ell(a)^(1-α),  ell(a) = [(1-α)*θ*a/W̄]^(1/α)

The marginal product of capital is INDEPENDENT of K̃, so the value
function Ṽ(K̃, a) is LINEAR in K̃ and the optimal R&D choice Z̃ depends
only on a (not K̃). The capital Euler is then degenerate as a constraint
on Z̃ (K̃ does not fluctuate), and the correct perturbation system is the
R&D FOC together with the value-function Bellman.

Log-linearisation system (log-deviations from SS):
  â    = log(a/a_SS)
  Ẑ    = log(Z̃/Z̃_SS)   — R&D log-deviation
  V̂    = log(Ṽ/Ṽ_SS)   — value log-deviation
  Λ̂    = coef_Lam_Z * Ẑ  (∂log Λ̃/∂Ẑ from Λ̃ = β/(1+(λ-1)*η*Z̃^γ))

R&D FOC (log-lin):
  0 = Λ̂ + (γ-1)*Ẑ + E_t[V̂_{t+1}]
  → (coef_Lam_Z + γ - 1)*c_Za + c_Va * ρ_a = 0             ... (i)

Value function (log-lin):
  V̂ = (coeff_D_a * â + coeff_D_Z * Ẑ)/V_SS + β * E_t[V̂_{t+1}]
  → c_Va*(1 - β*ρ_a) = (coeff_D_a + coeff_D_Z*c_Za)/V_SS   ... (ii)

where (from D̃ = F̃(a) - Z̃ - (λ-1)*η*Z̃^γ - δ with K̃=1):
  coeff_D_a = θ*Y_SS        (∂D̃/∂a * a, using F̃ ∝ a^{1/α})
  coeff_D_Z = -(Z̃_SS + (λ-1)*P_SS*γ)   (∂D̃/∂Z̃ * Z̃_SS)

Jointly solving (i) and (ii):
  Define A = -(coef_Lam_Z + γ - 1)/ρ_a, so c_Va = A * c_Za.
  Substituting into (ii):
    A * c_Za * (1 - β*ρ_a) = (coeff_D_a + coeff_D_Z*c_Za)/V_SS
    c_Za = coeff_D_a / [A*(1-β*ρ_a)*V_SS - coeff_D_Z]
    c_Va = A * c_Za

Simulation note:
  The state is â_t (log TFP deviation). Each firm has an independent AR(1):
    â_{i,t+1} = ρ_a * â_{i,t} + σ_a * ε_{i,t+1}
  Policy function:
    Ẑ_{i,t} = c_Za * â_{i,t}
  Level R&D: Z_{it} = Z̃_SS * exp(Ẑ_{it}) * Q_{it}
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from .params import ModelParams
from .steady_state import SteadyState, solve as solve_ss


@dataclass
class PerturbationSolution:
    """
    First-order perturbation policy functions.

    Policy (log-deviations from SS):
      Ẑ_{i,t}  = c_Za * â_{i,t}
      V̂_{i,t}  = c_Va * â_{i,t}

    State dynamics:
      â_{i,t+1} = ρ_a * â_{i,t} + σ_a * ε_{i,t+1}
    """
    c_Za: float      # ∂Ẑ/∂â  (R&D log-elasticity w.r.t. TFP)
    c_Va: float      # ∂V̂/∂â  (value log-elasticity w.r.t. TFP)
    ss:   SteadyState
    p:    ModelParams

    # Diagnostic coefficients (for checking / exposition)
    coef_Lam_Z:  float = 0.0   # ∂log(Λ̃)/∂Ẑ
    mpk_share:   float = 0.0   # Λ̃_SS * α*θ*Y/K  (capital Euler weight)

    def policy_Z(self, a_hat: np.ndarray) -> np.ndarray:
        """Z̃ given log-TFP deviation â (array-safe)."""
        return self.ss.Z_tilde * np.exp(self.c_Za * a_hat)

    def simulate(self, N: int = None, T: int = None, seed: int = 42) -> dict:
        """
        Simulate N firms × T periods.
        Returns dict with 'Z_tilde', 'Y_tilde', 'a' (all shape (N, T)).
        """
        p = self.p; ss = self.ss
        if N is None: N = p.N_firms
        if T is None: T = p.T_sim
        T_total = T + p.T_burn

        rng = np.random.default_rng(seed)
        eps = rng.standard_normal((N, T_total))

        a_hat = np.zeros((N, T_total))
        for t in range(1, T_total):
            a_hat[:, t] = p.rho_a * a_hat[:, t-1] + p.sigma_a * eps[:, t]

        # Policy functions
        Z_hat = self.c_Za * a_hat
        # Output log-deviation: Ŷ = â/α
        Y_hat = a_hat / p.alpha

        # Discard burn-in
        a_hat  = a_hat[:, p.T_burn:]
        Z_hat  = Z_hat[:, p.T_burn:]
        Y_hat  = Y_hat[:, p.T_burn:]

        return {
            "a_hat":   a_hat,
            "Z_hat":   Z_hat,
            "Y_hat":   Y_hat,
            "Z_tilde": ss.Z_tilde * np.exp(Z_hat),
            "Y_tilde": ss.Y_tilde * np.exp(Y_hat),
            "a":       np.exp(a_hat),
        }


def solve(p: ModelParams, verbose: bool = False) -> PerturbationSolution:
    """
    Compute first-order perturbation policy functions analytically.

    Jointly solves the log-linearised R&D FOC and Bellman equation for
    (c_Za, c_Va) — the coefficients on â in the R&D and value policies.

    Parameters
    ----------
    p       : ModelParams
    verbose : print diagnostic output

    Returns
    -------
    PerturbationSolution with c_Za, c_Va
    """
    ss = solve_ss(p, verbose=False)

    alpha = p.alpha; theta = p.theta; beta = p.beta
    lam = p.lam; gamma = p.gamma; eta = p.eta
    rho_a = p.rho_a; P_SS = p.P_SS

    Y_SS  = ss.Y_tilde; K_SS = ss.K_tilde; Z_SS = ss.Z_tilde
    D_SS  = ss.D_tilde; V_SS = ss.V_tilde; Lam_SS = ss.Lambda

    # ── Step 1: Discount-factor elasticity ────────────────────────────────────
    # Λ̃ = β/(1+(λ-1)*η*Z̃^γ)  →  ∂log(Λ̃)/∂Ẑ = -γ*(λ-1)*P_SS/(1+(λ-1)*P_SS)
    Q_step_SS  = 1.0 + (lam - 1.0) * P_SS
    P_frac     = (lam - 1.0) * P_SS / Q_step_SS
    coef_Lam_Z = -gamma * P_frac           # ∂log(Λ̃)/∂Ẑ  (negative)

    # ── Step 2: Dividend partial derivatives at SS ────────────────────────────
    # D̃(a, Z̃) = F̃(a) - Z̃ - (λ-1)*η*Z̃^γ - δ  with K̃=1
    # F̃(a) = θ*Ỹ(a) - W̄*L(a) = α*θ*Ỹ(a)  (labour FOC → W̄*L = (1-α)*θ*Ỹ)
    # ∂D̃/∂a * a_SS = ∂F̃/∂a * a_SS = (1/α)*F̃_SS = θ*Y_SS
    #   [since F̃ ∝ a^{1/α} → elasticity 1/α → ∂F̃/∂a*a = F̃/α = α*θ*Y/α = θ*Y]
    # ∂D̃/∂Z̃ * Z̃_SS = [-1 - (λ-1)*η*γ*Z̃^{γ-1}] * Z̃_SS
    #                = -Z̃_SS - (λ-1)*P_SS*γ
    coeff_D_a = theta * Y_SS                           # ∂D̃/∂a * a_SS
    coeff_D_Z = -(Z_SS + (lam - 1.0) * P_SS * gamma)  # ∂D̃/∂Z̃ * Z̃_SS

    # ── Step 3: Solve 2×2 system for (c_Za, c_Va) ────────────────────────────
    # R&D FOC log-lin:  (coef_Lam_Z + γ - 1)*c_Za + c_Va*ρ_a = 0    ... (i)
    # Value fn log-lin: c_Va*(1 - β*ρ_a) = (coeff_D_a + coeff_D_Z*c_Za)/V_SS ... (ii)
    #
    # From (i):  c_Va = A * c_Za,  where A = -(coef_Lam_Z + γ - 1)/ρ_a
    # Substituting into (ii):
    #   A*c_Za*(1-β*ρ_a) = (coeff_D_a + coeff_D_Z*c_Za)/V_SS
    #   c_Za * [A*(1-β*ρ_a)*V_SS - coeff_D_Z] = coeff_D_a
    A = -(coef_Lam_Z + gamma - 1.0) / rho_a

    denom = A * (1.0 - beta * rho_a) * V_SS - coeff_D_Z
    if abs(denom) < 1e-14:
        raise ValueError(f"Perturbation system singular (denom={denom:.3e}).")

    c_Za = coeff_D_a / denom
    c_Va = A * c_Za

    # ── Step 4: Internal consistency check ───────────────────────────────────
    # c_Va from VF Bellman should match c_Va from the R&D FOC by construction.
    # Cross-check: c_Va*(1-β*ρ_a) == (coeff_D_a + coeff_D_Z*c_Za)/V_SS
    vf_lhs = c_Va * (1.0 - beta * rho_a)
    vf_rhs = (coeff_D_a + coeff_D_Z * c_Za) / V_SS
    residual = abs(vf_lhs - vf_rhs)

    if verbose:
        print(f"\nPerturbation solution (γ={gamma:.2f}):")
        print(f"  coef_Lam_Z  = {coef_Lam_Z:.6f}  (∂log Λ̃/∂Ẑ)")
        print(f"  A           = {A:.6f}  (-(coef_Lam_Z+γ-1)/ρ_a)")
        print(f"  coeff_D_a   = {coeff_D_a:.6f}  (∂D̃/∂a * a_SS)")
        print(f"  coeff_D_Z   = {coeff_D_Z:.6f}  (∂D̃/∂Z̃ * Z̃_SS)")
        print(f"  c_Za        = {c_Za:.6f}  (R&D log-elasticity w.r.t. TFP)")
        print(f"  c_Va        = {c_Va:.6f}  (value log-elasticity w.r.t. TFP)")
        print(f"  VF residual = {residual:.3e}  (should be ~0)")
        if residual > 1e-10:
            print(f"  WARNING: VF residual too large ({residual:.3e})")

    return PerturbationSolution(
        c_Za=c_Za, c_Va=c_Va,
        ss=ss, p=p,
        coef_Lam_Z=coef_Lam_Z,
        mpk_share=0.0,   # not used; retained for API compatibility
    )
