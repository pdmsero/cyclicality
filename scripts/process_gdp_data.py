# process_gdp_data.py
# Script to process GDP macroeconomic data for the Cyclicality of R&D at the Firm Level project
# Data source: U.S. Bureau of Economic Analysis (BEA) National Income and Product Accounts (NIPA)
# https://www.bea.gov/data/gdp/gross-domestic-product

# Data Source Information
#
# Nominal Values:
#   Table 1.5.5. Gross Domestic Product, Expanded Detail
#   [Billions of dollars]
#   [Last Revised: June 26, 2025 – Next Release: July 30, 2025]
#   https://apps.bea.gov/iTable/?reqid=19&step=2&isuri=1&categories=survey&_gl=1*kfq9yj*_ga*MzgzNzk3NjcyLjE3NTE0MTI1ODA.*_ga_J4698JNNFT*czE3NTE0MTI1ODAkbzEkZzEkdDE3NTE0MTI1OTQkajQ2JGwwJGgw#eyJhcHBpZCI6MTksInN0ZXBzIjpbMSwyLDMsM10sImRhdGEiOltbImNhdGVnb3JpZXMiLCJTdXJ2ZXkiXSxbIk5JUEFfVGFibGVfTGlzdCIsIjM1Il0sWyJGaXJzdF9ZZWFyIiwiMjAyMyJdLFsiTGFzdF9ZZWFyIiwiMjAyNSJdLFsiU2NhbGUiLCItOSJdLFsiU2VyaWVzIiwiQSJdLFsiU2VsZWN0X2FsbF95ZWFycyIsIjEiXV19
#
# Price Indices:
#   Table 1.5.4. Price Indexes for Gross Domestic Product, Expanded Detail
#   [Index numbers, 2017=100]
#   [Last Revised: June 26, 2025 – Next Release: July 30, 2025]
#   https://apps.bea.gov/iTable/?reqid=19&step=2&isuri=1&categories=survey&_gl=1*kfq9yj*_ga*MzgzNzk3NjcyLjE3NTE0MTI1ODA.*_ga_J4698JNNFT*czE3NTE0MTI1ODAkbzEkZzEkdDE3NTE0MTI1OTQkajQ2JGwwJGgw#eyJhcHBpZCI6MTksInN0ZXBzIjpbMSwyLDMsM10sImRhdGEiOltbImNhdGVnb3JpZXMiLCJTdXJ2ZXkiXSxbIk5JUEFfVGFibGVfTGlzdCIsIjM1Il0sWyJGaXJzdF9ZZWFyIiwiMjAyMyJdLFsiTGFzdF9ZZWFyIiwiMjAyNSJdLFsiU2NhbGUiLCItOSJdLFsiU2VyaWVzIiwiQSJdLFsiU2VsZWN0X2FsbF95ZWFycyIsIjEiXV19
#
# These are the authoritative sources for all macroeconomic series processed in this script.

import pandas as pd
import numpy as np
import os

# UPDATE THIS PATH to match your Google Drive letter (e.g., G:) if needed
DATA_DIR = r"G:\My Drive\Work\Research\Papers\Cyclicality of R&D at the Firm Level\Data files"

def read_bea_detail(path):
    with open(path, encoding='utf-8-sig') as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        if line.strip().startswith('Line,,'):
            header_idx = i
            break
    df = pd.read_csv(path, header=header_idx)
    return df

def clean_and_wide(df):
    if df.iloc[0, 0] == 'Line':
        df = df.iloc[1:]
    long = df.melt(id_vars=['Line', 'Unnamed: 1'], var_name='year', value_name='value')
    long = long.rename(columns={'Unnamed: 1': 'variable'})
    long['variable'] = long['variable'].astype(str).str.strip()
    long = long.drop(columns=['Line'])
    long = long[long['year'].str.isnumeric()]
    long['year'] = long['year'].astype(int)
    long['value'] = pd.to_numeric(long['value'], errors='coerce')
    long = long.dropna(subset=['variable', 'value'])
    long = long.drop_duplicates(subset=['variable', 'year'])
    # Get variable order as in the original file (excluding duplicates, preserving order)
    var_order = long['variable'].drop_duplicates().tolist()
    wide = long.pivot(index='year', columns='variable', values='value').reset_index()
    wide.columns.name = None
    # Reorder columns: year first, then variables in original order
    cols = ['year'] + [v for v in var_order if v in wide.columns]
    wide = wide[cols]
    return wide

# Process nominal table
gdp_nom = read_bea_detail(os.path.join(DATA_DIR, "BEA_GDP_Detail.csv"))
gdp_nom_wide = clean_and_wide(gdp_nom)
gdp_nom_wide.to_csv(os.path.join(DATA_DIR, "BEA_GDP_Detail_clean.csv"), index=False)

# Process price index table
gdp_price = read_bea_detail(os.path.join(DATA_DIR, "BEA_GDP_Prices_Detail.csv"))
gdp_price_wide = clean_and_wide(gdp_price)
gdp_price_wide.to_csv(os.path.join(DATA_DIR, "BEA_GDP_Prices_Detail_clean.csv"), index=False)

def extract_series(df, label):
    desc_col = 'Unnamed: 1'
    matches = df[df[desc_col].astype(str).str.strip().str.contains(label, case=False, na=False)]
    if matches.empty:
        raise ValueError(f"Label '{label}' not found in the data.")
    row = matches.iloc[0]
    series = row.drop(['Line', desc_col]).astype(float)
    series.index = series.index.astype(int)
    return series

# Read data
nom = read_bea_detail(os.path.join(DATA_DIR, "BEA_GDP_Detail.csv"))
prices = read_bea_detail(os.path.join(DATA_DIR, "BEA_GDP_Prices_Detail.csv"))

# Extract series
gdp_nom = extract_series(nom, "Gross domestic product")
gdp_defl = extract_series(prices, "Gross domestic product")
rd_nom = extract_series(nom, "Research and development")
rd_defl = extract_series(prices, "Research and development")

years = gdp_nom.index

df = pd.DataFrame({
    'year': years,
    'GDP_nominal': gdp_nom.values,
    'GDP_deflator': gdp_defl.values,
    'GDP_real': gdp_nom.values / gdp_defl.values,
    'R&D_nominal': rd_nom.values,
    'R&D_deflator': rd_defl.values,
    'R&D_real': rd_nom.values / rd_defl.values
})

df['d_gdp'] = np.log(df['GDP_real']).diff()
df['d_rd'] = np.log(df['R&D_real']).diff()

df.to_csv(os.path.join(DATA_DIR, "Country_RD_GDP_Clean.csv"), index=False) 