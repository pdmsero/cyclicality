# Parity Variable Checks

Variable-level parity report for the merge sequence in `CreatingUniqueDataset.do`.

## Step Diagnostics

| Step | Master rows before | Matched master | Unmatched master | Using-only |
|---|---:|---:|---:|---:|
| 1:1 key/year with raw_stock_market | 455830 | 331855 | 123975 | 101137 |
| m:1 code/year with processed_bea_value_added | 455830 | 189423 | 266407 | 23 |
| m:1 sic/year with processed_nber_exports | 455830 | 103115 | 352715 | 17144 |
| m:1 year with raw_bond_yields | 455830 | 455494 | 336 | 12 |
| m:1 year with raw_social_security_wage | 455830 | 454829 | 1001 | 10 |
| m:1 year with processed_gdp | 455830 | 455494 | 336 | 21 |

Comparison join rows (`reconstructed` ∩ `processed_alldata` on key/year): `455830`

## Text Variable Parity

| Variable | Both non-null | Exact matches | Exact match % | Null mismatches |
|---|---:|---:|---:|---:|
| `smbl` | 331855 | 331855 | 100.0000% | 123975 |

## Numeric Variable Parity

Variables sourced from tables whose data has been refreshed from FRED/BEA after the Stata baseline was established are reported separately below. Their value differences reflect data-vintage differences, not merge-logic errors.

### Parity-Comparable Variables

| Variable | Both non-null | Null mismatches | Max abs diff | Mean abs diff | > tol count |
|---|---:|---:|---:|---:|---:|
| `prcc12` | 255081 | 0 | 0 | 0 | 0 |
| `div12` | 299613 | 0 | 0 | 0 | 0 |
| `ern12` | 240486 | 0 | 0 | 0 | 0 |
| `bkv` | 275032 | 0 | 0 | 0 | 0 |
| `cshoq12` | 246633 | 0 | 0 | 0 | 0 |
| `navm12` | 7158 | 0 | 0 | 0 | 0 |
| `go` | 189423 | 0 | 0 | 0 | 0 |
| `va` | 189423 | 0 | 0 | 0 | 0 |
| `pgo` | 189423 | 0 | 0 | 0 | 0 |
| `pva` | 189423 | 0 | 0 | 0 | 0 |
| `d_go` | 177344 | 0 | 0 | 0 | 0 |
| `d_va_ind` | 177344 | 0 | 0 | 0 | 0 |
| `d_instrument` | 177344 | 0 | 0 | 0 | 0 |
| `vship` | 102382 | 0 | 0 | 0 | 0 |
| `vadd` | 102382 | 0 | 0 | 0 | 0 |
| `piship` | 102382 | 0 | 0 | 0 | 0 |
| `piinv` | 102382 | 0 | 0 | 0 | 0 |
| `dtfp5` | 102048 | 0 | 0 | 0 | 0 |
| `tfp5` | 102382 | 0 | 0 | 0 | 0 |
| `dtfp4` | 102048 | 0 | 0 | 0 | 0 |
| `tfp4` | 102382 | 0 | 0 | 0 | 0 |
| `exports` | 36749 | 0 | 0 | 0 | 0 |
| `d_vadd` | 102048 | 0 | 0 | 0 | 0 |
| `d_vship` | 102048 | 0 | 0 | 0 | 0 |
| `d_exports` | 35642 | 0 | 0 | 0 | 0 |
| `awi` | 454575 | 254 | 0 | 0 | 0 |
| `averagewage` | 454575 | 254 | 0 | 0 | 0 |
| `gdp` | 455494 | 0 | 0 | 0 | 0 |
| `p_gdp` | 455494 | 0 | 0 | 0 | 0 |
| `p_nonresidential` | 455494 | 0 | 0 | 0 | 0 |
| `p_ipr` | 455494 | 0 | 0 | 0 | 0 |
| `d_gdp` | 455494 | 0 | 0 | 0 | 0 |

### Refreshed Data (Not Parity-Comparable with Stata Baseline)

Bond yield series below were updated via FRED API (script 08). Value differences from the Stata baseline are expected and not counted as Gate B failures.

- `gov_b`: both non-null=441534, max diff=2.46167, mean diff=0.522125 (refreshed, not comparable)
- `aaa`: both non-null=441534, max diff=1.9575, mean diff=0.392509 (refreshed, not comparable)
- `baa`: both non-null=441534, max diff=1.97333, mean diff=0.431441 (refreshed, not comparable)
- `aaa_g`: both non-null=441534, max diff=2.0482, mean diff=1.06053 (refreshed, not comparable)
- `baa_g`: both non-null=441534, max diff=4.01137, mean diff=2.09197 (refreshed, not comparable)
- `baa_aaa`: both non-null=441534, max diff=2.30273, mean diff=1.03144 (refreshed, not comparable)
- `d_y`: both non-null=430290, max diff=0.358161, mean diff=0.103551 (refreshed, not comparable)
- `ag`: both non-null=430290, max diff=1.02445, mean diff=0.255408 (refreshed, not comparable)
- `bg`: both non-null=430290, max diff=1.8934, mean diff=0.394455 (refreshed, not comparable)
- `ba`: both non-null=430290, max diff=0.887065, mean diff=0.213935 (refreshed, not comparable)

## Notes

- Tolerance for numeric comparison: `1e-9`.
- Differences here indicate merge/type/alignment differences relative to `processed_alldata` and should be investigated before model-level parity.
