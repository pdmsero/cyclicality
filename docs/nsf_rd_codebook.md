# NSF Industrial R&D Survey — Archive Codebook

This document describes the seven archival tables in `data/cyclicality.db` that hold data
from the NSF Survey of Industrial Research and Development (1953–2009).  All claims are
verified against the database as of the ingestion run recorded in `nsf_source_files.ingested_at`.

Ingestion script: `code/python/ingest_nsf_archival.py`

---

## 1. Survey background

The NSF Survey of Industrial Research and Development was conducted annually from 1953 to
2009, when it was replaced by the Business R&D and Innovation Survey (BRDIS).  It collected
company-funded and federally funded R&D expenditures, employment of R&D scientists and
engineers, net sales, and related variables from R&D-performing firms in manufacturing and
selected non-manufacturing industries.

The survey was published as a series of Excel workbooks.  Each workbook typically contains
multiple sheets, each presenting one variable (or a small set of related variables) broken
down by industry and, in most cases, multiple survey years.  Industry classification
follows SIC codes through 1996 and NAICS codes from 1997 onward.

---

## 2. Source files

**Location:** `data/industry/nsf_raw/` (27 index subdirectories) plus
`archive_historical` (1991–1993 data reconstructed from `archive_historical_nsf_raw`)

**Total files indexed:** 1,061 from `data/industry/nsf_raw/` (table `raw_nsf_file_index`),
plus 137 additional files from `archive/historical/` not covered by the index.

**Files with at least one parsed sheet:** 885 distinct source files contributing 1,246 sheets
to `nsf_source_files`.  Of the 1,061 indexed files, 319 carry `parse_status = 'ok'` or
`'ok_v2'` (industry×year format confirmed); the remainder carry `'no_industry_format'` but
were parsed as size-breakdown, aggregate, or category time-series sheets.

**Files not yet ingested:** 0.  All previously unprocessed `no_industry_format` files are
now fully ingested across the four parser types.

**Files unreadable:** 3 (HTML files served with `.xls` extension;
`parse_status = 'error:open:...'`).

---

## 3. Database tables

### 3.1 `nsf_source_files`

One row per (source file, sheet).  Provenance anchor for all three observation tables.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Surrogate key |
| `source_file` | TEXT | Absolute path to source `.xls` file |
| `index_folder` | TEXT | Subdirectory name from `raw_nsf_file_index`, or `archive_historical` |
| `sheet_name` | TEXT | Excel sheet name as read by xlrd |
| `table_title` | TEXT | Concatenation of non-empty cells in the first three rows of the sheet; up to 500 characters |
| `series_code` | TEXT | Assigned series code (see section 5) |
| `unit` | TEXT | Unit string extracted from the first eight rows; e.g. `Dollars in millions`, `In thousands`, `Percent` |
| `years_covered` | TEXT | Range string `YYYY–YYYY` (or single year) of observations in this sheet and vintage |
| `n_observations` | INTEGER | Row count inserted into the relevant observation table |
| `ingested_at` | TEXT | ISO-8601 timestamp of ingestion run |

**Unique constraint:** `(source_file, sheet_name)`.  Re-running the ingestion script
upserts this table; observation tables are deleted and reinserted for each source.

**Note on `unit`:** Unit strings are extracted by regex from raw cell text and are not
normalised.  The same underlying unit appears as `Dollars in millions`, `In millions of
dollars`, `Millions of dollars`, and `in millions` across different publication years.
Callers must apply their own normalisation before comparing values across vintages.

---

### 3.2 `nsf_observations`

Industry × year observations from tables where years appear as column headers.  This is
the primary analytical table.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Surrogate key |
| `source_file_id` | INTEGER FK | References `nsf_source_files.id` |
| `series_code` | TEXT | Series code (see section 5) |
| `industry_name` | TEXT | Raw industry label as it appears in the source file; up to 500 characters |
| `industry_name_norm` | TEXT | Lowercased, whitespace-collapsed, footnote-stripped form of `industry_name` |
| `sic_code` | TEXT | SIC or NAICS code as published by NSF; not standardised (see section 6) |
| `year` | INTEGER | Survey year |
| `value` | REAL | Numeric value, or NULL if suppressed |
| `suppression_flag` | TEXT | NSF suppression code if value is withheld (see section 7) |
| `ingested_at` | TEXT | ISO-8601 timestamp |

**Row count:** 115,304

**Year coverage:** 1953–2014 (57 distinct years).  Note that industry-level R&D series
(TOTAL_RD, CO_RD, FED_RD) are absent for 1954 and 1955 — NSF did not publish detailed
industry breakdowns for those years.  Coverage also thins after 2007 as the survey wound
down prior to its replacement by BRDIS in 2010.

**Multi-vintage design:** The same (industry, SIC code, year) triple may appear in
multiple rows from different source files.  NSF routinely revised prior-year estimates in
subsequent publications.  No deduplication is applied; `source_file` is the vintage key.
To obtain the latest vintage for a given observation, filter to the source file with the
most recent `ingested_at` or highest publication year implied by the filename.

**Indexes:** `(series_code, sic_code, year)` and `(year)`.

---

### 3.3 `nsf_us_aggregates`

US national totals from time-series tables where survey years appear as row labels and
fund sources or R&D types appear as column headers.  These tables have no industry
dimension.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Surrogate key |
| `source_file_id` | INTEGER FK | References `nsf_source_files.id` |
| `series_code` | TEXT | Series code |
| `year` | INTEGER | Survey year |
| `col_label` | TEXT | Column label built from multi-level Excel headers (see note below) |
| `value` | REAL | Numeric value, or NULL if suppressed |
| `suppression_flag` | TEXT | NSF suppression code |
| `ingested_at` | TEXT | ISO-8601 timestamp |

**Row count:** 16,309

**Year coverage:** 1953–2007 (55 distinct years)

**`col_label` values for `US_TOTAL_RD` series:**

- `All sources — Current $`
- `All sources — Constant $`
- `Federal — Current $`
- `Federal — Constant $`
- `Company and other — Current $`
- `Company and other — Constant $`

The constant-dollar series uses the price base specified in the source publication (varies
across vintages; typically constant 2000 dollars in the 2000s publications).

**Note on `col_label`:** Labels are constructed by forward-filling merged Excel cells
across header rows and joining levels with ` — `.  In some publications the column
hierarchy has three levels (e.g. `All sources — Basic research — Current $`).  Labels are
deterministic given the source file layout but are not normalised across publications.

**Index:** `(series_code, year)`.

---

### 3.4 `nsf_size_breakdowns`

Industry × company-size cross-sections from tables where company-size brackets (or R&D
type) appear as column headers and each table covers a single survey year.  The survey
year is extracted from the table title rather than from column headers.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Surrogate key |
| `source_file_id` | INTEGER FK | References `nsf_source_files.id` |
| `series_code` | TEXT | Series code |
| `year` | INTEGER | Survey year extracted from table title (NULL if not parseable) |
| `row_label` | TEXT | Industry label, or `{industry} — {size sub-category}` for nested rows |
| `row_label_norm` | TEXT | Normalised form of `row_label` |
| `sic_code` | TEXT | SIC or NAICS code from the industry row; empty for size sub-rows |
| `col_label` | TEXT | Column header, constructed from multi-level Excel headers (see note) |
| `value` | REAL | Numeric value, or NULL if suppressed |
| `suppression_flag` | TEXT | NSF suppression code |
| `ingested_at` | TEXT | ISO-8601 timestamp |

**Row count:** 261,612

**Year coverage:** 1953–2008 (55 distinct years); no NULL years.

**`col_label` note:** These labels are concatenations of multi-level Excel column headers
joined with ` — `.  Size brackets frequently span two rows in the source (e.g. `Less
than` / `500` or `1,000 to` / `4,999`), producing labels such as
`Companies with total employment of-- — Less than — 1000`.  Multi-year tables
(where the same sheet covers two or three survey years with size sub-columns under each
year) produce labels such as `1988 — Less than 500`.  These labels are archivally correct
representations of the source layout but are not a clean categorical variable.  Analysts
constructing size-of-company panels should parse `col_label` with string operations or
build a normalisation map.

**`row_label` for sub-rows:** When a table nests size categories under each industry, the
sub-row label is `{parent industry name} — {size category label}` and `sic_code` is
empty.  The parent industry row (with a SIC/NAICS code) appears as a separate record with
the same `sic_code`.

**Index:** `(series_code, year)`.

---

### 3.5 `nsf_category_timeseries`

Observations from tables where categories (energy source, research field, geographic area,
occupational group) appear as row labels and survey years appear as column headers.  These
tables have no industry dimension and are not time-series in the aggregate-sheet sense;
they record how a US-level total is distributed across a set of named categories for each
available year.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Surrogate key |
| `source_file_id` | INTEGER FK | References `nsf_source_files.id` |
| `series_code` | TEXT | Series code |
| `row_label` | TEXT | Category label as it appears in the source file; up to 500 characters |
| `row_label_norm` | TEXT | Normalised form of `row_label` |
| `year` | INTEGER | Survey year (extracted from column headers) |
| `value` | REAL | Numeric value, or NULL if suppressed |
| `suppression_flag` | TEXT | NSF suppression code |
| `ingested_at` | TEXT | ISO-8601 timestamp |

**Row count:** 912

**Year coverage:** 1957–1996 (35 distinct years)

**Series breakdown:**

| Series code | Rows | Content |
|---|---|---|
| `BASIC_RD_BY_FIELD` | 741 | Basic research funds by field of science (1957–1985) |
| `FFRDC` | 97 | FFRDC R&D by industry sponsor (1976–1986) |
| `FTE_SCI` | 39 | FTE scientists and engineers by occupational group (1989–1991) |
| `ENERGY_RD_GENERAL` | 30 | Energy R&D by primary source (1977–1980) |
| `OTHER` | 5 | Unclassified (junk sheet; excluded from analysis) |

**Index:** `(series_code, year)`.

---

### 3.6 `nsf_industry_names`

Lookup table of distinct normalised industry name strings.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Surrogate key |
| `industry_name_norm` | TEXT UNIQUE | Normalised name (lowercase, footnote-stripped) |
| `example_raw_name` | TEXT | One raw name that maps to this normalised form |
| `n_occurrences` | INTEGER | Count across `nsf_observations` |

**Row count:** 421

**Purpose:** Canonical crosswalk anchor.  Each `industry_name_norm` is mapped to a
canonical SIC or NAICS code in `nsf_industry_crosswalk` (see section 3.7).
`industry_name_norm` is not a stable identifier across publication years; use
`primary_code` from the crosswalk for linking to external datasets.

---

### 3.7 `nsf_industry_crosswalk`

Maps every `industry_name_norm` to a canonical SIC or NAICS code.  Built by
`code/python/build_crosswalk.py`; re-run with `--rebuild` to regenerate.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Surrogate key |
| `industry_name_norm` | TEXT UNIQUE FK | References `nsf_industry_names.industry_name_norm` |
| `row_type` | TEXT | `industry`, `aggregate`, `size_bracket`, or `other` |
| `code_system` | TEXT | `SIC` or `NAICS`; NULL for aggregates and non-industries |
| `primary_code` | TEXT | Canonical code for the closest single-industry match |
| `code_range` | TEXT | Raw NSF-published code string (cleaned) |
| `sic_codes_covered` | TEXT | Comma-separated 2–4-digit SIC codes for multi-code groups |
| `naics_codes_covered` | TEXT | NAICS codes or ranges covered by this NSF grouping |
| `canonical_name` | TEXT | Official description from `sic_codes` or `naics_codes` |
| `map_method` | TEXT | `manual`, `parsed`, `aggregate`, or `non_industry` |
| `notes` | TEXT | NSF-specific caveats (e.g. combined groupings) |

**Row count:** 421 (one per `industry_name_norm`)

**Row type breakdown:**

| row_type | Code system | Count | Interpretation |
|---|---|---|---|
| `industry` | SIC | 247 | Pre-1997 SIC-era industry names |
| `industry` | NAICS | 112 | Post-1996 NAICS-era industry names |
| `aggregate` | — | 22 | Aggregates (total, manufacturing, non-manufacturing) |
| `size_bracket` | — | 30 | Employment-size bracket labels, not industries |
| `other` | — | 10 | Header fragments and pollution categories |

**Crosswalk limitations:**

NSF regularly combined SIC industries into non-standard groupings (e.g. "Petroleum refining and extraction" spans SIC 13 + 29; "Aircraft and missiles" spans SIC 372 + 376).  `sic_codes_covered` records the NSF grouping; `primary_code` gives the closest single code.  Analysts linking to 2-digit SIC data should use `primary_code`; those needing exact coverage should parse `sic_codes_covered`.

The same `industry_name_norm` can represent different underlying industries across classification eras.  Names like "primary metals" appear in both SIC-era (SIC 33) and NAICS-era publications (NAICS 331); the crosswalk maps to the dominant usage (SIC 33 in this case).  Where names are unambiguous NAICS (e.g. "computer and electronic products" → NAICS 334), they are mapped to NAICS.

---

### 3.8 `sic_codes`

Canonical SIC 1987 2-digit major group codes.  Source: OSHA SIC Manual.

| Column | Type | Description |
|---|---|---|
| `sic_code` | INTEGER PK | 2-digit SIC code |
| `description` | TEXT | Official description |

**Row count:** 83

---

### 3.9 `naics_codes`

Canonical NAICS 2002 codes at all hierarchical levels (2–6 digits).  Source: US Census Bureau Statistics of U.S. Businesses file.

| Column | Type | Description |
|---|---|---|
| `naics_code` | TEXT PK | NAICS code (2–6 digits) |
| `description` | TEXT | Official description |
| `level` | INTEGER | Number of digits: 2 (sector), 3 (subsector), 4 (industry group), 5 (NAICS industry), 6 (national industry) |

**Row count:** 2,123

---

## 4. Series catalogue

The table `nsf_series_catalogue` lists all assigned series codes.  The codes below cover
observations in all three observation tables.

| Series code | Description | Primary table | Typical unit |
|---|---|---|---|
| `BASIC_APPLIED_DEV` | Funds for basic research, applied research, and development | obs / size / agg | Millions of dollars |
| `BASIC_RD_BY_FIELD` | Funds for basic research by field of science | size / cat | Millions of dollars |
| `CO_COUNT` | Number of R&D-performing companies | obs / size | Count |
| `CO_RD` | Company and other (except Federal) funds for industrial R&D | obs / size | Millions of dollars |
| `CO_RD_ALT` | Company funds for R&D (older survey wording, pre-1970s) | obs / size | Millions of dollars |
| `COST_PER_SCI` | Cost per R&D scientist or engineer | obs / size | Thousands of dollars |
| `EMPLOYMENT` | Total domestic employment of R&D-performing companies | obs / size | Thousands |
| `ENERGY_RD_GENERAL` | Expenditures / funds for industrial energy R&D (source unspecified) | obs / size / cat | Millions of dollars |
| `FED_RD` | Federal funds for industrial R&D | obs / size | Millions of dollars |
| `FEDERAL_BY_AGENCY` | Federal R&D funds received by industry, by agency | obs | Millions of dollars |
| `FFRDC` | R&D at industry-administered federally funded R&D centres | size / cat | Millions of dollars |
| `FTE_SCI` | Number of FTE R&D scientists and engineers | obs / size / cat | Thousands |
| `FTE_SCI_RATE` | FTE R&D scientists and engineers per 1,000 employees | obs / size | Rate |
| `GEOGRAPHIC_RD` | Industrial R&D by geographic area or state | size | Millions of dollars |
| `METHODOLOGY` | Survey methodology: response rates, imputation rates, sample sizes | size | Count / percent |
| `NET_SALES` | Net sales of R&D-performing companies | obs / size | Millions of dollars |
| `POLLUTION_RD_GENERAL` | Expenditures / funds for pollution-abatement R&D (source unspecified) | obs / size | Millions of dollars |
| `RD_APPLIED_PRODUCT_FIELD` | Funds for applied R&D by industry and product field | size | Millions of dollars |
| `RD_CONTRACTED` | Company R&D contracted to outside organisations | obs / size | Millions of dollars |
| `RD_COST_TYPE` | Distribution of R&D costs by industry and type of cost | size | Millions of dollars |
| `RD_OUTSIDE_US` | Company R&D performed outside the United States | obs / size | Millions of dollars |
| `RD_PCT_SALES` | R&D funds as a percent of net sales | obs / size | Percent |
| `RD_PER_EMPLOYEE` | R&D funds per employee | size | Thousands of dollars |
| `SALES_EMPLOYMENT` | Net sales and employment (combined table) | obs | Mixed |
| `SELECTED_DATA` | Selected data for R&D-performing companies (multiple variables) | obs | Mixed |
| `SIZE_BREAKDOWN` | Funds or employment by industry and size of company (variable unspecified) | size | Mixed |
| `STATE_INDUSTRY` | Total R&D by state and industry | size | Millions of dollars |
| `SUMMARY` | Summary data (multiple variables in one table) | obs | Mixed |
| `TOTAL_RD` | Total (company, Federal, and other) funds for industrial R&D | obs / size | Millions of dollars |
| `TOTAL_RD_ENERGY` | Total funds for industrial energy R&D | size | Millions of dollars |
| `TOTAL_RD_POLLUTION` | Total funds for industrial pollution-abatement R&D | obs | Millions of dollars |
| `TRENDS_TOTAL_RD` | Trends in industrial R&D performance by source of funds (US aggregate) | agg | Millions of dollars |
| `US_TOTAL_RD` | US aggregate industrial R&D by source of funds | agg | Millions of dollars |
| `OTHER` | Unclassified (19 records from three junk sheets; not real data) | agg / cat | — |

**Primary table key:** obs = `nsf_observations`; agg = `nsf_us_aggregates`; size = `nsf_size_breakdowns`; cat = `nsf_category_timeseries`.
Many series appear in more than one table.

**Unit caveat:** The `unit` column on `nsf_source_files` records the unit string as
extracted from the source sheet.  A normalised form `unit_norm` is also available on
`nsf_source_files`; it collapses all dollar-million label variants to `millions_usd`,
percentage labels to `percent`, etc.  For `SALES_EMPLOYMENT`, `SUMMARY`, and
`SELECTED_DATA` the unit field often reflects only the first variable encountered in the
sheet; callers must interpret values by column context.

---

## 5. Series assignment

Series codes are assigned by applying ordered regex rules to `table_title` (the
concatenated first-three-row cell text of each sheet).  The first matching rule wins.
Rules are defined in `SERIES_RULES` in `code/python/ingest_nsf_archival.py`.

The title text is lowercased and matched with `re.IGNORECASE | re.DOTALL`.  Unmatched
titles receive `OTHER`.  As of the current ingestion run, 19 records carry `OTHER`, from
three internal-check sheets (`Vertical`, `%CHANGE 1996/1995`, `CHECK 1994`) in a single
archive file.  These contain no substantive data.

---

## 6. Industry and SIC/NAICS codes

**SIC era (1953–1996):** `sic_code` in `nsf_observations` contains SIC codes as
published by NSF.  These are typically 2-digit codes for major industry groups (e.g.
`20`, `28`, `35`) but occasionally 3- or 4-digit codes for detailed industries.  NSF's
SIC groupings do not always align exactly with Census Bureau SIC definitions;
manufacturing aggregates sometimes include selected non-manufacturing industries.

**NAICS era (1997 onward):** NSF switched to NAICS classification from the 1997 survey
year.  `sic_code` for post-1996 observations contains NAICS code ranges
(e.g. `31–33`, `21–23, 31–33, 42, 44–81`).  The column name retains `sic_code` for
schema continuity but holds NAICS values for this period.

**Empty `sic_code`:** 7,657 observations in `nsf_observations` (6.7%) have an empty
`sic_code`.  These are predominantly aggregate rows (`All industries`, `Total`,
`Manufacturing`, `Non-manufacturing`) where NSF did not print a code, and size sub-rows
in `nsf_size_breakdowns`.

**Crosswalk:** `nsf_industry_crosswalk` (section 3.7) maps all 421 `industry_name_norm`
strings to canonical SIC 1987 or NAICS 2002 codes.  The `primary_code` column gives the
closest single-code match; `sic_codes_covered` and `naics_codes_covered` give the full
NSF grouping where it spans multiple codes.  Analysts linking to external industry-level
data should join via `nsf_industry_crosswalk` and filter on `row_type = 'industry'`.

---

## 7. Suppression flags

NSF applied disclosure-avoidance suppression to cells where reporting would reveal
individual company data.  Suppressed cells are stored with `value = NULL` and a
`suppression_flag` code.

| Flag | Meaning | Count in `nsf_observations` |
|---|---|---|
| `D` | Withheld to avoid disclosing data for individual companies | 18,091 |
| `S` | Withheld because estimate does not meet publication standards | 3,374 |
| `T` | Data withheld; combined with another category | 2,493 |
| `NA` | Not applicable or not available | 147 |
| `Z` | Less than half the unit of measure shown | 1 |
| `UNPARSED` | Cell contained a non-numeric, non-recognised string | 4,280 |
| NULL | Value present and numeric | 86,918 |

`UNPARSED` records arise when a cell contains text the parser could not classify as a
number or a known suppression code.  These are predominantly footnote references, blank
cells with whitespace, or formatting artefacts.  Callers should treat `UNPARSED` as
missing rather than suppressed.

---

## 8. Known gaps and limitations

**1954 and 1955:** NSF did not publish detailed industry-level breakdowns for these years.
They are absent from `nsf_observations` across all spending series.  The US aggregate
series (`nsf_us_aggregates`) does cover these years in some publications.

**Post-2007 thinning:** The survey was wound down between 2007 and 2009.  Coverage in
`nsf_observations` after 2007 is sparse; `SALES_EMPLOYMENT` (2005–2008) is the only
series with systematic post-2007 industry-level coverage in this archive.

**`col_label` in `nsf_size_breakdowns`:** These labels are archivally faithful to the
source Excel layout but are not a clean categorical variable.  The view `v_size_breakdown`
adds `col_label_clean` (year prefix stripped), `col_category` (semantic classification:
`size_bracket`, `fund_source`, `rd_type`, `price_basis`, `total`, `other`), and
`year_from_col` (survey year inferred from column prefix where applicable).  See section
11 for the full view schema.

**Unit heterogeneity:** The `unit` field on `nsf_source_files` records the unit as
printed in the source sheet and is not normalised.  Use `unit_norm` for comparisons:
`millions_usd`, `thousands_usd`, `percent`, `thousands_persons`, `count`, `usd_per_unit`,
`ratio`, or `other`; NULL where no unit string was found.  Dollar values are consistently
in millions (current dollars unless the table title specifies constant dollars).

**Junk sheets:** Three sheets (`Vertical`, `%CHANGE 1996/1995`, and `CHECK 1994`) from a
single archive file were parsed and carry `series_code = 'OTHER'` (19 records total).
They should be excluded from all analysis by filtering `WHERE series_code != 'OTHER'`.

---

## 9. How to use the multi-vintage design

Each source file is a distinct publication vintage.  NSF frequently revised prior-year
estimates; a value for (industry, year) = (Chemicals, 1980) may appear in the 1981, 1982,
1983, and 1984 publications with different values.

To obtain a single value per (series, industry, year):

```sql
-- Latest vintage: keep the observation from the most recently ingested source file
SELECT o.series_code, o.industry_name_norm, o.sic_code, o.year, o.value
FROM nsf_observations o
JOIN nsf_source_files sf ON sf.id = o.source_file_id
WHERE o.series_code = 'TOTAL_RD'
  AND o.sic_code != ''
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY o.series_code, o.industry_name_norm, o.year
    ORDER BY sf.ingested_at DESC
) = 1;
```

SQLite does not support `QUALIFY`; use a subquery or window function equivalent.

To examine revision magnitude, group by `(series_code, industry_name_norm, year)` and
inspect the distribution of `value` across `source_file_id`.

---

## 10. Ingestion provenance

| Item | Value |
|---|---|
| Ingestion script | `code/python/ingest_nsf_archival.py` |
| Source index table | `raw_nsf_file_index` (1,061 rows); 1,246 sheets ingested |
| Archive cell store | `archive_historical_nsf_raw` (74,817 rows) |
| Excel engine | xlrd (`.xls` format only) |
| Year parser | Regex `^(1[89]\d{2}|20\d{2})([\s\d,./a-z]{0,4})?$`, range guard 1951–2015 |
| NAICS detection | Header row search for cells containing `naics` (case-insensitive) |
| Data-column offset detection | Scan of first 6 non-empty data rows; count numeric hits at year_col vs year_col+1 |
| Series assignment | `SERIES_RULES` list in ingestion script; ordered regex on `table_title` |
| Unit extraction | Regex scan of first 8 rows of each sheet |
| Crosswalk script | `code/python/build_crosswalk.py` |
| Crosswalk sources | SIC: OSHA SIC Manual; NAICS: US Census Bureau SUSB 1998–2002 |

---

## 11. Helper views

Two views simplify common analytical patterns.  Both are rebuilt by `build_crosswalk.py --rebuild`.

### `v_size_breakdown`

Adds derived columns to `nsf_size_breakdowns`:

| Column | Description |
|---|---|
| `year_from_col` | Survey year inferred from a `YYYY — ` prefix in `col_label`; falls back to the `year` column |
| `col_label_clean` | `col_label` with any leading `YYYY — ` prefix stripped |
| `col_category` | Semantic classification of `col_label_clean`: `size_bracket`, `fund_source`, `rd_type`, `price_basis`, `total`, or `other` |

Multi-year sheets (where a single sheet covers two or three survey years with size sub-columns under each year) encode the year in the column label as `1988 — Less than 500`.  `year_from_col` extracts it and `col_label_clean` strips it, making year-specific filtering straightforward.

### `v_observations`

Joins `nsf_observations` with `nsf_source_files` to expose `unit_norm` alongside each observation.  Equivalent to:

```sql
SELECT o.*, sf.unit_norm
FROM nsf_observations o
JOIN nsf_source_files sf ON sf.id = o.source_file_id;
```
