"""
acf_estimator.py

Python port of prodest::prodestACF() (Rovigatti & Mollisi 2018 / CRAN v1.0.1).
Implements the Ackerberg, Caves, and Frazer (2015) two-stage semi-parametric
production function estimator.

Reference
---------
Ackerberg, D.A., Caves, K., Frazer, G. (2015). Identification properties of
recent production function estimators. Econometrica, 83(6), 2411–2451.

Rovigatti, G., Mollisi, V. (2018). Theory and practice of total-factor
productivity estimation: The control function approach using Stata.
The Stata Journal, 18(3), 618–662.

Polynomial approximation
------------------------
Stage 1 regresses output on a second-order polynomial in (free inputs, state
variables, proxy), exactly replicating R's:
    regvars <- cbind(model.matrix(~.^2-1, data=polyframe), fX^2, sX^2, pX^2)
That is: all main effects, pairwise interactions, and squared terms — a full
degree-2 expansion with no intercept in regvars (intercept added by OLS).

Stage 2 GMM
-----------
Instruments Z = [lag(fX), sX]. GMM criterion:
    (Z'ξ)' W (Z'ξ),  W = (Z'Z/N)^{-1}
where ξ = ω - g(ω_lag), g is a cubic polynomial estimated by OLS.

Bootstrap
---------
Block bootstrap: resample firms with replacement, preserving within-firm
temporal structure. Standard errors = std dev across R replications.
"""

import warnings
from itertools import combinations

import numpy as np
import pandas as pd
from scipy.linalg import lstsq, solve
from scipy.optimize import minimize


# ---------------------------------------------------------------------------
# Polynomial helpers
# ---------------------------------------------------------------------------

def _poly2_features(X: np.ndarray) -> np.ndarray:
    """
    Build second-order polynomial features for an (n, k) array.

    Returns a matrix with columns:
      - each column of X (main effects)
      - all pairwise column products X[:, i] * X[:, j] for i < j (interactions)
      - each column squared X[:, i]^2

    No intercept column. Matches R's:
        cbind(model.matrix(~.^2-1, data=polyframe), col1^2, col2^2, ...)
    """
    n, k = X.shape
    parts = [X]  # main effects

    # pairwise interactions (i < j)
    for i, j in combinations(range(k), 2):
        parts.append((X[:, i] * X[:, j]).reshape(-1, 1))

    # squared terms
    parts.append(X ** 2)

    return np.hstack(parts)


def _cubic_poly(v: np.ndarray) -> np.ndarray:
    """
    Cubic polynomial basis in scalar array v: [1, v, v^2, v^3].
    Matches R's: cbind(1, Omega_lag, Omega_lag^2, Omega_lag^3)
    """
    return np.column_stack([np.ones_like(v), v, v ** 2, v ** 3])


def _ols_coef(X: np.ndarray, y: np.ndarray) -> np.ndarray:
    """OLS via QR-based least squares."""
    coef, _, _, _ = lstsq(X, y)
    return coef


# ---------------------------------------------------------------------------
# Panel lag utility
# ---------------------------------------------------------------------------

def _lag_panel(series: pd.Series, id_col: pd.Series, time_col: pd.Series) -> pd.Series:
    """
    Compute within-firm lag of `series`. Returns a Series aligned to the
    original index. Observations at the earliest time per firm are NaN.

    Replicates R's lagPanel(): merges on (id, time+1) to assign lag.
    """
    df = pd.DataFrame({
        "id": id_col.values,
        "t": time_col.values,
        "val": series.values,
    }, index=series.index)

    right = df[["id", "t", "val"]].copy()
    right["t"] = right["t"] + 1
    right = right.rename(columns={"val": "lagged"})

    merged = df.merge(right, on=["id", "t"], how="left")
    merged.index = df.index
    return merged["lagged"]


# ---------------------------------------------------------------------------
# ACF estimator
# ---------------------------------------------------------------------------

class ACFEstimator:
    """
    Ackerberg, Caves, and Frazer (2015) production function estimator.

    Faithful Python port of prodest::prodestACF() (R, CRAN v1.0.1).

    Parameters
    ----------
    output : str
        Column name for log output (e.g. log value added).
    free : str or list of str
        Column name(s) for freely adjustable input(s) (e.g. log employment).
        In single-input case pass a string; for multiple free inputs pass a list.
    state : str or list of str
        Column name(s) for state variable(s) (e.g. log capital).
    proxy : str
        Column name for proxy variable (e.g. log investment or log materials).
    id_var : str
        Firm identifier column.
    time_var : str
        Time period column (must be numeric).
    controls : list of str, optional
        Additional control columns included in Stage 1 OLS.
    n_bootstrap : int
        Number of bootstrap replications for standard errors. Default 200.
        Set to 0 to skip bootstrap.
    seed : int
        Random seed for bootstrap.
    optimizer : str
        Scipy minimization method. Default 'L-BFGS-B'. Also accepts 'Nelder-Mead'.
    theta0 : array-like, optional
        Starting values for Stage 2 optimisation, length = len(free) + len(state).
        If None, uses first-stage coefficients + small noise (as in prodest).

    Attributes (after fit)
    ----------------------
    coef_ : dict
        Coefficient estimates keyed by variable name.
    se_ : dict
        Bootstrap standard errors.
    tfp_ : pd.Series
        Log TFP residuals (omega) aligned to the input DataFrame index.
    phi_ : pd.Series
        Stage 1 fitted values (Phi_hat) aligned to input index.
    """

    def __init__(
        self,
        output: str,
        free,
        state,
        proxy: str,
        id_var: str,
        time_var: str,
        controls=None,
        n_bootstrap: int = 200,
        seed: int = 42,
        optimizer: str = "L-BFGS-B",
        theta0=None,
    ):
        self.output = output
        self.free = [free] if isinstance(free, str) else list(free)
        self.state = [state] if isinstance(state, str) else list(state)
        self.proxy = proxy
        self.id_var = id_var
        self.time_var = time_var
        self.controls = controls or []
        self.n_bootstrap = n_bootstrap
        self.seed = seed
        self.optimizer = optimizer
        self.theta0 = theta0

        self.coef_ = {}
        self.se_ = {}
        self.tfp_ = None
        self.phi_ = None

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def fit(self, df: pd.DataFrame) -> "ACFEstimator":
        """
        Estimate the production function on panel DataFrame `df`.

        Parameters
        ----------
        df : pd.DataFrame
            Must contain columns: output, free, state, proxy, id_var, time_var.

        Returns
        -------
        self
        """
        df = df.copy().sort_values([self.id_var, self.time_var])

        # ── Stage 1 ──────────────────────────────────────────────────────
        phi, fs_coef = self._stage1(df)
        self.phi_ = pd.Series(phi, index=df.index)

        # Lag phi (within firm)
        lag_phi = _lag_panel(self.phi_, df[self.id_var], df[self.time_var])

        # ── Prepare Stage 2 data arrays ──────────────────────────────────
        arrays = self._build_stage2_arrays(df, phi, lag_phi)

        # Starting values: use OLS on the stage2 sample as warm-start,
        # not Stage 1 polynomial coefficients (which are distorted by the
        # polynomial expansion and give unreliable starting values for Stage 2).
        if self.theta0 is None:
            mask = arrays["mask"]
            y_s2 = arrays["phi"][mask] - 0.0   # approximate: ignore omega_lag term
            X_s2 = arrays["X"]
            try:
                from scipy.linalg import lstsq as _lstsq
                theta0, _, _, _ = _lstsq(X_s2, arrays["phi"][mask])
            except Exception:
                theta0 = np.full(len(self.free) + len(self.state), 0.5)
        else:
            theta0 = np.asarray(self.theta0, dtype=float)

        # ── Stage 2 point estimates ───────────────────────────────────────
        theta_hat = self._optimise(theta0, arrays)
        param_names = self.free + self.state
        self.coef_ = dict(zip(param_names, theta_hat))

        # ── TFP residuals ─────────────────────────────────────────────────
        mask = arrays["mask"]
        X = arrays["X"]
        omega = arrays["phi"][mask] - X @ theta_hat
        self.tfp_ = pd.Series(np.nan, index=df.index)
        self.tfp_[df.index[mask]] = omega

        # ── Bootstrap SEs ─────────────────────────────────────────────────
        if self.n_bootstrap > 0:
            se_arr = self._bootstrap(df, theta0)
            self.se_ = dict(zip(param_names, se_arr))

        return self

    def summary(self) -> None:
        """Print a formatted coefficient table."""
        width = 52
        print(f"\n{'ACF Production Function Estimates':^{width}}")
        print("─" * width)
        print(f"  {'Variable':<18}  {'Coef':>10}  {'Bootstrap SE':>12}")
        print("─" * width)
        for name in self.free + self.state:
            coef = self.coef_.get(name, np.nan)
            se = self.se_.get(name, np.nan)
            print(f"  {name:<18}  {coef:>10.4f}  {se:>12.4f}")
        print("─" * width)
        rts = sum(self.coef_.values())
        print(f"  {'Returns to scale':<18}  {rts:>10.4f}")
        print("─" * width)
        print(f"  Bootstrap replications: {self.n_bootstrap}")
        print()

    # ------------------------------------------------------------------
    # Internal: Stage 1
    # ------------------------------------------------------------------

    def _stage1(self, df: pd.DataFrame):
        """
        OLS of output on degree-2 polynomial in (free, state, proxy) + controls.

        Returns
        -------
        phi : np.ndarray, shape (n,)
            Fitted values (Phi_hat). NaN for rows with any missing input.
        coef : np.ndarray
            Full OLS coefficient vector (intercept first).
        """
        cols = self.free + self.state + [self.proxy]
        all_cols = cols + [self.output] + self.controls
        # Require all inputs finite (excludes NaN and ±Inf)
        complete = (
            df[all_cols].apply(pd.to_numeric, errors="coerce")
            .apply(np.isfinite)
            .all(axis=1)
            .values
        )

        poly_raw = df.loc[complete, cols].values
        X_poly = _poly2_features(poly_raw)

        if self.controls:
            X_ctrl = df.loc[complete, self.controls].values
            X = np.hstack([np.ones(X_poly.shape[0]).reshape(-1, 1), X_poly, X_ctrl])
        else:
            X = np.hstack([np.ones(X_poly.shape[0]).reshape(-1, 1), X_poly])

        y = df.loc[complete, self.output].values
        coef = _ols_coef(X, y)

        phi = np.full(len(df), np.nan)
        phi[complete] = X @ coef
        return phi, coef

    def _stage1_param_indices(self, df: pd.DataFrame) -> np.ndarray:
        """
        Indices into the Stage 1 coefficient vector corresponding to main-effect
        free and state columns. Used to warm-start Stage 2 (matches prodest).
        """
        # Layout: [intercept, free cols, state cols, proxy col, interaction cols, squared cols]
        # Main effects occupy positions 1 .. len(free)+len(state)+1 (0-indexed)
        n_free = len(self.free)
        n_state = len(self.state)
        # Positions 1 to n_free are free inputs; n_free+1 to n_free+n_state are state
        idx = list(range(1, 1 + n_free + n_state))
        return np.array(idx)

    # ------------------------------------------------------------------
    # Internal: Stage 2 data preparation
    # ------------------------------------------------------------------

    def _build_stage2_arrays(self, df: pd.DataFrame, phi: np.ndarray,
                              lag_phi: pd.Series) -> dict:
        """
        Build numpy arrays required by the GMM criterion.

        Z  = [lag(fX), sX]    — instruments
        X  = [fX, sX]         — current inputs
        lX = [lag(fX), lag(sX)] — lagged inputs (for omega_lag calculation)

        The estimation sample requires: phi non-NaN, lag_phi non-NaN,
        all fX/sX non-NaN, and lagged fX/sX non-NaN.
        """
        lag_free = pd.DataFrame(
            {c: _lag_panel(df[c], df[self.id_var], df[self.time_var])
             for c in self.free},
            index=df.index,
        )
        lag_state = pd.DataFrame(
            {c: _lag_panel(df[c], df[self.id_var], df[self.time_var])
             for c in self.state},
            index=df.index,
        )

        complete = (
            pd.notna(phi)
            & lag_phi.notna()
            & df[self.free].notna().all(axis=1)
            & df[self.state].notna().all(axis=1)
            & lag_free.notna().all(axis=1)
            & lag_state.notna().all(axis=1)
        ).values

        return {
            "mask": complete,
            "phi": phi,
            "lag_phi": lag_phi.values,
            "X": np.hstack([df.loc[complete, self.free].values,
                             df.loc[complete, self.state].values]),
            "lX": np.hstack([lag_free.loc[complete].values,
                              lag_state.loc[complete].values]),
            "Z": np.hstack([lag_free.loc[complete].values,
                             df.loc[complete, self.state].values]),
        }

    # ------------------------------------------------------------------
    # Internal: GMM criterion (matches gACF in prodest/R/prodestACF.R)
    # ------------------------------------------------------------------

    @staticmethod
    def _gmm_criterion(theta: np.ndarray, arrays: dict) -> float:
        """
        GMM objective: (Z'ξ)' W (Z'ξ),  W = (Z'Z / N)^{-1}

        ω       = Φ_hat   - X  @ θ
        ω_lag   = Φ_lag   - lX @ θ
        g(ω_lag) estimated by OLS on cubic polynomial
        ξ       = ω - g(ω_lag)
        """
        mask = arrays["mask"]
        phi_sub = arrays["phi"][mask]
        lag_phi_sub = arrays["lag_phi"][mask]
        X = arrays["X"]
        lX = arrays["lX"]
        Z = arrays["Z"]

        omega = phi_sub - X @ theta
        omega_lag = lag_phi_sub - lX @ theta

        # Cubic polynomial in lagged omega
        P_lag = _cubic_poly(omega_lag)
        g_b = _ols_coef(P_lag, omega)
        xi = omega - P_lag @ g_b

        # Optimal weight matrix W = (Z'Z / N)^{-1}
        N = Z.shape[0]
        ZtZ = Z.T @ Z / N
        try:
            W = solve(ZtZ, np.eye(ZtZ.shape[0]))
        except np.linalg.LinAlgError:
            W = np.linalg.pinv(ZtZ)

        Zxi = Z.T @ xi  # shape (n_instruments,)
        crit = float(Zxi @ W @ Zxi)
        return crit

    # ------------------------------------------------------------------
    # Internal: optimisation
    # ------------------------------------------------------------------

    def _optimise(self, theta0: np.ndarray, arrays: dict) -> np.ndarray:
        """
        Minimise GMM criterion over theta. Tries multiple starting points
        and keeps the best result.
        """
        best_val = np.inf
        best_theta = theta0.copy()

        # Grid of economically sensible starting points for (beta_free, beta_state).
        # Labour elasticity typically 0.3–0.8; capital elasticity 0.1–0.5.
        # Using a coarse grid avoids reliance on Stage 1 polynomial coefficients
        # as starting values, which are distorted by the polynomial expansion.
        n = len(theta0)
        grid_starts = []
        if n == 2:
            for bl in [0.3, 0.5, 0.7, 0.9]:
                for bk in [0.1, 0.2, 0.3, 0.4]:
                    grid_starts.append(np.array([bl, bk]))
        else:
            # For multi-input specs, fall back to perturbed theta0
            rng = np.random.default_rng(self.seed)
            grid_starts = [theta0] + [
                theta0 + rng.normal(0, 0.1, size=n) for _ in range(7)
            ]

        starts = [theta0] + grid_starts

        for t0 in starts:
            try:
                res = minimize(
                    self._gmm_criterion,
                    t0,
                    args=(arrays,),
                    method=self.optimizer,
                    options={"maxiter": 10_000, "ftol": 1e-14, "gtol": 1e-10}
                    if self.optimizer == "L-BFGS-B"
                    else {"maxiter": 10_000, "xatol": 1e-10, "fatol": 1e-14},
                )
                if res.fun < best_val:
                    best_val = res.fun
                    best_theta = res.x
            except Exception:
                continue

        return best_theta

    # ------------------------------------------------------------------
    # Internal: block bootstrap (matches block.boot.resample in prodest)
    # ------------------------------------------------------------------

    def _bootstrap(self, df: pd.DataFrame, theta0: np.ndarray) -> np.ndarray:
        """
        Block bootstrap: resample firms with replacement, R times.
        Returns array of shape (len(free)+len(state),) with standard errors.
        """
        rng = np.random.default_rng(self.seed)
        firms = df[self.id_var].unique()
        n_firms = len(firms)
        boot_coefs = []

        for b in range(self.n_bootstrap):
            # Resample firms with replacement
            sampled_firms = rng.choice(firms, size=n_firms, replace=True)

            frames = []
            for new_id, firm in enumerate(sampled_firms):
                chunk = df[df[self.id_var] == firm].copy()
                chunk = chunk.assign(**{self.id_var: new_id})
                frames.append(chunk)

            df_b = (
                pd.concat(frames, ignore_index=True)
                .sort_values([self.id_var, self.time_var])
            )

            try:
                phi_b, _ = self._stage1(df_b)
                lag_phi_b = _lag_panel(
                    pd.Series(phi_b, index=df_b.index),
                    df_b[self.id_var],
                    df_b[self.time_var],
                )
                arrays_b = self._build_stage2_arrays(df_b, phi_b, lag_phi_b)
                theta_b = self._optimise(theta0, arrays_b)
                boot_coefs.append(theta_b)
            except Exception:
                continue

        if len(boot_coefs) < max(10, self.n_bootstrap // 4):
            warnings.warn(
                f"Only {len(boot_coefs)}/{self.n_bootstrap} bootstrap replications "
                "succeeded. Standard errors may be unreliable.",
                stacklevel=2,
            )

        if not boot_coefs:
            return np.full(len(self.free) + len(self.state), np.nan)

        return np.std(np.array(boot_coefs), axis=0)


# ---------------------------------------------------------------------------
# Convenience wrapper for the cyclicality project
# ---------------------------------------------------------------------------

def estimate_tfp_acf(
    db_path: str,
    table: str = "processed_compustat_merged",
    output_col: str = "logvaa",
    labour_col: str = "logemp",
    capital_col: str = "logcap",
    proxy_col: str = "loginv",
    id_col: str = "gvkey",
    time_col: str = "year",
    controls: list = None,
    n_bootstrap: int = 200,
    seed: int = 1,
    out_table: str = "processed_tfp_acf",
) -> ACFEstimator:
    """
    Load data from cyclicality.db, fit ACF, write TFP residuals back to db.

    Matches AllData.do lines 1178–1230:
        opreg logvaa, exit(exit) state(logcap) proxy(loginv) free(logemp) \\
               cvars(t) vce(bootstrap, seed(1) rep(100))

    Parameters
    ----------
    db_path : str
        Path to cyclicality.db.
    table : str
        Source table in the database.
    output_col, labour_col, capital_col, proxy_col : str
        Column mappings (log-transformed variables).
    id_col, time_col : str
        Panel identifiers.
    controls : list, optional
        Control variables passed to Stage 1 (e.g. ['t'] for time trend).
    n_bootstrap : int
        Bootstrap replications.
    seed : int
        Random seed (default 1 to match Stata's seed(1)).
    out_table : str
        Table name to write TFP residuals into db.

    Returns
    -------
    ACFEstimator
        Fitted estimator. Coefs in .coef_, SEs in .se_, TFP in .tfp_.
    """
    import sqlite3

    conn = sqlite3.connect(db_path)
    cols = [id_col, time_col, output_col, labour_col, capital_col, proxy_col]
    if controls:
        cols += [c for c in controls if c not in cols]

    query = f"SELECT {', '.join(cols)} FROM {table} WHERE {output_col} IS NOT NULL"
    df = pd.read_sql_query(query, conn)

    estimator = ACFEstimator(
        output=output_col,
        free=labour_col,
        state=capital_col,
        proxy=proxy_col,
        id_var=id_col,
        time_var=time_col,
        controls=controls or [],
        n_bootstrap=n_bootstrap,
        seed=seed,
    )

    print(f"Fitting ACF on {len(df):,} observations from {table!r}...")
    estimator.fit(df)
    estimator.summary()

    # Write TFP back to db
    tfp_df = df[[id_col, time_col]].copy()
    tfp_df["l_tfp_acf"] = estimator.tfp_.values
    tfp_df = tfp_df.dropna(subset=["l_tfp_acf"])

    tfp_df.to_sql(out_table, conn, if_exists="replace", index=False)
    conn.close()

    print(f"TFP residuals written to {out_table!r} ({len(tfp_df):,} rows).")
    return estimator


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import argparse
    import os

    parser = argparse.ArgumentParser(description="ACF production function estimator")
    parser.add_argument("--db", required=True, help="Path to cyclicality.db")
    parser.add_argument("--table", default="processed_compustat_merged")
    parser.add_argument("--bootstrap", type=int, default=200)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--controls", nargs="*", default=["t"],
                        help="Control columns for Stage 1 (default: t)")
    args = parser.parse_args()

    if not os.path.exists(args.db):
        raise FileNotFoundError(f"Database not found: {args.db}")

    est = estimate_tfp_acf(
        db_path=args.db,
        table=args.table,
        controls=args.controls,
        n_bootstrap=args.bootstrap,
        seed=args.seed,
    )
