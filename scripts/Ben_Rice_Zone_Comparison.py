
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# Locate the main project folder
PROJECT_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = PROJECT_DIR / "outputs"

# Create outputs folder if needed
OUTPUT_DIR.mkdir(exist_ok=True)

# Strike-zone vertical thirds
zones = ["High", "Middle", "Low"]

# Results from PostgreSQL analysis
whiff_rates = [11.11, 9.97, 24.62]
exit_velocity = [93.89, 95.16, 91.17]
contact_value = [0.428, 0.543, 0.460]

# Create three side-by-side charts
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Chart 1: Whiff rate
axes[0].bar(zones, whiff_rates, color="#174A67")
axes[0].set_title("Whiff Rate")
axes[0].set_ylabel("Whiff Rate (%)")
axes[0].set_ylim(0, 30)

for i, value in enumerate(whiff_rates):
    axes[0].text(
        i, value + 0.5,
        f"{value:.2f}%",
        ha="center",
        fontweight="bold"
    )

# Chart 2: Average exit velocity
axes[1].bar(zones, exit_velocity, color="#C23B3B")
axes[1].set_title("Average Exit Velocity")
axes[1].set_ylabel("Miles per Hour")
axes[1].set_ylim(0, 110)

for i, value in enumerate(exit_velocity):
    axes[1].text(
        i, value + 1,
        f"{value:.2f}",
        ha="center",
        fontweight="bold"
    )

# Chart 3: Estimated contact value
axes[2].bar(zones, contact_value, color="#D5A021")
axes[2].set_title("Estimated Contact Value")
axes[2].set_ylabel("Mean Estimated wOBA on Contact")
axes[2].set_ylim(0, 0.65)

for i, value in enumerate(contact_value):
    axes[2].text(
        i, value + 0.01,
        f"{value:.3f}",
        ha="center",
        fontweight="bold"
    )

# Main title
fig.suptitle(
    "Ben Rice | 2026 Strike-Zone Performance",
    fontsize=17,
    fontweight="bold"
)

plt.tight_layout()

# Save chart to outputs folder
output_path = OUTPUT_DIR / "ben_rice_zone_comparison.png"

plt.savefig(
    output_path,
    dpi=300,
    bbox_inches="tight"
)

plt.show()

print(f"Chart saved to: {output_path}")
