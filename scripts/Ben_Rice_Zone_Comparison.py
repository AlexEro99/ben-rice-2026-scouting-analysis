from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

# Project directories
PROJECT_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = PROJECT_DIR / "outputs"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Strike-zone vertical thirds
zones = ["High", "Middle", "Low"]

# Precomputed results from PostgreSQL analysis
# These values are not retrieved from the database at runtime.

# Swings and whiffs by vertical zone
swings = np.array([189, 291, 264])
whiffs = np.array([21, 29, 65])

# Balls in play used for contact-quality calculations
balls_in_play = np.array([88, 133, 102])

# Contact-quality results
exit_velocity = np.array([93.89, 95.16, 91.17])
contact_value = np.array([0.428, 0.543, 0.460])

# Calculate whiff rates
whiff_rates = np.divide(
    whiffs,
    swings,
    out=np.zeros_like(whiffs, dtype=float),
    where=swings > 0
) * 100

# Create three side-by-side charts
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Chart 1: Whiff rate
axes[0].bar(zones, whiff_rates, color="#174A67")
axes[0].set_title("Whiff Rate")
axes[0].set_ylabel("Whiffs / Swings (%)")
axes[0].set_ylim(0, 32)

for i, value in enumerate(whiff_rates):
    axes[0].text(
        i, value + 0.6,
        f"{value:.2f}%\n"
        f"({whiffs[i]}/{swings[i]} swings)",
        ha="center",
        fontsize=9,
        fontweight="bold"
    )

# Chart 2: Average exit velocity
axes[1].bar(zones, exit_velocity, color="#C23B3B")
axes[1].set_title("Average Exit Velocity")
axes[1].set_ylabel("Miles per Hour")
axes[1].set_ylim(0, 115)

for i, value in enumerate(exit_velocity):
    axes[1].text(
        i, value + 1,
        f"{value:.2f} mph\n"
        f"(n={balls_in_play[i]})",
        ha="center",
        fontsize=9,
        fontweight="bold"
    )

# Chart 3: Estimated contact value
axes[2].bar(zones, contact_value, color="#D5A021")
axes[2].set_title("Estimated Contact Value")
axes[2].set_ylabel("Mean Estimated wOBA on Contact")
axes[2].set_ylim(0, 0.7)

for i, value in enumerate(contact_value):
    axes[2].text(
        i, value + 0.012,
        f"{value:.3f}\n"
        f"(n={balls_in_play[i]})",
        ha="center",
        fontsize=9,
        fontweight="bold"
    )

# Main title
fig.suptitle(
    "Ben Rice | 2026 Strike-Zone Performance",
    fontsize=17,
    fontweight="bold"
)

fig.tight_layout(rect=[0, 0, 1, 0.93])

# Save chart
output_path = OUTPUT_DIR / "ben_rice_zone_comparison.png"

fig.savefig(
    output_path,
    dpi=300,
    bbox_inches="tight"
)

plt.close(fig)

print(f"Chart saved to: {output_path}")