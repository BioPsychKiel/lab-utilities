from mnelab.io.xdf import read_raw_xdf, _resample_streams
import mne
from mne.io.pick import get_channel_type_constants
from mne_bids import write_raw_bids, BIDSPath
import numpy as np
from pathlib import Path
from pyxdf import match_streaminfos, load_xdf, resolve_streams

from src.utls import find_participant_folders, find_xdf_files

bids_root = Path(r'D:\kiel\epi2bids_jw\data\bids')
tasks_oi = ['alertness', 'restingstate', 'gonogo']

# find all participant folders
participant_folders = find_participant_folders(r'.\data\sourcedata')

# loop over all participant folders
for participant_folder in participant_folders:

    # find all xdf files in the participant folder
    xdf_files = find_xdf_files(participant_folder)

    # loop over all xdf files
    for xdf_file in xdf_files:
            
        # check if file should be processed
        if 'old' in xdf_file.name:
            continue

        # write to BIDS
        fname_info = xdf_file.name.split('_')
        subject_id = fname_info[1]

        # check if subject_id has length of 6 and is made up of letter,letter,digit,digit,letter,letter
        # if not, skip this file
        if len(subject_id) != 6:
            print(f'Error: subject_id {subject_id} has length {len(subject_id)}')
            break
        if not subject_id[0:2].isupper() and not subject_id[2:4].isdigit() and not subject_id[4:6].isupper():
            print(f'Error: subject_id {subject_id} is not in the format LLDDLL')
            break
        
        task = fname_info[2].split('.')[0].lower()
        # only process the task if it is one of the tasks in the list
        if task not in tasks_oi:
            continue

        # find all streams in the xdf file
        streams, _ = load_xdf(xdf_file)
        streams = {stream["info"]["stream_id"]: stream for stream in streams}

        stream_types = [stream['info']['type'] for stream in streams.values()]

        # loop over all streams
        for stream in streams.values():
            stream_name = stream['info']['name']
            stream_id = stream['info']['stream_id']
            stream_type = stream['info']['type']

            # write to BIDS if stream holds EEG data
            if stream_type[0] == 'EEG':
                # read eeg data from the xdf file
                raw = read_raw_xdf(fname=xdf_file, stream_ids=[stream_id], prefix_markers=True)  # this is a mne.io.Raw object
                raw.info['line_freq'] = 50  # specify power line frequency as required by BIDS
                
                # delete events if they start before eeg recording
                events = mne.events_from_annotations(raw)
                bids_path = BIDSPath(subject=subject_id, task=task, datatype='eeg', root=bids_root)
                write_raw_bids(raw, bids_path, overwrite=True, allow_preload=True, format='BrainVision', verbose=True)

                print(f'Finished writing BIDS for participant {subject_id} and task {task}')

