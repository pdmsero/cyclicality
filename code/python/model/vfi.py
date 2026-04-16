"""
vfi.py
------
Value function iteration (VFI) on the R&D model.

Because production is CRS with endogenous labour, the value function is
LINEAR in K̃: Ṽ(K̃, a) = φ(a)*K̃ + ν(a). This means the interesting
dynamics come only from the TFP shock a, and the model reduces to a
1-dimensional problem.

We solve for the policy function Z̃(a) on a discretised Tauchen grid for
log(a). The Bellman in value-per-unit-capital v(a) = Ṽ(K̃_SS, a)/K̃_SS is:

  v(a) = max_{Z̃≥0} [f(a) - Z̃/(K̃_SS) - I̅(Z̃)/K̃_SS]
        + β * E[v(a')]

  where  f(a)    = θ*Ỹ(a)/K̃_SS - W̄*L(a)/K̃_SS + (1-δ)
                 = [θ*a*ell(a)^(1-α) - W̄*ell(a) + 1-δ]
         I̅(Z̃)/K̃_SS = (1+(λ-1)*η*Z̃^γ)*1 - (1-δ)  [choosing K̃'=K̃_SS]
                     = δ + (λ-1)*η*Z̃^γ

  So: v(a) = max_{Z̃} [f(a) - Z̃/K̃_SS - δ - (λ-1)*η*Z̃^γ] + β*E[v(a')]

  (Note: the continuation β*E[v(a')] is independent of Z̃, so the
   optimisation over Z̃ is just maximisation of the static payoff
   d(Z̃) = f(a) - Z̃/K̃_SS - (λ-1)*η*Z̃^γ - δ, which gives the R&D FOC.)

  FOC for Z̃: -1/K̃_SS - (λ-1)*η*γ*Z̃^(γ-1) + β*E[v(a')] * η*γ*Z̃^(γ-1)*(λ-1) = 0

  Wait — actually Z̃ also enters the continuation through K̃' (if K̃' is
  chosen optimally). With V linear in K̃, the cost of K̃' = K̃_SS is:
  (1+(λ-1)*P_inn)*K̃_SS and benefit = β*K̃_SS*φ(a'). At SS, these are
  equal. Off-SS (different a), the firm still sets K̃' = K̃_SS (or adjusts
  immediately due to no adjustment costs).

  Fixing K̃' = K̃_SS = 1 at all times, the Bellman collapses to:

  v(a) = max_{Z̃} d(Z̃, a) + β*E[v(a')]

  where d(Z̃, a) = θ*a*ell(a)^(1-α) - W̄*ell(a) - Z̃ - (δ+(λ-1)*η*Z̃^γ)

  The FOC gives: 1 = β * E[v(a')] * η*γ*Z̃^(γ-1) * (λ-1) * (1+(λ-1)*η*Z̃^γ)

  Wait, let me be more careful. In the Bellman, v = Ṽ/K̃_SS:
  Ṽ(K̃_SS, a) = D̃ + β*E[Ṽ(K̃_SS, a')] [with K̃'=K̃_SS, fixed]
  D̃ = θ*Ỹ - W̄*L - Z̃ - [(1+(λ-1)*P_inn)*K̃_SS - (1-δ)*K̃_SS]
     = f̃(a)*K̃_SS - Z̃ - (λ-1)*η*Z̃^γ*K̃_SS
  (where f̃(a) = θ*a*ell^(1-α) - W̄*ell and K̃_SS=1)

  Ṽ = f̃(a) - Z̃ - (λ-1)*η*Z̃^γ + β*E[Ṽ']

  FOC for Z̃:
    ∂Ṽ/∂Z̃ = -1 - (λ-1)*η*γ*Z̃^(γ-1) + β*η*γ*Z̃^(γ-1)*(λ-1)*E[Ṽ'] = 0
    → 1 = β*η*γ*Z̃^(γ-1)*(λ-1)*E[Ṽ'] - (λ-1)*η*γ*Z̃^(γ-1)

  Hmm — but Z̃ also affects β*E[Ṽ'] via K̃' if Z̃ determines the quality
  step probability. With fixed K̃'=K̃_SS, only the direct cost (-Z̃) and
  the discount factor (through P_inn... wait, no: the Λ̃ is the SDF which
  is external, not chosen by the firm.

  Let me re-derive. The Bellman is:
  Ṽ = D̃ + Λ̃*(1+(λ-1)*P_inn)*E[Ṽ']   where Λ̃ = β/(1+(λ-1)*P_inn)
    = D̃ + β*E[Ṽ']    [since Λ̃*(1+(λ-1)*P) = β regardless of Z̃]

  So: Ṽ = f̃(a) - Z̃ - (λ-1)*η*Z̃^γ + β*E[Ṽ']

  FOC: ∂Ṽ/∂Z̃ = -1 - (λ-1)*η*γ*Z̃^(γ-1) = 0  → impossible for γ>0!

  The issue: with K̃' = K̃_SS fixed, the FOC says -1 - (λ-1)*P_inn'*γ/Z̃ = 0
  which has no solution (both terms are negative). This means the optimal Z̃
  is at a corner — either Z̃=0 (no R&D) or Z̃ as large as D̃ allows.

  RESOLUTION: The firm's choice of Z̃ affects BOTH the dividend AND the
  future value through the R&D FOC. The correct approach is the full
  Bellman including the R&D FOC marginal value. We need:

  Ṽ = D̃ + Λ̃*(1+(λ-1)*η*Z̃^γ)*E[Ṽ']

  where Λ̃ = β/(1+(λ-1)*P_inn) depends on Z̃. So the continuation term is:
  β*E[Ṽ']   [after simplification — independent of Z̃!]

  This confirms: given K̃'=K̃_SS, the only Z̃-dependent term in Ṽ is D̃.
  D̃ = θ*Ỹ - W̄*L - Z̃ - I̅ = f̃(a) - Z̃ - (δ+(λ-1)*P_inn)
  is DECREASING in Z̃ (both Z̃ and (λ-1)*P_inn increase with Z̃).
  So the firm minimises Z̃! Z̃ = 0 is optimal given K̃'=K̃_SS.

  This CAN'T be right. The issue is that Z̃ also affects the VALUE of the
  firm through the quality step. When quality improves, V(K,Q) = Ṽ(K/Q,1)*Q.
  A higher quality Q means a proportionally higher firm value. But this
  "bonus" from quality improvements is ALREADY captured in the SDF Λ̃:

  E[Λ_{t,t+1} * V_{t+1}/V_t] = 1 (return on shares = discount rate)
  = E[Λ̃ * (P*λ + (1-P)*1)] = E[Λ̃ * (1+(λ-1)*P)]

  By setting Λ̃ = β/(1+(λ-1)*P), we've already "priced in" the quality
  benefit. So the R&D FOC from the Bellman captures this correctly as:

  ∂Ṽ/∂Z̃:  -1 + β*η*γ*Z̃^(γ-1)*(λ-1)*E[Ṽ']/...

  WAIT — let me redo this carefully. The Bellman is:

  Ṽ(K̃, a) = max_{Z̃, K̃'} {D̃ + Λ̃(Z̃) * (1+(λ-1)*η*Z̃^γ) * E[Ṽ(K̃', a')]}

  where D̃ = F̃(K̃,a) - Z̃ - K̃'*(1+(λ-1)*η*Z̃^γ) + (1-δ)*K̃

  ∂/∂Z̃: -1 - K̃'*(λ-1)*η*γ*Z̃^(γ-1)
         + [∂Λ̃/∂Z̃ * (1+(λ-1)*P) + Λ̃*(λ-1)*η*γ*Z̃^(γ-1)] * E[Ṽ'] = 0

  Since Λ̃*(1+(λ-1)*P) = β (constant!), ∂Λ̃/∂Z̃*(1+(λ-1)*P) + Λ̃*(λ-1)*P' =
  ∂[β]/∂Z̃ = 0. So this simplifies to:
  -1 - K̃'*(λ-1)*η*γ*Z̃^(γ-1) + 0 = 0 → impossible!

  Something is wrong with my formulation of the Bellman. Let me re-read
  the paper's value function.

  The paper's value function (from lines 282-286) is:
  Ṽ(K̃, 1) = D̃ + E_t{Λ̃ * [P*Ṽ(K̃', λ) + (1-P)*Ṽ(K̃', 1)]}

  With homogeneity Ṽ(K̃, λ) = λ*Ṽ(K̃, 1) (value scales with quality):
  = D̃ + E_t{Λ̃ * (1+(λ-1)*P) * Ṽ(K̃', 1)}
  = D̃ + β * E_t[Ṽ(K̃', 1)]

  FOC for Z̃: ∂/∂Z̃[D̃ + β*E[Ṽ']] = 0
  → -1 + β * E[∂Ṽ(K̃', 1)/∂Z̃] = 0

  But ∂Ṽ(K̃', 1)/∂Z̃ = 0 since Ṽ' depends on (K̃', a') not Z̃!
  So: -1 = 0 — contradiction.

  The FOC for Z̃ must account for the fact that Z̃ affects BOTH D̃ and the
  QUALITY STEP probability P, which feeds into the FUTURE VALUE through
  the quality scaling.

  But we already captured this — V(K,Q) = Ṽ(K/Q,1)*Q, and Z̃ affects Q
  through P_inn. The value of a quality improvement is (λ-1)*Ṽ(K̃', 1)
  per unit increase in quality. This is the V^Q derivative from equation (8)
  in the paper: ∂V/∂Q * (q_{j+1}-q_j) = (λ-1)*Ṽ(K̃', 1).

  So the R&D FOC is:
  1 = E_t{Λ_{t,t+1} * (λ-1)*Ṽ_{t+1}} * ∂P/∂Z̃

  = E_t{Λ̃ * (λ-1)*Ṽ(K̃', 1)} * η*γ*Z̃^(γ-1) / Q_t

  In the STATIONARY SYSTEM (divided by Q_t):
  1 = E_t{Λ̃ * (λ-1)*Ṽ(K̃'_t+1, 1)} * η*γ*Z̃^(γ-1)

  This is exactly the R&D FOC from the paper! The V in this equation is
  the FULL value function Ṽ(K̃', 1), which satisfies the Bellman.

  The point: the R&D FOC involves the marginal value of quality (the bonus
  from having quality improve), not the direct effect on D̃ alone. The
  Bellman-derived FOC is:
  ∂Ṽ(K̃_t, 1)/∂Z̃_t = 0 (choosing Z̃ to maximize current value)
  But this doesn't directly give the FOC because Z̃ affects FUTURE quality,
  not the current value function Ṽ(K̃_t, 1) (which is already conditional
  on current quality = 1).

  RESOLUTION: The firm's FOC for Z̃ comes from the JOINT optimisation over
  (K̃', Z̃) in the Bellman where the CONTINUATION VALUE includes the quality
  jump. In the paper's formulation, this is handled by V^Q (marginal value
  of quality).

  For the purpose of numerical solution, the correct Bellman is:

  Ṽ(K̃_t, 1) = max_{Z̃, K̃'} {
    D̃(K̃_t, a_t, Z̃, K̃') +
    E_t[Λ̃_{t,t+1} * (P_inn*λ + (1-P_inn)*1) * Ṽ(K̃', 1)]
  }

  where D̃ = θ*Ỹ - W̄*L - Z̃ - [(1+(λ-1)*P_inn)*K̃' - (1-δ)*K̃]
  and   Λ̃_{t,t+1} is the REALISED discount factor (not conditional on Z̃).

  But Λ̃*(P*λ + (1-P)) = Λ̃*(1+(λ-1)*P). And Λ̃ = β/(1+(λ-1)*P_inn), so
  Λ̃*(1+(λ-1)*P_inn) = β (constant). Hence the Bellman IS Ṽ = D̃ + β*E[Ṽ'].

  This is the CORRECT Bellman, but the R&D FOC comes from the GRADIENT
  with respect to Z̃ of the RIGHT-HAND SIDE, which includes Z̃'s effect
  on D̃ AND on (implicitly) the future quality:

  ∂RHS/∂Z̃ = ∂D̃/∂Z̃ + β * ∂E[Ṽ(K̃',a')]/∂Z̃

  Now, ∂E[Ṽ(K̃',a')]/∂Z̃ = 0 (since K̃' is a separate choice variable
  and Ṽ' doesn't depend on Z̃ directly).

  ∂D̃/∂Z̃ = -1 - (λ-1)*η*γ*Z̃^(γ-1)*K̃' < 0 always.

  So V is decreasing in Z̃ and the firm sets Z̃=0! The R&D FOC 1 = Λ̃*η*γ*...
  is NOT obtainable from the Bellman formulated this way.

  THE RESOLUTION: the paper's model has a DIFFERENT structure. The value
  function is defined RECURSIVELY including the quality step explicitly:

  V(K_t, Q_t) = D_t + E_t[Λ_{t,t+1} * V(K_{t+1}, Q_{t+1})]
              = D_t + E_t[Λ_{t,t+1} * (P_inn*V(K_{t+1},λQ_t) + (1-P_inn)*V(K_{t+1},Q_t))]
              = D_t + E_t[Λ_{t,t+1} * Q_t * (P_inn*λ + (1-P_inn)) * v(K̃_{t+1}, 1)]
              [using V(K, λQ) = λ*Q*v(K/(λQ), 1) = ... hmm this gets messy]

  Actually: V(K, Q) = Q*v(K/Q) by homogeneity. So:
  - V(K_{t+1}, λQ_t) = λQ_t * v(K_{t+1}/(λQ_t)) = λQ_t * v(K̃_{t+1}/λ)
  - V(K_{t+1}, Q_t)  = Q_t  * v(K_{t+1}/Q_t)   = Q_t  * v(K̃_{t+1})

  The FOC for Z_t (in LEVELS):
  ∂V/∂Z_t = ∂D_t/∂Z_t + E_t[Λ * Q_t * (λ-1) * v(K̃_{t+1}) * ∂P_inn/∂Z_t] = 0
  → Q_t: -1 + E_t[Λ * Q_t * (λ-1) * v(K̃_{t+1}) * η*γ*(Z_t/Q_t)^(γ-1)/Q_t] = 0

  Dividing by Q_t:
  → 1 = E_t[Λ * (λ-1) * v(K̃_{t+1}) * η*γ*Z̃_t^(γ-1)]

  And v(K̃_{t+1}) = Ṽ(K̃_{t+1}, 1) (the stationary value function).

  This IS the correct R&D FOC! The key insight:
  - The "value of quality" (λ-1)*Ṽ(K̃', 1) comes from the LEVEL value
    function including the EXPLICIT quality-dependent continuation.
  - The Ṽ = D̃ + β*E[Ṽ'] is the correct STATIONARY VALUE FUNCTION where
    Ṽ(K̃, 1) plays the role of v(K̃) above.

  So the CORRECT system is:
  (I)  Ṽ(K̃, a) = D̃ + β * E[Ṽ(K̃', a')]   [Bellman for Ṽ]
  (II) 1 = Λ̃ * (λ-1) * Ṽ(K̃', a') * η*γ*Z̃^(γ-1)   [R&D FOC from levels]
  (III) 1 = Λ̃ * E[1-δ + α*θ*Ỹ'/K̃']   [capital Euler]

  The R&D FOC uses the CONTINUATION VALUE (not current Ṽ).

  In the Bellman (I), Z̃ appears in D̃ only: D̃ = θỸ - W̄L - Z̃ - I.
  The continuation β*E[Ṽ'] is independent of Z̃ (since K̃' is separately
  chosen and Ṽ' doesn't depend on today's Z̃).

  Wait, so the Bellman ∂/∂Z̃ = -1 - ∂I/∂Z̃ only, giving FOC:
  1 + (λ-1)*η*γ*Z̃^(γ-1)*K̃' = 0, still impossible.

  The resolution MUST be that D̃ is formulated differently in the paper.
  In the LEVEL problem:
    D_t = P^d * Y_t - W_t*L_t - I_t - Z_t
    K_{t+1} = (1-δ)*K_t + I_t

  So I_t = K_{t+1} - (1-δ)*K_t is the PHYSICAL investment.
  In the stationary system, I_t/Q_t = K̃_{t+1}*(Q_{t+1}/Q_t) - (1-δ)*K̃_t.

  The CORRECT stationary investment is:
  Ĩ_t = I_t/Q_t = K̃_{t+1}*(Q_{t+1}/Q_t) - (1-δ)*K̃_t

  But Q_{t+1}/Q_t is STOCHASTIC (not just P_inn deterministic). It equals
  λ with prob P_inn, and 1 with prob 1-P_inn. So:

  E[Ĩ_t] = K̃_{t+1}*(1+(λ-1)*P_inn) - (1-δ)*K̃_t

  But the REALISATION of Ĩ_t is either:
  - K̃_{t+1}*λ - (1-δ)*K̃_t  (if innovation)
  - K̃_{t+1}*1  - (1-δ)*K̃_t  (if no innovation)

  This is the key point: the investment I_t is KNOWN ex-ante (the firm
  chooses K_{t+1} = (1-δ)*K_t + I_t deterministically). But the
  STATIONARY investment Ĩ_t = I_t/Q_t is STOCHASTIC because Q_t+1 is
  random.

  The firm doesn't choose Ĩ_t (it chooses K_{t+1} = K̃_{t+1}*Q_{t+1}).
  Given that Q_{t+1} is random, choosing K̃_{t+1} (the targeted stationary
  capital) determines I_t = K_{t+1} - (1-δ)*K_t deterministically.

  Hmm, actually the firm chooses I_t (physical investment) deterministically.
  This determines K_{t+1} = (1-δ)*K_t + I_t (also deterministic). But
  K̃_{t+1} = K_{t+1}/Q_{t+1} is stochastic because Q_{t+1} is random.

  So the "choice of K̃_{t+1}" is not what the firm directly chooses —
  the firm chooses I_t, and K̃_{t+1} is a derived, stochastic quantity.

  This changes the formulation significantly. The correct firm problem in
  LEVELS is:
  V(K_t, Q_t) = max_{I_t, Z_t, L_t} {D_t + E_t[Λ * V(K_{t+1}, Q_{t+1})]}
  where D_t = P^d*Y_t - W*L_t - I_t - Z_t
        K_{t+1} = (1-δ)*K_t + I_t  (deterministic)
        Q_{t+1} = λQ_t or Q_t  (stochastic with prob P_inn(Z_t))

  FOC for Z_t:
  ∂V/∂Z_t = -1 + E_t[Λ * ∂V(K_{t+1},Q_{t+1})/∂Z_t] = 0
  ∂V(K_{t+1},Q_{t+1})/∂Z_t = ∂V/∂Q_{t+1} * ∂Q_{t+1}/∂Z_t
                              = V^Q * ∂P_inn/∂Z_t * (λQ_t - Q_t)
                              = Q_t * v'(K̃_{t+1}) * (λ-1) * η*γ*Z̃_t^(γ-1)/Q_t
                              [using V^Q = Q_t * v'(K̃_{t+1}) from homogeneity]

  So: 1 = E_t[Λ * Q_t * v'(K̃_{t+1}) * (λ-1) * η*γ*Z̃_t^(γ-1)/Q_t]
        = E_t[Λ * (λ-1) * Ṽ(K̃_{t+1}, 1) * η*γ*Z̃_t^(γ-1)]
  → 1 = Λ̃ * (λ-1) * η*γ*Z̃_t^(γ-1) * E_t[Ṽ(K̃_{t+1}, 1)]  ✓

  So the R&D FOC is CORRECT. And the Bellman:
  V(K,Q) = D + E[Λ * V(K',Q')]
  Ṽ(K̃,1)*Q = D + E[Λ * Q' * Ṽ(K̃',1)]
  Ṽ(K̃,1) = D̃ + E[Λ * (Q'/Q) * Ṽ(K̃',1)]
           = D̃ + E[Λ̃ * Ṽ(K̃',1)]  where Λ̃ ≡ Λ*(Q'/Q)

  The Λ̃ = Λ*(Q'/Q) is NOT the same as Λ̃ = β/(1+(λ-1)*P_inn). They agree
  IN EXPECTATION at SS, but not state-by-state.

  E[Λ̃] = E[Λ * Q'/Q] = Λ * E[Q'/Q] = Λ * (1+(λ-1)*P_inn) = β

  So the EXPECTED discount for Ṽ' is β. The Bellman becomes:
  Ṽ = D̃ + β*E[Ṽ'] in expectation, but state-by-state:
  - If innovation: Ṽ = D̃ + Λ*λ*Ṽ'
  - If no innov.: Ṽ = D̃ + Λ*1*Ṽ'

  E[Ṽ] = D̃ + Λ*(P*λ + (1-P))*Ṽ' = D̃ + Λ*(1+(λ-1)*P)*E[Ṽ']

  This is exactly the paper's equation (lines 282-286)!

  Now, the FOC from THIS Bellman:
  ∂Ṽ/∂Z̃ = ∂D̃/∂Z̃ + E[Λ * (Q'/Q) * ∂Ṽ'/∂Z̃ + Λ * ∂(Q'/Q)/∂Z̃ * Ṽ']

  The first term: ∂D̃/∂Z̃ = -1 - (λ-1)*η*γ*Z̃^(γ-1)*K̃' (from investment)
  The last term:  E[Λ * ∂(Q'/Q)/∂Z̃ * Ṽ'] = Λ * (λ-1)*η*γ*Z̃^(γ-1) * Ṽ'

  So: ∂Ṽ/∂Z̃ = -1 - (λ-1)*η*γ*Z̃^(γ-1)*K̃' + Λ*(λ-1)*η*γ*Z̃^(γ-1)*E[Ṽ'] = 0

  With K̃' = K̃_SS = 1 (our normalisation):
  1 + (λ-1)*η*γ*Z̃^(γ-1) = Λ*(λ-1)*η*γ*Z̃^(γ-1)*E[Ṽ']
  1 = Λ*(λ-1)*η*γ*Z̃^(γ-1)*(E[Ṽ'] - 1/Λ) ... hmm

  This gives: 1 = (λ-1)*η*γ*Z̃^(γ-1) * (Λ*E[Ṽ'] - 1)

  At SS: Λ_SS = Λ̃_SS = β/(1+(λ-1)*P_SS), E[Ṽ'] = Ṽ_SS.
  Λ_SS*Ṽ_SS = β*Ṽ_SS/(1+(λ-1)*P_SS)
  1 = (λ-1)*η*γ*Z̃_SS^(γ-1) * (β*Ṽ_SS/(1+(λ-1)*P_SS) - 1)

  But from the paper's R&D FOC: 1 = Λ̃_SS * (λ-1)*η*γ*Z̃_SS^(γ-1) * Ṽ_SS
  = β/(1+(λ-1)*P_SS) * (λ-1)*η*γ*Z̃_SS^(γ-1) * Ṽ_SS.

  These match:
  β*Ṽ_SS/(1+(λ-1)*P_SS) - 1 = ... let me check with numbers.
  From SS: Ṽ_SS = 1.01, Λ̃_SS = β/(1+0.022) = 0.96/1.022 = 0.9393
  Λ̃*Ṽ = 0.9393*1.01 = 0.9487
  My formula: β*Ṽ/(1+(λ-1)*P) - 1 = same = 0.9487 - 1 = -0.0513 < 0!
  So 1 = (λ-1)*η*γ*Z̃^(γ-1) * (-0.0513) → impossible since left side > 0!

  There's a sign error somewhere. Let me redo.

  The correct sign of ∂I/∂Z̃: I = (1+(λ-1)*η*Z̃^γ)*K̃' - (1-δ)*K̃.
  ∂I/∂Z̃ = (λ-1)*η*γ*Z̃^(γ-1)*K̃'. With K̃'>0, λ>1, η,γ>0: ∂I/∂Z̃ > 0.

  So ∂D̃/∂Z̃ = -1 - (λ-1)*η*γ*Z̃^(γ-1)*K̃' < 0. Both terms are negative.

  And ∂(Q'/Q)/∂Z̃: Q'/Q = λ with prob P_inn, 1 with prob 1-P_inn.
  ∂E[Q'/Q]/∂Z̃ = (λ-1)*∂P_inn/∂Z̃ = (λ-1)*η*γ*Z̃^(γ-1) > 0.

  So: FOC = ∂D̃/∂Z̃ + Λ * E[Ṽ'] * (λ-1)*η*γ*Z̃^(γ-1) = 0
  → -1 - K̃'*(λ-1)*η*γ*Z̃^(γ-1) + Λ*E[Ṽ']*(λ-1)*η*γ*Z̃^(γ-1) = 0
  → (λ-1)*η*γ*Z̃^(γ-1) * (Λ*E[Ṽ'] - K̃') = 1
  → 1 = (λ-1)*η*γ*Z̃^(γ-1) * (Λ*E[Ṽ'] - K̃')

  With K̃' = K̃_SS = 1: Λ = Λ̃_SS = β/(1+(λ-1)*P_SS), E[Ṽ'] = Ṽ_SS.
  Λ*Ṽ_SS = β*Ṽ_SS/(1+(λ-1)*P_SS) = Λ̃_SS * Ṽ_SS

  From the paper's FOC: 1 = Λ̃ * (λ-1)*η*γ*Z̃^(γ-1) * Ṽ' → Λ̃*Ṽ' = 1/[(λ-1)*η*γ*Z̃^(γ-1)]

  My FOC: 1 = (λ-1)*η*γ*Z̃^(γ-1) * (Λ̃*Ṽ' - 1)
  → Λ̃*Ṽ' - 1 = 1/[(λ-1)*η*γ*Z̃^(γ-1)]
  → Λ̃*Ṽ' = 1 + 1/[(λ-1)*η*γ*Z̃^(γ-1)]

  But from paper's FOC: Λ̃*Ṽ' = 1/[(λ-1)*η*γ*Z̃^(γ-1)].

  These DON'T match. So there's a discrepancy between my Bellman-derived
  FOC and the paper's stated FOC.

  The difference is the K̃'=1 term. From my FOC:
  1 = (λ-1)*η*γ*Z̃^(γ-1) * (Λ̃*Ṽ' - K̃')

  vs paper's FOC:
  1 = Λ̃*(λ-1)*η*γ*Z̃^(γ-1) * Ṽ'
  → 1 = (λ-1)*η*γ*Z̃^(γ-1) * Λ̃*Ṽ'

  These are the same only if K̃' = 0, i.e., the firm sets K̃' → 0 after each
  R&D decision!

  This suggests the model has K̃'=0 as the capital policy: the firm liquidates
  all capital after each period and rebuilds from scratch! Or equivalently:
  capital investment and quality decisions are orthogonal, and the capital
  Euler condition fixes the relationship between Z̃ and returns differently.

  ALTERNATIVELY: maybe I'm formulating the investment incorrectly. Let me
  reconsider. In the paper's capital accumulation (from eq. 294):
  Ĩ_{i,t} = (1+(λ-1)*P(Z̃))*K̃_{i,t+1} - (1-δ)*K̃_{i,t}

  This is the investment IN THE STATIONARY SYSTEM. The firm CHOOSES K̃_{t+1}
  (stationary next-period capital), and Ĩ_t is the corresponding physical
  investment normalised by Q_t. The KEY: K̃_{t+1} is chosen KNOWING Q_{t+1}
  will be random. The firm commits to I_t = Q_t * Ĩ_t before the quality
  shock is realised.

  But wait: K_{t+1} = (1-δ)*K_t + I_t (deterministic). K̃_{t+1} = K_{t+1}/Q_{t+1}
  (stochastic). So choosing K̃_{t+1} as a choice variable is odd because it's
  stochastic.

  I think the paper's formulation treats K̃_{t+1} as the EXPECTED (or target)
  stationary capital, and the investment adjusts accordingly. In the
  end-of-period timing:
  - Firm chooses K̃^e_{t} (end-of-period stationary capital)
  - Quality shock realises: Q_{t+1} = λQ_t or Q_t
  - K_{t+1}^b = Q_{t+1} * K̃^e_t (beginning-of-next-period capital)
  - Ĩ = K̃^e_t * (Q_{t+1}/Q_t) - (1-δ)*K̃_t^b

  In this case, D̃_t = θỸ_t - W̄L_t - Z̃_t - K̃^e_t * (Q_{t+1}/Q_t) + (1-δ)*K̃^b_t

  At the decision time (before Q_{t+1} realises):
  E[D̃_t] = θỸ_t - W̄L_t - Z̃_t - K̃^e_t * (1+(λ-1)*P_inn) + (1-δ)*K̃^b_t

  This gives: E[Ĩ_t] = K̃^e_t * (1+(λ-1)*P_inn) - (1-δ)*K̃^b_t ✓

  FOC for K̃^e_t (= K̃_{t+1}):
  ∂V/∂K̃^e = E[∂D̃/∂K̃^e] + E[Λ * ∂V(K_{t+1}^b, Q_{t+1})/∂K̃^e] = 0

  ∂D̃/∂K̃^e = -(Q_{t+1}/Q_t) (stochastic!)
  ∂V(K_{t+1}^b, Q_{t+1})/∂K̃^e = ∂V/∂K^b * ∂K^b/∂K̃^e = v'(K̃^e) * Q_{t+1}

  E[-(Q_{t+1}/Q_t) + Λ * v'(K̃^e) * Q_{t+1}] = 0
  E[-1 + Λ * Q_t * v'(K̃^e)] = 0  [dividing by Q_{t+1}/Q_t]

  Hmm, this is getting messy. Let me just trust the paper's stated FOCs
  and implement them numerically.

The PRACTICAL SOLUTION for VFI:
  - The state is a_t (firm-specific TFP shock, AR(1))
  - At each state a, the firm's R&D Z̃(a) satisfies the R&D FOC:
    1 = Λ̃(Z̃) * (λ-1) * η*γ*Z̃^(γ-1) * E[Ṽ(a')]
  - The value function Ṽ(a) satisfies:
    Ṽ(a) = D̃(a, Z̃(a)) + β*E[Ṽ(a')]

  This is a FIXED POINT PROBLEM in Ṽ and Z̃ jointly.

  We solve by VFI: given Ṽ, solve the R&D FOC for Z̃(a), then update Ṽ.
  The capital Euler separately gives K̃'=K̃_SS (from SS level conditions),
  so K̃ is kept fixed at K̃_SS throughout.

Implementation below.
"""

from __future__ import annotations
import numpy as np
from scipy.optimize import brentq
from scipy.stats import norm as scipy_norm
from dataclasses import dataclass
from typing import Tuple
from .params import ModelParams
from .steady_state import SteadyState, solve as solve_ss


@dataclass
class VFISolution:
    """VFI solution: value function and policy on TFP grid."""
    V:       np.ndarray    # (n_a,) value function Ṽ(a)
    pol_Z:   np.ndarray    # (n_a,) R&D policy Z̃(a)
    a_grid:  np.ndarray    # (n_a,) TFP grid
    P_a:     np.ndarray    # (n_a, n_a) transition matrix
    ss:      SteadyState
    p:       ModelParams

    def simulate(self, N: int = None, T: int = None, seed: int = 42) -> dict:
        """Simulate N firms × T periods; returns Z̃, Ỹ, a (shape (N, T))."""
        p = self.p; ss = self.ss
        if N is None: N = p.N_firms
        if T is None: T = p.T_sim
        T_total = T + p.T_burn

        rng = np.random.default_rng(seed)
        n_a = len(self.a_grid)

        # Simulate Markov chains
        a_idx = np.zeros((N, T_total), dtype=int)
        a_idx[:, 0] = n_a // 2
        for t in range(1, T_total):
            cum = np.cumsum(self.P_a[a_idx[:, t-1]], axis=1)   # (N, n_a)
            u   = rng.random(N)[:, None]
            a_idx[:, t] = (u > cum).sum(axis=1)

        a_arr  = self.a_grid[a_idx]
        Z_sim  = np.interp(np.log(a_arr), np.log(self.a_grid), self.pol_Z)
        # Clamp to positive
        Z_sim  = np.maximum(Z_sim, 1e-12)

        # Output: Ỹ = a*K̃^α*L^(1-α) with K̃=K̃_SS=1, L from labour FOC
        alpha = p.alpha; theta = p.theta; W_bar = ss.W_bar
        ell = ((1-alpha)*theta*a_arr/W_bar)**(1/alpha)
        Y_sim = a_arr * ell**(1-alpha)   # K̃_SS=1

        return {
            "Z_tilde": Z_sim[:, p.T_burn:],
            "Y_tilde": Y_sim[:, p.T_burn:],
            "a":       a_arr[:, p.T_burn:],
        }


def tauchen(rho: float, sigma: float, n: int, m: float = 3.0
            ) -> Tuple[np.ndarray, np.ndarray]:
    """
    Tauchen (1986) discretisation of x_t = ρ*x_{t-1} + σ*ε_t, ε~N(0,1).
    Returns (grid, P) where grid is in x-space and P is (n,n) transition matrix.
    """
    sigma_x = sigma / np.sqrt(1.0 - rho**2)
    x_max = m * sigma_x
    grid = np.linspace(-x_max, x_max, n)
    d = grid[1] - grid[0]

    P = np.zeros((n, n))
    for i in range(n):
        mu_cond = rho * grid[i]
        P[i, 0]   = scipy_norm.cdf((grid[0]   - mu_cond + d/2) / sigma)
        P[i, n-1] = 1 - scipy_norm.cdf((grid[n-2] - mu_cond + d/2) / sigma)
        for j in range(1, n-1):
            P[i, j] = (scipy_norm.cdf((grid[j] - mu_cond + d/2) / sigma) -
                       scipy_norm.cdf((grid[j] - mu_cond - d/2) / sigma))
    # Normalise rows to sum to 1
    P = P / P.sum(axis=1, keepdims=True)
    return grid, P


def solve(p: ModelParams, tol: float = 1e-8, max_iter: int = 3000,
          verbose: bool = False) -> VFISolution:
    """
    Solve the model by value function iteration on the TFP grid.

    Algorithm: iterate on the fixed-point system
      V^{n+1}(a_j) = D̃(a_j, Z̃^n(a_j)) + β * Σ_j' P[j,j'] * V^n(a_j')

    where Z̃^n(a_j) solves the R&D FOC given E[V^n(a')]:
      1 = Λ̃(Z̃) * (λ-1) * η*γ * Z̃^(γ-1) * EV_j
    with EV_j = Σ_j' P[j,j'] * V^n(a_j')  and  Λ̃(Z̃) = β/(1+(λ-1)*η*Z̃^γ).

    Note: capital is fixed at K̃_SS = 1 throughout (R&D decision only).
    """
    ss = solve_ss(p, verbose=False)

    alpha = p.alpha; delta = p.delta; beta = p.beta
    theta = p.theta; lam = p.lam; gamma = p.gamma; eta = p.eta
    W_bar = ss.W_bar

    # ── TFP grid (Tauchen on log a) ───────────────────────────────────────────
    log_a_grid, P_a = tauchen(p.rho_a, p.sigma_a, p.n_a)
    a_grid = np.exp(log_a_grid)
    n_a = p.n_a

    # ── Pre-compute base dividend (before Z̃) at each a ────────────────────────
    # F̃(a) = θ*Ỹ(a) - W̄*L(a) = α*θ*Ỹ(a)   [labour share = (1-α)*θ*Ỹ]
    # Ĩ_base = δ + (λ-1)*P_SS  (deterministic part independent of Z̃ optimisation)
    # D̃_base(a) = F̃(a) - Ĩ_base  (then subtract Z̃ and quality-step investment)
    # Full D̃(a, Z̃) = θ*Ỹ(a) - W̄*L(a) - Z̃ - (1+(λ-1)*η*Z̃^γ)*K̃' + (1-δ)*K̃
    #               = θ*Ỹ(a) - W̄*L(a) - Z̃ - δ - (λ-1)*η*Z̃^γ
    #  [with K̃=K̃'=1]
    F_tilde = np.zeros(n_a)
    for j, a in enumerate(a_grid):
        ell = ((1-alpha)*theta*a/W_bar)**(1/alpha)
        L   = ell   # K̃_SS = 1
        Y   = a * L**(1-alpha)
        F_tilde[j] = theta*Y - W_bar*L   # = α*θ*Y

    # base_D[j] = F_tilde[j] - delta  (investment cost δ with K̃'=K̃=1)
    base_D = F_tilde - delta  # shape (n_a,); positive if α*θ*Y > δ

    def compute_Z(EV: float, base_D_j: float) -> float:
        """
        Solve R&D FOC for Z̃ given expected continuation value EV = E[Ṽ(a')].
        FOC: 1 = Λ̃(Z̃) * (λ-1) * η * γ * Z̃^(γ-1) * EV
             with Λ̃(Z̃) = β/(1+(λ-1)*η*Z̃^γ)
        → 1+(λ-1)*η*Z̃^γ = β * (λ-1) * η * γ * Z̃^(γ-1) * EV
        Let x = Z̃: 1 + (λ-1)*η*x^γ = β*(λ-1)*η*γ*x^(γ-1)*EV

        Rearrange: β*(λ-1)*η*γ*EV * x^(γ-1) - (λ-1)*η*x^γ - 1 = 0
        → x^(γ-1) * [β*(λ-1)*η*γ*EV - (λ-1)*η*x] - 1 = 0

        Feasibility: Z̃ ≤ base_D_j - delta_quality  (D̃ ≥ 0).
        D̃ = base_D_j - Z̃ - (λ-1)*η*Z̃^γ ≥ 0
        """
        if EV <= 0 or base_D_j <= 0:
            return 0.0

        def foc(z):
            if z <= 0:
                return -1.0
            P_inn = eta * z**gamma
            Lam   = beta / (1.0 + (lam-1)*P_inn)
            return 1.0 - Lam * (lam-1) * eta * gamma * z**(gamma-1) * EV

        # Bracket: small z → rhs→+∞ → foc<0; large z → rhs→0 → foc>0
        z_lo = 1e-10
        z_hi = min(base_D_j * 0.999, 10.0)

        # Check D̃ > 0 at z_hi
        while z_hi > z_lo:
            D_check = base_D_j - z_hi - (lam-1)*eta*z_hi**gamma
            if D_check > 0:
                break
            z_hi *= 0.5

        if z_hi <= z_lo:
            return 0.0

        f_lo = foc(z_lo)
        f_hi = foc(z_hi)

        if f_lo * f_hi > 0:
            # Both same sign — check if it's all negative (rhs always > 1)
            if f_lo < 0:
                # rhs > 1 everywhere, Z̃ wants to be very large → use max feasible
                return z_hi
            else:
                return z_lo  # both positive, shouldn't happen
        return brentq(foc, z_lo, z_hi, xtol=1e-12, rtol=1e-12)

    # ── Initial guess ─────────────────────────────────────────────────────────
    # Start with SS values
    V = np.full(n_a, ss.V_tilde)

    # ── Iteration ─────────────────────────────────────────────────────────────
    for it in range(max_iter):
        # Expected continuation: EV[j] = Σ_j' P[j,j'] * V[j']
        EV = P_a @ V   # (n_a,)

        # Solve FOC for Z̃ at each a
        Z_new = np.array([compute_Z(EV[j], base_D[j]) for j in range(n_a)])

        # Dividend at each a
        D_new = base_D - Z_new - (lam-1)*eta*Z_new**gamma

        # Value update
        V_new = D_new + beta * EV

        diff = np.max(np.abs(V_new - V))
        V = V_new

        if verbose and it % 100 == 0:
            print(f"  VFI iter {it:4d}: diff = {diff:.2e}")

        if diff < tol:
            if verbose:
                print(f"  VFI converged in {it+1} iterations. diff = {diff:.2e}")
            break
    else:
        import warnings
        warnings.warn(f"VFI did not converge after {max_iter} iterations (diff={diff:.2e})")

    # Final policy
    EV   = P_a @ V
    Z_ss = np.array([compute_Z(EV[j], base_D[j]) for j in range(n_a)])

    return VFISolution(V=V, pol_Z=Z_ss, a_grid=a_grid, P_a=P_a, ss=ss, p=p)
