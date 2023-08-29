import numpy as np
import mne
from pyxdf import load_xdf
from pathlib import Path
from mne.io.pick import get_channel_type_constants
from mne_bids import write_raw_bids, BIDSPath
from mnelab.io.xdf import read_raw_xdf, _resample_streams



def find_xdf_files(path):
    """Find all xdf files in a directory tree."""
    return list(Path(path).rglob('*.xdf'))

def create_raw_xdf(xdf_path, stream_id):
    """
    Create a raw object from an XDF file containing specific streams.

    Parameters:
    xdf_path (str): The path to the XDF file.

    Returns:
    mne.io.RawXDF: The raw object created from the XDF file.

    """
    # Get the stream id of the EEG stream
    raw = read_raw_xdf(xdf_path,stream_ids=[stream_id],prefix_markers=True)
    return raw

def find_participant_folders(path):
    """Find all participant folders in a directory tree."""
    return [p for p in Path(path).iterdir() if p.is_dir()]

def read_raw_xdf(fname, stream_ids=None, fs_new=None, prefix_markers=False):
    """Read a raw object from an XDF file."""
    streams, _ = load_xdf(fname)
    streams = {stream["info"]["stream_id"]: stream for stream in streams}

    labels_all, types_all, units_all = [], [], []
    for stream_id in stream_ids:
        stream = streams[stream_id]

        n_chans = int(stream["info"]["channel_count"][0])
        labels, types, units = [], [], []
        try:
            for ch in stream["info"]["desc"][0]["channels"][0]["channel"]:
                labels.append(str(ch["label"][0]))
                if ch["type"] and ch["type"][0].lower() in get_channel_type_constants(
                    include_defaults=True
                ):
                    types.append(ch["type"][0].lower())
                else:
                    types.append("misc")
                units.append(ch["unit"][0] if ch["unit"] else "NA")
        except (TypeError, IndexError):  # no channel labels found
            pass
        if not labels:
            labels = [f"{stream['info']['name'][0]}_{n}" for n in range(n_chans)]
        if not units:
            units = ["NA" for _ in range(n_chans)]
        if not types:
            types = ["misc" for _ in range(n_chans)]
        labels_all.extend(labels)
        types_all.extend(types)
        units_all.extend(units)

    if fs_new is not None:
        all_time_series, first_time = _resample_streams(streams, stream_ids, fs_new)
        fs = fs_new
    else:  # only possible if a single stream was selected
        all_time_series = streams[stream_ids[0]]["time_series"]
        first_time = streams[stream_ids[0]]["time_stamps"][0]
        fs = float(np.array(stream["info"]["effective_srate"]).item())

    info = mne.create_info(ch_names=labels_all, sfreq=fs, ch_types=types_all)

    microvolts = ("microvolt", "microvolts", "µV", "μV", "uV")
    scale = np.array([1e-6 if u in microvolts else 1 for u in units_all])
    all_time_series_scaled = (all_time_series * scale).T

    raw = mne.io.RawArray(all_time_series_scaled, info)
    raw._filenames = [fname]

    # convert marker streams to annotations
    for stream_id, stream in streams.items():
        srate = float(stream["info"]["nominal_srate"][0])
        n_chans = int(stream["info"]["channel_count"][0])
        name = stream["info"]["name"][0]
        # marker streams with regular srate or more than 1 channel are not supported yet
        if srate != 0 or n_chans > 1:
            continue

        # check if stream is a marker stream from PsychoPy
        if name != 'PsychoPyTrigger':
            continue

        onsets = stream["time_stamps"] - first_time
        prefix = f"{stream_id}-" if prefix_markers else ""
        descriptions = [f"{prefix}{item}" for sub in stream["time_series"] for item in sub]

        # delete all events which have a negative onset
        onsets, descriptions = zip(
            *[(o, d) for o, d in zip(onsets, descriptions) if o >= 0]
        )
        raw.annotations.append(onsets, [0] * len(onsets), descriptions)

    return raw