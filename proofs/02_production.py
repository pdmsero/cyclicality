"""
02_production.py — Cobb-Douglas production: CRS, factor shares, MPK identities.

Ref: paper/main.tex equation1.

  Y = Omega * K^alpha * (Q*L)^(1-alpha)
"""

import sympy as sp

Omega, K, alpha, Q, L = sp.symbols("Omega K alpha Q L", positive=True)
Y = Omega * K**alpha * (Q * L)**(1 - alpha)

# ----------------------------------------------------------------------
# Claim 1 — Constant returns to scale in (K, L).
# Y(s*K, s*L) = s * Y(K, L).
# ----------------------------------------------------------------------
s = sp.symbols("s", positive=True)
Y_scaled = Y.subs({K: s * K, L: s * L})
expected = s * Y
diff = sp.simplify(Y_scaled - expected)
assert diff == 0
print("PASS 1: CRS in (K, L).")

# ----------------------------------------------------------------------
# Claim 2 — Factor shares: alpha to capital, 1-alpha to (effective) labour.
# MPK * K / Y = alpha; MPL * L / Y = 1 - alpha.
# ----------------------------------------------------------------------
MPK = sp.diff(Y, K)
MPL = sp.diff(Y, L)
share_K = sp.simplify(MPK * K / Y)
share_L = sp.simplify(MPL * L / Y)
assert share_K - alpha == 0
assert sp.simplify(share_L - (1 - alpha)) == 0
print("PASS 2: Capital share = alpha; labour share = 1 - alpha.")

# ----------------------------------------------------------------------
# Claim 3 — Quality augments labour. dY/dQ * Q / Y = 1 - alpha (same as labour share).
# ----------------------------------------------------------------------
share_Q = sp.simplify(sp.diff(Y, Q) * Q / Y)
assert sp.simplify(share_Q - (1 - alpha)) == 0
print("PASS 3: Quality Q enters as labour-augmenting; dlog Y / dlog Q = 1 - alpha.")

# ----------------------------------------------------------------------
# Claim 4 — MPK identity used in capital FOC (eq. equation7):
#   MPK * (epsilon - 1) / epsilon = alpha * (epsilon-1)/epsilon * Y/K
# Verify the form. The (eps-1)/eps factor comes from monopolistic-competition pricing,
# applied separately in 03_capital_foc.py.
# ----------------------------------------------------------------------
expected_MPK = alpha * Y / K
diff_MPK = sp.simplify(MPK - expected_MPK)
assert diff_MPK == 0
print("PASS 4: MPK = alpha * Y / K (used in capital FOC eq. 7).")

print("\nAll 02_production claims pass.")
