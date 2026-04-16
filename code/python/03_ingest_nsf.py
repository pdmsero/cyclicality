#!/usr/bin/env python3
"""
NSF Industrial R&D Survey — archival database builder.

Replaces the ad-hoc raw_nsf_rd table with a properly structured archive:

  nsf_source_files      one row per (source_file, sheet); provenance metadata
  nsf_series_catalogue  canonical series codes with descriptions and units
  nsf_observations      every observation, fully labelled, no deduplication
  nsf_industry_names    unique industry name strings with normalised form
                        (basis for a future SIC crosswalk)

Design principles
-----------------
* Nothing is discarded.  Net sales, employment, FTE scientists, energy R&D,
  pollution-abatement R&D — all preserved with their series label.
* No deduplication across series.  The same (SIC, year) pair legitimately
  appears in many series; collapsing them destroys information.
* Within a single series, later publications may revise earlier estimates.
  All versions are kept; source_file is the dedup key if the user wants
  "latest vintage".
* Units are extracted from the table and stored on nsf_source_files.
* Series codes are assigned by regex on the table title; the raw title is
  also stored for full provenance.

Usage:
    python code/python/ingest_nsf_archival.py [--dry-run] [--verbose]
    python code/python/ingest_nsf_archival.py --rebuild   # drop and recreate
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import sqlite3
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB_PATH = ROOT / "data" / "cyclicality.db"

# ---------------------------------------------------------------------------
# Series classification
# ---------------------------------------------------------------------------

# Each entry: (series_code, description, regex_pattern)
# Patterns are tested in order; first match wins.
SERIES_RULES: list[tuple[str, str, str]] = [
    # --- R&D spending by fund source ---
    # Match "total (company, Federal…)" and "total (Federal plus company…)"
    ("TOTAL_RD",
     "Total (company, Federal, and other) funds for industrial R&D performance",
     r"total.{0,30}(company.{0,15}federal|federal.{0,10}(plus|and).{0,10}company).{0,80}(r&d|research)"),
    # "TABLE 1/3/30. Funds for industrial R&D…" — no fund-source qualifier = total
    ("TOTAL_RD",
     "Total (company, Federal, and other) funds for industrial R&D performance",
     r"^(table\s+[a-z]?[\d-]+\.?\s+)?funds for industrial (r&d|research and development)"),
    # Company + other, any wording
    ("CO_RD",
     "Company and other (except Federal) funds for industrial R&D performance",
     r"company and other.{0,30}(except federal|non.?federal).{0,80}(r&d|research)"),
    # Old wording: "company funds for research and development"
    ("CO_RD_ALT",
     "Company funds for R&D performance (older survey wording)",
     r"company.{0,10}(own\s+)?funds for (r&d|research and development)"),
    # Federal funds, any wording
    ("FED_RD",
     "Federal funds for industrial R&D performance",
     r"federal funds.{0,80}(r&d|research and development)"),

    # --- R&D by application domain ---
    ("TOTAL_RD_ENERGY",
     "Total funds for industrial energy R&D",
     r"total.{0,30}funds.{0,30}(energy|energy r&d)"),
    ("CO_RD_ENERGY",
     "Company and other funds for industrial energy R&D",
     r"company.{0,30}(own|other|nonfederal).{0,30}funds.{0,30}(energy|energy r&d)"),
    ("FED_RD_ENERGY",
     "Federal funds for industrial energy R&D",
     r"federal funds.{0,30}(energy|energy r&d)"),
    ("ENERGY_RD_GENERAL",
     "Expenditures / funds for industrial energy R&D (source unspecified)",
     r"(expenditure|fund|r&d).{0,40}energy.{0,40}(r&d|research|expenditure|fund)"),
    ("TOTAL_RD_POLLUTION",
     "Total funds for industrial pollution-abatement R&D",
     r"total.{0,30}funds.{0,30}pollution"),
    ("CO_RD_POLLUTION",
     "Company and other funds for industrial pollution-abatement R&D",
     r"company.{0,30}(own|other|nonfederal).{0,30}funds.{0,30}pollution"),
    ("FED_RD_POLLUTION",
     "Federal funds for industrial pollution-abatement R&D",
     r"federal funds.{0,30}pollution"),
    ("POLLUTION_RD_GENERAL",
     "Expenditures / funds for pollution-abatement R&D (source unspecified)",
     r"(expenditure|fund).{0,60}pollution"),

    # --- R&D by type of work ---
    ("BASIC_APPLIED_DEV",
     "Funds for basic research, applied research, and development",
     r"(basic|applied).{0,20}research.{0,20}develop"),

    # --- R&D outside US / contracted ---
    ("RD_OUTSIDE_US",
     "Company R&D performed outside the United States",
     r"(r&d|research).{0,30}(outside|performed outside|foreign)"),
    ("RD_CONTRACTED",
     "Company R&D contracted to outside organisations",
     r"contracted? to outside"),

    # --- Workforce and costs ---
    ("FTE_SCI_RATE",
     "FTE R&D scientists and engineers per 1,000 employees",
     r"(fte|full.?time.?equivalent).{0,40}per 1,?000"),
    ("FTE_SCI",
     "Number of FTE R&D scientists and engineers",
     r"(number of.{0,10})?(fte|full.?time.?equivalent).{0,40}(scientist|engineer)"),
    ("COST_PER_SCI",
     "Cost per R&D scientist or engineer",
     r"(cost|r&d funds) per.{0,20}(scientist|engineer)"),
    ("EMPLOYMENT",
     "Total domestic employment of R&D-performing companies",
     r"(domestic |total )employment"),
    ("EMPLOYMENT",
     "Total domestic employment of R&D-performing companies",
     r"number of employees.{0,60}(research and development|r&d|performing)"),

    # --- Financial context ---
    ("NET_SALES",
     "Net sales / domestic net sales of R&D-performing companies",
     r"(net sales|domestic net sales)"),
    ("RD_PCT_SALES",
     "R&D funds as a percent of net sales",
     r"(r&d|research).{0,20}percent.{0,20}(net )?sales"),
    ("TOTAL_PCT_SALES",
     "Total R&D as a percent of net sales",
     r"total r&d as a percent"),
    ("CO_COUNT",
     "Number of R&D-performing companies",
     r"number of.{0,20}(r&d.?performing|performing) compan"),
    # Older wording: "number of companies with R&D expenditures / funds for R&D"
    ("CO_COUNT",
     "Number of R&D-performing companies",
     r"number of compan.{0,80}(r&d|research and development|funds for|perform)"),
    # "R&D-performing companies in manufacturing/nonmanufacturing industries"
    ("CO_COUNT",
     "Number of R&D-performing companies",
     r"r&d.?performing companies.{0,60}(manufacturing|nonmanufacturing|industr)"),

    # --- Mixed / summary ---
    # "Sales and employment" tables (TABLE 2/31 format)
    ("SALES_EMPLOYMENT",
     "Sales and employment for R&D-performing companies (combined table)",
     r"sales and employment"),
    # Catch remaining "funds for research and development" (generic old wording)
    ("TOTAL_RD",
     "Total (company, Federal, and other) funds for industrial R&D performance",
     r"^(table\s+[a-z]?[\d-]+\.?\s+)?funds for (r&d|research and development).{0,60}(industry|compan)"),
    ("SUMMARY",
     "Summary data (multiple variables combined in one table)",
     r"summary data"),
    ("SELECTED_DATA",
     "Selected data for R&D-performing companies (multiple variables)",
     r"selected data.{0,30}(r&d.?performing|performing|companies performing) (compan|r&d|research)"),
    ("FEDERAL_BY_AGENCY",
     "Federal R&D by agency",
     r"federal.{0,20}by agency"),
    ("GEOGRAPHIC_RD",
     "Industrial R&D by geographic area or state",
     r"geographic distribution.{0,60}(r&d|research and development|funds)"),
    ("GEOGRAPHIC_RD",
     "Industrial R&D by geographic area or state",
     r"(industrial|r&d).{0,60}(by state|by area|by region).{0,60}(source of funds|performance|r&d)"),
    ("STATE_INDUSTRY",
     "Total R&D by state and industry",
     r"by state and industry"),
    # Aggregate trend tables (US total, no industry dimension)
    ("TRENDS_TOTAL_RD",
     "Trends in industrial R&D performance by source of funds (US aggregate)",
     r"trends in industrial (r&d|research)"),
    # Specialised series
    ("RD_PER_EMPLOYEE",
     "R&D funds per employee",
     r"(r&d|research).{0,20}funds? per employee"),
    ("FTE_SCI_RATE",
     "FTE R&D scientists and engineers per 1,000 employees",
     r"(scientist|engineer|r&d).{0,30}per 1,?000 employees"),
    ("RD_APPLIED_PRODUCT_FIELD",
     "Funds for applied R&D by product field",
     r"applied (r&d|research).{0,60}product field"),
    # Basic research by field of science
    ("BASIC_RD_BY_FIELD",
     "Funds for basic research by industry and field of science",
     r"basic research.{0,60}field of science"),
    ("CO_COUNT_ENERGY",
     "Number of companies performing energy R&D",
     r"number of compan.{0,30}energy"),
    ("FFRDC",
     "Industry-administered federally funded R&D centres",
     r"federally funded (r&d|research and development) cent"),
    # Survey methodology (response rates, imputation rates, sample sizes)
    ("METHODOLOGY",
     "Survey methodology: response rates, imputation rates, sample sizes",
     r"(response rate|imputation rate|relative standard error|number of companies"
     r" in the (universe|sample)|item response|unit response)"),
    # US aggregate time-series: industrial R&D by source of funds
    ("US_TOTAL_RD",
     "US aggregate industrial R&D by source of funds (time-series)",
     r"industrial r&d (perform\w*).{0,60}by source of funds"),
    # US aggregate: basic research, applied research, development totals
    ("US_RD_BY_TYPE",
     "US aggregate industrial R&D by type of work (time-series)",
     r"(basic research|applied research).{0,30}development.{0,60}(united states|u\.s\.)"),
    # Size-of-company breakdowns (also "company size" wording)
    ("SIZE_BREAKDOWN",
     "Funds or employment by industry and size of company (cross-section)",
     r"by industry and (size of company|company size)"),
    # Funds and number of companies combined table
    ("FUNDS_AND_COMPANIES",
     "Funds for and number of companies performing industrial R&D",
     r"funds for and (number of )?companies performing"),
    # R&D cost distribution by type of cost / expenditure
    ("RD_COST_TYPE",
     "Distribution of R&D costs by industry and type of cost",
     r"(distribution of r&d costs|r&d costs).{0,80}(type of cost|type of expenditure)"),
    # Distribution of company and Federal funds (by industry/type)
    ("CO_RD_ALT",
     "Company funds for R&D performance (older survey wording)",
     r"distribution of companies.{0,20}(own|nonfederal).{0,30}(r&d|research).{0,20}funds"),
    # Scientists and engineers (without FTE qualifier, older surveys)
    ("FTE_SCI",
     "Number of FTE R&D scientists and engineers",
     r"scientists and engineers.{0,30}(research and development|r&d)"),
    # Basic research cost compared with total R&D
    ("BASIC_APPLIED_DEV",
     "Funds for basic research, applied research, and development",
     r"cost of basic research.{0,40}total research"),
    # Early survey wording: "cost of company-financed and government-financed R&D"
    ("TOTAL_RD",
     "Total (company, Federal, and other) funds for industrial R&D performance",
     r"cost of (company.financed|company and other).{0,30}(government.financed|federal).{0,80}(research|r&d)"),
    # "Research and development cost and companies conducting..."
    ("TOTAL_RD",
     "Total (company, Federal, and other) funds for industrial R&D performance",
     r"research and development cost and companies conducting"),
    # "Expenditures by private industry for research and development"
    ("TOTAL_RD",
     "Total (company, Federal, and other) funds for industrial R&D performance",
     r"expenditures? by (private industry|industry).{0,40}(research and development|r&d)"),
    # Number of companies without R&D qualifier (older surveys)
    ("CO_COUNT",
     "Number of R&D-performing companies",
     r"(total )?number of (manufacturing )?companies.{0,40}(perform|r&d|research|employ)"),
]

# Compiled patterns
_COMPILED = [(code, desc, re.compile(pat, re.IGNORECASE | re.DOTALL))
             for code, desc, pat in SERIES_RULES]


def classify_series(title: str) -> tuple[str, str]:
    """Return (series_code, series_description) for a table title."""
    t = title.strip().lower()
    for code, desc, pat in _COMPILED:
        if pat.search(t):
            return code, desc
    return "OTHER", "Unclassified series"


# ---------------------------------------------------------------------------
# Unit extraction
# ---------------------------------------------------------------------------

UNIT_RE = re.compile(
    r'\[?\s*(in\s+)?(millions? of dollars?|thousands?|dollars? in millions?'
    r'|millions? of current.{0,30}dollars?|percent|thousands? of employees?'
    r'|in thousands?|in millions?)\s*\]?',
    re.IGNORECASE,
)


def extract_unit(rows: list[list[str]]) -> str:
    """Scan the first 8 rows for a unit string."""
    for row in rows[:8]:
        for cell in row:
            m = UNIT_RE.search(str(cell))
            if m:
                return m.group(0).strip().strip("[]").strip()
    return ""


# ---------------------------------------------------------------------------
# Parsing helpers (shared with ingest_nsf_improved.py)
# ---------------------------------------------------------------------------

SUPPRESSION_CODES = {"(D)", "(T)", "(NA)", "(S)", "(Z)", "D", "T", "NA", "S"}
YEAR_FUZZY = re.compile(r"^(1[89]\d{2}|20\d{2})([\s\d,./a-z]{0,4})?$")
_NSF_YEAR_MIN = 1951
_NSF_YEAR_MAX = 2015


def _extract_year(val: str) -> int | None:
    # Strip trailing dot leaders, ellipsis, and whitespace that NSF tables use
    # for visual alignment (e.g. "1953 1/..............….").
    s = re.sub(r"[.…\s]+$", "", val.strip())
    if len(s) > 8:
        return None
    m = YEAR_FUZZY.match(s)
    if not m:
        return None
    y = int(m.group(1))
    if y < _NSF_YEAR_MIN or y > _NSF_YEAR_MAX:
        return None
    return y


def _parse_value(raw: str) -> tuple[float | None, str | None]:
    s = str(raw).strip()
    if not s or s.lower() in ("nan", "none", ""):
        return None, None
    upper = s.upper().replace(" ", "")
    if upper in {f"({c})" for c in ["D", "T", "NA", "S", "Z"]} or upper in SUPPRESSION_CODES:
        return None, upper.strip("()")
    cleaned = s.replace(",", "").replace(" ", "")
    try:
        return float(cleaned), None
    except ValueError:
        return None, "UNPARSED"


def _normalise_name(name: str) -> str:
    s = str(name).strip()
    s = re.sub(r"[…\.]{2,}", "", s)
    # strip trailing footnote markers: digits, /, *, and whitespace after last word char
    s = re.sub(r"[\s\d/*\\]+$", "", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip().lower()


def _find_header_row(rows: list[list[str]]) -> int | None:
    for i, row in enumerate(rows):
        txt = " ".join(str(c) for c in row
                       if str(c).strip() and str(c).lower() != "nan").lower()
        if "industry" in txt and ("sic" in txt or "naics" in txt or "code" in txt):
            return i
    return None


def _year_cols_in_row(row: list[str]) -> list[tuple[int, int]]:
    result = []
    for c, val in enumerate(row):
        y = _extract_year(str(val))
        if y is not None:
            result.append((c, y))
    return result


def _has_year_row(row: list[str], min_years: int = 2) -> bool:
    return len(_year_cols_in_row(row)) >= min_years


def _detect_data_offset(rows: list[list[str]], data_start: int,
                        year_cols: list[tuple[int, int]]) -> int:
    """
    Detect whether data values sit at the year-header column (offset=0) or
    one column to the right (offset=1).

    SIC-era files: year header and data are in the same column (offset=0).
    NAICS-era files (post-1997): year headers are at even columns and data
    values are at the next odd column (offset=1).

    Strategy: scan the first few non-empty data rows and count how many
    cells at offset=0 vs offset=1 parse as a numeric value or a recognised
    suppression code.  Whichever offset yields more hits wins.
    """
    count0 = 0
    count1 = 0
    rows_examined = 0
    for row in rows[data_start:data_start + 15]:
        row_text = [str(c).strip() for c in row]
        if not any(v for v in row_text if v and v.lower() not in ("nan", "none")):
            continue
        rows_examined += 1
        if rows_examined > 6:
            break
        for col_idx, _year in year_cols:
            v0 = row_text[col_idx] if col_idx < len(row_text) else ""
            v1 = row_text[col_idx + 1] if col_idx + 1 < len(row_text) else ""
            val0, flag0 = _parse_value(v0)
            val1, flag1 = _parse_value(v1)
            if val0 is not None or flag0 not in (None, "UNPARSED"):
                count0 += 1
            if val1 is not None or flag1 not in (None, "UNPARSED"):
                count1 += 1
    return 1 if count1 > count0 else 0


def _extract_pages(rows: list[list[str]], header_row: int,
                   year_row: int) -> list[dict]:
    header = [str(c).strip() for c in rows[header_row]]
    pages: list[dict] = []
    page_starts = [i for i, h in enumerate(header) if "industry" in h.lower()]
    year_row_cells = [str(c).strip() for c in rows[year_row]]

    for p_idx, col_start in enumerate(page_starts):
        col_end = (page_starts[p_idx + 1] if p_idx + 1 < len(page_starts)
                   else len(header))

        # Find the code column: search header row for "sic" or "naics" text
        # within this page's column range.  Fall back to col_start+1.
        sic_col = col_start + 1
        for c in range(col_start + 1, col_end):
            if c < len(header):
                cell_lower = header[c].lower()
                if "sic" in cell_lower or "naics" in cell_lower:
                    sic_col = c
                    break

        # Collect year columns from the year row
        year_cols: list[tuple[int, int]] = []
        for c in range(col_start + 1, col_end):
            if c >= len(year_row_cells):
                break
            y = _extract_year(year_row_cells[c])
            if y is not None:
                year_cols.append((c, y))

        if not year_cols:
            continue

        # Detect whether data is at year_col or year_col+1
        data_start_row = max(header_row, year_row) + 1
        offset = _detect_data_offset(rows, data_start_row, year_cols)
        if offset:
            year_cols = [(c + 1, y) for c, y in year_cols]

        pages.append({
            "col_industry": col_start,
            "col_sic": sic_col,
            "year_cols": year_cols,
            "data_start_row": data_start_row,
        })
    return pages


def parse_sheet(rows: list[list[str]]) -> list[dict] | None:
    """
    Parse one sheet's grid into a list of observation dicts.
    Returns None if the sheet does not have a recognisable structure.
    Each dict: industry_name, industry_name_norm, sic_code, year, value,
               suppression_flag.
    """
    header_row = _find_header_row(rows)
    if header_row is None:
        return None

    if _has_year_row(rows[header_row]):
        year_row = header_row
    else:
        year_row = None
        for offset in range(1, 6):
            for sign in (+1, -1):
                ri = header_row + sign * offset
                if 0 <= ri < len(rows) and _has_year_row(rows[ri]):
                    year_row = ri
                    break
            if year_row is not None:
                break
        if year_row is None:
            return None

    pages = _extract_pages(rows, header_row, year_row)
    if not pages:
        return None

    records: list[dict] = []
    for page in pages:
        col_ind = page["col_industry"]
        col_sic = page["col_sic"]
        year_cols = page["year_cols"]
        data_start = page["data_start_row"]

        for row in rows[data_start:]:
            ind_val = row[col_ind] if col_ind < len(row) else ""
            if not ind_val or ind_val.lower() in ("nan", "none", ""):
                continue
            if "industry" in ind_val.lower() and "size" in ind_val.lower():
                continue

            sic_val = row[col_sic] if col_sic < len(row) else ""
            if sic_val.lower() in ("nan", "none"):
                sic_val = ""

            ind_norm = _normalise_name(ind_val)
            if not ind_norm:
                continue

            for col_idx, year in year_cols:
                raw = row[col_idx] if col_idx < len(row) else ""
                if raw.lower() in ("nan", "none", ""):
                    continue
                value, flag = _parse_value(raw)
                records.append({
                    "industry_name": ind_val[:500],
                    "industry_name_norm": ind_norm[:500],
                    "sic_code": sic_val[:50],
                    "year": year,
                    "value": value,
                    "suppression_flag": flag,
                })
    return records if records else None


# ---------------------------------------------------------------------------
# Supplementary parsers: US aggregates and size breakdowns
# ---------------------------------------------------------------------------

YEAR_IN_TITLE_RE = re.compile(r'\b(1[89]\d{2}|20\d{2})\b')


def _year_from_title(rows: list[list[str]], max_rows: int = 5) -> int | None:
    """Extract the single survey year from a table title (first few rows)."""
    # Prefer year at end of a cell, after colon
    for row in rows[:max_rows]:
        for cell in row:
            s = str(cell).strip()
            m = re.search(r':\s*(1[89]\d{2}|20\d{2})\s*$', s)
            if m:
                y = int(m.group(1))
                if _NSF_YEAR_MIN <= y <= _NSF_YEAR_MAX:
                    return y
    # Fallback: last year found in title text
    found = []
    for row in rows[:max_rows]:
        for cell in row:
            for m in YEAR_IN_TITLE_RE.findall(str(cell)):
                y = int(m)
                if _NSF_YEAR_MIN <= y <= _NSF_YEAR_MAX:
                    found.append(y)
    return found[-1] if found else None


def _build_col_labels(header_rows: list[list[str]]) -> list[str]:
    """
    Build column labels from multi-level header rows.

    Excel merged cells appear as value-in-first-cell + empty strings.  Each
    row is forward-filled so that all columns under a merged header inherit
    the parent label.  Labels from successive rows are joined with ' — ' to
    produce a composite like "All sources — Current $".
    """
    if not header_rows:
        return []
    n_cols = max(len(r) for r in header_rows)
    levels: list[list[str]] = []
    for row in header_rows:
        padded = [str(c).strip() for c in row] + [""] * (n_cols - len(row))
        last = ""
        filled = []
        for v in padded:
            clean = v if v and v.lower() not in ("nan", "none") else ""
            if clean:
                last = clean
            else:
                clean = last  # forward-fill from merged parent
            filled.append(clean)
        levels.append(filled)

    labels = []
    for c in range(n_cols):
        parts: list[str] = []
        seen: set[str] = set()
        for lvl in levels:
            v = lvl[c] if c < len(lvl) else ""
            if v and v not in seen:
                parts.append(v)
                seen.add(v)
        raw = " — ".join(parts) if parts else ""
        # Normalise whitespace: collapse embedded newlines and multiple spaces
        raw = re.sub(r"[\n\r]+", " ", raw)
        raw = re.sub(r"\s{2,}", " ", raw).strip()
        labels.append(raw)
    return labels


def parse_aggregate_sheet(rows: list[list[str]]) -> list[dict] | None:
    """
    Parse US-aggregate time-series tables where row[0] is a year.

    Returns list of {year, col_label, value, suppression_flag}, or None if the
    sheet does not have this structure.
    """
    # Find where data rows start: first row whose col 0 parses as a valid year
    data_start: int | None = None
    for ri, row in enumerate(rows):
        if row and _extract_year(str(row[0])) is not None:
            data_start = ri
            break
    if data_start is None or data_start == 0:
        return None

    # Header rows: rows above data_start whose content spans multiple columns
    # (i.e., column-structure rows, not single-cell prose titles).
    header_rows: list[list[str]] = []
    for ri in range(data_start):
        cells = [str(c).strip() for c in rows[ri]]
        non_empty = [v for v in cells
                     if v and v.lower() not in ("nan", "none", "year")]
        if not non_empty:
            continue
        # Discard title rows: content concentrated in col 0 only (long prose)
        first_cell = cells[0] if cells else ""
        if len(non_empty) <= 2 and len(first_cell) > 40:
            continue
        header_rows.append(cells)

    col_labels = _build_col_labels(header_rows)

    records: list[dict] = []
    for row in rows[data_start:]:
        if not row:
            continue
        year_val = _extract_year(str(row[0]))
        if year_val is None:
            continue
        for ci in range(1, len(row)):
            raw = str(row[ci]).strip()
            if not raw or raw.lower() in ("nan", "none"):
                continue
            label = (col_labels[ci] if ci < len(col_labels) else "")
            if not label:
                label = f"col_{ci}"
            value, flag = _parse_value(raw)
            if value is not None or (flag is not None and flag != "UNPARSED"):
                records.append({
                    "year": year_val,
                    "col_label": label[:200],
                    "value": value,
                    "suppression_flag": flag,
                })
    return records if records else None


def parse_category_timeseries_sheet(rows: list[list[str]]) -> list[dict] | None:
    """
    Parse sheets where categories are rows (energy source, geographic area,
    research field, pollution type) and years are columns.

    Returns list of {row_label, row_label_norm, year, value, suppression_flag}
    or None if the sheet does not have this structure.
    """
    # Find first non-title row where cols 1+ contain at least 2 year values.
    header_row: int | None = None
    for ri, row in enumerate(rows):
        if ri == 0:
            continue  # Title row
        year_cols = _year_cols_in_row([str(v) for v in row])
        if len(year_cols) >= 2:
            header_row = ri
            break

    if header_row is None:
        return None

    header = [str(v).strip() for v in rows[header_row]]
    year_cols = _year_cols_in_row(header)
    if len(year_cols) < 2:
        return None

    # Skip immediate post-header rows that are blank or unit strings
    data_start = header_row + 1
    while data_start < len(rows):
        cells = [str(v).strip() for v in rows[data_start]
                 if str(v).strip() and str(v).lower() not in ("nan", "none")]
        if not cells:
            data_start += 1
            continue
        if UNIT_RE.search(cells[0]):
            data_start += 1
            continue
        break

    records: list[dict] = []
    for row in rows[data_start:]:
        if not row:
            continue
        label = str(row[0]).strip() if row else ""
        if not label or label.lower() in ("nan", "none"):
            continue
        if _extract_year(label) is not None:
            continue
        # Skip rows that look like repeated year-header rows
        if len(_year_cols_in_row([str(v) for v in row])) >= 2:
            continue

        label_norm = _normalise_name(label)
        if not label_norm:
            continue

        for col_idx, year in year_cols:
            raw = str(row[col_idx]).strip() if col_idx < len(row) else ""
            if not raw or raw.lower() in ("nan", "none"):
                continue
            value, flag = _parse_value(raw)
            if value is not None or (flag is not None and flag != "UNPARSED"):
                records.append({
                    "row_label":        label[:500],
                    "row_label_norm":   label_norm[:500],
                    "year":             year,
                    "value":            value,
                    "suppression_flag": flag,
                })

    return records if records else None


def parse_size_breakdown_sheet(rows: list[list[str]]) -> dict | None:
    """
    Parse industry × size-of-company cross-section tables.

    Returns {year: int|None, records: list[dict]}, where each dict has
    {row_label, row_label_norm, sic_code, col_label, value, suppression_flag}.
    Returns None if the sheet cannot be parsed.
    """
    year = _year_from_title(rows)

    header_row = _find_header_row(rows)
    # If header_row is too deep it is likely a repeated mid-table header, not
    # the structural one.  Prefer an earlier heuristic match.
    _DIM_KW = ("industry", "industries", "product field", "location",
               "primary energy", "area", "state", "company size",
               "size of company", "size of r&d", "type of pollution",
               "occupational group", "size of")
    if header_row is None or header_row > 20:
        fb: int | None = None
        for i, row in enumerate(rows[:25]):
            cells = [str(c).strip() for c in row
                     if str(c).strip() and str(c).lower() not in ("nan", "none")]
            if len(cells) == 0:
                continue
            if len(cells) == 1:
                # Single-cell dimension label (e.g. "Size of company"): treat
                # the next non-empty multi-cell row as the header.
                if any(kw in cells[0].lower() for kw in _DIM_KW):
                    for j in range(i + 1, min(i + 6, len(rows))):
                        cells2 = [str(c).strip() for c in rows[j]
                                  if str(c).strip()
                                  and str(c).lower() not in ("nan", "none")]
                        if len(cells2) >= 2:
                            fb = j
                            break
                    if fb is not None:
                        break
                continue
            row_text = " ".join(c.lower() for c in cells)
            if any(kw in row_text for kw in _DIM_KW):
                fb = i
                break
        if fb is not None:
            header_row = fb
    if header_row is None:
        return None

    header = [str(c).strip() for c in rows[header_row]]

    # Identify industry and code columns
    ind_col = next((i for i, h in enumerate(header)
                    if "industry" in h.lower()), 0)
    code_col = next((i for i, h in enumerate(header)
                     if "sic" in h.lower() or "naics" in h.lower()),
                    ind_col + 1)
    data_col_start = code_col + 1

    if data_col_start >= len(header):
        return None

    # Build column labels from rows between title and the main header row.
    # Filter out single-cell title/unit/pagination rows; keep only rows whose
    # content spans multiple columns (true column-header structure rows).
    _SKIP_RE = re.compile(
        r'^\[|^page\s+\d|^\(|^dollars|^in thousands|^in millions',
        re.IGNORECASE,
    )
    pre_header: list[list[str]] = []
    for ri in range(max(0, header_row - 6), header_row):
        cells = [str(c).strip() for c in rows[ri]]
        non_empty = [v for v in cells
                     if v and v.lower() not in ("nan", "none")]
        if not non_empty:
            continue
        if "industry" in " ".join(non_empty).lower():
            continue
        if len(non_empty) <= 1:
            v0 = non_empty[0] if non_empty else ""
            if _SKIP_RE.search(v0) or len(v0) > 40:
                continue
            # Skip rows whose only value is a year (merged year-header rows)
            if _extract_year(v0) is not None:
                continue
        pre_header.append(cells)
    # Include the main header row with row-dimension columns (industry, code)
    # zeroed out so they cannot forward-fill into data column positions.
    header_for_labels = list(header)
    for c in range(data_col_start):
        header_for_labels[c] = ""
    pre_header.append(header_for_labels)

    col_labels_all = _build_col_labels(pre_header)
    data_col_labels = {
        c: (col_labels_all[c] if c < len(col_labels_all) else f"col_{c}")
        for c in range(data_col_start, len(header))
    }

    data_start = header_row + 1
    records: list[dict] = []
    current_industry = ""
    current_sic = ""

    for row in rows[data_start:]:
        if not row or len(row) <= ind_col:
            continue
        ind_val = str(row[ind_col]).strip()
        if not ind_val or ind_val.lower() in ("nan", "none"):
            continue
        # Skip repeat-header rows that sometimes appear mid-table
        if "industry" in ind_val.lower() and "size" in ind_val.lower():
            continue

        code_val = (str(row[code_col]).strip()
                    if code_col < len(row) else "")
        if code_val.lower() in ("nan", "none"):
            code_val = ""

        if code_val:
            # Main industry row
            current_industry = ind_val
            current_sic = code_val
            row_label = ind_val
        else:
            # Size sub-row under the current industry
            row_label = (f"{current_industry} — {ind_val}"
                         if current_industry else ind_val)

        row_norm = _normalise_name(row_label)
        if not row_norm:
            continue

        for ci in range(data_col_start, len(row)):
            raw = str(row[ci]).strip() if ci < len(row) else ""
            if not raw or raw.lower() in ("nan", "none"):
                continue
            col_label = data_col_labels.get(ci, f"col_{ci}") or f"col_{ci}"
            value, flag = _parse_value(raw)
            if value is not None or (flag is not None and flag != "UNPARSED"):
                records.append({
                    "row_label":      row_label[:500],
                    "row_label_norm": row_norm[:500],
                    "sic_code":       current_sic[:50],
                    "col_label":      col_label[:200],
                    "value":          value,
                    "suppression_flag": flag,
                })

    return {"year": year, "records": records} if records else None


# ---------------------------------------------------------------------------
# Schema
# ---------------------------------------------------------------------------

DDL = """
CREATE TABLE IF NOT EXISTS nsf_source_files (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file     TEXT NOT NULL,
    index_folder    TEXT,
    sheet_name      TEXT NOT NULL,
    table_title     TEXT,
    series_code     TEXT,
    unit            TEXT,
    years_covered   TEXT,
    n_observations  INTEGER,
    ingested_at     TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (source_file, sheet_name)
);

CREATE INDEX IF NOT EXISTS idx_nsf_sf_series ON nsf_source_files (series_code);

CREATE TABLE IF NOT EXISTS nsf_series_catalogue (
    series_code     TEXT PRIMARY KEY,
    description     TEXT NOT NULL,
    n_source_files  INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS nsf_observations (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file_id   INTEGER NOT NULL REFERENCES nsf_source_files(id),
    series_code      TEXT NOT NULL,
    industry_name    TEXT,
    industry_name_norm TEXT,
    sic_code         TEXT,
    year             INTEGER NOT NULL,
    value            REAL,
    suppression_flag TEXT,
    ingested_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_nsf_obs_series_sic_year
    ON nsf_observations (series_code, sic_code, year);
CREATE INDEX IF NOT EXISTS idx_nsf_obs_year
    ON nsf_observations (year);

CREATE TABLE IF NOT EXISTS nsf_industry_names (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    industry_name_norm TEXT NOT NULL UNIQUE,
    example_raw_name TEXT,
    n_occurrences    INTEGER DEFAULT 0
);

-- US aggregate time-series (year as row, fund-source/R&D-type as column)
CREATE TABLE IF NOT EXISTS nsf_us_aggregates (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file_id   INTEGER NOT NULL REFERENCES nsf_source_files(id),
    series_code      TEXT NOT NULL,
    year             INTEGER NOT NULL,
    col_label        TEXT NOT NULL,
    value            REAL,
    suppression_flag TEXT,
    ingested_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_nsf_agg_series_year
    ON nsf_us_aggregates (series_code, year);

-- Industry × size-of-company cross-sections (single survey year per table)
CREATE TABLE IF NOT EXISTS nsf_size_breakdowns (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file_id   INTEGER NOT NULL REFERENCES nsf_source_files(id),
    series_code      TEXT NOT NULL,
    year             INTEGER,
    row_label        TEXT NOT NULL,
    row_label_norm   TEXT,
    sic_code         TEXT,
    col_label        TEXT NOT NULL,
    value            REAL,
    suppression_flag TEXT,
    ingested_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_nsf_size_series_year
    ON nsf_size_breakdowns (series_code, year);

-- Category × year time-series (energy source, geographic area, research field,
-- pollution type: rows are categories, columns are years)
CREATE TABLE IF NOT EXISTS nsf_category_timeseries (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    source_file_id   INTEGER NOT NULL REFERENCES nsf_source_files(id),
    series_code      TEXT NOT NULL,
    row_label        TEXT NOT NULL,
    row_label_norm   TEXT,
    year             INTEGER NOT NULL,
    value            REAL,
    suppression_flag TEXT,
    ingested_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_nsf_cat_ts_series_year
    ON nsf_category_timeseries (series_code, year);
"""


# ---------------------------------------------------------------------------
# File iteration
# ---------------------------------------------------------------------------

def iter_source_paths() -> list[tuple[Path, str]]:
    """
    Return (xls_path, index_folder) for every file with parse_status in
    ('ok', 'ok_v2') in raw_nsf_file_index, plus archive/historical files.
    """
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute(
        "SELECT source_file, index_folder FROM raw_nsf_file_index "
        "WHERE parse_status IN ('ok', 'ok_v2', 'no_industry_format') "
        "ORDER BY source_file"
    )
    main_files = [(Path(r[0]), r[1]) for r in cur.fetchall()]

    # Archive files (not in raw_nsf_file_index)
    cur.execute("SELECT DISTINCT source_file FROM archive_historical_nsf_raw")
    arch_files = [(Path(r[0]), "archive_historical") for r in cur.fetchall()]
    con.close()

    return main_files + arch_files


def read_archive_sheet(con: sqlite3.Connection, source_file: str,
                       sheet_name: str) -> list[list[str]]:
    cur = con.cursor()
    cur.execute(
        "SELECT row_idx, col_idx, value_raw "
        "FROM archive_historical_nsf_raw "
        "WHERE source_file=? AND sheet_name=?",
        (source_file, sheet_name),
    )
    cells = cur.fetchall()
    if not cells:
        return []
    max_row = max(r for r, c, v in cells)
    max_col = max(c for r, c, v in cells)
    grid = [[""] * (max_col + 1) for _ in range(max_row + 1)]
    for r, c, v in cells:
        grid[r][c] = str(v).strip() if v is not None else ""
    return grid


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build archival NSF database (nsf_observations etc.)"
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("--rebuild", action="store_true",
                        help="Drop and recreate all nsf_* tables")
    args = parser.parse_args()

    now = dt.datetime.now().isoformat()

    con = sqlite3.connect(DB_PATH)
    try:
        cur = con.cursor()

        if args.rebuild and not args.dry_run:
            print("Dropping existing nsf_* tables …")
            for tbl in ("nsf_observations", "nsf_us_aggregates",
                        "nsf_size_breakdowns", "nsf_category_timeseries",
                        "nsf_source_files",
                        "nsf_series_catalogue", "nsf_industry_names"):
                cur.execute(f"DROP TABLE IF EXISTS {tbl}")

        cur.executescript(DDL)

        source_paths = iter_source_paths()
        print(f"Source (file, sheet) pairs to process: scanning …")

        total_obs = 0
        total_sheets = 0
        skipped = 0
        total_agg = 0
        total_size = 0
        total_cat_ts = 0

        series_stats: dict[str, int] = {}
        industry_counts: dict[str, tuple[str, int]] = {}

        # Track archive sheets needing cell reconstruction
        arch_con = sqlite3.connect(DB_PATH)
        cur2 = arch_con.cursor()
        cur2.execute(
            "SELECT DISTINCT source_file, sheet_name "
            "FROM archive_historical_nsf_raw ORDER BY source_file, sheet_name"
        )
        arch_sheet_index = {(r[0], r[1]) for r in cur2.fetchall()}
        arch_con.close()

        for xls_path, index_folder in source_paths:
            is_archive = (index_folder == "archive_historical")

            # Get sheets to process
            if is_archive:
                sheets_to_process = [
                    s for sf, s in arch_sheet_index
                    if sf == str(xls_path)
                ]
            else:
                try:
                    import pandas as pd
                    xl = pd.ExcelFile(str(xls_path), engine="xlrd")
                    sheets_to_process = xl.sheet_names
                except Exception:
                    skipped += 1
                    continue

            for sheet_name in sheets_to_process:
                # Build row grid
                if is_archive:
                    rows = read_archive_sheet(con, str(xls_path), sheet_name)
                else:
                    try:
                        import pandas as pd
                        df = pd.ExcelFile(str(xls_path), engine="xlrd").parse(
                            sheet_name, header=None
                        )
                        if df.empty:
                            continue
                        rows = [[str(v).strip() for v in row]
                                for row in df.values.tolist()]
                    except Exception:
                        continue

                if not rows:
                    continue

                # Extract table title (first non-empty cell in first 3 rows)
                title_parts = []
                for i in range(min(3, len(rows))):
                    cell = rows[i][0] if rows[i] else ""
                    if cell and cell.lower() not in ("nan", ""):
                        title_parts.append(cell.strip())
                table_title = re.sub(r"\s+", " ",
                                    " ".join(title_parts)).strip()[:500]

                series_code, _series_desc = classify_series(table_title)
                unit = extract_unit(rows)

                # ----------------------------------------------------------
                # Try parsers in order: industry×year → US aggregate →
                # size breakdown → category time-series.
                # Only the first successful parse is kept.
                # ----------------------------------------------------------

                obs = parse_sheet(rows)
                agg_result = None
                size_result = None
                cat_ts_result = None

                if obs is None:
                    agg_result = parse_aggregate_sheet(rows)
                if obs is None and agg_result is None:
                    size_result = parse_size_breakdown_sheet(rows)
                if obs is None and agg_result is None and size_result is None:
                    cat_ts_result = parse_category_timeseries_sheet(rows)

                if (obs is None and agg_result is None
                        and size_result is None and cat_ts_result is None):
                    continue

                # Determine years string for provenance
                if obs:
                    years = sorted({o["year"] for o in obs})
                    years_str = (f"{years[0]}–{years[-1]}" if len(years) > 1
                                 else str(years[0])) if years else ""
                    n_rec = len(obs)
                elif agg_result:
                    years = sorted({o["year"] for o in agg_result})
                    years_str = (f"{years[0]}–{years[-1]}" if len(years) > 1
                                 else str(years[0])) if years else ""
                    n_rec = len(agg_result)
                elif size_result:
                    yr = size_result["year"]
                    years_str = str(yr) if yr else ""
                    n_rec = len(size_result["records"])
                else:
                    years = sorted({o["year"] for o in cat_ts_result})
                    years_str = (f"{years[0]}–{years[-1]}" if len(years) > 1
                                 else str(years[0])) if years else ""
                    n_rec = len(cat_ts_result)

                if args.verbose:
                    table_type = ("ind×yr" if obs else
                                  "agg" if agg_result else
                                  "size" if size_result else "cat_ts")
                    print(f"  [{series_code}|{table_type}] "
                          f"{xls_path.name}/{sheet_name}: "
                          f"{n_rec} records ({years_str})")

                if not args.dry_run:
                    # Upsert source file record
                    cur.execute(
                        """
                        INSERT INTO nsf_source_files
                            (source_file, index_folder, sheet_name, table_title,
                             series_code, unit, years_covered, n_observations,
                             ingested_at)
                        VALUES (?,?,?,?,?,?,?,?,?)
                        ON CONFLICT(source_file, sheet_name) DO UPDATE SET
                            table_title=excluded.table_title,
                            series_code=excluded.series_code,
                            unit=excluded.unit,
                            years_covered=excluded.years_covered,
                            n_observations=excluded.n_observations,
                            ingested_at=excluded.ingested_at
                        """,
                        (str(xls_path), index_folder, str(sheet_name),
                         table_title, series_code, unit, years_str,
                         n_rec, now),
                    )
                    sf_id = cur.lastrowid or cur.execute(
                        "SELECT id FROM nsf_source_files "
                        "WHERE source_file=? AND sheet_name=?",
                        (str(xls_path), str(sheet_name)),
                    ).fetchone()[0]

                    if obs:
                        # Delete old observations for this source
                        cur.execute(
                            "DELETE FROM nsf_observations "
                            "WHERE source_file_id=?", (sf_id,))
                        cur.executemany(
                            """
                            INSERT INTO nsf_observations
                                (source_file_id, series_code, industry_name,
                                 industry_name_norm, sic_code, year, value,
                                 suppression_flag, ingested_at)
                            VALUES (?,?,?,?,?,?,?,?,?)
                            """,
                            [(sf_id, series_code,
                              o["industry_name"], o["industry_name_norm"],
                              o["sic_code"], o["year"], o["value"],
                              o["suppression_flag"], now)
                             for o in obs],
                        )
                        # Accumulate industry name counts
                        for o in obs:
                            key = o["industry_name_norm"]
                            existing = industry_counts.get(key)
                            if existing is None:
                                industry_counts[key] = (o["industry_name"], 1)
                            else:
                                industry_counts[key] = (existing[0],
                                                        existing[1] + 1)

                    elif agg_result:
                        cur.execute(
                            "DELETE FROM nsf_us_aggregates "
                            "WHERE source_file_id=?", (sf_id,))
                        cur.executemany(
                            """
                            INSERT INTO nsf_us_aggregates
                                (source_file_id, series_code, year,
                                 col_label, value, suppression_flag, ingested_at)
                            VALUES (?,?,?,?,?,?,?)
                            """,
                            [(sf_id, series_code,
                              o["year"], o["col_label"], o["value"],
                              o["suppression_flag"], now)
                             for o in agg_result],
                        )

                    elif size_result:
                        cur.execute(
                            "DELETE FROM nsf_size_breakdowns "
                            "WHERE source_file_id=?", (sf_id,))
                        yr = size_result["year"]
                        cur.executemany(
                            """
                            INSERT INTO nsf_size_breakdowns
                                (source_file_id, series_code, year,
                                 row_label, row_label_norm, sic_code,
                                 col_label, value, suppression_flag, ingested_at)
                            VALUES (?,?,?,?,?,?,?,?,?,?)
                            """,
                            [(sf_id, series_code, yr,
                              r["row_label"], r["row_label_norm"],
                              r["sic_code"], r["col_label"],
                              r["value"], r["suppression_flag"], now)
                             for r in size_result["records"]],
                        )

                    else:  # cat_ts_result
                        cur.execute(
                            "DELETE FROM nsf_category_timeseries "
                            "WHERE source_file_id=?", (sf_id,))
                        cur.executemany(
                            """
                            INSERT INTO nsf_category_timeseries
                                (source_file_id, series_code, row_label,
                                 row_label_norm, year, value,
                                 suppression_flag, ingested_at)
                            VALUES (?,?,?,?,?,?,?,?)
                            """,
                            [(sf_id, series_code,
                              o["row_label"], o["row_label_norm"],
                              o["year"], o["value"],
                              o["suppression_flag"], now)
                             for o in cat_ts_result],
                        )

                series_stats[series_code] = (
                    series_stats.get(series_code, 0) + n_rec
                )
                if obs:
                    total_obs += n_rec
                elif agg_result:
                    total_agg += n_rec
                elif size_result:
                    total_size += n_rec
                else:
                    total_cat_ts += n_rec
                total_sheets += 1

        if not args.dry_run:
            # Populate series catalogue
            for code, count in series_stats.items():
                desc = next(
                    (d for c, d, _ in _COMPILED if c == code),
                    "Unclassified series",
                )
                cur.execute(
                    """
                    INSERT INTO nsf_series_catalogue (series_code, description,
                                                      n_source_files)
                    VALUES (?,?,?)
                    ON CONFLICT(series_code) DO UPDATE SET
                        n_source_files=excluded.n_source_files
                    """,
                    (code, desc, count),
                )

            # Populate industry names table
            cur.execute("DELETE FROM nsf_industry_names")
            cur.executemany(
                """
                INSERT INTO nsf_industry_names
                    (industry_name_norm, example_raw_name, n_occurrences)
                VALUES (?,?,?)
                """,
                [(norm, raw, cnt)
                 for norm, (raw, cnt) in industry_counts.items()],
            )

            con.commit()

        # Summary
        print(f"\n{'[DRY RUN] ' if args.dry_run else ''}Ingestion complete")
        print(f"  Sheets parsed:            {total_sheets}")
        print(f"  Industry×year obs:      {total_obs:>10,}")
        print(f"  US aggregate records:   {total_agg:>10,}")
        print(f"  Size breakdown recs:    {total_size:>10,}")
        print(f"  Category time-series:   {total_cat_ts:>10,}")
        print(f"  Skipped files:            {skipped}")
        print(f"\n  Series breakdown:")
        for code, count in sorted(series_stats.items(),
                                  key=lambda x: -x[1]):
            desc = next((d for c, d, _ in _COMPILED if c == code),
                        "Unclassified")
            print(f"    {code:<22} {count:>8,}  {desc[:55]}")

        if not args.dry_run:
            cur.execute("SELECT COUNT(DISTINCT industry_name_norm) "
                        "FROM nsf_industry_names")
            print(f"\n  Distinct industry name strings: "
                  f"{cur.fetchone()[0]}")
            cur.execute("SELECT MIN(year), MAX(year) FROM nsf_observations")
            yr = cur.fetchone()
            print(f"  Year range:  {yr[0]}–{yr[1]}")

    except Exception:
        con.rollback()
        traceback.print_exc()
        raise
    finally:
        con.close()


if __name__ == "__main__":
    main()
