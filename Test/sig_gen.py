import numpy as np

# Parameters
fs = 1000  # Sampling frequency (Hz)
t = np.arange(0, 1, 1/fs)  # Time vector from 0 to 1 second with 1/fs spacing
f = 10  # Frequency of the sinusoid (Hz)
A = 1  # Amplitude of the sinusoid
noise_level = 0.1  # Level of noise

# Generate sinusoid
sinusoid = A * np.sin(2 * np.pi * f * t)

# Generate noise
noise = noise_level * np.random.randn(len(t))  # Gaussian noise with zero mean and unit variance

# Add noise to sinusoid
noisy_signal = sinusoid + noise

# Save data to file
np.savetxt('data.txt', noisy_signal, delimiter='\n')

print("Data saved to 'data.txt'")
