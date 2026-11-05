from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

# Project directories
PROJECT_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = PROJECT_DIR / "outputs"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Results from PostgreSQL strike-zone analysis
# Rows: High, Middle, Low
# Columns: Left, Middle, Right
#
# These are precomputed SQL results, not a live database query.

swings = np.array([
    [46, 77, 66],
    [64, 125, 112],
    [59, 116, 89]
])

whiffs = np.array([
    [2, 7, 12],
    [5, 11, 13],
    [14, 31, 20]
])

# Calculate whiff rate as a percentage of swings
whiff_rates = np.divide(
    whiffs,
    swings,
    out=np.zeros_like(whiffs, dtype=float),
    where=swings > 0
) * 100

# Create heatmap
fig, ax = plt.subplots(figsize=(8, 7))

heatmap = ax.imshow(
    whiff_rates,
    cmap="YlOrRd",
    vmin=0,
    vmax=35
)

# Add percentage and sample size to each cell
for row in range(3):
    for col in range(3):
        ax.text(
            col,
            row,
            f"{whiff_rates[row, col]:.2f}%\n"
            f"({whiffs[row, col]}/{swings[row, col]} whiffs/swings)",
            ha="center",
            va="center",
            fontsize=10,
            fontweight="bold"
        )

# Axis labels
ax.set_xticks([0, 1, 2])
ax.set_xticklabels(["Left", "Middle", "Right"])

ax.set_yticks([0, 1, 2])
ax.set_yticklabels(["High", "Middle", "Low"])

ax.set_xlabel("Horizontal Pitch Location")
ax.set_ylabel("Vertical Pitch Location")

ax.set_title(
    "Ben Rice | 2026 In-Zone Whiff Rate\n"
    "Catcher's Perspective",
    fontsize=16,
    fontweight="bold",
    pad=20
)

# Color scale
colorbar = fig.colorbar(heatmap, ax=ax)
colorbar.set_label("Whiff Rate (%)")

# Save visualization
fig.tight_layout()

output_path = OUTPUT_DIR / "ben_rice_whiff_heatmap.png"

fig.savefig(
    output_path,
    dpi=300,
    bbox_inches="tight"
)

plt.close(fig)

print(f"Heatmap saved to: {output_path}")