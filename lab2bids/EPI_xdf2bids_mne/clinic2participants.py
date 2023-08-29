from pathlib import Path
import pandas as pd

bids_root = Path(r'D:\kiel\epi2bids_jw\data\bids')
source_root = Path(r'D:\kiel\epi2bids_jw\data\sourcedata')

# read clinical data
clinical_data = pd.read_csv(source_root / 'EEGEpilepsie_DATA_20230727.csv')

# read excel file with id matches which is password protected
id_matches = pd.read_csv(source_root / 'idschluessel.csv', sep=';', index_col=False, header=0)

# merge clinical data with id matches
clinical_data = pd.merge(clinical_data, id_matches, how='left', left_on='id', right_on='id')

# make pseudonym bids comliant (adding 'sub-' in front of the pseudonym)
clinical_data['pseudonym'] = 'sub-' + clinical_data['pseudonym']

# complete participand.tsv file from bids
participants = pd.read_csv(bids_root / 'participants.tsv', sep='\t', index_col=False, header=0)
# add clinical data to participants
participants = pd.merge(participants, clinical_data, how='left', left_on='participant_id', right_on='pseudonym')

# select substrings for columns to keep
columns_oi = ['participant_id','alter', 'tmt', 'rwt']
# select columns to keep
columns_oi = [col for col in participants.columns if any(x in col for x in columns_oi)]
# select columns to drop
columns_drop = [col for col in participants.columns if col not in columns_oi]
# drop columns
participants = participants.drop(columns=columns_drop)
participants.head()

# write participants.tsv file
participants.to_csv(bids_root / 'participants.tsv', sep='\t', index=False)