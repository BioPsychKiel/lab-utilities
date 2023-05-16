# lab-utilities
This repo contains relevant utilities for eeg lab research at the [University of Kiel](https://www.uni-kiel.de/de/) and is maintained by various members from the [Department of Psychology](https://www.psychologie.uni-kiel.de/de) and the [Department of Neurology](https://www.neurologie.uni-kiel.de/de).

## Welcome <3

<img src="lab_pics\lab_wide.jpg"  width="40%">

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
