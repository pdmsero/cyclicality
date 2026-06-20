"""
simulation.py
-------------
Simulate the model panel (N firms × T periods) from any solution method, in the
genuine 2-state (K̃, a) world, and reconstruct level variables including the
quality ladder Q and capital expenditure (capx) Ĩ.

Procedure (per firm):
  1. Draw the idiosyncratic TFP path a_{i,t} (AR(1)); the aggregate Ȳ is held
     constant at Ỹ_SS (LLN over a continuum of firms), so perceived revenue
     r̃ = Ȳ^{1/ε}·Ỹ^θ is concave in own output.
  2. Roll the solution's policy forward to get the capital state K̃_{i,t} and the
     R&D control Z̃_{i,t} (perturbation: Klein recursion; VFI/projection: the 2D
     policy functions g_K and g_Z).
  3. Recover the remaining flows (L, Ỹ, r̃, Ĩ, D̃, innovation prob) from the EXACT
     model equations — shared across methods so they are directly comparable.
  4. Simulate the quality ladder: Q_{t+1} = λ·Q_t with prob P̃_t = η·Z̃_t^γ.
  5. Scale stationary (tilde) variables to levels: X = X̃·Q.

The regression analysis (Table 4) then uses, in levels:
  Spec A:  Δlog Z_{it} = β·Δlog PY_{it} + FE + ε     (R&D smoothing)
  capx:    Δlog I_{it} = β·Δlog PY_{it} + FE + ε     (capx accelerator)
and the headline contrast is β_capx > β_R&D, generated endogenously now that
K̃ fluctuates.
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
    df: pd.DataFrame   # columns: firm, year, K, Z, Y, I, D, Q, a, K_tilde, Z_tilde, I_tilde

    @property
    def N(self) -> int:
        return int(self.df["firm"].nunique())

    @property
    def T(self) -> int:
        return int(self.df["year"].nunique())


# ---------------------------------------------------------------------------
# Shared exact-model flow reconstruction
# ---------------------------------------------------------------------------

def _model_flows(K_tilde: np.ndarray, K_next: np.ndarray, Z_tilde: np.ndarray,
                 a_arr: np.ndarray, p: ModelParams, ss: SteadyState):
    """
    Given the states/controls (K̃, K̃', Z̃, a), recover all remaining stationary
    flows from the EXACT equilibrium equations (not the linear approximation).

    Returns dict of arrays (same shape as inputs):
      L_tilde, Y_tilde, rev_tilde, I_tilde, D_tilde, P_innov
    """
    alpha = p.alpha; delta = p.delta; theta = p.theta
    lam = p.lam; eta = p.eta; gamma = p.gamma
    W_bar = ss.W_bar
    Ybar = ss.Y_tilde            # constant aggregate demand (idiosyncratic shock)
    eps = p.eps

    Z_pos = np.maximum(Z_tilde, 0.0)
    P_innov = np.clip(eta * Z_pos ** gamma, 0.0, 1.0)

    # Labour from the static FOC with concave (CES) revenue.
    # rev = Ybar^{1/ε}·Ỹ^θ,  Ỹ = a·K̃^α·L^{1-α},  W̄ = θ(1-α)·rev/L
    #   ⇒ L = [θ(1-α)·Ybar^{1/ε}·(a·K̃^α)^θ / W̄]^{1/(1-(1-α)θ)}
    expo = 1.0 / (1.0 - (1.0 - alpha) * theta)
    base = (theta * (1.0 - alpha) * Ybar ** (1.0 / eps)
            * (a_arr * K_tilde ** alpha) ** theta / W_bar)
    L_tilde = base ** expo

    Y_tilde = a_arr * K_tilde ** alpha * L_tilde ** (1.0 - alpha)
    rev_tilde = Ybar ** (1.0 / eps) * Y_tilde ** theta

    # Capital accumulation: K̃'(1+(λ-1)P) = (1-δ)K̃ + Ĩ  ⇒  Ĩ = K̃'(1+(λ-1)P) - (1-δ)K̃
    I_tilde = K_next * (1.0 + (lam - 1.0) * P_innov) - (1.0 - delta) * K_tilde

    # Capital adjustment cost Φ(Ĩ,K̃) = (φ/2)(Ĩ/K̃ - δ̄)²·K̃ (0 at SS).
    Phi = 0.5 * p.phi * (I_tilde / K_tilde - p.delta_bar) ** 2 * K_tilde

    # Dividend (option (a)): D̃ = r̃ - W̄L - Ĩ - Φ - Z̃
    D_tilde = rev_tilde - W_bar * L_tilde - I_tilde - Phi - Z_tilde

    return {"L_tilde": L_tilde, "Y_tilde": Y_tilde, "rev_tilde": rev_tilde,
            "I_tilde": I_tilde, "D_tilde": D_tilde, "P_innov": P_innov}


def _reconstruct_levels(K_tilde: np.ndarray, K_next: np.ndarray,
                        Z_tilde: np.ndarray, a_arr: np.ndarray,
                        p: ModelParams, ss: SteadyState,
                        T_burn: int, seed: int = 1) -> SimulatedPanel:
    """
    Build the level panel from stationary state/control paths.

    All input arrays are (N, T_total). K_next[:, t] is K̃_{t+1} (the chosen
    next-period capital), used for the capx identity. The quality ladder Q is
    simulated from the innovation probability, then tilde variables are scaled
    to levels and the burn-in is discarded.
    """
    rng = np.random.default_rng(seed)
    N, T_total = K_tilde.shape

    flows = _model_flows(K_tilde, K_next, Z_tilde, a_arr, p, ss)
    P_innov = flows["P_innov"]

    # Quality ladder
    Q = np.ones((N, T_total))
    for t in range(T_total - 1):
        success = rng.random(N) < P_innov[:, t]
        Q[:, t + 1] = np.where(success, p.lam * Q[:, t], Q[:, t])

    # Scale tilde -> levels
    K_lev = K_tilde * Q
    Z_lev = Z_tilde * Q
    Y_lev = flows["Y_tilde"] * Q
    I_lev = flows["I_tilde"] * Q
    D_lev = flows["D_tilde"] * Q

    s = T_burn
    df = pd.DataFrame({
        "firm":    np.repeat(np.arange(N), T_total - s),
        "year":    np.tile(np.arange(T_total - s), N),
        "K":       K_lev[:, s:].ravel(),
        "Z":       Z_lev[:, s:].ravel(),
        "Y":       Y_lev[:, s:].ravel(),
        "I":       I_lev[:, s:].ravel(),
        "D":       D_lev[:, s:].ravel(),
        "Q":       Q[:, s:].ravel(),
        "a":       a_arr[:, s:].ravel(),
        "K_tilde": K_tilde[:, s:].ravel(),
        "Z_tilde": Z_tilde[:, s:].ravel(),
        "I_tilde": flows["I_tilde"][:, s:].ravel(),
    })
    return SimulatedPanel(df=df)


# ---------------------------------------------------------------------------
# Public simulation functions
# ---------------------------------------------------------------------------

def simulate_from_perturbation(sol, N: int = None, T: int = None,
                               seed: int = 42) -> SimulatedPanel:
    """
    Simulate the panel from the 2-state Klein (perturbation) solution.

    States/controls follow the linear recursion y_t = P y_{t-1} + Q ε_t (level
    deviations); the capital state K̃ and R&D control Z̃ are read off, and the
    remaining flows are recovered from the exact model equations.
    """
    p = sol.p; ss = sol.ss
    if N is None: N = p.N_firms
    if T is None: T = p.T_sim
    T_total = T + p.T_burn

    rng = np.random.default_rng(seed)
    eps = rng.standard_normal((N, T_total)) * p.sigma_a   # innovations in a-units

    dev = sol.simulate_deviations(eps)                    # (N, T_total, n_vars)
    iK = sol.idx["K"]; iZ = sol.idx["Z"]; ia = sol.idx["a"]
    K_ss = sol.y_ss[iK]; Z_ss = sol.y_ss[iZ]

    Kdyn    = K_ss + dev[:, :, iK]                         # Dynare K = end-of-period capital K̃_{t+1}
    Z_tilde = Z_ss + dev[:, :, iZ]
    a_arr   = np.exp(dev[:, :, ia])                        # a is log-TFP (a_SS=0)

    # Use the predetermined capital K̃_t entering period t, to match the panel
    # convention of the global methods (where K̃ is the state). Dynare's K is the
    # end-of-period stock (K̃_{t+1}), so shift it back one period and seed the
    # first column with K̃_SS. K_next is then K̃_{t+1} (= Kdyn), so the capx
    # identity Ĩ_t = K̃_{t+1}(1+(λ-1)P_t) - (1-δ)K̃_t is correctly timed.
    K_next  = Kdyn
    K_tilde = np.empty_like(Kdyn)
    K_tilde[:, 0] = ss.K_tilde
    K_tilde[:, 1:] = Kdyn[:, :-1]

    return _reconstruct_levels(K_tilde, K_next, Z_tilde, a_arr, p, ss,
                               p.T_burn, seed=seed + 1)


def _simulate_markov_a(sol, N, T_total, seed):
    """Simulate a Markov-chain TFP path on the solution's grid (VFI/projection)."""
    rng = np.random.default_rng(seed)
    a_grid = sol.a_sim_grid if hasattr(sol, "a_sim_grid") else sol.a_grid
    P_a = sol.P_a
    n_a = len(a_grid)
    a_idx = np.zeros((N, T_total), dtype=int)
    a_idx[:, 0] = n_a // 2
    for t in range(1, T_total):
        cum = np.cumsum(P_a[a_idx[:, t - 1]], axis=1)
        u = rng.random(N)[:, None]
        a_idx[:, t] = (u > cum).sum(axis=1).clip(0, n_a - 1)
    return a_grid[a_idx]


def _simulate_from_2d_policy(sol, N=None, T=None, seed=42) -> SimulatedPanel:
    """
    Shared driver for the global methods (VFI, projection), whose solutions
    expose 2D policy functions:
        sol.policy_Knext(K, a) -> K̃'      (next-period capital)
        sol.policy_Z(K, a)     -> Z̃       (R&D)
    Capital is rolled forward from K̃_SS using the policy; TFP follows the
    method's Markov chain.
    """
    p = sol.p; ss = sol.ss
    if N is None: N = p.N_firms
    if T is None: T = p.T_sim
    T_total = T + p.T_burn

    a_arr = _simulate_markov_a(sol, N, T_total, seed)

    K_tilde = np.empty((N, T_total))
    K_next  = np.empty((N, T_total))
    Z_tilde = np.empty((N, T_total))
    K_cur = np.full(N, ss.K_tilde)
    for t in range(T_total):
        a_t = a_arr[:, t]
        Knext = sol.policy_Knext(K_cur, a_t)
        Zt    = sol.policy_Z(K_cur, a_t)
        K_tilde[:, t] = K_cur
        K_next[:, t]  = Knext
        Z_tilde[:, t] = Zt
        K_cur = Knext

    return _reconstruct_levels(K_tilde, K_next, np.maximum(Z_tilde, 1e-20),
                               a_arr, p, ss, p.T_burn, seed=seed + 1)


def simulate_from_vfi(sol, N: int = None, T: int = None,
                      seed: int = 42) -> SimulatedPanel:
    """Simulate the panel from the 2D VFI solution (policy g_K, g_Z on (K̃,a))."""
    return _simulate_from_2d_policy(sol, N, T, seed)


def simulate_from_projection(sol, N: int = None, T: int = None,
                             seed: int = 42) -> SimulatedPanel:
    """Simulate the panel from the 2D Chebyshev projection solution."""
    return _simulate_from_2d_policy(sol, N, T, seed)
