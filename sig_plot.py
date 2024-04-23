import matplotlib.pyplot as plt

# Read data from file
data_file = "data.csv"
with open(data_file, "r") as file:
    lines = file.readlines()
d = []
for line in lines:
    d.append(int(line))
indices_d = range(len(d))

# Read data from file
data_file = "output.txt"
with open(data_file, "r") as file:
    lines = file.readlines()
o = []
for line in lines:
    o.append(int(line))
indices_o = range(len(o))

# Plot signals on subplots
plt.figure(figsize=(10, 5))  # Adjust the figure size if needed
plt.subplot(2, 1, 1)
plt.plot(indices_d, d, marker='o', linestyle='-')
plt.title('Signal In')
plt.ylabel('Amplitude')

plt.subplot(2, 1, 2)
plt.plot(indices_o, o, marker='o', linestyle='-')
plt.title('Signal Out')
plt.xlabel('Index')
plt.ylabel('Amplitude')

plt.tight_layout()  # Adjust the layout to prevent overlap
plt.show()
