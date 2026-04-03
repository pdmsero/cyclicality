# NSF Industrial R&D Survey — data quality report

**Database:** `data/cyclicality.db`
**Date:** 2026-03-30
**Scripts:** `code/python/ingest_nsf_archival.py`, `code/python/build_crosswalk.py`, `code/python/fix_data_quality.py`
**Status:** All seven data quality fixes applied. See §8 for post-fix filter recommendations.

---

## Overview

The harmonised database contains 393,137 observations across four archival tables drawn from 1,246 parsed Excel sheets. The core analytical table, `nsf_observations`, holds 115,304 industry × year rows covering 1953–2014. Seven structural issues were identified during audit and subsequently resolved by `fix_data_quality.py`. The post-fix database is analysis-ready subject to the standard filter set in §8.

---

## 1. Coverage and completeness

**Year coverage** is continuous from 1956 onwards for the three principal series (TOTAL_RD, CO_RD, FED_RD). The only structural gap is 1954–1955 in `nsf_observations`: NSF did not publish industry-level breakdowns for those years, though `nsf_us_aggregates` carries national totals back to 1953. TOTAL_RD is present in 53 distinct years between 1953 and 2007 with a single gap (1954–1956 resolved to 1953 and then 1956). Post-2007 coverage thins sharply; `SALES_EMPLOYMENT` (2005–2008) is the only series with systematic industry-level data after 2007.

**Series depth** varies substantially. TOTAL_RD has 28,327 observations across 53 years; BASIC_APPLIED_DEV has 740 (1966–1984 only); RD_CONTRACTED has 334 (1966–1977 only). Analysts constructing long balanced panels should expect significant attrition in the pre-1960 and post-2000 periods for all series except TOTAL_RD, CO_RD, FED_RD, and NET_SALES.

**Crosswalk linkage** covers all 115,304 observations in `nsf_observations`. Of these, 80.6% link to a named industry (SIC or NAICS), 11.0% to aggregate rows (total, manufacturing, non-manufacturing), 7.8% to size bracket rows, and 0.6% to header fragments. The 7.8% size bracket share reflects NSF's practice of printing size sub-categories as separate rows in the same industry × year table; these rows carry no SIC code and should be excluded from industry-level regressions.

---

## 2. Suppression and parse failures

**D-flag suppression** (withheld to avoid disclosing individual company data) is the dominant form of missingness. In `nsf_observations` it accounts for 15.7% of all rows (18,091 cells) and 15.6% in `nsf_size_breakdowns` (40,734 cells). Suppression is not random: it concentrates in narrow industries, small-industry sub-series, and sub-national breakdowns. TOTAL_RD carries 8,816 D-flagged cells (31.1% of its total), FED_RD carries 3,520 (24.3%).

**UNPARSED cells** account for 3.7% of `nsf_observations` (4,280 rows). These arise in two distinct patterns:

- *Continuation cells parsed as data.* In ENERGY_RD_GENERAL (1,102 UNPARSED) and POLLUTION_RD_GENERAL (771 UNPARSED), cells contain narrative text or footnote numbers that the parser could not classify as either a numeric value or a recognised suppression code. These originate in publication-era tables where NSF embedded continuation caveats in data cells.

- *Sentinel codes encoded as numbers.* The "radio and tv receiving equipment" (SIC 365) industry and related industries carry small negative integers (-5, -6, -7) for TOTAL_RD, FED_RD, and NET_SALES in the 1950s–70s. These are NSF-internal sentinel codes, not real R&D figures.

**[Fixed]** The `fix_data_quality.py` script flagged all 1,376 negative rows in `nsf_observations` (and 2,030 in `nsf_size_breakdowns`) as `suppression_flag = 'SENTINEL'` with `value = NULL`. The largest populations were ENERGY_RD_GENERAL (393), FED_RD (248), POLLUTION_RD_GENERAL (234), and NET_SALES (183). Zero negative values remain.

**Recommended filter for clean analysis:**

```sql
WHERE value IS NOT NULL
  AND suppression_flag IS NULL
  AND value >= 0
```

This removes D/S/T/NA suppressed cells, UNPARSED cells, and sentinel negatives in a single step. After fixing and filtering, `nsf_observations` retains 85,542 numeric rows (74.2% of total).

---

## 3. Value plausibility

**Negative values in `nsf_observations`** are fully resolved. Before fixing, 1,376 rows carried negative values, concentrated across ENERGY_RD_GENERAL, FED_RD, POLLUTION_RD_GENERAL, NET_SALES, CO_RD_ALT, and a CO_RD 2001 vintage with signed revision adjustments. All are now `SENTINEL`-flagged with value nulled.

**Extremely large values in `nsf_size_breakdowns`** represented a parsing defect where SIC code strings (e.g., "801,806,807") were ingested into the `value` column. The col_1/col_2/... label was a reliable marker. **[Fixed]** 79 contaminated rows deleted. An additional 43,847 col_% rows with valid values (≤ 1,000,000) were retained — the col_label is uninformative but the values are real.

**Negative values in `nsf_size_breakdowns`** are fully resolved. Before fixing, 2,030 rows carried negatives (1,895 small sentinel codes, 135 large geographic adjustment values). All are now `SENTINEL`-flagged.

---

## 4. Multi-unit contamination

Several series carry both dollar and percent observations in `nsf_source_files`. **[Fixed]** 60 TOTAL_RD and CO_RD sheets that carried percent-unit observations have been reclassified from their original series codes to `RD_PCT_SALES` (62 total after accounting for pre-existing RD_PCT_SALES sheets). This affects 9,690 rows in `nsf_observations` and 8,695 in `nsf_size_breakdowns`.

FED_RD percent sheets (6 sheets) are retained as FED_RD: their table titles confirm they represent "Federal funds as a percentage of net sales", a legitimately distinct NSF-published series rather than a misclassification.

Analysts must still filter on `unit_norm` before pooling dollar series:

```sql
JOIN nsf_source_files sf ON sf.id = o.source_file_id
WHERE sf.unit_norm = 'millions_usd'
```

**FTE_SCI unit misclassification [Fixed]:** Nine sheets had `unit_norm = 'millions_usd'` due to a nearby dollar-unit string being picked up during parsing. Their actual data are FTE counts (range: 1–787 thousand persons). Corrected to `thousands_persons`. The 227 sheets with `unit_norm = NULL` lack any parseable unit string and cluster in CO_COUNT, TOTAL_RD, CO_RD, and SIZE_BREAKDOWN. These should be verified against source files before inclusion.

---

## 5. Multi-vintage revisions

NSF revised prior-year estimates in subsequent publications. The revision structure is substantial: the average CO_COUNT (industry, year) pair appears in 7.5 distinct vintages; CO_RD and TOTAL_RD average 5.9 and 5.5 vintages respectively. This is expected behaviour and the database preserves all vintages.

The apparently enormous revision ranges for SALES_EMPLOYMENT and TOTAL_RD (reported max-minus-min of $6 trillion) are an artefact of mixing aggregate rows across vintages that report in different units. Within a given vintage, all rows for a given year use the same unit. Across vintages, one publication may report net sales in millions and another in thousands, producing a spurious 1,000x inflation. Vintage comparisons require filtering to `unit_norm = 'millions_usd'` before computing revision magnitudes.

Genuine revision magnitudes for TOTAL_RD at the industry level, after filtering to millions_usd and a single well-specified industry, are typically in the range 0–15% of the initial estimate, consistent with NSF's stated practice of incorporating late respondents in subsequent publications.

---

## 6. SIC/NAICS code quality

Of 115,304 rows in `nsf_observations`, 17,401 (15.1%) now have an empty `sic_code`, combining rows that were already empty and rows where **[Fixed]** dot-leader and placeholder values (`.`, `...(dots)...`, `na`, `--`, `SIC code`, 42 distinct patterns) were normalised to empty string across 9,662 rows.

These empty-code rows are predominantly aggregate rows (all industries, manufacturing, non-manufacturing totals) where NSF did not print a code. For analysis requiring a canonical code, use `nsf_industry_crosswalk.primary_code` joined on `industry_name_norm`. This gives a clean SIC or NAICS code for 80.6% of observations (the `row_type = 'industry'` stratum).

---

## 7. Geographic breakdown null years

**Partially resolved.** Before fixing, 769 rows in `nsf_size_breakdowns` had `year = NULL`. These were in two source sheets:

- *Geographic distribution table* (sf_id=1096, 670 rows): the year was stored in column headers rather than the table title. **[Fixed]** Year recovered via `CAST(col_label AS INTEGER)` for all 670 rows.

- *Table 13* (sf_id=109, 99 rows): col_labels are `col_2`, `col_3`, `col_4`, and one text label ("Company funds as percent of total R&D funds"). No year is recoverable from these labels or the filename alone. These 99 rows remain `year = NULL` and require manual inspection of the source workbook (`nsf_68-02013.xls`, a 1968 publication). The survey year is likely 1966 or 1967.

---

## 8. Post-fix filter recommendations

The following filters produce a clean analytical sample from the fixed database.

| Issue | Rows affected | Recommended filter |
|---|---|---|
| Suppressed cells (D/S/T/NA/SENTINEL) | 19,467 in obs; 42,764 in size | `WHERE value IS NOT NULL AND suppression_flag IS NULL` |
| UNPARSED cells | 4,280 in obs | caught by `suppression_flag IS NULL` |
| Multi-unit mixing (dollar series) | TOTAL_RD, CO_RD, FTE_SCI | `JOIN nsf_source_files ON ... WHERE unit_norm = 'millions_usd'` |
| Size bracket rows in obs | 9,016 rows | `JOIN nsf_industry_crosswalk ON ... WHERE row_type = 'industry'` |
| Null year in size breakdowns | 99 rows | `WHERE year IS NOT NULL` |
| Multi-vintage duplicates | up to 7.5x per cell | apply vintage filter (latest publication_year) |
| Percent-unit R&D series | 9,690 obs reclassified | use `series_code = 'RD_PCT_SALES'` to isolate; exclude from dollar analyses |

A standard clean filter for `nsf_observations` dollar analyses:

```sql
SELECT o.*
FROM nsf_observations o
JOIN nsf_source_files sf ON sf.id = o.source_file_id
JOIN nsf_industry_crosswalk xw ON xw.industry_name_norm = o.industry_name_norm
WHERE o.value IS NOT NULL
  AND o.suppression_flag IS NULL
  AND sf.unit_norm = 'millions_usd'
  AND xw.row_type = 'industry'
```

This yields a fully clean, industry-coded, dollar-denominated sample. Vintage deduplication (retaining the latest `publication_year` per industry × year cell) should be applied on top depending on the analysis.
