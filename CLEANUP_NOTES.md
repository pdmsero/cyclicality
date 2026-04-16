# Cleanup notes

Tracks known structural issues that were either deferred or require a decision
before action. Created April 2026 as part of a structural review of the project.

---

## Deferred — requires a decision

~~### 1. Two diverged `.bib` files~~ → **Resolved April 2026** (see below)

---

~~### 2. Markdown reports in `data/`~~ → **Resolved April 2026** (see below)

---

~~### 3. `data/processed/` naming~~ → **Resolved April 2026** (see below)

---

## Potential future deletion (safe only after Python validation)

### 4. `archive/r_project/`

Archived April 2026. Contains the accidentally committed `code/r/cyclicality/`
subproject (a full duplicate Windows R project with NSF raw data) and a single
NSF XLS file that was committed under its Windows absolute path as a filename.

**Safe to delete once:** Python pipeline has been confirmed to reproduce all
analytical content that the R scripts contributed (NSF extraction and BEA GDP
processing). NSF raw data is already available at `data/industry/nsf_raw/`.

---

### 5. `data.dvc` — **keep, DVC integration planned**

Initialised but not yet populated (`nfiles: 0, size: 0`). DVC integration is
intended for tracking large data files in future. No pipeline scripts depend on
it yet.

**Next step:** When ready, populate by running `dvc add data/` and configure a
remote (e.g. S3 or Google Drive) via `dvc remote add`.

---

### 6. `data/literature.db` and `data/literature.json`

Empty scaffolding for a planned literature-review tool (0 papers, 0 analysis
runs). `literature.json` points to a `../references` folder that does not exist.

**Safe to delete once:** Decision made that the literature review tool will not
be built, or alternatively, once the tool is properly set up.

---

### 7. `data/stata_baseline/` (full directory)

665 MB of Stata baseline `.dta` files. Currently needed for parity checks.

**Safe to archive/delete once:** Python pipeline validation is complete and all
target paper outputs have been reproduced with sufficient accuracy. At that point
these files can move to cold storage or a separate archive repo.

---

### 8. `archive/r_project/` and `archive/stata/`

All R scripts (`Extract NSF Data.R`, `GDP_R.R`) and Stata scripts (`AllData.do`,
`[1–5]_*.do`, `supporting/`) archived April 2026. Safe to delete once Python
pipeline validation is complete.

---

## Already resolved (April 2026)

- `code/r/` Windows path artefacts and nested `cyclicality/` subproject → archived to `archive/r_project/`
- `code/r/` R scripts → archived to `archive/r_project/`
- `code/stata/` Stata scripts → archived to `archive/stata/`
- `data/instruments/InputOutputCode.do` → moved to `code/stata/supporting/` (then archived with Stata scripts)
- README.md updated to reflect current project state
- WAL file checkpointed to zero
- `data/processed/README.md` written explaining Stata baseline role
- `data/README.md` written explaining generated reports
- `requirements.txt` created
- `.env.example` created
- Two diverged `.bib` files resolved: `references.bib` (root) is now canonical (1,351 lines, same 86 keys, richer metadata); `paper/research.bib` replaced with a symlink to `../references.bib`. `MainText.tex` continues to compile unchanged (`\bibliography{research}`).
- Markdown reports relocated: all 15 pipeline-generated `.md` files moved from `data/` to `docs/reports/`; output path constants updated in scripts 10–12 and 20–27; zero stale `data/` references remain.
- `data/processed/` renamed to `data/stata_baseline/` to clarify it contains Stata outputs rather than Python pipeline products, and updated path constants across `01_convert_to_sqlite.py` and `08_refresh_macro_data.py`.
