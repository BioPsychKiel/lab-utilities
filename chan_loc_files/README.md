# chan_locs_files
Here you can find channel location files for setups used in Kiel

| file | amp | location | info |
|------|-----|----------| ---- |
| BCA-128-pass-lay* | actiChamp | UKSH Kiel | Layout files for the 128 channel cap |
| BC-MR-32* | actiChamp | UKSH Kiel |  Layout files for the 32 channel cap from Helmut Laufs |


## Fieldtrip
To use sensor locations for fieldtrip analysis you can load the `BC-128-pass-lay.mat` file which contains the variable elec.
In fieldtrip you can use this information to prepare your layout the following:

```
cfg = [];
cfg.elec = elec;
layout = ft_prepare_layout(cfg);
```

## EEGLab
To use the sensor location it is recommended to load thze bvef file to EEGLab and go from there.