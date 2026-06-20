"""
global_solver.py
----------------
Shared machinery for the GLOBAL (nonlinear) solution of the 2-state (K̃, a) firm
problem, used by both vfi.py (grid time iteration) and projection.py (Chebyshev
collocation).

There is no clean Bellman for this model (the quality-ladder R&D benefit folds
into the value via E[Ṽ']), so we solve the equilibrium-condition *system*
directly by time iteration: at each state (K̃, a) we solve the two coupled
optimality conditions for the controls (Z̃, K̃'),

  capital Euler:  q = Λ̃·E[ θα·rev'/K̃' − Φ_K' + q'(1−δ) | a ],   q = 1 + φ(Ĩ/K̃ − δ̄)
  R&D FOC:        1 = Λ̃·η γ Z̃^{γ−1}(λ−1)·E[ Ṽ' | a ],

given next-period interpolants for (Ṽ, g_Z, g_K). The value is then updated by
Ṽ = D̃ + β·E[Ṽ'] (since Λ̃(1+(λ−1)P) = β). At the steady state this system has
the fixed point K̃'=K̃_SS, Z̃=Z̃_SS, Ṽ=Ṽ_SS, q=1, matching steady_state.py and
the perturbation/Dynare solution.

Both global methods share:
  - tauchen()                : TFP discretisation
  - static_flows()           : L, Ỹ, rev from the static block (closed form)
  - solve_node()             : the 2-equation root-find for (Z̃, K̃') at one state
"""

from __future__ import annotations
import numpy as np
from scipy.stats import norm as scipy_norm
from scipy.optimize import fsolve

from .params import ModelParams
from .steady_state import SteadyState


def tauchen(rho: float, sigma: float, n: int, m: float = 3.0):
    """Tauchen (1986) discretisation of x_t = ρ x_{t-1} + σ ε_t. Returns (grid, P)."""
    sigma_x = sigma / np.sqrt(1.0 - rho ** 2)
    x_max = m * sigma_x
    grid = np.linspace(-x_max, x_max, n)
    d = grid[1] - grid[0]
    P = np.zeros((n, n))
    for i in range(n):
        mu = rho * grid[i]
        P[i, 0] = scipy_norm.cdf((grid[0] - mu + d / 2) / sigma)
        P[i, n - 1] = 1 - scipy_norm.cdf((grid[n - 2] - mu + d / 2) / sigma)
        for j in range(1, n - 1):
            P[i, j] = (scipy_norm.cdf((grid[j] - mu + d / 2) / sigma)
                       - scipy_norm.cdf((grid[j] - mu - d / 2) / sigma))
    P /= P.sum(axis=1, keepdims=True)
    return grid, P


def static_flows(K: np.ndarray, a: np.ndarray, p: ModelParams, ss: SteadyState):
    """
    Static block: given capital K̃ and TFP level a, return (L, Ỹ, rev).
    Concave (CES) revenue with constant aggregate Ȳ = Ỹ_SS:
      L   = [θ(1-α)·Ȳ^{1/ε}·(a·K̃^α)^θ / W̄]^{1/(1-(1-α)θ)}
      Ỹ   = a·K̃^α·L^{1-α}
      rev = Ȳ^{1/ε}·Ỹ^θ
    """
    alpha, theta, eps = p.alpha, p.theta, p.eps
    Ybar, W_bar = ss.Y_tilde, ss.W_bar
    expo = 1.0 / (1.0 - (1.0 - alpha) * theta)
    L = (theta * (1.0 - alpha) * Ybar ** (1.0 / eps)
         * (a * K ** alpha) ** theta / W_bar) ** expo
    Y = a * K ** alpha * L ** (1.0 - alpha)
    rev = Ybar ** (1.0 / eps) * Y ** theta
    return L, Y, rev


def make_context(p: ModelParams, ss: SteadyState, n_a: int = None):
    """Precompute the TFP grid/transition and pack constants used by solve_node."""
    if n_a is None:
        n_a = p.n_a
    log_a_grid, P_a = tauchen(p.rho_a, p.sigma_a, n_a)
    a_grid = np.exp(log_a_grid)
    return {"a_grid": a_grid, "P_a": P_a, "n_a": n_a, "dbar": p.delta_bar}


def solve_node(K, ja, ctx, p, ss, eval_next, x0):
    """
    Solve the two optimality conditions for (Z̃, K̃') at state (K̃=K, a=a_grid[ja]).

    Parameters
    ----------
    K        : current capital (scalar)
    ja       : index of current a in ctx['a_grid']
    ctx      : make_context() output
    eval_next: callable Kp(array) -> (Vp, gZp, gKp) each shape (len(Kp), n_a),
               the next-period value/policies on the a-grid, evaluated at Kp.
               Used to form expectations E[·|a] = P_a[ja] · (·).
    x0       : initial guess [log Z̃, K̃']

    Returns
    -------
    (Z, Kp, info) where info has the realised flows at the solution.
    """
    alpha, delta, theta = p.alpha, p.delta, p.theta
    lam, eta, gamma, beta = p.lam, p.eta, p.gamma, p.beta
    phi, dbar = p.phi, ctx["dbar"]
    a_grid, P_a = ctx["a_grid"], ctx["P_a"]
    w = P_a[ja]                      # (n_a,) transition weights

    def resid(x):
        Z = np.exp(x[0]); Kp = x[1]
        P = eta * Z ** gamma
        Lam = beta / (1.0 + (lam - 1.0) * P)
        I = Kp * (1.0 + (lam - 1.0) * P) - (1.0 - delta) * K
        q = 1.0 + phi * (I / K - dbar)
        # next-period objects at (Kp, a') for all a'
        Vp, gZp, gKp = eval_next(np.array([Kp]))      # each (1, n_a)
        Vp = Vp[0]; gZp = gZp[0]; gKp = gKp[0]
        _, _, revp = static_flows(Kp, a_grid, p, ss)  # (n_a,)
        Pp = eta * np.maximum(gZp, 1e-12) ** gamma
        Ip = gKp * (1.0 + (lam - 1.0) * Pp) - (1.0 - delta) * Kp
        ratiop = Ip / Kp
        qp = 1.0 + phi * (ratiop - dbar)
        PhiKp = 0.5 * phi * (ratiop - dbar) ** 2 - phi * (ratiop - dbar) * ratiop
        termp = theta * alpha * revp / Kp - PhiKp + qp * (1.0 - delta)
        EV = float(w @ Vp)
        Eterm = float(w @ termp)
        R1 = q - Lam * Eterm                                          # capital Euler
        R2 = 1.0 - Lam * eta * gamma * Z ** (gamma - 1.0) * (lam - 1.0) * EV  # R&D FOC
        return [R1, R2]

    sol, _, ier, _ = fsolve(resid, x0, full_output=True, xtol=1e-11)
    Z = float(np.exp(sol[0])); Kp = float(sol[1])

    # realised flows + EV at the solution (for the value update)
    P = eta * Z ** gamma
    Lam = beta / (1.0 + (lam - 1.0) * P)
    I = Kp * (1.0 + (lam - 1.0) * P) - (1.0 - delta) * K
    Phi = 0.5 * phi * (I / K - dbar) ** 2 * K
    _, _, rev = static_flows(K, a_grid[ja], p, ss)
    L, _, _ = static_flows(K, a_grid[ja], p, ss)
    D = rev - ss.W_bar * L - I - Phi - Z
    Vp, _, _ = eval_next(np.array([Kp]))
    EV = float(w @ Vp[0])
    V = D + beta * EV
    return Z, Kp, {"V": V, "I": I, "D": D, "ier": ier}
