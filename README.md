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

## Cap Cleaning Guidelines 
1. Please use all caps carefully, and clean them carefully. Cleaning  takes time, and you will get wet if you do this properly. You need to use the strongest possible  stream of water for cleaning a cap. 
2. Connectors from multi-channel caps must never ever get wet (risk of  short circuits). 
3. Once caps are dried please check whether they are really clean (dry  gel shows up as white powder). 
4. Do NOT use physical forces for cleaning the cap, just (warm) water  and if necessary a toothbrush (usually not needed, and not recommended).
5. Remember to clean the nose-tip electrode when cleaning the  high-density caps (frequently forgotten). Don’t forget to clean the closures. 
6. Please make sure you do not wrap the cable bundles when cleaning  high-density caps. 
7. If there is a delay between taking off the cap and cleaning place the  cap into a bucket of (warm) water in the meantime, this will speed up  cleaning afterwards. 
8. Caps are extremely expensive, I cannot easily replace high-density  caps (they cost up to 10k EUR!), and repairing caps is very time-consuming. 
9. Document cap use in the lab book! Each cap has a unique ID (little  label flag in the back) 
10. If you feel an electrode is broken or a cap does not work well,  document the problem and let Julius know. He can fix most cap problems,  but this takes time (days, month even years, not minutes). 
11. Keep in mind that time spent on properly setting up and cleaning the cap is very well spent - it will pay off during analysis!!
