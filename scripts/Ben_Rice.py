from pathlib import Path
import matplotlib.pyplot as plt
from pybaseball import statcast_batter

# Project directories
PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "data"
OUTPUT_DIR = PROJECT_DIR / "outputs"

DATA_DIR.mkdir(parents=True, exist_ok=True)
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Ben Rice's MLB player ID and analysis period
PLAYER_ID = 700250
START_DATE = "2026-03-01"
END_DATE = "2026-10-01"

# Download Statcast pitch-level data
print("Downloading Ben Rice's 2026 Statcast data...")

df = statcast_batter(
    START_DATE,
    END_DATE,
    PLAYER_ID
)

# Validate downloaded data
if df.empty:
    raise ValueError(
        "No Statcast data was returned. "
        "Check the player ID, date range, or connection."
    )

if "game_type" not in df.columns:
    raise ValueError("Missing expected column: game_type")

# Keep regular-season games only
df = df.loc[df["game_type"] == "R"].copy()

if df.empty:
    raise ValueError(
        "No regular-season pitches were found."
    )

# Validate required analysis columns
required_columns = ["pitch_name", "game_pk"]
missing_columns = [
    col for col in required_columns
    if col not in df.columns
]

if missing_columns:
    raise ValueError(
        f"Missing required columns: {missing_columns}"
    )

# Save dataset
csv_path = DATA_DIR / "ben_rice_2026_statcast.csv"
df.to_csv(csv_path, index=False)

# Display dataset summary
print(f"Total pitches: {len(df):,}")
print(f"Total games: {df['game_pk'].nunique():,}")

print("\nPitch types:")
print(df["pitch_name"].value_counts(dropna=False))

# Calculate pitch-type distribution
pitch_counts = (
    df["pitch_name"]
    .fillna("Unknown")
    .value_counts()
)

pitch_percentages = (
    pitch_counts / pitch_counts.sum() * 100
)

# Create visualization
fig, ax = plt.subplots(figsize=(10, 6))

pitch_percentages.sort_values().plot(
    kind="barh",
    ax=ax
)

ax.set_title("Ben Rice - Pitch Types Faced (2026)")
ax.set_xlabel("Percentage of Pitches (%)")
ax.set_ylabel("Pitch Type")

fig.tight_layout()

# Save visualization
chart_path = OUTPUT_DIR / "ben_rice_pitch_types.png"

fig.savefig(
    chart_path,
    dpi=300,
    bbox_inches="tight"
)

plt.close(fig)

print(f"\nDataset saved to: {csv_path}")
print(f"Chart saved to: {chart_path}")