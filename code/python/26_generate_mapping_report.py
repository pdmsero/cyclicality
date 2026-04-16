#!/usr/bin/env python3
from __future__ import annotations

import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DB = ROOT / "data" / "cyclicality.db"
OUT = ROOT / "data" / "MAPPING_INTEGRITY_REPORT.md"


def q1(conn: sqlite3.Connection, sql: str):
    return conn.execute(sql).fetchone()[0]


def qall(conn: sqlite3.Connection, sql: str):
    return conn.execute(sql).fetchall()


def fmt_pct(num: float) -> str:
    return f"{num:.2f}%"


def main() -> int:
    conn = sqlite3.connect(DB)
    conn.execute("PRAGMA busy_timeout=5000")

    # Core table counts
    raw_rows = q1(conn, "SELECT COUNT(*) FROM raw_compustat")
    pa_rows = q1(conn, "SELECT COUNT(*) FROM processed_alldata")

    # Lookup integrity basics
    lookup_stats = qall(
        conn,
        """
        SELECT 'lookup_naics_to_sic' AS table_name, COUNT(*) AS rows,
               COUNT(DISTINCT CAST(naics AS TEXT)||'-'||CAST(sic AS TEXT)) AS distinct_pairs
        FROM lookup_naics_to_sic
        UNION ALL
        SELECT 'lookup_codes_naics_sic', COUNT(*),
               COUNT(DISTINCT COALESCE(naics3,'')||'-'||COALESCE(sic,''))
        FROM lookup_codes_naics_sic
        UNION ALL
        SELECT 'lookup_bea_naics_two_digit', COUNT(*),
               COUNT(DISTINCT COALESCE(naics,'')||'-'||CAST(year AS TEXT))
        FROM lookup_bea_naics_two_digit
        UNION ALL
        SELECT 'lookup_bea_naics_three_digit', COUNT(*),
               COUNT(DISTINCT COALESCE(naics3,'')||'-'||CAST(year AS TEXT))
        FROM lookup_bea_naics_three_digit
        UNION ALL
        SELECT 'lookup_two_digit_bea_naics', COUNT(*),
               COUNT(DISTINCT COALESCE(naics,'')||'-'||CAST(year AS TEXT))
        FROM lookup_two_digit_bea_naics
        """,
    )

    # One-to-many profile in lookup crosswalks
    naics_multi_sic = q1(
        conn,
        """
        SELECT COUNT(*)
        FROM (
          SELECT naics
          FROM lookup_naics_to_sic
          GROUP BY naics
          HAVING COUNT(DISTINCT sic) > 1
        )
        """,
    )

    naics3_multi_sic = q1(
        conn,
        """
        SELECT COUNT(*)
        FROM (
          SELECT naics3
          FROM lookup_codes_naics_sic
          GROUP BY naics3
          HAVING COUNT(DISTINCT sic) > 1
        )
        """,
    )

    # Join key uniqueness in source tables used by m:1 merges in Stata
    bea_dup_count = q1(
        conn,
        """
        SELECT COUNT(*)
        FROM (
          SELECT code, year, COUNT(*) c
          FROM processed_bea_value_added
          GROUP BY code, year
          HAVING c > 1
        )
        """,
    )

    bea_top_dupes = qall(
        conn,
        """
        SELECT CAST(code AS INT) AS code, year, COUNT(*) c
        FROM processed_bea_value_added
        GROUP BY code, year
        HAVING c > 1
        ORDER BY c DESC, code, year
        LIMIT 10
        """,
    )

    nber_dup_count = q1(
        conn,
        """
        SELECT COUNT(*)
        FROM (
          SELECT sic, year, COUNT(*) c
          FROM processed_nber_exports
          GROUP BY sic, year
          HAVING c > 1
        )
        """,
    )

    bea_null_code = q1(conn, "SELECT COUNT(*) FROM processed_bea_value_added WHERE code IS NULL")
    bea_null_year = q1(conn, "SELECT COUNT(*) FROM processed_bea_value_added WHERE year IS NULL")
    nber_null_sic = q1(conn, "SELECT COUNT(*) FROM processed_nber_exports WHERE sic IS NULL")
    nber_null_year = q1(conn, "SELECT COUNT(*) FROM processed_nber_exports WHERE year IS NULL")

    # Coverage in already-merged processed_alldata
    bea_matched = q1(conn, "SELECT COUNT(*) FROM processed_alldata WHERE pva IS NOT NULL")
    bea_unmatched = pa_rows - bea_matched
    bea_match_pct = 100.0 * bea_matched / pa_rows if pa_rows else 0.0

    nber_matched = q1(conn, "SELECT COUNT(*) FROM processed_alldata WHERE exports IS NOT NULL")
    nber_unmatched = pa_rows - nber_matched
    nber_match_pct = 100.0 * nber_matched / pa_rows if pa_rows else 0.0

    # Compustat key completeness
    naics_missing = q1(conn, "SELECT COUNT(*) FROM raw_compustat WHERE naics IS NULL OR TRIM(naics)='' ")
    sic_missing = q1(conn, "SELECT COUNT(*) FROM raw_compustat WHERE sic IS NULL OR TRIM(CAST(sic AS TEXT))='' ")

    # NAICS->SIC lookup coverage using first 6 NAICS digits
    naics_lookup_join = q1(
        conn,
        """
        WITH base AS (
          SELECT rowid rid,
                 CASE WHEN naics GLOB '[0-9][0-9][0-9][0-9][0-9][0-9]*'
                      THEN CAST(substr(naics,1,6) AS INTEGER)
                      ELSE NULL END AS naics6
          FROM raw_compustat
        )
        SELECT COUNT(*)
        FROM base b
        JOIN lookup_naics_to_sic l ON l.naics = b.naics6
        """,
    )

    naics_lookup_covered_rows = q1(
        conn,
        """
        WITH base AS (
          SELECT rowid rid,
                 CASE WHEN naics GLOB '[0-9][0-9][0-9][0-9][0-9][0-9]*'
                      THEN CAST(substr(naics,1,6) AS INTEGER)
                      ELSE NULL END AS naics6
          FROM raw_compustat
        )
        SELECT COUNT(DISTINCT b.rid)
        FROM base b
        JOIN lookup_naics_to_sic l ON l.naics = b.naics6
        """,
    )

    # Year-level unmatched summaries
    bea_unmatched_by_year = qall(
        conn,
        """
        SELECT CAST(year AS INT) AS year,
               COUNT(*) AS total,
               SUM(CASE WHEN pva IS NULL THEN 1 ELSE 0 END) AS unmatched,
               ROUND(100.0 * SUM(CASE WHEN pva IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS unmatched_pct
        FROM processed_alldata
        GROUP BY CAST(year AS INT)
        ORDER BY unmatched_pct DESC, year
        LIMIT 10
        """,
    )

    nber_unmatched_by_year = qall(
        conn,
        """
        SELECT CAST(year AS INT) AS year,
               COUNT(*) AS total,
               SUM(CASE WHEN exports IS NULL THEN 1 ELSE 0 END) AS unmatched,
               ROUND(100.0 * SUM(CASE WHEN exports IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS unmatched_pct
        FROM processed_alldata
        GROUP BY CAST(year AS INT)
        ORDER BY unmatched_pct DESC, year
        LIMIT 10
        """,
    )

    lines: list[str] = []
    lines.append("# Mapping Integrity Report")
    lines.append("")
    lines.append("Generated from `data/cyclicality.db` to audit NAICS/SIC/BEA mapping and merge integrity.")
    lines.append("")
    lines.append("## Baseline Scope")
    lines.append("")
    lines.append(f"- `raw_compustat` rows: `{raw_rows}`")
    lines.append(f"- `processed_alldata` rows: `{pa_rows}`")
    lines.append("")

    lines.append("## Lookup Table Uniqueness")
    lines.append("")
    lines.append("| Table | Rows | Distinct key-pairs | Duplicate rows (rows - distinct) |")
    lines.append("|---|---:|---:|---:|")
    for name, rows, distinct_pairs in lookup_stats:
        dup = rows - distinct_pairs
        lines.append(f"| `{name}` | {rows} | {distinct_pairs} | {dup} |")
    lines.append("")
    lines.append(f"- `lookup_naics_to_sic`: NAICS codes mapping to multiple SIC values: `{naics_multi_sic}`")
    lines.append(f"- `lookup_codes_naics_sic`: NAICS3 codes mapping to multiple SIC values: `{naics3_multi_sic}`")
    lines.append("")

    lines.append("## Merge Key Cardinality Checks")
    lines.append("")
    lines.append(f"- `processed_bea_value_added` duplicate `(code, year)` keys: `{bea_dup_count}`")
    lines.append(f"- `processed_nber_exports` duplicate `(sic, year)` keys: `{nber_dup_count}`")
    lines.append(f"- `processed_bea_value_added` null join keys: `code={bea_null_code}`, `year={bea_null_year}`")
    lines.append(f"- `processed_nber_exports` null join keys: `sic={nber_null_sic}`, `year={nber_null_year}`")
    if bea_top_dupes:
        lines.append("")
        lines.append("Top BEA duplicate keys:")
        lines.append("")
        lines.append("| code | year | duplicate_count |")
        lines.append("|---:|---:|---:|")
        for code, year, c in bea_top_dupes:
            lines.append(f"| {code} | {year} | {c} |")
    lines.append("")

    lines.append("## Coverage in `processed_alldata`")
    lines.append("")
    lines.append(f"- BEA join proxy (`pva` non-null): `{bea_matched}` matched / `{bea_unmatched}` unmatched (`{fmt_pct(bea_match_pct)}` match)")
    lines.append(f"- NBER join proxy (`exports` non-null): `{nber_matched}` matched / `{nber_unmatched}` unmatched (`{fmt_pct(nber_match_pct)}` match)")
    lines.append("")

    lines.append("Worst BEA unmatched years (top 10):")
    lines.append("")
    lines.append("| year | total_rows | unmatched_rows | unmatched_pct |")
    lines.append("|---:|---:|---:|---:|")
    for year, total, unmatched, pct in bea_unmatched_by_year:
        lines.append(f"| {year} | {total} | {unmatched} | {pct}% |")
    lines.append("")

    lines.append("Worst NBER unmatched years (top 10):")
    lines.append("")
    lines.append("| year | total_rows | unmatched_rows | unmatched_pct |")
    lines.append("|---:|---:|---:|---:|")
    for year, total, unmatched, pct in nber_unmatched_by_year:
        lines.append(f"| {year} | {total} | {unmatched} | {pct}% |")
    lines.append("")

    lines.append("## Compustat Key Completeness")
    lines.append("")
    lines.append(f"- Missing/blank `naics` in `raw_compustat`: `{naics_missing}`")
    lines.append(f"- Missing/blank `sic` in `raw_compustat`: `{sic_missing}`")
    lines.append(f"- Rows covered by `lookup_naics_to_sic` join (via first 6 NAICS digits): `{naics_lookup_covered_rows}` / `{raw_rows}`")
    lines.append(f"- Raw join hit count (`raw_compustat` x `lookup_naics_to_sic`): `{naics_lookup_join}`")
    lines.append("")

    lines.append("## Must-Fix Before Full Python Parity")
    lines.append("")
    must_fix = []
    if bea_dup_count > 0:
        must_fix.append("Resolve duplicate `(code, year)` keys in `processed_bea_value_added` before enforcing strict `m:1` semantics in Python.")
    if bea_null_code > 0 or bea_null_year > 0:
        must_fix.append("Handle null BEA join keys (`code`/`year`) before strict merge parity checks.")
    if naics_multi_sic > 0:
        must_fix.append("Document one-to-many NAICS->SIC mapping policy to avoid row explosion during crosswalk joins.")
    if bea_match_pct < 99.0:
        must_fix.append("Investigate BEA unmatched records (`pva` null) and decide whether to drop, impute, or re-map before model parity checks.")
    if nber_match_pct < 99.0:
        must_fix.append("Investigate NBER unmatched records (`exports` null) and ensure this matches intended sample restrictions from Stata.")
    if not must_fix:
        must_fix.append("No high-priority mapping integrity blockers detected.")

    for item in must_fix:
        lines.append(f"- {item}")

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
