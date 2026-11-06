from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Locate the project folders
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_PATH = BASE_DIR / "data" / "ben_rice_2026_statcast.csv"
OUTPUT_PATH = BASE_DIR / "outputs" / "ben_rice_outside_zone_whiff_heatmap.png"

# Load Statcast pitch-level data
df = pd.read_csv(DATA_PATH)

print("Total pitches:", len(df))
print("Columns available:", len(df.columns))

# Confirm the fields needed for the heatmap
required_columns = [
    "plate_x",
    "plate_z",
    "sz_top",
    "sz_bot",
    "description"
]

for column in required_columns:
    print(f"{column}: {column in df.columns}")
    
# Convert location columns to numeric values
location_columns = ["plate_x", "plate_z", "sz_top", "sz_bot"]

for column in location_columns:
    df[column] = pd.to_numeric(df[column], errors="coerce")

# Remove pitches with missing location information
df = df.dropna(subset=location_columns).copy()

# Identify swings and whiffs
swing_descriptions = [
    "swinging_strike",
    "swinging_strike_blocked",
    "foul_tip",
    "foul",
    "foul_bunt",
    "foul_pitchout",
    "hit_into_play",
    "missed_bunt",
    "bunt_foul_tip"
]

whiff_descriptions = [
    "swinging_strike",
    "swinging_strike_blocked",
    "foul_tip"
]

df["is_swing"] = df["description"].isin(swing_descriptions)
df["is_whiff"] = df["description"].isin(whiff_descriptions)

# Classify pitches into four non-overlapping outside regions.
# Corners are assigned to above/below first.
def classify_location(row):
    if row["plate_z"] > row["sz_top"]:
        return "Above Zone"
    elif row["plate_z"] < row["sz_bot"]:
        return "Below Zone"
    elif row["plate_x"] > 0.85:
        return "Catcher's Left"
    elif row["plate_x"] < -0.85:
        return "Catcher's Right"
    else:
        return "In Zone"

df["location_group"] = df.apply(classify_location, axis=1)

# Keep pitches outside the zone
outside_df = df[df["location_group"] != "In Zone"].copy()

# Calculate whiff rate per swing
summary = (
    outside_df.groupby("location_group")
    .agg(
        pitches=("is_swing", "size"),
        swings=("is_swing", "sum"),
        whiffs=("is_whiff", "sum")
    )
)

summary["whiff_rate"] = np.where(
    summary["swings"] > 0,
    summary["whiffs"] / summary["swings"] * 100,
    np.nan
)

print("\nOUT-OF-ZONE WHIFF SUMMARY")
print(summary.round(2).to_string())
print("\nTotal classified pitches:", len(df))
print("Total out-of-zone pitches:", len(outside_df))

from matplotlib.patches import Rectangle
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable

# Four outside regions arranged around the strike zone
region_positions = {
    "Above Zone": (1, 2),
    "Below Zone": (1, 0),
    "Catcher's Left": (0, 1),
    "Catcher's Right": (2, 1)
}

fig, ax = plt.subplots(figsize=(9, 7))

cmap = plt.get_cmap("YlOrRd")
norm = Normalize(vmin=0, vmax=60)

# Draw colored outside-zone regions
for region, (x, y) in region_positions.items():
    row = summary.loc[region]
    rate = row["whiff_rate"]

    color = cmap(norm(rate))

    ax.add_patch(
        Rectangle(
            (x, y), 1, 1,
            facecolor=color,
            edgecolor="white",
            linewidth=3
        )
    )

    ax.text(
        x + 0.5, y + 0.68,
        region,
        ha="center", va="center",
        fontsize=10, fontweight="bold"
    )

    ax.text(
        x + 0.5, y + 0.43,
        f"{rate:.2f}%",
        ha="center", va="center",
        fontsize=17, fontweight="bold"
    )

    ax.text(
        x + 0.5, y + 0.20,
        f"{int(row['whiffs'])}/{int(row['swings'])} whiffs/swings",
        ha="center", va="center",
        fontsize=8
    )

# Draw the strike zone in the center
ax.add_patch(
    Rectangle(
        (1, 1), 1, 1,
        facecolor="#e9edf2",
        edgecolor="#263b53",
        linewidth=2.5
    )
)

ax.text(
    1.5, 1.5,
    "STRIKE\nZONE",
    ha="center", va="center",
    fontsize=13, fontweight="bold",
    color="#263b53"
)

# Color legend
sm = ScalarMappable(norm=norm, cmap=cmap)
sm.set_array([])
cbar = fig.colorbar(sm, ax=ax, fraction=0.035, pad=0.04)
cbar.set_label("Whiff Rate (%)")

ax.set_xlim(-0.15, 3.15)
ax.set_ylim(-0.15, 3.15)
ax.set_aspect("equal")
ax.axis("off")

ax.set_title(
    "Ben Rice | 2026 Out-of-Zone Whiff Rate",
    fontsize=17, fontweight="bold", pad=20
)

fig.text(
    0.5, 0.04,
    "Catcher's perspective | Whiff rate = whiffs / swings\n"
    "Above/below regions include outside-zone corners",
    ha="center", fontsize=9, color="#555555"
)

OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
plt.savefig(OUTPUT_PATH, dpi=300, bbox_inches="tight")
plt.show()

print(f"\nHeatmap saved to: {OUTPUT_PATH}")
