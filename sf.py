import numpy as np
import matplotlib.pyplot as plt

def moving_average(data, window_size):
    """Apply moving average filter to data."""
    weights = np.repeat(1.0, window_size) / window_size
    return np.convolve(data, weights, 'valid')

# Generate example data
#x = np.linspace(0, 10, 100)
#y = np.sin(x) + np.random.normal(0, 0.1, 100)  # Noisy sinusoidal data

# Read data from file
data_file = "data.txt"
with open(data_file, "r") as file:
    lines = file.readlines()

# Extract x and y coordinates
x = []
y = []
for line in lines:
    parts = line.split()
    x.append(int(parts[0]))
    y.append(int(parts[1]))

# Apply 2nd order smoothing filter (moving average)
window_size = 3  # Adjust window size as needed
smoothed_x = moving_average(x, window_size)


# Plot signals on subplots
plt.figure(figsize=(10, 5))  # Adjust the figure size if needed
plt.subplot(2, 1, 1)
plt.plot(x, marker='o', linestyle='-')
plt.title('Signal In')
plt.ylabel('Amplitude')

plt.subplot(2, 1, 2)
plt.plot(smoothed_x, marker='o', linestyle='-')
plt.title('Signal Out')
plt.xlabel('Index')
plt.ylabel('Amplitude')

plt.tight_layout()  # Adjust the layout to prevent overlap
plt.show()
