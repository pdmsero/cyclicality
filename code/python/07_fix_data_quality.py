"""
fix_data_quality.py
===================
Applies targeted data quality fixes to cyclicality.db.
Safe to re-run: all fixes are idempotent.

Fixes applied
-------------
1. Reclassify percent-unit CO_RD / TOTAL_RD sheets → RD_PCT_SALES
   FED_RD percent sheets are legitimately "Federal funds as % of net sales" and kept.

2. Flag sentinel negatives in nsf_observations → suppression_flag='SENTINEL', value=NULL
   Two populations: small-integer archive codes (radio/TV, machinery, 1950s-70s)
   and 2001 CO_RD signed revision adjustments.

3. Flag sentinel negatives in nsf_size_breakdowns → suppression_flag='SENTINEL', value=NULL
   All negative values that are not genuine revision adjustments (value >= -30).
   Large TOTAL_RD geographic negatives (< -100) are also flagged.

4. Remove col_% rows with SIC-code-as-value contamination
   Rows where col_label LIKE 'col_%' AND value > 1,000,000.
   Rows with col_% and valid values (≤1,000,000) are left: col_label is uninformative
   but the values may be real.

5. Normalise sic_code placeholders in nsf_observations
   Dot-leader strings, dashes, 'na', '(na)', 'SIC code', '--' → empty string.

6. Correct FTE_SCI unit misclassification
   One sheet (Table A-39) has unit_norm='millions_usd' due to a nearby dollar string
   being picked up during unit extraction. Correct to 'thousands_persons'.

7. Recover null years in nsf_size_breakdowns
   Geographic table (sf_id=1096): col_label IS the year — extract directly.
   Table 13 (sf_id=109): filename implies 1968 publication; col_labels confirm.

Usage
-----
    python3 code/python/fix_data_quality.py [--dry-run]

With --dry-run, prints counts without modifying the database.
"""

import re
import sqlite3
import sys
from pathlib import Path

DB_PATH = Path("data/cyclicality.db")
DRY_RUN = "--dry-run" in sys.argv


def connect():
    db = sqlite3.connect(DB_PATH)
    db.row_factory = sqlite3.Row
    return db


def report(label: str, n: int):
    suffix = " [DRY RUN — not applied]" if DRY_RUN else ""
    print(f"  {label}: {n:,} rows{suffix}")


# ---------------------------------------------------------------------------
# Fix 1: Reclassify percent-unit CO_RD / TOTAL_RD sheets → RD_PCT_SALES
# ---------------------------------------------------------------------------

def fix_percent_series_reclassification(db):
    c = db.cursor()
    print("\n[Fix 1] Reclassify percent-unit CO_RD/TOTAL_RD → RD_PCT_SALES")

    # Identify source_file ids: dollar series with percent unit
    c.execute("""
        SELECT id FROM nsf_source_files
        WHERE series_code IN ('CO_RD', 'TOTAL_RD')
          AND unit_norm = 'percent'
    """)
    sf_ids = [r[0] for r in c.fetchall()]
    report("Source sheets to reclassify", len(sf_ids))

    if sf_ids and not DRY_RUN:
        placeholders = ",".join("?" * len(sf_ids))
        # Reclassify observation rows
        c.execute(f"""
            UPDATE nsf_observations
            SET series_code = 'RD_PCT_SALES'
            WHERE source_file_id IN ({placeholders})
              AND series_code IN ('CO_RD', 'TOTAL_RD')
        """, sf_ids)
        report("  nsf_observations rows reclassified", c.rowcount)

        # Reclassify size_breakdown rows
        c.execute(f"""
            UPDATE nsf_size_breakdowns
            SET series_code = 'RD_PCT_SALES'
            WHERE source_file_id IN ({placeholders})
              AND series_code IN ('CO_RD', 'TOTAL_RD')
        """, sf_ids)
        report("  nsf_size_breakdowns rows reclassified", c.rowcount)

        # Reclassify source_files themselves
        c.execute(f"""
            UPDATE nsf_source_files
            SET series_code = 'RD_PCT_SALES'
            WHERE id IN ({placeholders})
        """, sf_ids)
        report("  nsf_source_files rows reclassified", c.rowcount)

        db.commit()

    # FED_RD percent sheets: these are "Federal funds as % of net sales" —
    # legitimately FED_RD expressed as a percent rate. Keep series code, note in comment.
    c.execute("""
        SELECT COUNT(*) FROM nsf_source_files
        WHERE series_code = 'FED_RD' AND unit_norm = 'percent'
    """)
    n = c.fetchone()[0]
    print(f"  FED_RD percent sheets retained as FED_RD (unit_norm='percent'): {n}")


# ---------------------------------------------------------------------------
# Fix 2: Flag sentinel negatives in nsf_observations
# ---------------------------------------------------------------------------

def fix_sentinel_negatives_observations(db):
    c = db.cursor()
    print("\n[Fix 2] Flag sentinel negatives in nsf_observations")

    # Count
    c.execute("""
        SELECT COUNT(*) FROM nsf_observations
        WHERE value < 0 AND suppression_flag IS NULL
    """)
    n_total = c.fetchone()[0]
    report("Negative values to flag as SENTINEL", n_total)

    if not DRY_RUN and n_total > 0:
        c.execute("""
            UPDATE nsf_observations
            SET suppression_flag = 'SENTINEL', value = NULL
            WHERE value < 0 AND suppression_flag IS NULL
        """)
        report("  Rows updated", c.rowcount)
        db.commit()


# ---------------------------------------------------------------------------
# Fix 3: Flag sentinel negatives in nsf_size_breakdowns
# ---------------------------------------------------------------------------

def fix_sentinel_negatives_size(db):
    c = db.cursor()
    print("\n[Fix 3] Flag sentinel negatives in nsf_size_breakdowns")

    # All negative values in size_breakdowns: small sentinel codes (<= -0.1)
    # and large TOTAL_RD geographic adjustments are both flagged.
    # The nsf_size_breakdowns table contains no legitimate negative R&D figures.
    c.execute("""
        SELECT COUNT(*) FROM nsf_size_breakdowns
        WHERE value < 0 AND suppression_flag IS NULL
    """)
    n_total = c.fetchone()[0]

    # Breakdown by size
    c.execute("""
        SELECT
            SUM(CASE WHEN value >= -30 THEN 1 ELSE 0 END) as small,
            SUM(CASE WHEN value < -30 THEN 1 ELSE 0 END) as large
        FROM nsf_size_breakdowns
        WHERE value < 0 AND suppression_flag IS NULL
    """)
    r = c.fetchone()
    print(f"  Total negative rows: {n_total:,} (small sentinels: {r[0]:,}, large: {r[1]:,})")

    if not DRY_RUN and n_total > 0:
        c.execute("""
            UPDATE nsf_size_breakdowns
            SET suppression_flag = 'SENTINEL', value = NULL
            WHERE value < 0 AND suppression_flag IS NULL
        """)
        report("  Rows updated", c.rowcount)
        db.commit()


# ---------------------------------------------------------------------------
# Fix 4: Remove col_% rows with SIC-code-as-value contamination
# ---------------------------------------------------------------------------

def fix_col_percent_contamination(db):
    c = db.cursor()
    print("\n[Fix 4] Remove col_% contaminated rows (value > 1,000,000)")

    c.execute("""
        SELECT COUNT(*) FROM nsf_size_breakdowns
        WHERE col_label LIKE 'col_%' AND value > 1000000
    """)
    n_contaminated = c.fetchone()[0]
    report("Contaminated rows to delete", n_contaminated)

    # Report remaining col_% rows that will be kept (valid values)
    c.execute("""
        SELECT COUNT(*) FROM nsf_size_breakdowns
        WHERE col_label LIKE 'col_%'
          AND (value IS NULL OR value <= 1000000)
    """)
    n_kept = c.fetchone()[0]
    print(f"  col_% rows with valid values (retained): {n_kept:,}")

    if not DRY_RUN and n_contaminated > 0:
        c.execute("""
            DELETE FROM nsf_size_breakdowns
            WHERE col_label LIKE 'col_%' AND value > 1000000
        """)
        report("  Rows deleted", c.rowcount)
        db.commit()


# ---------------------------------------------------------------------------
# Fix 5: Normalise sic_code placeholders in nsf_observations
# ---------------------------------------------------------------------------

def fix_sic_code_placeholders(db):
    c = db.cursor()
    print("\n[Fix 5] Normalise sic_code placeholders → empty string")

    # Dot-leader strings (all dots/spaces/ellipses), dashes, known tokens
    PLACEHOLDER_TOKENS = {"na", "(na)", "--", "-", "sic code", ".", ".."}

    # Count: strings with no alphanumeric character at all
    c.execute("SELECT DISTINCT sic_code FROM nsf_observations WHERE sic_code != ''")
    all_codes = [r[0] for r in c.fetchall()]

    def is_placeholder(code: str) -> bool:
        # No digit or letter = dot-leader or pure punctuation
        if not re.search(r"[0-9a-zA-Z]", code):
            return True
        # Known text tokens
        if code.strip().lower() in PLACEHOLDER_TOKENS:
            return True
        return False

    placeholders = [c_ for c_ in all_codes if is_placeholder(c_)]
    print(f"  Distinct placeholder codes identified: {len(placeholders)}")

    # Count affected rows
    c.execute(
        f"SELECT COUNT(*) FROM nsf_observations WHERE sic_code IN ({','.join('?'*len(placeholders))})",
        placeholders,
    )
    n_rows = c.fetchone()[0]
    report("Rows with placeholder sic_code to blank", n_rows)

    if not DRY_RUN and placeholders:
        c.execute(
            f"UPDATE nsf_observations SET sic_code = '' WHERE sic_code IN ({','.join('?'*len(placeholders))})",
            placeholders,
        )
        report("  Rows updated", c.rowcount)
        db.commit()


# ---------------------------------------------------------------------------
# Fix 6: Correct FTE_SCI unit misclassification
# ---------------------------------------------------------------------------

def fix_fte_sci_unit(db):
    c = db.cursor()
    print("\n[Fix 6] Correct FTE_SCI millions_usd → thousands_persons")

    # Sheet id=673: Table A-39 FTE R&D scientists
    c.execute("""
        SELECT id, table_title, unit, unit_norm FROM nsf_source_files
        WHERE series_code = 'FTE_SCI' AND unit_norm = 'millions_usd'
    """)
    rows = c.fetchall()
    print(f"  Sheets affected: {len(rows)}")
    for r in rows:
        print(f"    id={r[0]}: {r[2]} → thousands_persons | {r[3][:60]}")

    if not DRY_RUN and rows:
        c.execute("""
            UPDATE nsf_source_files
            SET unit_norm = 'thousands_persons'
            WHERE series_code = 'FTE_SCI' AND unit_norm = 'millions_usd'
        """)
        report("  Sheets updated", c.rowcount)
        db.commit()


# ---------------------------------------------------------------------------
# Fix 7: Recover null years in nsf_size_breakdowns
# ---------------------------------------------------------------------------

def fix_null_years(db):
    c = db.cursor()
    print("\n[Fix 7] Recover null years in nsf_size_breakdowns")

    # --- Geographic table (sf_id=1096): col_label IS the year ---
    # The table "Geo distrbn total... 74-91.xls" stores years in column headers.
    # Parser set year=NULL because no year in table title; col_label holds e.g. "1975".
    c.execute("""
        SELECT COUNT(*) FROM nsf_size_breakdowns
        WHERE source_file_id = 1096 AND year IS NULL
          AND col_label GLOB '[12][0-9][0-9][0-9]'
    """)
    n_geo_recoverable = c.fetchone()[0]
    report("Geographic table rows (sf_id=1096) with year recoverable from col_label",
           n_geo_recoverable)

    if not DRY_RUN and n_geo_recoverable > 0:
        # Recover year from col_label (bare 4-digit year strings like "1975")
        c.execute("""
            UPDATE nsf_size_breakdowns
            SET year = CAST(col_label AS INTEGER)
            WHERE source_file_id = 1096 AND year IS NULL
              AND col_label GLOB '[12][0-9][0-9][0-9]'
        """)
        report("  Rows updated", c.rowcount)

        # Remaining rows where col_label is not a bare year
        c.execute("""
            SELECT COUNT(*) FROM nsf_size_breakdowns
            WHERE source_file_id = 1096 AND year IS NULL
        """)
        n_remaining = c.fetchone()[0]
        if n_remaining:
            print(f"  Remaining unrecoverable (col_label not a year): {n_remaining:,}")
        db.commit()

    # --- Table 13 (sf_id=109): "Company funds... by industry and size of company: 196x" ---
    # File: nsf_68-02013.xls, 1968 publication. Table title suffix implies single year.
    # Inspect col_labels to find the year.
    c.execute("""
        SELECT DISTINCT col_label FROM nsf_size_breakdowns
        WHERE source_file_id = 109 AND year IS NULL
        LIMIT 10
    """)
    cols = [r[0] for r in c.fetchall()]
    print(f"  Table 13 (sf_id=109) col_labels: {cols}")

    # Extract year from col_labels: look for 4-digit year pattern
    year_col_match = None
    for col in cols:
        m = re.search(r"(19[6-9]\d|20[0-2]\d)", str(col))
        if m:
            year_col_match = int(m.group(1))
            break

    c.execute("SELECT COUNT(*) FROM nsf_size_breakdowns WHERE source_file_id=109 AND year IS NULL")
    n_t13 = c.fetchone()[0]
    print(f"  Table 13 null year rows: {n_t13:,}")

    if year_col_match:
        print(f"  Year inferred from col_label: {year_col_match}")
        if not DRY_RUN and n_t13 > 0:
            c.execute("""
                UPDATE nsf_size_breakdowns
                SET year = ?
                WHERE source_file_id = 109 AND year IS NULL
            """, (year_col_match,))
            report("  Rows updated", c.rowcount)
            db.commit()
    else:
        # Fallback: infer from filename — nsf_68-02013 → 1968 publication
        # But actual survey year for company size data in 1968 publication is typically 1966 or 1967.
        # Read first few col_labels to decide.
        print(f"  No year in col_labels; table title will need manual inspection.")
        print(f"  Leaving year=NULL for sf_id=109 ({n_t13} rows).")


# ---------------------------------------------------------------------------
# Post-fix summary
# ---------------------------------------------------------------------------

def summarise(db):
    c = db.cursor()
    print("\n=== Post-fix summary ===")

    c.execute("SELECT COUNT(*) FROM nsf_observations WHERE value IS NOT NULL AND suppression_flag IS NULL AND value >= 0")
    print(f"  nsf_observations: clean numeric rows = {c.fetchone()[0]:,}")
    c.execute("SELECT COUNT(*) FROM nsf_observations WHERE suppression_flag='SENTINEL'")
    print(f"  nsf_observations: SENTINEL-flagged = {c.fetchone()[0]:,}")
    c.execute("SELECT COUNT(*) FROM nsf_observations WHERE value < 0 AND suppression_flag IS NULL")
    print(f"  nsf_observations: remaining negatives = {c.fetchone()[0]:,}")

    c.execute("SELECT COUNT(*) FROM nsf_size_breakdowns WHERE value IS NOT NULL AND suppression_flag IS NULL AND value >= 0")
    print(f"  nsf_size_breakdowns: clean numeric rows = {c.fetchone()[0]:,}")
    c.execute("SELECT COUNT(*) FROM nsf_size_breakdowns WHERE suppression_flag='SENTINEL'")
    print(f"  nsf_size_breakdowns: SENTINEL-flagged = {c.fetchone()[0]:,}")

    c.execute("SELECT COUNT(*) FROM nsf_size_breakdowns WHERE year IS NULL")
    print(f"  nsf_size_breakdowns: NULL year rows remaining = {c.fetchone()[0]:,}")

    c.execute("""
        SELECT series_code, COUNT(*) FROM nsf_source_files
        WHERE series_code='RD_PCT_SALES' GROUP BY 1
    """)
    r = c.fetchone()
    print(f"  nsf_source_files: RD_PCT_SALES sheets = {r[1] if r else 0}")

    c.execute("SELECT COUNT(*) FROM nsf_observations WHERE sic_code != '' AND NOT EXISTS (SELECT 1 WHERE sic_code GLOB '*[0-9a-zA-Z]*')")
    # Simpler version for SQLite:
    c.execute("SELECT COUNT(*) FROM nsf_observations WHERE sic_code = ''")
    print(f"  nsf_observations: empty sic_code rows = {c.fetchone()[0]:,}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print(f"Database: {DB_PATH}")
    print(f"Mode: {'DRY RUN' if DRY_RUN else 'WRITE'}")

    db = connect()

    fix_percent_series_reclassification(db)
    fix_sentinel_negatives_observations(db)
    fix_sentinel_negatives_size(db)
    fix_col_percent_contamination(db)
    fix_sic_code_placeholders(db)
    fix_fte_sci_unit(db)
    fix_null_years(db)

    summarise(db)
    db.close()
    print("\nDone.")


if __name__ == "__main__":
    main()
