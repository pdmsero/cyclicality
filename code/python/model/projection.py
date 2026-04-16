"""
projection.py
-------------
Chebyshev projection solution for the R&D model.

Because the value function is linear in K̃ (CRS + endogenous labour), the
model reduces to a 1-dimensional problem in a only. We approximate V(a) and
Z̃(a) using Chebyshev polynomials on the TFP support [a_lo, a_hi] and solve
the residual equations at Chebyshev collocation nodes.

Algorithm:
  1. Define TFP support: [a_lo, a_hi] = [exp(-m*σ_x), exp(m*σ_x)] where
     σ_x = σ_a/√(1-ρ_a²) is the unconditional standard deviation.
  2. Place n_proj Chebyshev nodes in log-a space and map to a-space.
  3. Iterate:
       a. Compute EV_j = E[V(a') | a_j] using Tauchen transition from a_j.
       b. Solve R&D FOC at each node: 1 = Λ̃(Z̃_j)*(λ-1)*η*γ*Z̃_j^(γ-1)*EV_j.
       c. Update V_j = D̃(a_j, Z̃_j) + β*EV_j.
       d. Re-fit Chebyshev coefficients via least squares.
  4. Store coefficients for interpolation during simulation.

Convergence criterion: sup_j |V_j^{n+1} - V_j^n| < tol.
"""

from __future__ import annotations
import numpy as np
from scipy.optimize import brentq
from scipy.stats import norm as scipy_norm
from dataclasses import dataclass
from .params import ModelParams
from .steady_state import SteadyState, solve as solve_ss
from .vfi import tauchen   # reuse Tauchen discretisation


@dataclass
class ProjectionSolution:
    """
    Chebyshev projection solution.

    pol_Z       : R&D policy at Chebyshev collocation nodes  (n_proj,)
    V           : Value function at collocation nodes         (n_proj,)
    a_grid      : Chebyshev collocation nodes in a-space      (n_proj,)
    P_a         : Tauchen transition matrix for simulation    (n_a, n_a)
    a_sim_grid  : Tauchen a-grid for simulation               (n_a,)
    theta_V     : Chebyshev coefficients for V                (n_proj,)
    theta_Z     : Chebyshev coefficients for log Z̃            (n_proj,)
    ss, p       : steady state and parameters
    a_lo, a_hi  : TFP support bounds
    """
    pol_Z:       np.ndarray
    V:           np.ndarray
    a_grid:      np.ndarray
    P_a:         np.ndarray
    a_sim_grid:  np.ndarray
    theta_V:     np.ndarray
    theta_Z:     np.ndarray
    ss:          SteadyState
    p:           ModelParams
    a_lo:        float
    a_hi:        float

    def eval_Z(self, a: float) -> float:
        """Evaluate R&D policy at arbitrary a by Chebyshev interpolation."""
        x = _a_to_x(np.array([a]), self.a_lo, self.a_hi)[0]
        x = float(np.clip(x, -1.0, 1.0))
        return float(np.exp(cheb_basis(x, len(self.theta_Z)) @ self.theta_Z))

    def eval_V(self, a: float) -> float:
        """Evaluate value function at arbitrary a by Chebyshev interpolation."""
        x = _a_to_x(np.array([a]), self.a_lo, self.a_hi)[0]
        x = float(np.clip(x, -1.0, 1.0))
        return float(cheb_basis(x, len(self.theta_V)) @ self.theta_V)


# ---------------------------------------------------------------------------
# Chebyshev utilities
# ---------------------------------------------------------------------------

def cheb_nodes(n: int) -> np.ndarray:
    """Chebyshev nodes on [-1, 1]: x_j = cos((2j-1)π/(2n)), j=1,...,n."""
    j = np.arange(1, n + 1)
    return np.cos((2 * j - 1) * np.pi / (2 * n))


def cheb_basis(x: float, n: int) -> np.ndarray:
    """Evaluate Chebyshev basis T_0,...,T_{n-1} at scalar x ∈ [-1,1]."""
    T = np.zeros(n)
    T[0] = 1.0
    if n > 1:
        T[1] = x
    for k in range(2, n):
        T[k] = 2.0 * x * T[k-1] - T[k-2]
    return T


def cheb_basis_matrix(x_vec: np.ndarray, n: int) -> np.ndarray:
    """Chebyshev basis for all x in x_vec. Returns (len(x_vec), n)."""
    m = len(x_vec)
    B = np.zeros((m, n))
    B[:, 0] = 1.0
    if n > 1:
        B[:, 1] = x_vec
    for k in range(2, n):
        B[:, k] = 2.0 * x_vec * B[:, k-1] - B[:, k-2]
    return B


def _a_to_x(a_vec: np.ndarray, a_lo: float, a_hi: float) -> np.ndarray:
    """Map a ∈ [a_lo, a_hi] to x ∈ [-1, 1] via log scale."""
    log_lo = np.log(a_lo); log_hi = np.log(a_hi)
    return 2.0 * (np.log(a_vec) - log_lo) / (log_hi - log_lo) - 1.0


# ---------------------------------------------------------------------------
# Main solver
# ---------------------------------------------------------------------------

def solve(p: ModelParams, n_proj: int = 12, m_tauchen: float = 3.0,
          tol: float = 1e-8, max_iter: int = 3000,
          verbose: bool = False) -> ProjectionSolution:
    """
    Solve the model by Chebyshev projection on the TFP support.

    Parameters
    ----------
    p         : ModelParams
    n_proj    : number of Chebyshev collocation nodes (= polynomial degree)
    m_tauchen : width of TFP support in unconditional std devs
    tol       : convergence tolerance on sup|ΔV|
    max_iter  : maximum iterations
    verbose   : print iteration progress

    Returns
    -------
    ProjectionSolution
    """
    ss = solve_ss(p, verbose=False)

    alpha = p.alpha; delta = p.delta; beta = p.beta
    theta = p.theta; lam = p.lam; gamma = p.gamma; eta = p.eta
    W_bar = ss.W_bar

    # ── TFP support ────────────────────────────────────────────────────────
    sigma_x  = p.sigma_a / np.sqrt(1.0 - p.rho_a ** 2)
    log_a_lo = -m_tauchen * sigma_x
    log_a_hi =  m_tauchen * sigma_x
    a_lo = np.exp(log_a_lo); a_hi = np.exp(log_a_hi)

    # Chebyshev nodes (in [-1,1]) and corresponding a-values
    x_nodes = cheb_nodes(n_proj)                   # (n_proj,)
    a_nodes = np.exp(log_a_lo +
                     (x_nodes + 1.0) / 2.0 * (log_a_hi - log_a_lo))

    # Basis matrix at collocation nodes
    B = cheb_basis_matrix(x_nodes, n_proj)         # (n_proj, n_proj)

    # ── Fine Tauchen grid for computing conditional expectations ───────────
    n_fine = max(p.n_a, 25)
    log_a_fine, P_a_fine = tauchen(p.rho_a, p.sigma_a, n_fine, m=m_tauchen)
    a_fine = np.exp(log_a_fine)
    x_fine = _a_to_x(a_fine, a_lo, a_hi)
    x_fine = np.clip(x_fine, -1.0, 1.0)
    B_fine = cheb_basis_matrix(x_fine, n_proj)    # (n_fine, n_proj)

    # Coarser Tauchen grid for simulation
    log_a_sim, P_a_sim = tauchen(p.rho_a, p.sigma_a, p.n_a, m=m_tauchen)
    a_sim = np.exp(log_a_sim)

    # ── Base dividends (before subtracting Z̃ terms) ───────────────────────
    def base_div(a_vec: np.ndarray) -> np.ndarray:
        ell = ((1.0 - alpha) * theta * a_vec / W_bar) ** (1.0 / alpha)
        L   = ell   # K̃ = 1
        Y   = a_vec * L ** (1.0 - alpha)
        return theta * Y - W_bar * L - delta

    base_D_nodes = base_div(a_nodes)  # (n_proj,)

    # ── R&D FOC solver at a single node ───────────────────────────────────
    def compute_Z_node(EV: float, base_D_j: float) -> float:
        if EV <= 0.0 or base_D_j <= 0.0:
            return ss.Z_tilde * 1e-4
        def foc(z):
            P_inn = eta * max(z, 1e-20) ** gamma
            Lam   = beta / (1.0 + (lam - 1.0) * P_inn)
            return 1.0 - Lam * (lam - 1.0) * eta * gamma * z ** (gamma - 1.0) * EV
        z_lo, z_hi = 1e-10, base_D_j * 0.9999
        try:
            if foc(z_lo) * foc(z_hi) >= 0:
                return ss.Z_tilde
            return brentq(foc, z_lo, z_hi, xtol=1e-12, rtol=1e-12)
        except ValueError:
            return ss.Z_tilde

    # ── Initialise from SS ─────────────────────────────────────────────────
    V_nodes = np.full(n_proj, ss.V_tilde)
    Z_nodes = np.full(n_proj, ss.Z_tilde)
    theta_V = np.linalg.lstsq(B, V_nodes, rcond=None)[0]
    theta_Z = np.linalg.lstsq(B, np.log(np.maximum(Z_nodes, 1e-20)),
                               rcond=None)[0]

    # ── Iteration ──────────────────────────────────────────────────────────
    for it in range(max_iter):
        # V at fine grid by Chebyshev interpolation
        V_fine = B_fine @ theta_V                  # (n_fine,)

        # EV at collocation nodes: use fine Tauchen transition.
        # For each collocation node a_j, approximate E[V(a')|a_j] by
        # conditional normal transition (continuous approximation).
        EV_nodes = np.zeros(n_proj)
        for j, a_j in enumerate(a_nodes):
            log_aj    = np.log(a_j)
            mu_next   = p.rho_a * log_aj
            probs     = scipy_norm.pdf(log_a_fine, loc=mu_next, scale=p.sigma_a)
            probs    /= probs.sum()
            EV_nodes[j] = probs @ V_fine

        # Solve Z̃ at each node
        Z_new = np.array([
            compute_Z_node(EV_nodes[j], base_D_nodes[j])
            for j in range(n_proj)
        ])

        # Update V at collocation nodes
        P_inn_nodes = eta * np.maximum(Z_new, 1e-20) ** gamma
        D_nodes     = base_D_nodes - Z_new - (lam - 1.0) * P_inn_nodes
        V_new       = D_nodes + beta * EV_nodes

        # Re-fit Chebyshev coefficients
        theta_V_new = np.linalg.lstsq(B, V_new, rcond=None)[0]
        theta_Z_new = np.linalg.lstsq(B, np.log(np.maximum(Z_new, 1e-20)),
                                       rcond=None)[0]

        diff    = np.max(np.abs(V_new - V_nodes))
        theta_V = theta_V_new
        theta_Z = theta_Z_new
        V_nodes = V_new
        Z_nodes = Z_new

        if verbose and it % 100 == 0:
            print(f"  Proj iter {it:4d}: diff = {diff:.2e}")
        if diff < tol:
            if verbose:
                print(f"  Proj converged in {it+1} iterations. diff = {diff:.2e}")
            break
    else:
        if verbose:
            print(f"  WARNING: projection did not converge in {max_iter} iters.")

    return ProjectionSolution(
        pol_Z=Z_nodes,
        V=V_nodes,
        a_grid=a_nodes,
        P_a=P_a_sim,
        a_sim_grid=a_sim,
        theta_V=theta_V,
        theta_Z=theta_Z,
        ss=ss,
        p=p,
        a_lo=a_lo,
        a_hi=a_hi,
    )
