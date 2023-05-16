import matplotlib.pyplot as plt 
from matplotlib.colors import LinearSegmentedColormap
import mne
import numpy as np
from pathlib import Path

dir_data = Path(r'C:\Users\User\Desktop\kiel\lab\lab-utilities\eeg_sanity') # update the path to your folder
fname_bv = Path.joinpath(dir_data,"raw","RO26BU.vhdr") # adjust the filename for your filo oi

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
fig.suptitle('Aguf07 Electrical Distance Matrix')

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
    title='Aguf07 Bridged Electrodes', topomap_args=dict(vlim=(None, 5)));

# get impedances, all but ground
all_imp = [info["imp"] for i, info in raw.impedances.items() if i != 'Gnd']

rng = np.random.default_rng(11)  # seed for reproducibility

# typically impedances < 25 kOhm are acceptable for active systems and
# impedances < 5 kOhm are desirable for a passive system
impedances = all_imp

cmap = LinearSegmentedColormap.from_list(
    name="impedance_cmap", colors=["g", "y", "r"], N=256
)
fig, ax = plt.subplots(figsize=(5, 5))
im, cn = mne.viz.plot_topomap(impedances, raw.info, axes=ax, cmap=cmap, vlim=(0, 30))
ax.set_title("Electrode Impendances")
cax = fig.colorbar(im, ax=ax)
cax.set_label(r"Impedance (k$\Omega$)")