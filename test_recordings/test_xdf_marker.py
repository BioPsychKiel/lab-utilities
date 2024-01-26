import pyxdf

# Load in the data
data, hdr = pyxdf.load_xdf('Experiment_testlauf.xdf')

# Print the triggers
print(data[0]['time_series']) # data from the first stream