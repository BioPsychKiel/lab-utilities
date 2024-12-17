import matplotlib.pyplot as plt 
from matplotlib.colors import LinearSegmentedColormap
import mne
import numpy as np
from pathlib import Path

dir_data = Path(r'W:\source_projects\senseAge_ls\pilot_data') # update the path to your folder
# find the latest file with the extension .vhdr
fname_bv = dir_data.glob('*.vhdr')
fname_bv = max(fname_bv, key=lambda p: p.stat().st_ctime)
fname_bv = str(fname_bv)



# load data
raw = mne.io.read_raw_brainvision(fname_bv, verbose=False, preload=True);
# check if bva got the correct channel locations
raw.plot_sensors(show_names=True);
chns_layout = raw.get_montage()
## initate bridges
ed_data = dict()  # electrical distance/bridging data
raw_data = dict()  # store infos for electrode positions

print(f'Computing electrode bridges')

raw.set_montage(chns_layout, on_missing = 'ignore', verbose=False)
ed_data = mne.preprocessing.compute_bridged_electrodes(raw)

bridged_idx, ed_matrix = ed_data

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(8, 4))
fig.suptitle('Electrical Distance Matrix')

# take median across epochs, only use upper triangular, lower is NaNs
ed_plot = np.zeros(ed_matrix.shape[1:]) * np.nan
triu_idx = np.triu_indices(ed_plot.shape[0], 1)
for idx0, idx1 in np.array(triu_idx).T:
    ed_plot[idx0, idx1] = np.nanmedian(ed_matrix[:, idx0, idx1])

# plot full distribution color range
im1 = ax1.imshow(ed_plot, aspect='auto')
cax1 = fig.colorbar(im1, ax=ax1)
cax1.set_label(r'Electrical Distance ($\mu$$V^2$)')

# plot zoomed in colors
im2 = ax2.imshow(ed_plot, aspect='auto', vmax=5)
cax2 = fig.colorbar(im2, ax=ax2)
cax2.set_label(r'Electrical Distance ($\mu$$V^2$)')
for ax in (ax1, ax2):
    ax.set_xlabel('Channel Index')
    ax.set_ylabel('Channel Index')

fig.tight_layout()
fig.show()

mne.viz.plot_bridged_electrodes(
    raw.info, bridged_idx, ed_matrix,
    title='Bridged Electrodes', topomap_args=dict(vlim=(None, 5)));


# find all vdhr files
fnames_bv_all = dir_data.glob('*.vhdr')

# loop over all vdhr files and save the plots for the impedance
for fname_bv in fnames_bv_all:
    fname_bv = str(fname_bv)
    raw = mne.io.read_raw_brainvision(fname_bv, verbose=False, preload=True);
    # check if bva got the correct channel locations
    chns_layout = raw.get_montage()
    
    # get impedancesfrom eeg channels
    ch_types = raw.ch_names()
    eeg_chs = mne.pick_types(raw.info, meg=False, eeg=True)
    all_imp = [info["imp"] for i, info in raw.impedances.items() if i != "ECG" or i != "33"]

    # typically impedances < 25 kOhm are acceptable for active systems and
    # impedances < 5 kOhm are desirable for a passive system
    impedances = [imp for imp in all_imp if not np.isnan(imp)]

    cmap = LinearSegmentedColormap.from_list(
        name="impedance_cmap", colors=["g", "y", "r"], N=len(impedances) - 2
    )
    fig, ax = plt.subplots(figsize=(5, 5))
    im, cn = mne.viz.plot_topomap(impedances, raw.info, axes=ax, cmap=cmap, vlim=(0, 50))
    ax.set_title("Electrode Impendances")
    cax = fig.colorbar(im, ax=ax)
    cax.set_label(r"Impedance (k$\Omega$)")

    # find the electrode with the hightest impedance and mark it in the tpopplot with the value
    max_imp = max(impedances)
    max_imp_idx = impedances.index(max_imp)
    ax.plot(
        raw.info["chs"][max_imp_idx]["loc"][0],
        raw.info["chs"][max_imp_idx]["loc"][1],
        "r.",
        markersize=20,
        label=f"Max Impedance: {max_imp:.2f} kOhm",
    )

    # add legend
    ax.legend()
    # save the plot
    fname = fname_bv.split('.')[0]
    fname = dir_data.joinpath(fname + '_impedances.png')
    fig.savefig(fname, dpi=300)


