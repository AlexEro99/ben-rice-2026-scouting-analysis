
from pybaseball import statcast_batter
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# Locate the main project folder
PROJECT_DIR = Path(__file__).resolve().parent.parent

# Define project folders
DATA_DIR = PROJECT_DIR / "data"
OUTPUT_DIR = PROJECT_DIR / "outputs"

# Create folders if they don't exist
DATA_DIR.mkdir(exist_ok=True)
OUTPUT_DIR.mkdir(exist_ok=True)

# Ben Rice's MLB player ID
player_id = 700250

# Download 2026 Statcast data
df = statcast_batter(
    "2026-03-01",
    "2026-10-01",
    player_id
)

# Keep regular season games
df = df[df["game_type"] == "R"].copy()

# Save the dataset
csv_path = DATA_DIR / "ben_rice_2026_statcast.csv"
df.to_csv(csv_path, index=False)

# Verify results
print("Player:", df["player_name"].unique())
print("Total pitches:", len(df))
print("Total games:", df["game_pk"].nunique())

print("\nPitch types:")
print(df["pitch_name"].value_counts())

# Count each pitch type
pitch_counts = df["pitch_name"].value_counts()

# Calculate percentage of total pitches
pitch_percentages = (
    pitch_counts / pitch_counts.sum() * 100
)

# Create horizontal bar chart
plt.figure(figsize=(10, 6))

pitch_percentages.sort_values().plot(
    kind="barh"
)

plt.title("Ben Rice - Pitch Types Faced (2026)")
plt.xlabel("Percentage of Pitches (%)")
plt.ylabel("Pitch Type")

plt.tight_layout()

# Save chart in the outputs folder
chart_path = OUTPUT_DIR / "ben_rice_pitch_types.png"

plt.savefig(
    chart_path,
    dpi=300,
    bbox_inches="tight"
)

plt.show()

print(f"\nDataset saved to: {csv_path}")
print(f"Chart saved to: {chart_path}")
