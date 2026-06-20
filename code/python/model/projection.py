"""
projection.py
-------------
Global solution of the 2-state (K̃, a) firm problem by CHEBYSHEV projection
(collocation) in the capital dimension, with the Tauchen grid in the TFP
dimension.

Same equilibrium-condition system and node solver as vfi.py (see
model/global_solver.py); the only difference is the function representation:
the value Ṽ and the policies g_Z, g_K are stored as Chebyshev series in K̃ (one
series per a-node) and the next-period objects in the expectations are obtained
by Chebyshev evaluation rather than linear interpolation. Time iteration on the
collocation nodes converges to the same fixed point (SS reproduced exactly; near
the SS it matches the perturbation/Dynare policy and the grid VFI).

This replaces the old degenerate 1-state (a-only) projection, which froze K̃ = 1.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from numpy.polynomial import chebyshev as C

from .params import ModelParams
from .steady_state import SteadyState, solve as solve_ss
from .global_solver import make_context, solve_node


@dataclass
class ProjectionSolution:
    ss:      SteadyState
    p:       ModelParams
    K_lo:    float
    K_hi:    float
    a_grid:  np.ndarray              # (n_a,)
    P_a:     np.ndarray              # (n_a, n_a)
    cZ:      np.ndarray              # (deg+1, n_a) Chebyshev coeffs, R&D
    cK:      np.ndarray              # (deg+1, n_a) Chebyshev coeffs, next capital
    cV:      np.ndarray              # (deg+1, n_a) Chebyshev coeffs, value

    def __post_init__(self):
        self.a_sim_grid = self.a_grid

    def _z(self, K):
        return 2.0 * (np.asarray(K, float) - self.K_lo) / (self.K_hi - self.K_lo) - 1.0

    def policy_Z(self, K, a):
        K = np.atleast_1d(K); a = np.atleast_1d(a)
        ja = np.argmin(np.abs(a[:, None] - self.a_grid[None, :]), axis=1)
        out = np.array([C.chebval(self._z(K[i]), self.cZ[:, ja[i]]) for i in range(len(K))])
        return np.maximum(out, 1e-20)

    def policy_Knext(self, K, a):
        K = np.atleast_1d(K); a = np.atleast_1d(a)
        ja = np.argmin(np.abs(a[:, None] - self.a_grid[None, :]), axis=1)
        return np.array([C.chebval(self._z(K[i]), self.cK[:, ja[i]]) for i in range(len(K))])


def _cheb_nodes(deg, K_lo, K_hi):
    """deg+1 Chebyshev-Gauss nodes mapped to [K_lo, K_hi]."""
    k = np.arange(deg + 1)
    z = np.sort(np.cos((2 * k + 1) * np.pi / (2 * (deg + 1))))
    K = K_lo + (z + 1.0) * (K_hi - K_lo) / 2.0
    return K, z


def solve(p: ModelParams, n_proj: int = 8, tol: float = 1e-7,
          max_iter: int = 500, relax: float = 0.5,
          verbose: bool = False) -> ProjectionSolution:
    """
    Solve the 2-state firm problem by Chebyshev collocation + time iteration.

    Parameters
    ----------
    n_proj : Chebyshev degree in K̃ (uses n_proj+1 collocation nodes)
    """
    ss = solve_ss(p)
    ctx = make_context(p, ss)
    a_grid, P_a, n_a = ctx["a_grid"], ctx["P_a"], ctx["n_a"]

    K_lo = p.K_lo_mult * ss.K_tilde
    K_hi = p.K_hi_mult * ss.K_tilde
    deg = n_proj
    K_nodes, z_nodes = _cheb_nodes(deg, K_lo, K_hi)
    Vander = C.chebvander(z_nodes, deg)                   # (deg+1, deg+1)

    def fit(grid):                                        # (deg+1, n_a) -> (deg+1, n_a)
        return np.linalg.solve(Vander, grid)

    def z_of(K):
        return 2.0 * (K - K_lo) / (K_hi - K_lo) - 1.0

    cV = np.zeros((deg + 1, n_a)); cV[0] = ss.V_tilde
    cZ = np.zeros((deg + 1, n_a)); cZ[0] = ss.Z_tilde
    cK = np.zeros((deg + 1, n_a)); cK[0] = ss.K_tilde

    def make_eval_next(cV, cZ, cK):
        def eval_next(Kp):
            Kp = np.atleast_1d(Kp); zz = z_of(Kp)
            Vp = np.column_stack([C.chebval(zz, cV[:, j]) for j in range(n_a)])
            gZp = np.column_stack([C.chebval(zz, cZ[:, j]) for j in range(n_a)])
            gKp = np.column_stack([C.chebval(zz, cK[:, j]) for j in range(n_a)])
            return Vp, gZp, gKp
        return eval_next

    Zg = np.full((deg + 1, n_a), ss.Z_tilde)
    Kg = np.full((deg + 1, n_a), ss.K_tilde)
    for it in range(max_iter):
        eval_next = make_eval_next(cV, cZ, cK)
        Vn = np.empty((deg + 1, n_a)); Zn = np.empty_like(Vn); Kn = np.empty_like(Vn)
        for iK, K in enumerate(K_nodes):
            for ja in range(n_a):
                x0 = [np.log(max(Zg[iK, ja], 1e-12)), Kg[iK, ja]]
                Z, Kp, info = solve_node(K, ja, ctx, p, ss, eval_next, x0)
                Zn[iK, ja] = Z; Kn[iK, ja] = Kp; Vn[iK, ja] = info["V"]

        cZn, cKn, cVn = fit(Zn), fit(Kn), fit(Vn)
        diff = max(np.max(np.abs(cZn - cZ)), np.max(np.abs(cKn - cK)),
                   np.max(np.abs(cVn - cV)))
        cZ = (1 - relax) * cZ + relax * cZn
        cK = (1 - relax) * cK + relax * cKn
        cV = (1 - relax) * cV + relax * cVn
        Zg, Kg = Zn, Kn
        if verbose and (it % 10 == 0 or diff < tol):
            print(f"    PROJ it={it:3d}  sup|Δcoef|={diff:.3e}")
        if diff < tol:
            break

    return ProjectionSolution(ss=ss, p=p, K_lo=K_lo, K_hi=K_hi, a_grid=a_grid,
                              P_a=P_a, cZ=cZ, cK=cK, cV=cV)
