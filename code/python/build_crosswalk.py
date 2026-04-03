"""
build_crosswalk.py
==================
Ingests canonical SIC-1987 and NAICS-2002 reference tables into cyclicality.db,
then builds nsf_industry_crosswalk mapping every industry_name_norm to canonical codes.

Also adds:
  - unit_norm column on nsf_source_files
  - v_size_breakdown helper view with parsed col_label fields

Usage:
    python3 code/python/build_crosswalk.py [--rebuild]
"""

import re
import sqlite3
import csv
import sys
from pathlib import Path

DB_PATH   = Path("data/cyclicality.db")
SIC_CSV   = Path("data/crosswalks/sic_1987.csv")
NAICS_CSV = Path("data/crosswalks/naics_2002.csv")
REBUILD   = "--rebuild" in sys.argv

# ---------------------------------------------------------------------------
# DDL
# ---------------------------------------------------------------------------

DDL = """
CREATE TABLE IF NOT EXISTS sic_codes (
    sic_code    INTEGER PRIMARY KEY,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS naics_codes (
    naics_code  TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    level       INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS nsf_industry_crosswalk (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    industry_name_norm   TEXT NOT NULL UNIQUE REFERENCES nsf_industry_names(industry_name_norm),
    row_type             TEXT NOT NULL,   -- 'industry', 'aggregate', 'size_bracket', 'other'
    code_system          TEXT,            -- 'SIC', 'NAICS', NULL for aggregates/non-industries
    primary_code         TEXT,            -- canonical code for single-industry rows
    code_range           TEXT,            -- raw NSF-published code string (cleaned)
    sic_codes_covered    TEXT,            -- comma-separated 2-digit SIC codes for multi-code groups
    naics_codes_covered  TEXT,            -- comma-separated NAICS codes for multi-code groups
    canonical_name       TEXT,            -- official description from sic_codes/naics_codes
    map_method           TEXT,            -- 'exact', 'parsed', 'manual', 'aggregate', 'non_industry'
    notes                TEXT
);
"""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def normalise(s: str) -> str:
    return re.sub(r"\s+", " ", str(s)).strip().lower()

# SIC-era: common NSF name → canonical 2-digit SIC code(s)
# key = industry_name_norm, value = (primary_code, sic_codes_covered, canonical_name)
MANUAL_SIC: dict[str, tuple] = {
    # Aggregates / non-industry rows
    "total":                            ("", "", "All industries total", "aggregate"),
    "all industries":                   ("", "", "All industries", "aggregate"),
    "manufacturing":                    ("", "20-39", "Manufacturing", "aggregate"),
    "nonmanufacturing":                 ("", "", "Nonmanufacturing", "aggregate"),
    "nonmanufacturing industries":      ("", "", "Nonmanufacturing industries", "aggregate"),
    "other nonmanufacturing industries":("", "", "Other nonmanufacturing industries", "aggregate"),
    "other manufacturing industries":   ("", "27,31,39", "Other manufacturing industries", "aggregate"),
    "other industries":                 ("", "", "Other industries", "aggregate"),
    "industries":                       ("", "", "Industries (aggregate)", "aggregate"),
    "industry":                         ("", "", "Industry (header row)", "other"),
    "all other":                        ("", "", "All other (residual)", "aggregate"),
    "all other manufacturing industries":("","", "All other manufacturing industries", "aggregate"),
    "distribution by industry:":        ("", "", "Distribution by industry (header)", "other"),
    "distribution by industry":         ("", "", "Distribution by industry (header)", "other"),
    "nonmanufacturing ²":               ("", "", "Nonmanufacturing", "aggregate"),
    "nonmanufacturing2,":               ("", "", "Nonmanufacturing", "aggregate"),
    "manufacturing1,":                  ("", "", "Manufacturing", "aggregate"),
    "total (january)":                  ("", "", "Total (January estimate)", "aggregate"),
    "total (annual average)":           ("", "", "Total (annual average)", "aggregate"),
    "total .":                          ("", "", "Total", "aggregate"),
    "all agencies":                     ("", "", "All agencies (Federal)", "aggregate"),
    "other products fields, n.e.c.":    ("", "", "Other product fields, NEC", "aggregate"),
    "all other manufacturing industries .": ("", "", "All other manufacturing industries", "aggregate"),
    "industry and":                     ("", "", "Industry/size (header fragment)", "other"),
    "size of company":                  ("", "", "Size of company (header fragment)", "other"),
    # Size brackets — clearly not industries
    "1,000 to 4,":                      ("", "", "Size bracket 1,000-4,999", "size_bracket"),
    "5,000 to 9,":                      ("", "", "Size bracket 5,000-9,999", "size_bracket"),
    "10,000 to 24,":                    ("", "", "Size bracket 10,000-24,999", "size_bracket"),
    "25,000 or more":                   ("", "", "Size bracket 25,000+", "size_bracket"),
    "fewer than":                       ("", "", "Size bracket <500", "size_bracket"),
    "500 to":                           ("", "", "Size bracket 500-999", "size_bracket"),
    "less than 1,":                     ("", "", "Size bracket <1,000", "size_bracket"),
    "5,000 to":                         ("", "", "Size bracket 5,000+", "size_bracket"),
    "5 to":                             ("", "", "Size bracket 5–24", "size_bracket"),
    "25 to":                            ("", "", "Size bracket 25–49", "size_bracket"),
    "50 to":                            ("", "", "Size bracket 50–99", "size_bracket"),
    "100 to":                           ("", "", "Size bracket 100–249", "size_bracket"),
    "250 to":                           ("", "", "Size bracket 250–499", "size_bracket"),
    "5–":                               ("", "", "Size bracket 5–24", "size_bracket"),
    "25–":                              ("", "", "Size bracket 25–49", "size_bracket"),
    "50–":                              ("", "", "Size bracket 50–99", "size_bracket"),
    "100–":                             ("", "", "Size bracket 100–249", "size_bracket"),
    "250–":                             ("", "", "Size bracket 250–499", "size_bracket"),
    "500–":                             ("", "", "Size bracket 500–999", "size_bracket"),
    "1,000–4,":                         ("", "", "Size bracket 1,000–4,999", "size_bracket"),
    "5,000–9,":                         ("", "", "Size bracket 5,000–9,999", "size_bracket"),
    "10,000–24,":                       ("", "", "Size bracket 10,000–24,999", "size_bracket"),
    "all companies":                    ("", "", "All company sizes (total)", "size_bracket"),
    "small manufacturing companies":    ("", "", "Small manufacturing companies", "size_bracket"),
    "small nonmanufacturing companies": ("", "", "Small nonmanufacturing companies", "size_bracket"),
    # Pollution categories (from nsf_size_breakdowns GEOGRAPHIC_RD / POLLUTION sheets)
    "air":                              ("", "", "Air pollution (category)", "other"),
    "water":                            ("", "", "Water pollution (category)", "other"),
    "solid waste":                      ("", "", "Solid waste pollution (category)", "other"),
    "automotive emission":              ("", "", "Automotive emission (category)", "other"),
    "electric power plant emissions":   ("", "", "Electric power plant emissions (category)", "other"),
}

# NSF name fragments → primary SIC 2-digit code and covered codes
# Applied when direct lookup fails; first match wins.
# (pattern_in_norm, primary_sic, covered_sics, notes)
SIC_PATTERNS: list[tuple] = [
    # Agriculture / mining / construction
    (r"^agriculture|^crop|^livestock",                   "1",  "1,2,7,8,9",   None),
    (r"^forestry",                                       "8",  "8",           None),
    (r"^mining|^metal mining|^coal mining|^oil and gas", "10", "10,11,12,13,14", None),
    (r"^petroleum refining and extraction",              "13", "13,29",       "NSF combined SIC 13+29"),
    (r"^petroleum refining and related",                 "29", "29",          None),
    (r"^petroleum refining$",                            "29", "29",          None),
    (r"^construction",                                   "15", "15,16,17",    None),
    # Food / tobacco
    (r"^food and kindred|^food$",                        "20", "20",          None),
    (r"^food, kindred, and tobacco|^tobacco manufactures|^tobacco products", "20", "20,21", "NSF combined SIC 20+21"),
    (r"^beverage and tobacco",                           "20", "20,21",       None),
    # Textiles / apparel / leather
    (r"^textile mill",                                   "22", "22",          None),
    (r"^apparel$",                                       "23", "23",          None),
    (r"^textiles and apparel$",                          "22", "22,23",       "NSF combined SIC 22+23"),
    (r"^textiles, apparel, and leather",                 "22", "22,23,31",    None),
    (r"^leather",                                        "31", "31",          None),
    # Lumber / wood / furniture
    (r"^lumber, wood products, and furniture",           "24", "24,25",       "NSF combined SIC 24+25"),
    (r"^except furniture",                               "24", "24",          None),
    (r"^wood products",                                  "24", "24",          None),
    (r"^furniture and fixtures",                         "25", "25",          None),
    (r"^furniture and related",                          "25", "25",          None),
    # Paper / printing
    (r"^paper and allied",                               "26", "26",          None),
    (r"^printing, publishing",                           "27", "27",          None),
    (r"^publishing",                                     "27", "27",          None),
    # Chemicals
    (r"^industrial chemicals",                           "28", "281,282,286", None),
    (r"^drugs and medicines",                            "28", "283",         None),
    (r"^other chemicals$",                               "28", "284,285,287,288,289", None),
    (r"^chemicals and allied",                           "28", "28",          None),
    (r"^chemicals$",                                     "28", "28",          None),
    (r"^basic chemicals",                                "28", "281",         None),
    (r"^pharmaceuticals and medicines",                  "28", "283",         None),
    # Petroleum
    (r"^petroleum and coal products",                    "29", "29",          None),
    # Rubber / plastics
    (r"^rubber products",                                "30", "30",          None),
    (r"^plastics and rubber",                            "30", "28,30",       None),
    # Stone / clay / glass
    (r"^stone, clay, and glass",                         "32", "32",          None),
    (r"^nonmetallic mineral",                            "32", "32",          None),
    # Metals
    (r"^ferrous metals",                                 "33", "331,332",     None),
    (r"^nonferrous metals",                              "33", "333,334,335,336", None),
    (r"^primary metals",                                 "33", "33",          None),
    (r"^fabricated metal",                               "34", "34",          None),
    # Machinery
    (r"^office, computing|^accounting machines|^machines$|^computers and peripheral", "35", "357", None),
    (r"^other machinery, except electrical",             "35", "351,352,353,354,355,356,358,359", None),
    (r"^machinery$",                                     "35", "35",          None),
    # Electrical / electronics
    (r"^communication equipment$|^communications equipment$", "36", "366", None),
    (r"^radio and tv",                                   "36", "365",         None),
    (r"^electronic components",                          "36", "367",         None),
    (r"^other electrical equipment",                     "36", "361,362,363,364,369", None),
    (r"^electrical equipment and communication",         "36", "36,48",       "NSF combined SIC 36+48"),
    (r"^electrical equipment, appliances",               "36", "335",         None),  # NAICS-era label
    (r"^electrical equipment$",                          "36", "36",          None),
    (r"^equipment$",                                     "36", "36",          None),
    # Transportation equipment
    (r"^aircraft and missiles",                          "37", "372,376",     None),
    (r"^motor vehicles and motor vehicles|^vehicles equipment|^motor vehicles, trailers", "37", "371", None),
    (r"^motor vehicles and other transportation",        "37", "373,374,375,379", None),
    (r"^motor vehicles and other$",                      "37", "373,374,375,379", None),
    (r"^other transportation equipment",                 "37", "373,374,375,379", "NSF residual SIC 37"),
    (r"^aerospace products",                             "37", "372",         None),
    (r"^transportation equipment$",                      "37", "37",          None),
    (r"^transportation$",                                "37", "37",          None),
    # Instruments
    (r"^scientific and mechanical measuring|^measuring instruments$", "38", "381,382", None),
    (r"^optical, surgical, photographic|^and other instruments|^other instruments", "38", "384,385,386,387", None),
    (r"^professional and scientific instruments|^instruments$", "38", "38",   None),
    (r"^medical equipment",                              "38", "384",         None),
    # Misc manufacturing
    (r"^miscellaneous manufacturing",                    "39", "39",          None),
    (r"^other miscellaneous manufacturing",              "39", "39",          None),
    # Non-manufacturing: Transportation / utilities / communications
    (r"^electric, gas, and sanitary",                    "49", "49",          None),
    (r"^utilities$",                                     "49", "49",          None),
    (r"^telephone communications",                       "48", "481",         None),
    (r"^telecommunications",                             "48", "481",         None),
    (r"^other communications",                           "48", "482,483,484,489", None),
    (r"^communications$",                                "48", "48",          None),
    (r"^transportation and utilities",                   "40", "40,41,42,44,45,46,47,48,49", "NSF combined SIC 40-49"),
    (r"^other transportation and utilities",             "40", "40,41,42,44,45,46,47", None),
    (r"^transportation and warehousing",                 "40", "48,49",       None),
    # Trade
    (r"^trade$",                                         "50", "50,51,52,53,54,55,56,57,58,59", None),
    # Finance / insurance / real estate
    (r"^finance, insurance",                             "60", "60,61,62,63,64,65,67", None),
    # Services
    (r"^business services$|^miscellaneous business services",  "73", "73",    None),
    (r"^other business services",                        "73", "731,732,733,734,735,736,738", None),
    (r"^health services$|^other health services",        "80", "80",          None),
    (r"^health care services",                           "80", "80",          None),
    (r"^professional, scientific, and technical",        "73", "73,87",       None),
    (r"^miscellaneous services|^other services$",        "70", "70,72,75,76,78,79,81,82,83,84,86,88,89", None),
    (r"^services$",                                      "70", "70,72,73,75,76,78,79,80,81,82,83,84,86,87,88,89", None),
    (r"^mining, extraction",                             "10", "10,11,12,13,14", None),
    (r"^other wholesale trade",                          "50", "50,51",        None),
    (r"^other telecommunications",                       "48", "482,483,484,489", None),
    (r"^architectural|^and surveying|^surveying services", "87", "87",         None),
]

# NAICS-era NSF names → NAICS 2002 codes
# (industry_name_norm, primary_naics_code, covered_codes, canonical_name)
MANUAL_NAICS: dict[str, tuple] = {
    # Sector 11
    "agriculture":              ("11",  "11",    "Agriculture, forestry, fishing and hunting"),
    # Sector 21
    "mining":                   ("21",  "21",    "Mining"),
    "mining, extraction, and support activities": ("21", "21", "Mining"),
    # Sector 22
    "utilities":                ("22",  "22",    "Utilities"),
    # Sector 23
    "construction":             ("23",  "23",    "Construction"),
    # Sector 31-33
    "food":                     ("311", "311",   "Food manufacturing"),
    "beverage and tobacco products": ("312", "312", "Beverage and tobacco product manufacturing"),
    "textiles, apparel, and leather": ("313", "313,314,315,316", "Textiles, apparel, leather"),
    "wood products":            ("321", "321",   "Wood product manufacturing"),
    "paper":                    ("322", "322",   "Paper manufacturing"),
    "printing, publishing, and allied industries": ("323", "323", "Printing and related support activities"),
    "publishing":               ("511", "511",   "Publishing industries (except internet)"),
    "petroleum and coal products": ("324", "324", "Petroleum and coal products manufacturing"),
    "chemicals":                ("325", "325",   "Chemical manufacturing"),
    "basic chemicals":          ("3251","3251",  "Basic chemical manufacturing"),
    "pharmaceuticals and medicines": ("3254","3254", "Pharmaceutical and medicine manufacturing"),
    "plastics and rubber products": ("326","326", "Plastics and rubber products manufacturing"),
    "nonmetallic mineral products": ("327","327", "Nonmetallic mineral product manufacturing"),
    "fabricated metal products":("332", "332",   "Fabricated metal product manufacturing"),
    "computer and electronic products": ("334","334","Computer and electronic product manufacturing"),
    "computers and peripheral equipment": ("3341","3341","Computer and peripheral equipment manufacturing"),
    "communications equipment": ("3342","3342",  "Communications equipment manufacturing"),
    "other computer and electronic products": ("334","334 minus (3341,3342,3344,3345)", "Other computer and electronic products"),
    "electrical equipment, appliances, and components": ("335","335","Electrical equipment, appliance, and component manufacturing"),
    "motor vehicles, trailers, and parts": ("3361","3361,3362,3363","Motor vehicle manufacturing"),
    "aerospace products and parts": ("3364","3364","Aerospace product and parts manufacturing"),
    "furniture and related products": ("337","337","Furniture and related product manufacturing"),
    "miscellaneous manufacturing": ("339","339","Miscellaneous manufacturing"),
    "medical equipment and supplies": ("3391","3391","Medical equipment and supplies manufacturing"),
    "other miscellaneous manufacturing": ("339","339 minus (3391)","Other miscellaneous manufacturing"),
    # Sector 42-45 (trade)
    "trade":                    ("42",  "42,44,45","Wholesale and retail trade"),
    # Sector 48-49
    "transportation and warehousing": ("48","48,49","Transportation and warehousing"),
    # Sector 51
    "information":              ("51",  "51",    "Information"),
    "software":                 ("5112","5112",  "Software publishers"),
    "telecommunications":       ("5133","5133",  "Telecommunications"),
    "other information":        ("51",  "51 minus (511,513)","Other information"),
    # Sector 52-53
    "finance, insurance, and real estate": ("52","52,53","Finance, insurance, and real estate"),
    # Sector 54
    "professional, scientific, and technical services": ("54","54","Professional, scientific, and technical services"),
    "scientific r&d services":  ("5417","5417",  "Scientific research and development services"),
    # Sector 61-62
    "health care services":     ("621", "621,622,623","Ambulatory and hospital health care services"),
    # Sector 71-81
    "services":                 ("70",  "71,72,81","Arts, entertainment, recreation, accommodation, and other services"),
    "miscellaneous services":   ("70",  "71,72,81","Miscellaneous services"),
}

NAICS_AGGREGATE = {
    "manufacturing":            ("31",  "31,32,33","Manufacturing (all)"),
    "nonmanufacturing":         ("",    "",         "Nonmanufacturing (all)"),
    "nonmanufacturing industries": ("","",          "Nonmanufacturing industries"),
    "other nonmanufacturing industries": ("","",    "Other nonmanufacturing industries"),
    "other manufacturing industries": ("","",       "Other manufacturing industries"),
    "all industries":           ("",    "",         "All industries"),
    "total":                    ("",    "",         "All industries total"),
    "other":                    ("",    "",         "Other (residual)"),
    "other industries":         ("",    "",         "Other industries (residual)"),
    "all other":                ("",    "",         "All other (residual)"),
    "other services":           ("",    "",         "Other services (residual)"),
}

SIZE_BRACKET_RE = re.compile(
    r"^(\d[\d,\.]*\s*(to|–|-)\s*\d|\d[\d,\.]*\s*–$|\d[\d,\.]*\s*to\s*$"
    r"|fewer than|less than|\d[\d,\.]*\s*or more|under \d|over \d"
    r"|small (manufacturing|nonmanufacturing)|all companies"
    r"|^5\s+(to|–)|^25\s+(to|–)|^50\s+(to|–)|^100\s+(to|–)|^250\s+(to|–)|^500\s+(to|–)"
    r"|\d,\d{3}\s*–$|\d{1,3}–$)", re.I
)

def classify_row(norm: str, sample_sic: str | None, naics_set: set[str] | None = None) -> dict:
    """Return a crosswalk dict for one industry_name_norm."""
    rec = {
        "industry_name_norm":  norm,
        "row_type":            "industry",
        "code_system":         None,
        "primary_code":        None,
        "code_range":          sample_sic.strip() if sample_sic else None,
        "sic_codes_covered":   None,
        "naics_codes_covered": None,
        "canonical_name":      None,
        "map_method":          None,
        "notes":               None,
    }

    # --- Size brackets ---
    if SIZE_BRACKET_RE.match(norm):
        rec["row_type"]   = "size_bracket"
        rec["map_method"] = "non_industry"
        return rec

    # --- Manual SIC override ---
    if norm in MANUAL_SIC:
        val = MANUAL_SIC[norm]
        # val is (primary, covered, canonical_name, row_type)
        rec["row_type"]          = val[3] if len(val) >= 4 else "aggregate"
        rec["code_system"]       = "SIC" if val[0] else None
        rec["primary_code"]      = val[0] or None
        rec["sic_codes_covered"] = val[1] or None
        rec["canonical_name"]    = val[2]
        rec["map_method"]        = "aggregate" if rec["row_type"] == "aggregate" else "non_industry"
        return rec

    # --- NAICS aggregates ---
    if norm in NAICS_AGGREGATE:
        val = NAICS_AGGREGATE[norm]
        rec["row_type"]            = "aggregate"
        rec["code_system"]         = "NAICS" if val[0] else None
        rec["primary_code"]        = val[0] or None
        rec["naics_codes_covered"] = val[1] or None
        rec["canonical_name"]      = val[2]
        rec["map_method"]          = "aggregate"
        return rec

    # --- Detect NAICS era from sample_sic ---
    # Strategy: extract the first multi-digit number from sample_sic and check if it
    # exists verbatim as a code in the NAICS 2002 reference table.
    # This handles "334" (real NAICS code) vs "333–36" (SIC range whose first number 333
    # is NOT a valid NAICS 3-digit code in 2002).
    # Fall back to sector-prefix check for codes not in naics_set.
    NAICS_2DIG = {11,21,22,23,31,32,33,42,44,45,48,49,51,52,53,54,55,56,61,62,71,72,81,92}
    is_naics = False
    if sample_sic:
        sc = sample_sic.strip().rstrip(".")
        m = re.search(r"\d{2,6}", sc)
        if m:
            candidate = m.group()
            # Primary check: is this a real NAICS 2002 code?
            if naics_set and candidate in naics_set:
                is_naics = True
            # Secondary: 4+ digit codes whose first 2 digits are NAICS sectors
            elif len(candidate) >= 4:
                sector = int(candidate[:2])
                if sector in NAICS_2DIG:
                    is_naics = True

    # --- Manual NAICS mapping (explicit entries win over SIC patterns) ---
    if norm in MANUAL_NAICS:
        val = MANUAL_NAICS[norm]
        rec["code_system"]         = "NAICS"
        rec["primary_code"]        = val[0]
        rec["naics_codes_covered"] = val[1]
        rec["canonical_name"]      = val[2]
        rec["map_method"]          = "manual"
        return rec

    # --- SIC pattern matching ---
    # Checked after MANUAL_NAICS so explicit NAICS overrides are respected, but before
    # is_naics auto-detection so known SIC-era names with ambiguous codes are handled correctly.
    for pat, primary, covered, note in SIC_PATTERNS:
        if re.search(pat, norm, re.I):
            rec["code_system"]       = "SIC"
            rec["primary_code"]      = primary
            rec["sic_codes_covered"] = covered
            rec["map_method"]        = "parsed"
            rec["notes"]             = note
            return rec

    # --- NAICS: direct from sample_sic ---
    if is_naics and sample_sic:
        sc = re.sub(r"\s+", "", sample_sic.strip())
        primary = re.search(r"\d+", sc)
        rec["code_system"]         = "NAICS"
        rec["primary_code"]        = primary.group() if primary else None
        rec["naics_codes_covered"] = sc
        rec["map_method"]          = "parsed"
        return rec

    # --- SIC: direct single code from sample_sic ---
    if sample_sic and not is_naics:
        sc = sample_sic.strip().rstrip(".")
        m = re.match(r"^(\d{1,4})", sc)
        if m:
            rec["code_system"]       = "SIC"
            rec["primary_code"]      = m.group(1)
            rec["sic_codes_covered"] = re.sub(r"[^0-9,\-]", "", sc)
            rec["map_method"]        = "parsed"
            return rec

    # --- Fallback: unmatched ---
    rec["map_method"] = "unmatched"
    return rec


# ---------------------------------------------------------------------------
# Unit normalisation map
# ---------------------------------------------------------------------------

UNIT_NORM_MAP: list[tuple[str, str]] = [
    (r"(millions? of dollars?|in millions|dollars? in millions?)",   "millions_usd"),
    (r"thousands? of dollars?|dollars? in thousands?|in thousands?", "thousands_usd"),
    (r"billions? of dollars?",                                       "billions_usd"),
    (r"percent|per\s*cent",                                          "percent"),
    (r"thousands?\s*(of\s*)?persons?|thousands?\s*(of\s*)?employees?|thousands?\s*(of\s*)?workers?",
                                                                      "thousands_persons"),
    (r"number|count",                                                "count"),
    (r"dollars? per|per\s*\$",                                       "usd_per_unit"),
    (r"ratio",                                                       "ratio"),
]

def normalise_unit(unit_str: str | None) -> str | None:
    if not unit_str:
        return None
    s = unit_str.lower().strip()
    for pat, norm in UNIT_NORM_MAP:
        if re.search(pat, s, re.I):
            return norm
    return "other"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    db = sqlite3.connect(DB_PATH)
    db.row_factory = sqlite3.Row
    c = db.cursor()

    if REBUILD:
        for t in ["nsf_industry_crosswalk", "naics_codes", "sic_codes"]:
            c.execute(f"DROP TABLE IF EXISTS {t}")
        c.execute("DROP VIEW IF EXISTS v_size_breakdown")
        db.commit()
        print("Dropped existing crosswalk tables and views.")

    c.executescript(DDL)
    db.commit()

    # --- Ingest SIC reference ---
    c.execute("SELECT COUNT(*) FROM sic_codes")
    if c.fetchone()[0] == 0:
        with open(SIC_CSV, newline="") as f:
            reader = csv.DictReader(f)
            rows = [(int(r["sic_code"]), r["description"]) for r in reader]
        c.executemany("INSERT OR IGNORE INTO sic_codes VALUES (?,?)", rows)
        db.commit()
        print(f"Ingested {len(rows)} SIC codes.")
    else:
        print("SIC codes already present, skipping.")

    # --- Ingest NAICS reference ---
    c.execute("SELECT COUNT(*) FROM naics_codes")
    if c.fetchone()[0] == 0:
        with open(NAICS_CSV, newline="") as f:
            reader = csv.DictReader(f)
            rows = [(r["naics_code"], r["description"], int(r["level"])) for r in reader]
        c.executemany("INSERT OR IGNORE INTO naics_codes VALUES (?,?,?)", rows)
        db.commit()
        print(f"Ingested {len(rows)} NAICS codes.")
    else:
        print("NAICS codes already present, skipping.")

    # --- Build crosswalk ---
    c.execute("SELECT COUNT(*) FROM nsf_industry_crosswalk")
    if c.fetchone()[0] > 0 and not REBUILD:
        print("Crosswalk already populated. Use --rebuild to regenerate.")
    else:
        c.execute("""
            SELECT n.industry_name_norm, n.n_occurrences,
                   (SELECT o.sic_code FROM nsf_observations o
                    WHERE o.industry_name_norm = n.industry_name_norm
                      AND o.sic_code != '' LIMIT 1) as sample_sic
            FROM nsf_industry_names n
        """)
        names = c.fetchall()

        # Build NAICS lookup set
        c.execute("SELECT naics_code FROM naics_codes")
        naics_set = {r[0] for r in c.fetchall()}

        records = []
        for row in names:
            rec = classify_row(row["industry_name_norm"], row["sample_sic"], naics_set)
            records.append(rec)

        c.executemany("""
            INSERT OR REPLACE INTO nsf_industry_crosswalk
              (industry_name_norm, row_type, code_system, primary_code,
               code_range, sic_codes_covered, naics_codes_covered,
               canonical_name, map_method, notes)
            VALUES
              (:industry_name_norm, :row_type, :code_system, :primary_code,
               :code_range, :sic_codes_covered, :naics_codes_covered,
               :canonical_name, :map_method, :notes)
        """, records)
        db.commit()

        # Report
        from collections import Counter
        counts = Counter(r["map_method"] for r in records)
        print(f"\nCrosswalk built: {len(records)} rows")
        for k, v in sorted(counts.items()):
            print(f"  {k:15s}: {v}")

        unmatched = [r["industry_name_norm"] for r in records if r["map_method"] == "unmatched"]
        if unmatched:
            print(f"\nUnmatched ({len(unmatched)}):")
            for u in unmatched:
                print(f"  {u}")

    # --- Add unit_norm to nsf_source_files ---
    cols = [row[1] for row in c.execute("PRAGMA table_info(nsf_source_files)").fetchall()]
    if "unit_norm" not in cols:
        c.execute("ALTER TABLE nsf_source_files ADD COLUMN unit_norm TEXT")
        db.commit()
        c.execute("SELECT id, unit FROM nsf_source_files")
        updates = [(normalise_unit(r["unit"]), r["id"]) for r in c.fetchall()]
        c.executemany("UPDATE nsf_source_files SET unit_norm=? WHERE id=?", updates)
        db.commit()
        from collections import Counter
        dist = Counter(u[0] for u in updates)
        print(f"\nunit_norm column added and populated ({len(updates)} rows):")
        for k, v in sorted(dist.items(), key=lambda x: (x[0] is None, x[0])):
            print(f"  {str(k):20s}: {v}")
    else:
        print("\nunit_norm already present.")

    # --- v_size_breakdown view ---
    c.execute("DROP VIEW IF EXISTS v_size_breakdown")
    c.execute("""
CREATE VIEW v_size_breakdown AS
SELECT
    sb.*,
    -- Extract survey year when col_label starts with a 4-digit year (19xx or 20xx followed by space or end)
    CASE
        WHEN SUBSTR(col_label,1,2) IN ('19','20')
         AND TYPEOF(CAST(SUBSTR(col_label,1,4) AS INTEGER)) = 'integer'
         AND (LENGTH(col_label) = 4 OR SUBSTR(col_label,5,1) = ' ')
        THEN CAST(SUBSTR(col_label,1,4) AS INTEGER)
        ELSE sb.year
    END AS year_from_col,
    -- Strip leading "YYYY — " prefix to get the size/type label
    CASE
        WHEN SUBSTR(col_label,1,2) IN ('19','20')
         AND (LENGTH(col_label) = 4 OR SUBSTR(col_label,5,1) = ' ')
         AND INSTR(col_label,' — ') > 0
        THEN TRIM(SUBSTR(col_label, INSTR(col_label,' — ') + 3))
        ELSE col_label
    END AS col_label_clean,
    -- Classify col_label into semantic category using INSTR/LIKE (no REGEXP)
    CASE
        WHEN INSTR(LOWER(col_label),'less than') > 0
          OR INSTR(LOWER(col_label),'fewer than') > 0
          OR INSTR(LOWER(col_label),' to ') > 0
          OR INSTR(LOWER(col_label),'or more') > 0
          OR INSTR(LOWER(col_label),'employment of') > 0
          OR INSTR(LOWER(col_label),'total employ') > 0
        THEN 'size_bracket'
        WHEN INSTR(LOWER(col_label),'current $') > 0
          OR INSTR(LOWER(col_label),'constant $') > 0
          OR INSTR(LOWER(col_label),'current dollar') > 0
          OR INSTR(LOWER(col_label),'constant dollar') > 0
        THEN 'price_basis'
        WHEN INSTR(LOWER(col_label),'basic research') > 0
          OR INSTR(LOWER(col_label),'applied research') > 0
          OR INSTR(LOWER(col_label),'development') > 0
        THEN 'rd_type'
        WHEN INSTR(LOWER(col_label),'federal') > 0
          OR INSTR(LOWER(col_label),'company') > 0
          OR INSTR(LOWER(col_label),'fund') > 0
        THEN 'fund_source'
        WHEN INSTR(LOWER(col_label),'total') > 0
          OR INSTR(LOWER(col_label),'all companies') > 0
          OR INSTR(LOWER(col_label),'all sizes') > 0
        THEN 'total'
        ELSE 'other'
    END AS col_category
FROM nsf_size_breakdowns sb;
""")
    db.commit()
    print("\nv_size_breakdown view created.")

    # --- v_unit_norm convenience view on nsf_observations ---
    c.execute("DROP VIEW IF EXISTS v_observations")
    c.execute("""
CREATE VIEW v_observations AS
SELECT o.*, sf.unit_norm
FROM nsf_observations o
JOIN nsf_source_files sf ON sf.id = o.source_file_id;
""")
    db.commit()
    print("v_observations view created.")

    db.close()
    print("\nDone.")


if __name__ == "__main__":
    main()
