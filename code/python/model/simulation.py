"""
simulation.py
-------------
Simulate the model panel (N firms × T periods) from any solution method,
and reconstruct the level variables including quality Q.

The paper's simulation procedure:
  1. Each firm draws a_t from the TFP process (AR(1) or Markov chain).
  2. Given a_t, compute Z̃_{it} from the policy function (K̃ = K̃_SS = 1).
  3. Draw Bernoulli innovation: succeed with prob P_{it} = η*Z̃_{it}^γ.
  4. Q_{i,t+1} = λ*Q_{it} if success, else Q_{it}.
  5. Reconstruct levels: Z_{it} = Z̃_{it}*Q_{it}, Y_{it} = Ỹ_{it}*Q_{it}.

The regression analysis (Table 4) uses:
  Δlog(Z_{it}) = β_1*Δlog(PY_{it}) + FE + ε   [R&D growth on sales growth]
  Z_{it}/PY_{it} = β_1*Δlog(PY_{it}) + FE + ε  [R&D share on sales growth]

where PY = θ^{-1}*Y (pre-markup nominal revenue, ∝ Y in our normalisation).
The β_1 coefficient captures the pro-cyclicality of R&D.
"""

from __future__ import annotations
import numpy as np
import pandas as pd
from dataclasses import dataclass

from .params import ModelParams
from .steady_state import SteadyState


@dataclass
class SimulatedPanel:
    """Panel dataset from model simulation."""
    df: pd.DataFrame   # columns: firm, year, K, Z, Y, D, Q, a, K_tilde, Z_tilde

    @property
    def N(self) -> int:
        return int(self.df["firm"].nunique())

    @property
    def T(self) -> int:
        return int(self.df["year"].nunique())


# ---------------------------------------------------------------------------
# Public simulation functions
# ---------------------------------------------------------------------------

def simulate_from_perturbation(sol, N: int = None, T: int = None,
                                seed: int = 42) -> SimulatedPanel:
    """
    Simulate panel using first-order perturbation policy functions.

    Policy:  Z̃_{i,t} = Z̃_SS * exp(c_Za * â_{i,t})
    State:   â_{i,t+1} = ρ_a * â_{i,t} + σ_a * ε_{i,t+1}
    Capital: K̃ = K̃_SS = 1  (constant; model is 1-dimensional in a)

    Parameters
    ----------
    sol  : PerturbationSolution
    N, T : override p.N_firms and p.T_sim

    Returns
    -------
    SimulatedPanel (levels, after discarding burn-in)
    """
    p = sol.p; ss = sol.ss
    if N is None: N = p.N_firms
    if T is None: T = p.T_sim
    T_total = T + p.T_burn

    rng = np.random.default_rng(seed)
    eps = rng.standard_normal((N, T_total))

    # Simulate AR(1) log-TFP deviations
    a_hat = np.zeros((N, T_total))
    for t in range(1, T_total):
        a_hat[:, t] = p.rho_a * a_hat[:, t-1] + p.sigma_a * eps[:, t]

    # Policy: Z̃ = Z̃_SS * exp(c_Za * â)
    Z_tilde = ss.Z_tilde * np.exp(sol.c_Za * a_hat)
    # K̃ = 1 everywhere (constant state)
    K_tilde = np.ones_like(a_hat) * ss.K_tilde
    a_arr   = np.exp(a_hat)   # levels (a_SS = 1)

    return _reconstruct_panel(K_tilde, Z_tilde, a_arr, p, ss, p.T_burn,
                               seed=seed + 1)


def simulate_from_vfi(sol, N: int = None, T: int = None,
                      seed: int = 42) -> SimulatedPanel:
    """
    Simulate panel using VFI policy functions (interpolated on TFP grid).

    State:   a_t drawn from Markov chain with transition P_a
    Policy:  Z̃ = interp(a_t, a_grid, pol_Z)
    Capital: K̃ = K̃_SS = 1

    Parameters
    ----------
    sol  : VFISolution
    N, T : override p.N_firms and p.T_sim
    """
    p = sol.p; ss = sol.ss
    if N is None: N = p.N_firms
    if T is None: T = p.T_sim
    T_total = T + p.T_burn

    rng = np.random.default_rng(seed)
    n_a = len(sol.a_grid)

    # Simulate Markov chain on a_grid (vectorised)
    a_idx = np.zeros((N, T_total), dtype=int)
    a_idx[:, 0] = n_a // 2   # start at middle grid point
    for t in range(1, T_total):
        cum = np.cumsum(sol.P_a[a_idx[:, t-1]], axis=1)  # (N, n_a)
        u   = rng.random(N)[:, None]
        a_idx[:, t] = (u > cum).sum(axis=1).clip(0, n_a - 1)

    a_arr = sol.a_grid[a_idx]   # (N, T_total)

    # Policy: interpolate Z̃(a) on log scale
    log_a_grid = np.log(sol.a_grid)
    log_a_arr  = np.log(a_arr)
    log_Z_grid = np.log(np.maximum(sol.pol_Z, 1e-20))

    # Vectorised interpolation over all (firm, time) pairs
    Z_tilde = np.exp(np.interp(log_a_arr.ravel(),
                                log_a_grid, log_Z_grid)
                     ).reshape(N, T_total)
    K_tilde = np.ones_like(a_arr) * ss.K_tilde

    return _reconstruct_panel(K_tilde, Z_tilde, a_arr, p, ss, p.T_burn,
                               seed=seed + 1)


def simulate_from_projection(sol, N: int = None, T: int = None,
                              seed: int = 42) -> SimulatedPanel:
    """
    Simulate panel using Chebyshev projection policy functions.

    State:   a_t drawn from Markov chain on the Tauchen simulation grid
    Policy:  Z̃ = sol.eval_Z(a_t)  (Chebyshev interpolation)
    Capital: K̃ = K̃_SS = 1
    """
    p = sol.p; ss = sol.ss
    if N is None: N = p.N_firms
    if T is None: T = p.T_sim
    T_total = T + p.T_burn

    rng = np.random.default_rng(seed)
    # Use the dedicated Tauchen simulation grid (not the collocation nodes)
    a_sim_grid = sol.a_sim_grid   # (n_a,)
    P_a        = sol.P_a          # (n_a, n_a)
    n_a        = len(a_sim_grid)

    a_idx = np.zeros((N, T_total), dtype=int)
    a_idx[:, 0] = n_a // 2
    for t in range(1, T_total):
        cum = np.cumsum(P_a[a_idx[:, t-1]], axis=1)
        u   = rng.random(N)[:, None]
        a_idx[:, t] = (u > cum).sum(axis=1).clip(0, n_a - 1)

    a_arr = a_sim_grid[a_idx]     # (N, T_total)

    # Evaluate policy at each (firm, time) pair
    Z_tilde = np.array(
        [sol.eval_Z(a_arr[i, t])
         for i in range(N) for t in range(T_total)]
    ).reshape(N, T_total)
    Z_tilde = np.maximum(Z_tilde, 1e-20)
    K_tilde = np.ones_like(a_arr) * ss.K_tilde

    return _reconstruct_panel(K_tilde, Z_tilde, a_arr, p, ss, p.T_burn,
                               seed=seed + 1)


# ---------------------------------------------------------------------------
# Internal reconstruction function
# ---------------------------------------------------------------------------

def _reconstruct_panel(K_tilde: np.ndarray, Z_tilde: np.ndarray,
                        a_arr: np.ndarray, p: ModelParams,
                        ss: SteadyState, T_burn: int,
                        seed: int = 1) -> SimulatedPanel:
    """
    Given stationary (tilde) paths, reconstruct level paths including Q.

    Steps:
      1. Simulate quality path: Q_{t+1} = λ*Q_t w.p. η*Z̃_t^γ, else Q_t.
      2. Compute labour from static FOC: L̃ = ell(a)*K̃  [ell = ((1-α)*θ*a/W̄)^{1/α}]
      3. Compute stationary output and dividends:
           Ỹ = a * K̃^α * L̃^{1-α}
           D̃ = θ*Ỹ - W̄*L̃ - Z̃ - δ*K̃ - (λ-1)*η*Z̃^γ*K̃
         (second-to-last term = expected quality-step investment cost)
      4. Scale to levels: Z = Z̃*Q, Y = Ỹ*Q, K = K̃*Q, D = D̃*Q.
      5. Discard T_burn periods and return as DataFrame.
    """
    rng = np.random.default_rng(seed)
    N, T_total = K_tilde.shape

    alpha = p.alpha; delta = p.delta; theta = p.theta
    lam = p.lam; eta = p.eta; gamma = p.gamma; W_bar = ss.W_bar

    # 1. Quality path
    Q = np.ones((N, T_total))
    for t in range(T_total - 1):
        P_inn = eta * np.maximum(Z_tilde[:, t], 0.0) ** gamma
        P_inn = np.clip(P_inn, 0.0, 1.0)
        success = rng.random(N) < P_inn
        Q[:, t+1] = np.where(success, lam * Q[:, t], Q[:, t])

    # 2. Labour from static FOC
    ell     = ((1.0 - alpha) * theta * a_arr / W_bar) ** (1.0 / alpha)
    L_tilde = ell * K_tilde                               # (N, T_total)

    # 3. Stationary output and dividends
    Y_tilde = a_arr * K_tilde ** alpha * L_tilde ** (1.0 - alpha)
    P_inn_t = eta * np.maximum(Z_tilde, 0.0) ** gamma     # innovation prob
    D_tilde = (theta * Y_tilde - W_bar * L_tilde
               - Z_tilde
               - delta * K_tilde
               - (lam - 1.0) * P_inn_t * K_tilde)

    # 4. Level variables
    K_lev = K_tilde * Q
    Z_lev = Z_tilde * Q
    Y_lev = Y_tilde * Q
    D_lev = D_tilde * Q

    # 5. Discard burn-in
    s = T_burn
    df = pd.DataFrame({
        "firm":    np.repeat(np.arange(N), T_total - s),
        "year":    np.tile(np.arange(T_total - s), N),
        "K":       K_lev[:, s:].ravel(),
        "Z":       Z_lev[:, s:].ravel(),
        "Y":       Y_lev[:, s:].ravel(),
        "D":       D_lev[:, s:].ravel(),
        "Q":       Q[:, s:].ravel(),
        "a":       a_arr[:, s:].ravel(),
        "K_tilde": K_tilde[:, s:].ravel(),
        "Z_tilde": Z_tilde[:, s:].ravel(),
    })

    return SimulatedPanel(df=df)
