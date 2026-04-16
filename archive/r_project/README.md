# archive/r_project

Archived April 2026 during project cleanup. Do not delete without review.

## Contents

### cyclicality_subproject/
A complete duplicate of an older Windows R project that was accidentally committed
to `code/r/cyclicality/`. Contains its own LICENSE, README, Rproj, and a copy of
the NSF raw data directory tree (indexed XLS files accessed by the R extraction
scripts). The R functionality has been superseded by the Python pipeline.

### nsf_raw_windows_path
An XLS file (NSF historical R&D table 25) that was committed under its original
Windows absolute path as the filename:
  `G:\My Drive\Work\...\NSF\32.xls`
On Linux this became a single file with backslashes in its name. Content is the
same NSF raw data already ingested via `code/python/03_ingest_nsf.py`.

## Potential future deletion
Both items are safe to delete once:
- The Python pipeline has been confirmed to reproduce all results that the original
  R scripts contributed (primarily NSF extraction and BEA GDP processing).
- The NSF raw data is confirmed to exist in a clean location (data/industry/nsf_raw/).
