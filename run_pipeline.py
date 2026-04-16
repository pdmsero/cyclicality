#!/usr/bin/env python3
"""
run_pipeline.py
===============
Single entry point for the full cyclicality replication pipeline.

Usage
-----
    python3 run_pipeline.py                # run everything
    python3 run_pipeline.py --from 30      # start from analysis stage
    python3 run_pipeline.py --only 30 31   # run specific scripts
    python3 run_pipeline.py --list         # print the pipeline and exit

Stages
------
  01–09  Ingestion     — load raw data sources into cyclicality.db
  10–13  Transform     — build processed_alldata_stage1 through stage4
  20–27  Parity        — validate transforms against Stata baseline
  30–36  Analysis      — run all regressions, write results/
  40     Model Sim     — simulate R&D quality-ladder model, reproduce Table 4
  41     IV Extension  — extend IO shift-share instrument to 2014–2024

Notes
-----
  Scripts 01–09 (ingestion) hit external sources (BEA, BLS, WRDS) and
  require network access or licensed data files. They are SKIPPED by
  default when --from is not set, since the database already exists.
  Pass --include-ingestion to run them.

  acf_estimator.py is a helper module imported by 13_transform_stage4.py;
  it is not run directly.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import time
from pathlib import Path

PYTHON = sys.executable
ROOT   = Path(__file__).resolve().parent
CODE   = ROOT / "code" / "python"

# ---------------------------------------------------------------------------
# Pipeline definition
# ---------------------------------------------------------------------------

PIPELINE: list[tuple[int, str, str]] = [
    # (number, filename, description)
    # ── Ingestion ──────────────────────────────────────────────────────────
    ( 1, "01_convert_to_sqlite.py",       "Convert raw sources to SQLite"),
    ( 2, "02_ingest_archive.py",          "Ingest archive / historical data"),
    ( 3, "03_ingest_nsf.py",              "Ingest NSF R&D data"),
    ( 4, "04_ingest_io_tables.py",        "Ingest BEA input-output tables"),
    ( 5, "05_fetch_bls_wages.py",         "Fetch BLS QCEW wage data"),
    ( 6, "06_build_crosswalk.py",         "Build SIC/NAICS crosswalk"),
    ( 7, "07_fix_data_quality.py",        "Fix data quality issues"),
    ( 8, "08_refresh_macro_data.py",      "Refresh BEA/FRED macro series"),
    ( 9, "09_verify_ingestion.py",        "Verify ingestion completeness"),
    # ── Transform ──────────────────────────────────────────────────────────
    (10, "10_transform_stage1.py",        "Transform stage 1 — deflate & clean"),
    (11, "11_transform_stage2.py",        "Transform stage 2 — growth rates"),
    (12, "12_transform_stage3.py",        "Transform stage 3 — panel vars"),
    (13, "13_transform_stage4.py",        "Transform stage 4 — GMM / TFP"),
    # ── Parity & Validation ────────────────────────────────────────────────
    (20, "20_parity_stage1.py",           "Parity check — stage 1"),
    (21, "21_parity_stage2.py",           "Parity check — stage 2"),
    (22, "22_parity_stage3.py",           "Parity check — stage 3"),
    (23, "23_parity_checkpoints.py",      "Parity — merge checkpoints"),
    (24, "24_parity_variable_checks.py",  "Parity — variable-level checks"),
    (25, "25_audit_coverage.py",          "Audit transformation coverage"),
    (26, "26_generate_mapping_report.py", "Generate mapping integrity report"),
    (27, "27_generate_baseline_report.py","Generate baseline acceptance report"),
    # ── Analysis ───────────────────────────────────────────────────────────
    (30, "30_analyse_alldata_regressions.py", "AllData FE regressions (Tables 9 & 10)"),
    (31, "31_analyse_alldata_iv.py",           "AllData IV regressions"),
    (32, "32_analyse_compustat_nber.py",       "Compustat × NBER analysis"),
    (33, "33_analyse_compustat_bea_3digit.py", "Compustat × BEA 3-digit"),
    (34, "34_analyse_compustat_bea_2digit.py", "Compustat × BEA 2-digit"),
    (35, "35_analyse_rnd_industry.py",         "R&D industry analysis"),
    (36, "36_analyse_financial_constraints.py","Financial constraints analysis"),
    # ── Model Simulation ──────────────────────────────────────────────────
    (40, "40_simulate_model.py",              "Simulate R&D quality-ladder model (Table 4)"),
    # ── IV Extension ─────────────────────────────────────────────────────────
    (41, "41_build_io_instrument.py",         "Extend IO shift-share instrument to 2014–2024"),
]

INGESTION_NUMBERS = set(range(1, 10))


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _print_pipeline() -> None:
    groups = [
        ("Ingestion  (01–09)", range(1, 10)),
        ("Transform  (10–13)", range(10, 14)),
        ("Parity     (20–27)", range(20, 28)),
        ("Analysis   (30–36)", range(30, 37)),
        ("Model Sim  (40)",    range(40, 41)),
        ("IV Ext     (41)",    range(41, 42)),
    ]
    for group_label, nums in groups:
        print(f"\n  {group_label}")
        for n, fname, desc in PIPELINE:
            if n in nums:
                print(f"    {n:>2}  {fname:<42}  {desc}")


def _run(n: int, fname: str, desc: str) -> bool:
    """Run one script. Returns True on success."""
    script = CODE / fname
    if not script.exists():
        print(f"  [{n:>2}] MISSING  {fname}")
        return False

    print(f"\n  [{n:>2}] {desc}")
    print(f"        {fname}")
    t0 = time.time()

    result = subprocess.run(
        [PYTHON, str(script)],
        cwd=str(CODE),
    )

    elapsed = time.time() - t0
    if result.returncode == 0:
        print(f"        OK  ({elapsed:.1f}s)")
        return True
    else:
        print(f"        FAILED (exit {result.returncode}, {elapsed:.1f}s)")
        return False


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run the cyclicality replication pipeline.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--list",  action="store_true",
                        help="Print pipeline and exit")
    parser.add_argument("--from",  dest="from_n", type=int, default=None,
                        metavar="N",
                        help="Start from script number N (inclusive)")
    parser.add_argument("--only",  dest="only",   type=int, nargs="+",
                        metavar="N",
                        help="Run only these script numbers")
    parser.add_argument("--include-ingestion", action="store_true",
                        help="Include ingestion scripts (01–09) when running all")
    args = parser.parse_args()

    if args.list:
        print("\nCyclicality Replication Pipeline")
        _print_pipeline()
        print()
        return

    # Determine which scripts to run
    if args.only:
        to_run = [s for s in PIPELINE if s[0] in set(args.only)]
    elif args.from_n is not None:
        to_run = [s for s in PIPELINE if s[0] >= args.from_n]
    else:
        to_run = [s for s in PIPELINE
                  if args.include_ingestion or s[0] not in INGESTION_NUMBERS]

    if not to_run:
        print("Nothing to run.")
        return

    print("\nCyclicality Replication Pipeline")
    print(f"Python: {PYTHON}")
    print(f"Scripts to run: {[s[0] for s in to_run]}")
    if not args.include_ingestion and args.from_n is None and not args.only:
        print("(Ingestion scripts 01–09 skipped — pass --include-ingestion to run them)")

    failures: list[tuple[int, str]] = []
    t_total = time.time()

    for n, fname, desc in to_run:
        ok = _run(n, fname, desc)
        if not ok:
            failures.append((n, fname))

    elapsed_total = time.time() - t_total
    print(f"\n{'─' * 60}")
    print(f"Completed in {elapsed_total:.1f}s")

    if failures:
        print(f"FAILED ({len(failures)}):")
        for n, fname in failures:
            print(f"  [{n:>2}] {fname}")
        sys.exit(1)
    else:
        print(f"All {len(to_run)} scripts passed.")


if __name__ == "__main__":
    main()
