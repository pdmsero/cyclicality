# Data Sources Reference

This document inventories repository data assets and records verifiable structure, coverage, and provenance signals based on direct file/header inspection.

## data

**Location**
data/BASELINE_ACCEPTANCE_REPORT.md, data/BASELINE_SNAPSHOT.md, data/DATA_PROVENANCE_MAP.md, data/MAPPING_INTEGRITY_REPORT.md, data/PARITY_CHECKPOINTS.md, data/PARITY_PROGRESS.md, data/PARITY_VARIABLE_CHECKS.md, data/TRANSFORMATION_COVERAGE_AUDIT.md, data/TRANSFORMATION_STAGE1_PARITY.md, data/TRANSFORMATION_STAGE1_REPORT.md, data/TRANSFORMATION_STAGE2_PARITY.md, data/TRANSFORMATION_STAGE2_REPORT.md, data/TRANSFORMATION_STAGE3_PARITY.md, data/TRANSFORMATION_STAGE3_REPORT.md, data/cyclicality.db, data/literature.db, data/literature.json

**Source**
US National Science Foundation (NSF)

**Description**
14 .md file(s) 2 sqlite/db file(s); sample tables from `data/cyclicality.db`: instrument_bea, instrument_bea_deflators_gdp, instrument_bea_gdp, instrument_exports, instrument_klems_all_klems, instrument_klems_klems, instrument_klems_klems_comp, instrument_klems_klems_energy, instrument_klems_klems_energy_deflator, instrument_klems_klems_go 1 .json file(s); sample keys from `data/literature.json`: zotero_collection, pdf_folder, description; records=unknown

**Coverage**
- Time: Not explicit in filenames; verify in source metadata/content.
- Geography: Not explicit in inspected headers/keys.
- Unit of observation: Not explicit from inspected headers/keys.

**Caveats**
No additional source-specific caveat identified beyond cross-cutting caveats.


## data/compustat

**Location**
data/compustat/AllCompustat.dta, data/compustat/sic5809.dta

**Source**
Not explicitly identifiable from local file metadata; verify against project ingestion notes/scripts.

**Description**
2 .dta analytical binary file(s)

**Coverage**
- Time: Not explicit in filenames; verify in source metadata/content.
- Geography: Not explicit in inspected headers/keys.
- Unit of observation: Not explicit from inspected headers/keys.

**Caveats**
Provider/publication is not explicit in local metadata for this source group; verify provenance from ingestion scripts/notes before citation. Binary analytical formats are present; variable labels and full schema should be validated with native tooling before analysis changes. Limited header-level field verification was possible from inspectable text/metadata.


## data/industry

**Location**
data/industry/Section1All_xls.xlsx, data/industry/bea/BEA_All_Ind.csv, data/industry/bea/BEA_All_Ind_Prices.csv, data/industry/bea/BEA_GDP_Detail.csv, data/industry/bea/BEA_GDP_Detail_clean.csv, data/industry/bea/BEA_GDP_Prices_Detail.csv, data/industry/bea/BEA_GDP_Prices_Detail_clean.csv, data/industry/bea/BEA_ValueAdded.dta, data/industry/bea/BEA_ValueAdded_RawFile.dta, data/industry/nber/NBER_EXPORTS.dta, data/industry/nber/NBER_EXPORTS_RawFile.dta, data/industry/nber/NBER_MP_NAICS.dta, data/industry/nber/NBER_MP_SIC.dta, data/industry/nsf_raw/index_1/historical_tablesh-25.xls, data/industry/nsf_raw/index_1/nsf_01-305a-3.xls, data/industry/nsf_raw/index_1/nsf_02-312a-3.xls, data/industry/nsf_raw/index_1/nsf_03-318a-3.xls, data/industry/nsf_raw/index_1/nsf_05-305a-3.xls, data/industry/nsf_raw/index_1/nsf_06-3223.xls, data/industry/nsf_raw/index_1/nsf_06-3224.xls, data/industry/nsf_raw/index_1/nsf_07-3143.xls, data/industry/nsf_raw/index_1/nsf_07-3144.xls, data/industry/nsf_raw/index_1/nsf_09-3013.xls, data/industry/nsf_raw/index_1/nsf_09-3014.xls, data/industry/nsf_raw/index_1/nsf_10-3192.xls, data/industry/nsf_raw/index_1/nsf_20063.xls, data/industry/nsf_raw/index_1/nsf_200732.xls, data/industry/nsf_raw/index_1/nsf_56-16a-1.xls, data/industry/nsf_raw/index_1/nsf_71-018b-2.xls, data/industry/nsf_raw/index_1/nsf_83-325b-2.xls, data/industry/nsf_raw/index_1/nsf_95-324a-3.xls, data/industry/nsf_raw/index_1/nsf_96-304a-3.xls, data/industry/nsf_raw/index_1/nsf_97-331a-3.xls, data/industry/nsf_raw/index_1/nsf_99-312a-3.xls, data/industry/nsf_raw/index_1/nsf_99-312a-3a.xls, ... (1039 more files)

**Source**
US Bureau of Economic Analysis (BEA); National Bureau of Economic Research (NBER); US National Science Foundation (NSF)

**Description**
1061 spreadsheet file(s); sample sheets from `data/industry/nsf_raw/index_1/historical_tablesh-25.xls`: sheet names unavailable 6 .csv file(s); sample schema from `data/industry/bea/BEA_All_Ind.csv`: 1, All industries, 15393.6, 16217.0, 17273.4, 18625.7, 18884.5, 19173.8, 20140.7, 21689.1, 23517.9, 24925.5; rows=905 6 .dta analytical binary file(s) 1 spreadsheet file(s); sample sheets from `data/industry/Section1All_xls.xlsx`: Contents, T10101-A, T10101-Q, T10102-A, T10102-Q, T10103-A, T10103-Q, T10104-A

**Coverage**
- Time: Filename years observed: 1984 to 2007
- Geography: Not explicit in inspected headers/keys.
- Unit of observation: Not explicit from inspected headers/keys.

**Caveats**
Binary analytical formats are present; variable labels and full schema should be validated with native tooling before analysis changes.


## data/instruments

**Location**
data/instruments/BEA.csv, data/instruments/BEA_Deflators_GDP.xls, data/instruments/BEA_GDP.xls, data/instruments/InputOutputCode.do, data/instruments/ValueAddedInstrument.mat, data/instruments/exports/Exports72.csv, data/instruments/exports/Exports72.dta, data/instruments/exports/Exports73.csv, data/instruments/exports/Exports73.dta, data/instruments/exports/Exports74.csv, data/instruments/exports/Exports74.dta, data/instruments/exports/Exports75.csv, data/instruments/exports/Exports75.dta, data/instruments/exports/Exports76.csv, data/instruments/exports/Exports76.dta, data/instruments/exports/Exports77.csv, data/instruments/exports/Exports77.dta, data/instruments/exports/Exports78.csv, data/instruments/exports/Exports78.dta, data/instruments/exports/Exports79.csv, data/instruments/exports/Exports79.dta, data/instruments/exports/Exports80.csv, data/instruments/exports/Exports80.dta, data/instruments/exports/Exports81.csv, data/instruments/exports/Exports81.dta, data/instruments/exports/Exports82.csv, data/instruments/exports/Exports82.dta, data/instruments/exports/Exports83.csv, data/instruments/exports/Exports83.dta, data/instruments/exports/Exports84.csv, data/instruments/exports/Exports84.dta, data/instruments/exports/Exports85.csv, data/instruments/exports/Exports85.dta, data/instruments/exports/Exports86.csv, data/instruments/exports/Exports86.dta, ... (67 more files)

**Source**
US Bureau of Economic Analysis (BEA)

**Description**
40 .dta analytical binary file(s) 24 .csv file(s); sample schema from `data/instruments/BEA.csv`: code, year, VA, PVA, c, rVA; rows=1122 17 .zip file(s) 17 [no_ext] file(s) 2 spreadsheet file(s); sample sheets from `data/instruments/BEA_Deflators_GDP.xls`: sheet names unavailable 1 .do file(s) 1 .mat file(s)

**Coverage**
- Time: Not explicit in filenames; verify in source metadata/content.
- Geography: Not explicit in inspected headers/keys.
- Unit of observation: Time-indexed observations appear present.

**Caveats**
Binary analytical formats are present; variable labels and full schema should be validated with native tooling before analysis changes.


## data/processed

**Location**
data/processed/1939-2011_solowresidual.dta, data/processed/1960-2002_estimatesolowresidual.dta, data/processed/AllData.dta, data/processed/BondYields.dta, data/processed/Country_RD_GDP_Clean.csv, data/processed/Exports.dta, data/processed/GDPData.dta, data/processed/GDPData_RawFile.dta, data/processed/SIC.manufacturing.2digit.dta, data/processed/SIC.manufacturing.3digit.dta, data/processed/SIC.manufacturing.4digit.dta, data/processed/SocialSecurityWageData.dta, data/processed/StockMarketData.dta, data/processed/[1]_RND_Industry_data_final.dta, data/processed/[2]_final_data_compustat_NBER.dta, data/processed/[3]_BEA_ Value_Added.dta, data/processed/[3]_compustat_BEA_3digits.dta, data/processed/[4]_compustat_BEA_2digits.dta, data/processed/[5]_data_financial_constraints.dta, data/processed/all_data.dta, data/processed/averagewage.dta, data/processed/bea_naics_three_digit.dta, data/processed/bea_naics_two_digit.dta, data/processed/codes_naics_sic.dta, data/processed/compustat.dta, data/processed/deflator.dta, data/processed/hib.dta, data/processed/industrysales.dta, data/processed/naics_to_sic.dta, data/processed/nberces5818v1_n2012.csv, data/processed/nberces5818v1_n2012.dta, data/processed/obsdistribution.dta, data/processed/outputdata.dta, data/processed/outputdatawithrnd.dta, data/processed/sic5805.dta, ... (3 more files)

**Source**
US Bureau of Economic Analysis (BEA); National Bureau of Economic Research (NBER); Office for National Statistics (ONS)

**Description**
36 .dta analytical binary file(s) 2 .csv file(s); sample schema from `data/processed/Country_RD_GDP_Clean.csv`: year, GDP_nominal, GDP_deflator, GDP_real, R&D_nominal, R&D_deflator, R&D_real, d_gdp, d_rd; rows=96

**Coverage**
- Time: Filename date ranges include: 1939-2011, 1960-2002
- Geography: Not explicit in inspected headers/keys.
- Unit of observation: Time-indexed observations appear present.

**Caveats**
Binary analytical formats are present; variable labels and full schema should be validated with native tooling before analysis changes.


## Cross-Cutting Caveats

- Source attribution can be incomplete when provider/publication metadata is absent from local files; confirm against acquisition logs, scripts, or citations before publication use.
- Coverage summaries rely on inspected headers, sheet names, keys, and filename date patterns; validate against canonical source documentation for final claims.
- Mixed file formats and vintages can introduce schema drift and crosswalk inconsistencies; validate joins and harmonization assumptions before pooled analysis.
- Descriptive and predictive associations in these datasets do not establish causal effects without explicit identification design.

