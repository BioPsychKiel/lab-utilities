# lab-utilities
This repo contains relevant utilities for eeg lab research

## structure
```markdown
└─ chan_loc_files\
    ├─ BCA-128-X1.pdf
    └─...
└─ eeg_sanity\
    ├─ check_sanity.py
    ├─ \raw
    └─...
└─ code\
    └─...
```
## chan_loc_files
In this folder you can find channel location files for various cap layouts. Information about the amp and recording location are provided.

## eeg_sanity
This is a MNE based script to check potential electrode bridges and plot the impedances from BrainVision EEG files.
