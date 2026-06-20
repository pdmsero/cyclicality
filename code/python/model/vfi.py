"""
vfi.py
------
Global solution of the 2-state (K̃, a) firm problem by GRID time iteration
(value + policy iteration).

The model has no clean Bellman (the quality-ladder R&D benefit enters the value
via E[Ṽ']), so we iterate the equilibrium-condition system on a grid: on a
discretised (K̃, a) grid we solve, at each node, the capital Euler and the R&D
FOC for the controls (Z̃, K̃') given next-period interpolants for (Ṽ, g_Z, g_K),
then update Ṽ = D̃ + β·E[Ṽ']. See model/global_solver.py for the shared node
solver and static block.

This replaces the old degenerate 1-state (a-only) VFI, which froze K̃ = 1. The
fixed point reproduces the steady state (K̃'=1, Z̃=Z̃_SS, q=1) and, near the SS,
the perturbation/Dynare policy.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from scipy.interpolate import RegularGridInterpolator

from .params import ModelParams
from .steady_state import SteadyState, solve as solve_ss
from .global_solver import make_context, static_flows, solve_node


@dataclass
class VFISolution:
    ss:        SteadyState
    p:         ModelParams
    K_grid:    np.ndarray            # (n_K,)
    a_grid:    np.ndarray            # (n_a,)
    P_a:       np.ndarray            # (n_a, n_a)
    V:         np.ndarray            # (n_K, n_a) value
    pol_Z:     np.ndarray            # (n_K, n_a) R&D policy
    pol_Knext: np.ndarray            # (n_K, n_a) next-capital policy

    def __post_init__(self):
        self.a_sim_grid = self.a_grid
        self._iZ = RegularGridInterpolator((self.K_grid, self.a_grid), self.pol_Z,
                                           bounds_error=False, fill_value=None)
        self._iK = RegularGridInterpolator((self.K_grid, self.a_grid), self.pol_Knext,
                                           bounds_error=False, fill_value=None)

    def policy_Z(self, K, a):
        K = np.atleast_1d(K); a = np.atleast_1d(a)
        return np.maximum(self._iZ(np.column_stack([K, a])), 1e-20)

    def policy_Knext(self, K, a):
        K = np.atleast_1d(K); a = np.atleast_1d(a)
        return self._iK(np.column_stack([K, a]))


def _make_eval_next(K_grid, a_grid, V, gZ, gK):
    """Return eval_next(Kp_array) -> (Vp, gZp, gKp), each (len(Kp), n_a),
    by linear interpolation along K_grid at each a' column (flat extrapolation)."""
    def eval_next(Kp):
        Kp = np.atleast_1d(Kp)
        n_a = len(a_grid)
        Vp = np.empty((len(Kp), n_a)); gZp = np.empty_like(Vp); gKp = np.empty_like(Vp)
        for j in range(n_a):
            Vp[:, j] = np.interp(Kp, K_grid, V[:, j])
            gZp[:, j] = np.interp(Kp, K_grid, gZ[:, j])
            gKp[:, j] = np.interp(Kp, K_grid, gK[:, j])
        return Vp, gZp, gKp
    return eval_next


def solve(p: ModelParams, tol: float = 1e-7, max_iter: int = 500,
          relax: float = 0.5, verbose: bool = False) -> VFISolution:
    """
    Solve the 2-state firm problem by grid time iteration.

    Parameters
    ----------
    p        : ModelParams
    tol      : convergence tolerance on policies + value (sup norm)
    max_iter : maximum time-iteration sweeps
    relax    : damping on the policy/value update (0<relax≤1)
    """
    ss = solve_ss(p)
    ctx = make_context(p, ss)
    a_grid, P_a, n_a = ctx["a_grid"], ctx["P_a"], ctx["n_a"]

    n_K = p.n_K
    K_grid = np.linspace(p.K_lo_mult * ss.K_tilde, p.K_hi_mult * ss.K_tilde, n_K)

    # Initialise at the steady state (flat across the grid)
    V = np.full((n_K, n_a), ss.V_tilde)
    gZ = np.full((n_K, n_a), ss.Z_tilde)
    gK = np.full((n_K, n_a), ss.K_tilde)

    for it in range(max_iter):
        eval_next = _make_eval_next(K_grid, a_grid, V, gZ, gK)
        Vn = np.empty_like(V); gZn = np.empty_like(gZ); gKn = np.empty_like(gK)
        for iK, K in enumerate(K_grid):
            for ja in range(n_a):
                x0 = [np.log(max(gZ[iK, ja], 1e-12)), gK[iK, ja]]
                Z, Kp, info = solve_node(K, ja, ctx, p, ss, eval_next, x0)
                gZn[iK, ja] = Z; gKn[iK, ja] = Kp; Vn[iK, ja] = info["V"]

        diff = max(np.max(np.abs(gZn - gZ)), np.max(np.abs(gKn - gK)),
                   np.max(np.abs(Vn - V)))
        V = (1 - relax) * V + relax * Vn
        gZ = (1 - relax) * gZ + relax * gZn
        gK = (1 - relax) * gK + relax * gKn
        if verbose and (it % 10 == 0 or diff < tol):
            print(f"    VFI it={it:3d}  sup|Δ|={diff:.3e}")
        if diff < tol:
            break

    return VFISolution(ss=ss, p=p, K_grid=K_grid, a_grid=a_grid, P_a=P_a,
                       V=V, pol_Z=gZ, pol_Knext=gK)
