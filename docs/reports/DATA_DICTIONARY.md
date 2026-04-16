# Data Dictionary: processed_alldata_stage3

Stage 3 is the analysis-ready panel table written by `12_transform_stage3.py`
(416 columns, ~120 K firm-year rows before regression-level filters).
It contains all variables used in regressions and IV estimates in scripts 30–36.

Variable names follow a systematic naming convention documented below.
Stage 4 (`13_transform_stage4.py`) adds GMM and TFP columns not listed here.

---

## Naming conventions

| Pattern | Meaning |
|---|---|
| `r_{deflator}_{var}` | Nominal `var` divided by the `{deflator}` price index |
| `d_{deflator}_{var}` | Log-difference of `r_{deflator}_{var}` (growth rate) |
| `d_h_{var}` | Positive part of `d_{deflator}_{var}` (= value when > 0, else 0) |
| `d_l_{var}` | Negative part (≤ 0 portion) |
| `dev_{var}` | Firm-demeaned growth rate: `d_{var} − mean_d_{var}` |
| `dev_h_{var}`, `dev_l_{var}` | Positive / negative part of `dev_{var}` |
| `l_{col}`, `l2_{col}` | One- and two-period lags of `col` |
| `z_xrd_{base}` | Ratio of R&D to `{base}` (sale, va, va_a, capx) |
| `d_{var}_KZ{q}` | `d_{var}` × indicator that firm is in KZ quartile q |
| `d_{var}_WW{q}` | `d_{var}` × indicator that firm is in WW quartile q |
| `d_{var}_ag`, `d_{var}_bg`, `d_{var}_ba` | `d_{var}` × high/low spread indicator (aaa_g, baa_g, baa_aaa) |
| `sale_i` | Industry-level sales (used as IV / industry output measure) |

### Deflator prefixes

| Prefix | Price index | Source |
|---|---|---|
| `gdp` | GDP deflator (`P_GDP`) | BEA NIPA Table 1.1.9 |
| `va` | Industry value-added deflator (`PVA`) | BEA Annual Industry Accounts |
| `go` | Industry gross-output deflator (`PGO`) | BEA Annual Industry Accounts |
| `nber` | NBER-CES manufacturing shipments deflator (`piship`) | NBER-CES Manufacturing Productivity Database |
| `ipr` | BEA R&D implicit price deflator (`P_IPR`) | BEA R&D satellite accounts |
| `inv` | Non-residential fixed investment deflator (`P_NonResidential`) | BEA NIPA |
| `nberinv` | NBER-CES investment deflator (`piinv`) | NBER-CES |

---

## Identifiers and panel structure

| Variable | Description |
|---|---|
| `key` | Unique firm identifier (panel entity key; maps to `gvkey`) |
| `gvkey` | Compustat Global Company Key |
| `year` | Fiscal year |
| `sic` | SIC-4 industry code |
| `naics` | NAICS code |
| `firmid` | Numeric firm identifier (generated from sorted `gvkey`) |
| `cusip` | CUSIP security identifier |
| `datadate` | Compustat data date |
| `consol`, `indfmt`, `datafmt`, `popsrc`, `curcd`, `fic`, `costat`, `spcsrc`, `exchg`, `smbl` | Compustat header/admin fields |

---

## Raw Compustat balance-sheet and income-statement variables

All units: millions of US dollars (Compustat convention), except `emp` (thousands of employees).

| Variable | Compustat mnemonic | Description |
|---|---|---|
| `at` | AT | Total assets |
| `capx` | CAPX | Capital expenditures |
| `ceq` | CEQ | Common/ordinary equity |
| `che` | CHE | Cash and short-term investments |
| `dd1` | DD1 | Long-term debt due in one year |
| `dlc` | DLC | Debt in current liabilities |
| `dltt` | DLTT | Long-term debt total |
| `dp` | DP | Depreciation and amortisation |
| `dpact` | DPACT | Accumulated depreciation |
| `dvc` | DVC | Common dividends |
| `dvp` | DVP | Preferred dividends |
| `emp` | EMP | Employees (thousands) |
| `ib` | IB | Income before extraordinary items |
| `invt` | INVT | Inventories |
| `lt` | LT | Liabilities total |
| `oibdp` | OIBDP | Operating income before depreciation |
| `ppegt` | PPEGT | Property, plant and equipment (gross) |
| `ppent` | PPENT | Property, plant and equipment (net) |
| `sale` | SALE | Net sales / turnover |
| `seq` | SEQ | Stockholders' equity |
| `txdb` | TXDB | Deferred taxes (balance sheet) |
| `xlr` | XLR | Staff expense total |
| `xrd` | XRD | R&D expense |
| `xstfws` | XSTFWS | Staff expense (alternative) |

---

## Stock-market variables (annual Compustat)

| Variable | Description |
|---|---|
| `prcc12` | Closing share price at fiscal year end |
| `cshoq12` | Common shares outstanding at fiscal year end |
| `navm12` | Net asset value per share (fiscal year end) |
| `div12` | Dividends per share (fiscal year end) |
| `ern12` | Earnings per share |
| `q_ret` | Annual stock return |

---

## Macro and industry-level variables

| Variable | Description | Source |
|---|---|---|
| `gdp` | Nominal GDP | BEA |
| `p_gdp` | GDP price deflator | BEA NIPA |
| `p_ipr` | R&D implicit price deflator | BEA |
| `p_nonresidential` | Non-residential fixed investment deflator | BEA NIPA |
| `pva` | Industry value-added deflator | BEA Annual Industry Accounts |
| `pgo` | Industry gross-output deflator | BEA Annual Industry Accounts |
| `piship` | NBER-CES shipments deflator | NBER-CES |
| `piinv` | NBER-CES investment deflator | NBER-CES |
| `averagewage` | BEA/SSA average annual wage | SSA Average Wage Index |
| `awi` | Social Security average wage index | SSA |
| `gov_b` | Yield on 3-month government bonds | Federal Reserve |
| `aaa` | Yield on AAA-rated corporate bonds | Federal Reserve / Moody's |
| `baa` | Yield on BAA-rated corporate bonds | Federal Reserve / Moody's |
| `aaa_g` | Spread: AAA minus government bond | Derived |
| `baa_g` | Spread: BAA minus government bond | Derived |
| `baa_aaa` | Spread: BAA minus AAA | Derived |
| `vadd` | NBER-CES industry value added | NBER-CES |
| `vship` | NBER-CES industry shipments | NBER-CES |
| `exports` | Industry exports | NBER-CES |
| `sale_i` | Compustat industry-level aggregate sales (SIC-based) | Derived from Compustat |
| `r_sale` | Real sales (NBER-CES shipments deflated) | Derived |

---

## Constructed firm-level variables

| Variable | Description |
|---|---|
| `va` | Value added: `oibdp + xlr` |
| `va_a` | Value added (alternative): `oibdp + wagebill` |
| `va_e` | Value added (estimated payroll): `oibdp + payroll` |
| `va_o` | Value added (gross output approach): `sale − materials` |
| `cf` | Cash flow: `ib + dp` |
| `cfmxrd` | Cash flow minus R&D: `cf − xrd` |
| `tex` | Total expenses: `sale − oibdp` |
| `materials` | Material costs: `tex − wagebill` |
| `wagebill` | Approximate wage bill: `emp × averagewage / 1000` |
| `averagesalary` | Average salary at firm level: `xlr / emp × 1000` |
| `meansalary` | Mean salary across firms within year-SIC cell |
| `payroll` | Estimated payroll: `emp × meansalary / 1000` |
| `mkv` | Market capitalisation: `prcc12 × cshoq12` |
| `Q` | Tobin's Q: `(at + mkv − ceq − txdb) / at` |
| `cfratio` | Cash-flow to lagged physical capital: `(ib + dp) / L.ppent` |
| `debt` | Leverage: `(dltt + dlc) / (seq + dltt + dlc)` |
| `div` | Dividends to lagged physical capital: `(dvp + dvc) / L.ppent` |
| `cash` | Cash to lagged physical capital: `che / L.ppent` |
| `lnta` | Log real total assets (GDP-deflated) |
| `ln_va_ta` | Log real total assets (VA-deflated) |
| `ln_go_ta` | Log real total assets (GO-deflated) |
| `ln_nber_ta` | Log real total assets (NBER-deflated) |

---

## Financial constraint indices

### Kaplan-Zingales (KZ) index

`KZ = −1.001909 × cfratio + 0.2826389 × Q + 3.139193 × debt − 39.3678 × div − 1.314759 × cash`

(Lamont, Polk, and Saá-Requejo 2001)

| Variable | Description |
|---|---|
| `KZ` | KZ index (higher = more financially constrained) |
| `KZ_1` | Indicator: firm in KZ quartile 1 (least constrained) |
| `KZ_2` | Indicator: firm in KZ quartile 2 |
| `KZ_3` | Indicator: firm in KZ quartile 3 |
| `KZ_4` | Indicator: firm in KZ quartile 4 (most constrained) |

### Whited-Wu (WW) index

`WW = −0.091 × cfratio − 0.062 × divpos + 0.021 × debt − 0.044 × lnta + 0.102 × d_gdp_sale_i − 0.035 × d_gdp_sale`

(Whited and Wu 2006)

| Variable | Description |
|---|---|
| `WW` | WW index |
| `WW_1` | Indicator: firm in WW quartile 1 (least constrained) |
| `WW_2` | Indicator: firm in WW quartile 2 |
| `WW_3` | Indicator: firm in WW quartile 3 |
| `WW_4` | Indicator: firm in WW quartile 4 (most constrained) |
| `divpos` | Indicator: firm paid positive dividends (`dvc > 0` or `dvp > 0`) |

### Bond-spread indicators

Spread indicators `ag`, `bg`, `ba` capture whether the AAA-G, BAA-G, or BAA-AAA spread was above its prior-period value. Used to split sample into high/low financial stress periods.

| Variable | Description |
|---|---|
| `ag` | AAA-G spread level |
| `bg` | BAA-G spread level |
| `ba` | BAA-AAA spread level |
| `d_h_ag`, `d_l_ag` | High/low AAA-G indicator (1 if spread rose, 0 otherwise) |
| `d_h_bg`, `d_l_bg` | High/low BAA-G indicator |
| `d_h_ba`, `d_l_ba` | High/low BAA-AAA indicator |

---

## Deflated real variables

Follows pattern `r_{deflator}_{var}` for each Compustat variable crossed with each deflator.
The full grid is:

- **Compustat vars**: at, capx, ceq, cf, cfmxrd, che, dd1, dlc, dltt, dp, dvc, dvp, ib, lt, oibdp, ppegt, ppent, sale, sale_i, seq, tex, txdb, va, va_a, va_e, xlr, xrd, materials
- **Deflators**: gdp, va, go, nber (and inv/nberinv for capital/investment)
- **Special**: `r_ipr_xrd` (R&D deflated by BEA R&D price index), `r_inv_capx`, `r_inv_ppent`, `r_inv_ppegt`, `r_nberinv_capx`, `r_nberinv_ppent`, `r_nberinv_ppegt`

---

## Growth rates

Log-differences of real variables. Pattern: `d_{deflator}_{var}`.

Key variables used in regressions:

| Variable | Description |
|---|---|
| `d_gdp_xrd` | R&D growth (GDP deflator) |
| `d_ipr_xrd` | R&D growth (IPR deflator; primary spec for Table 9) |
| `d_gdp_sale` | Sales growth (GDP deflator; primary output measure) |
| `d_gdp_va` | Value-added growth (GDP deflator) |
| `d_gdp_sale_i` | Industry sales growth (GDP deflator; used in WW index) |
| `d_GDP` | Aggregate real GDP growth |
| `d_vadd` | Industry value-added growth (NBER-CES) |
| `d_vship` | Industry shipments growth (NBER-CES) |
| `d_va_ind` | Industry value-added growth (BEA; used as IV) |
| `d_exports` | Industry export growth |
| `d_instrument` | Instrument growth variable |
| `d_q` | Tobin's Q growth |

---

## Asymmetric growth variables

Decompose growth into positive and negative episodes (AllData.do Section 5).

Pattern: `d_h_{base}` = growth × 1(growth > 0); `d_l_{base}` = growth × 1(growth ≤ 0).

Applied to: GDP, sale, va, va_a, va_i, go, vadd, vship.

---

## Firm-demeaned variables

Subtract firm-specific mean growth rate across all years in the panel.

Pattern: `dev_{base}`, with positive/negative splits `dev_h_{base}`, `dev_l_{base}`.

Applied to: xrd, sale, GDP, va, va_a, va_i, go, vadd, vship.

| Variable | Description |
|---|---|
| `mean_d_{base}` | Firm-level mean of `d_{base}` (used to compute `dev_{base}`) |
| `dev_{base}` | `d_{base} − mean_d_{base}` |

---

## R&D ratios

| Variable | Description |
|---|---|
| `z_xrd_sale` | R&D / sales (primary ratio; truncated at 2 in regressions) |
| `z_xrd_va` | R&D / value added |
| `z_xrd_va_a` | R&D / value added (alternative) |
| `z_xrd_capx` | R&D / (R&D + capital expenditure) |

---

## Panel structure variables

| Variable | Description |
|---|---|
| `t` | Observation index within the full dataset |
| `count` | Number of years firm appears in the panel (used to compute `survivor`) |
| `survivor` | Indicator: firm observed in all 61 years (1951–2011) |
| `has95` | Indicator: firm observed in 2011 (the final year) |
| `has_gaps` | Indicator: firm has gaps in its time series |
| `exit` | Indicator: firm exits during the sample period (not a survivor, not in 2011, no gaps) |

---

## TFP variables (stage 4)

Estimated in `13_transform_stage4.py`. Not in stage3; stored in `processed_alldata_stage4`.

| Variable | Description |
|---|---|
| `tfp4` | TFP residual from OLS production function (4-factor) |
| `tfp5` | TFP residual from OLS production function (5-factor) |
| `dtfp4`, `dtfp5` | Log-differences of TFP |
| `z1`, `z2` | GMM R&D return scalars (B1, B2) |
| `average_z1`, `average_z2` | Firm-level averages of z1, z2 |

---

## Lagged variables

Scripts 30–36 construct L1/L2 lags internally from the stage3 panel where needed
(via `xtset key year` equivalent in pandas with `groupby(key).shift()`).
Pre-computed lag columns in stage3 follow the pattern `l_{col}` and `l2_{col}`.

---

*Generated from `12_transform_stage3.py` output. Last updated: 2026-04.*
