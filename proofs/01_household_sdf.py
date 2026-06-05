"""
01_household_sdf.py — SDF + Euler.

Ref: paper/main.tex eq. (equation6) footnote and surrounding text.

  Lambda_{t,t+1} = beta * (C_t / C_{t+1})^sigma
"""

import sympy as sp

beta_var, C_t, C_next, sigma_var = sp.symbols("beta_var C_t C_next sigma_var", positive=True)
Lambda = beta_var * (C_t / C_next)**sigma_var

# ----------------------------------------------------------------------
# Claim 1 — Form: Lambda = beta * (C_t / C_{t+1})^sigma.
# Equivalent: log Lambda = log beta + sigma * (log C_t - log C_{t+1}).
# ----------------------------------------------------------------------
log_Lambda = sp.log(Lambda)
expected_log = sp.log(beta_var) + sigma_var * (sp.log(C_t) - sp.log(C_next))
diff = sp.simplify(log_Lambda - expected_log)
assert diff == 0
print("PASS 1: log Lambda = log beta + sigma * (log C_t - log C_{t+1}).")

# ----------------------------------------------------------------------
# Claim 2 — Euler / bond pricing.
# Bond gross return R_b satisfies 1 = E[Lambda * R_b].
# Under deterministic certainty equivalence: R_b = 1/Lambda = (C_{t+1}/C_t)^sigma / beta.
# ----------------------------------------------------------------------
R_b = 1 / Lambda
expected_R_b = (C_next / C_t)**sigma_var / beta_var
assert sp.simplify(R_b - expected_R_b) == 0
print("PASS 2: Bond return R_b = (C_{t+1}/C_t)^sigma / beta.")

# ----------------------------------------------------------------------
# Claim 3 — On BGP with C_{t+1} = exp(g_C) * C_t: R_b = exp(sigma * g_C) / beta.
# ----------------------------------------------------------------------
g_C = sp.symbols("g_C", positive=True)
R_b_BGP = R_b.subs(C_next, sp.exp(g_C) * C_t)
R_b_BGP_simplified = sp.simplify(R_b_BGP)
expected_BGP = sp.exp(sigma_var * g_C) / beta_var
diff = sp.simplify(R_b_BGP_simplified - expected_BGP)
assert diff == 0, f"BGP rate mismatch: got {R_b_BGP_simplified}, expected {expected_BGP}"
print("PASS 3: BGP gross bond rate R_b = exp(sigma g_C) / beta.")

# Sign check.
test = R_b_BGP_simplified.subs({sigma_var: 1, g_C: sp.Rational(1, 100), beta_var: sp.Rational(99, 100)})
assert test > 1
print("PASS 3b: R_b > 1 under positive growth and beta < 1.")

print("\nAll 01_household_sdf claims pass.")
