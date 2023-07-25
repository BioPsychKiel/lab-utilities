# README: Convert EEG data in XDF format to BIDS format using MNE-BIDS

This README provides instructions on how to convert EEG data in XDF (Extensible Data Format) to BIDS (Brain Imaging Data Structure) format using MNE-BIDS. BIDS is a standard for organizing and describing neuroimaging data, and MNE-BIDS is a tool that helps create BIDS-compatible directories for EEG data.

## Authors
- Julius Welzel <j.welzel@neurologie.uni-kiel.de>

## License
- BSD (3-clause)

## Step 1: Download the data
First, you need to obtain the EEG data in XDF format. For this example, we will use the EEG Motor Movement/Imagery Dataset available on the PhysioBank database.

1. Make sure you have the required dependencies installed: MNE-Python and mne_bids.
2. Create a directory to save the data.
3. Define which tasks you want to download from the dataset (e.g., rest with closed eyes, motor imagery tasks).
4. Download the data for the specified subjects and tasks.

```python
import os
import mne
from mne.datasets import eegbci
from mne_bids import write_raw_bids, make_bids_basename
from mne_bids.utils import print_dir_tree

# Make a directory to save the data to
home = os.path.expanduser('~')
mne_dir = os.path.join(home, 'mne_data')
if not os.path.exists(mne_dir):
    os.makedirs(mne_dir)

# Define which tasks we want to download.
tasks = [2, 4, 12]  # Task IDs for rest with closed eyes and motor imagery tasks

# Download the data for subjects 1 and 2
for subj_idx in [1, 2]:
    eegbci.load_data(subject=subj_idx, runs=tasks, path=mne_dir, update_path=True)
```

## Step 2: Convert to BIDS format
Next, we will convert the downloaded EEG data in XDF format to BIDS format.

1. Read the XDF file using MNE-Python's io module with `preload=False`.
2. Read the annotations stored in the XDF file and convert them into events compatible with MNE.
3. Use the `write_raw_bids` function to create a new BIDS directory and format the data in BIDS-compatible structure.

```python
# Specify the subject ID and task for which you want to convert data
subject_id = '001'  # Zero padding for subject ID
task = 'resteyesclosed'  # Task name for rest with closed eyes

# Load the XDF data for the specified subject and task
xdf_path = eegbci.load_data(subject=1, runs=2)[0]
raw = mne.io.read_raw_edf(xdf_path, preload=False, stim_channel=None)

# Read the annotations and convert them into events
annot = mne.read_annotations(xdf_path)
raw.set_annotations(annot)
events, event_id = mne.events_from_annotations(raw)

# Convert the data to a new BIDS dataset
output_path = os.path.join(home, 'mne_data')  # Specify the output directory
trial_type = {'rest': 0, 'imagine left fist': 1, 'imagine right fist': 2}  # Event markers
bids_basename = make_bids_basename(subject=subject_id, task=task)  # Create BIDS filename
write_raw_bids(raw, bids_basename, output_path, event_id=trial_type, events_data=events, overwrite=True)
```

## Manual Inspection and Validation
After converting the EEG data to BIDS format using MNE-BIDS, you should manually inspect the BIDS directory and the meta files to ensure all necessary information is provided. For instance, you may need to describe EEGReference and EEGGround in the sidecar files if they were not automatically inferred by MNE-BIDS.

You can use the "BIDS-validator," a convenient JavaScript tool, to validate your BIDS directories for correctness and adherence to the BIDS standard. The BIDS-validator is available as both a web version and a command-line tool.

Please note that the provided code is a basic example and may need modifications based on your specific dataset and requirements. For more detailed information and advanced usage, refer to the MNE-BIDS documentation and BIDS specification.
