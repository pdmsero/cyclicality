# Proofs — symbolic verification (cyclicality)

SymPy scripts that verify the firm-level structural model in `paper/main.tex` §3 (the Markov equilibrium for the firm's R&D investment problem). Empirical content (Tables 9, 10, IV regressions, financial-constraint analyses) is not verifiable by algebra; see [`../results/`](../results/) for the Python pipeline outputs.

## Scope

Verifies the **theoretical-model layer only**. The bulk of the paper is empirical; the model is used for parameter calibration via simulation and to back out the structural elasticity $\gamma$ from observed first moments. The simulation is performed in Dynare (see [`../code/dynare/README.md`](../code/dynare/README.md) — the original `.mod` files are not preserved; reconstruction-only).

## Files

| Script | Verifies |
|---|---|
| [`01_household_sdf.py`](01_household_sdf.py) | Stochastic discount factor $\Lambda_{t,t+1} = \beta (C_t/C_{t+1})^\sigma$; Euler bond pricing. |
| [`02_production.py`](02_production.py) | Cobb–Douglas production $Y = \Omega K^\alpha (QL)^{1-\alpha}$; constant returns to scale; factor shares; marginal-product identities. |
| [`03_capital_foc.py`](03_capital_foc.py) | Capital first-order condition (eq. \ref{equation7}): $1 = \mathbb{E}_t[\Lambda(1 - \delta + \alpha((\epsilon-1)/\epsilon) Y/K)]$. Equivalence with the value-side form $\mathbb{E}_t[\Lambda V_{t+1}/(V_t - D_t)]$. |
| [`04_rnd_foc.py`](04_rnd_foc.py) | R&D first-order condition (eq. \ref{equation8}): $1 = \mathbb{E}_t[\Lambda V^Q_{t+1}] (\partial \mathcal{P}/\partial Z)(q_{j+1} - q_j)$. Identification of the structural elasticity $\gamma$ as the log-derivative of $\mathcal{P}$. |

## Running

```bash
cd papers/cyclicality/proofs
python 01_household_sdf.py
python 02_production.py
python 03_capital_foc.py
python 04_rnd_foc.py
```

## What's deliberately not verified

- Empirical regressions (Tables 9, 10, IV tables, KZ/WW indices). These are regression specifications, not symbolic identities. The Python pipeline in `code/python/` replicates the Stata baseline.
- Industry-level instrument validity (BEA IO tables, etc.). Verified by the IV pipeline (`code/python/30_*.py`).
- Dynare simulation results ($\gamma$ between 0.32 and 0.40, $\gamma \in \{0.05, 0.10, 0.15, 0.20\}$ parameter sweep). The original `.mod` files are missing; reconstructed from paper equations.

## Convention

Same as `papers/ai-compute-pricing/proofs/`.
