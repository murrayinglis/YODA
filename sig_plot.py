import matplotlib.pyplot as plt

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

# Plot signals on subplots
plt.figure(figsize=(10, 5))  # Adjust the figure size if needed
plt.subplot(2, 1, 1)
plt.plot(x, marker='o', linestyle='-')
plt.title('Signal In')
plt.ylabel('Amplitude')

plt.subplot(2, 1, 2)
plt.plot(y, marker='o', linestyle='-')
plt.title('Signal Out')
plt.xlabel('Index')
plt.ylabel('Amplitude')

plt.tight_layout()  # Adjust the layout to prevent overlap
plt.show()
