# process_bea_data.py
# Script to process BEA industry aggregate data for the Cyclicality of R&D at the Firm Level project
# Data source: U.S. Bureau of Economic Analysis (BEA) Industry Economic Accounts
# https://www.bea.gov/data/industry

import pandas as pd
import numpy as np
import os

# UPDATE THIS PATH to match your Google Drive letter (e.g., G:) if needed
DATA_DIR = r"G:\My Drive\Work\Research\Papers\Cyclicality of R&D at the Firm Level\Data files"

bea_path = os.path.join(DATA_DIR, "BEA_ValueAdded_RawFile.dta")
bea = pd.read_stata(bea_path)

# Deflate variables
bea['r_GO'] = bea['GO'] / bea['PGO']
bea['r_VA'] = bea['VA'] / bea['PVA']
bea['r_COMP'] = bea['COMP'] / bea['PVA']
bea['r_TAX'] = bea['TAX'] / bea['PVA']
bea['r_SURPLUS'] = bea['SURPLUS'] / bea['PVA']
bea['r_INPUTS'] = bea['INPUTS'] / bea['PINPUTS']
bea['r_ENER'] = bea['ENER'] / bea['PENER']
bea['r_MAT'] = bea['MAT'] / bea['PMAT']
bea['r_SERVICE'] = bea['SERVICE'] / bea['PSERVICE']

# Compute log growth rates (by industry code)
bea = bea.sort_values(['code', 'year'])
bea['d_go'] = np.log(bea['r_GO']) - np.log(bea['r_GO'].shift(1))
bea['d_va_ind'] = np.log(bea['r_VA']) - np.log(bea['r_VA'].shift(1))
bea['d_instrument'] = np.log(bea['Instrument']) - np.log(bea['Instrument'].shift(1))

# Drop unnecessary columns (as in Stata)
drop_cols = [
    'COMP', 'TAX', 'SURPLUS', 'INPUTS', 'ENER', 'MAT', 'SERVICE',
    'GO_GDP', 'VA_GDP', 'COMP_GDP', 'TAX_GDP', 'SURPLUS_GDP', 'INPUTS_GDP', 'ENER_GDP', 'MAT_GDP', 'SERVICE_GDP',
    'PINPUTS', 'PENER', 'PMAT', 'PSERVICE', 'PGO_GDP', 'PVA_GDP', 'PINPUTS_GDP', 'PENER_GDP', 'PMAT_GDP', 'PSERVICE_GDP',
    'Instrument', 'r_GO', 'r_VA', 'r_COMP', 'r_TAX', 'r_SURPLUS', 'r_INPUTS', 'r_ENER', 'r_MAT', 'r_SERVICE'
]
bea = bea.drop(columns=[col for col in drop_cols if col in bea.columns])

# Save processed data
output_path = os.path.join(DATA_DIR, "BEA_ValueAdded.csv")
bea.to_csv(output_path, index=False) 