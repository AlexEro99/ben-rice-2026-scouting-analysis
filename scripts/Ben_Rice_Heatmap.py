
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# Locate the main project folder
PROJECT_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = PROJECT_DIR / "outputs"

# Create outputs folder if needed
OUTPUT_DIR.mkdir(exist_ok=True)

# Whiff rates from PostgreSQL analysis
# Rows: High, Middle, Low
# Columns: Left, Middle, Right
# Catcher's perspective
whiff_rates = np.array([
    [18.18, 9.09, 4.35],
    [11.61, 8.80, 7.81],
    [22.47, 26.72, 23.73]
])

# Number of swings in each zone
swings = np.array([
    [66, 77, 46],
    [112, 125, 64],
    [89, 116, 59]
])

# Create heatmap
fig, ax = plt.subplots(figsize=(8, 7))

heatmap = ax.imshow(
    whiff_rates,
    cmap="YlOrRd",
    vmin=0,
    vmax=35
)

# Label each zone
for row in range(3):
    for col in range(3):
        ax.text(
            col, row,
            f"{whiff_rates[row, col]:.2f}%\n"
            f"({swings[row, col]} swings)",
            ha="center",
            va="center",
            fontsize=12,
            fontweight="bold"
        )

# Axis labels
ax.set_xticks([0, 1, 2])
ax.set_xticklabels(["Left", "Middle", "Right"])

ax.set_yticks([0, 1, 2])
ax.set_yticklabels(["High", "Middle", "Low"])

ax.set_xlabel("Horizontal Pitch Location")
ax.set_ylabel("Vertical Pitch Location")

# Chart title
ax.set_title(
    "Ben Rice | 2026 In-Zone Whiff Rate\n"
    "Catcher's Perspective",
    fontsize=16,
    fontweight="bold",
    pad=20
)

# Color scale
colorbar = plt.colorbar(heatmap, ax=ax)
colorbar.set_label("Whiff Rate (%)")

plt.tight_layout()

# Save visualization
output_path = OUTPUT_DIR / "ben_rice_whiff_heatmap.png"

plt.savefig(
    output_path,
    dpi=300,
    bbox_inches="tight"
)

plt.show()

print(f"Heatmap saved to: {output_path}")
