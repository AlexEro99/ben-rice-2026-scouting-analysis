from pathlib import Path
from getpass import getpass
import pandas as pd
from sqlalchemy import create_engine, inspect, text

# Locate the project and dataset
PROJECT_DIR = Path(__file__).resolve().parent.parent
CSV_PATH = PROJECT_DIR / "data" / "ben_rice_2026_statcast.csv"

TABLE_NAME = "ben_rice_pitches"

# Columns used in the SQL analysis
COLUMNS = [
    "game_date",
    "game_pk",
    "at_bat_number",
    "pitch_number",
    "pitch_type",
    "pitch_name",
    "release_speed",
    "plate_x",
    "plate_z",
    "sz_top",
    "sz_bot",
    "description",
    "events",
    "p_throws",
    "balls",
    "strikes",
    "launch_speed",
    "estimated_woba_using_speedangle",
]

# Check whether the dataset exists
if not CSV_PATH.is_file():
    raise FileNotFoundError(
        f"Dataset not found: {CSV_PATH}\n"
        "Run Ben_Rice.py first to download the data."
    )

# Read the dataset
df = pd.read_csv(CSV_PATH)

# Validate required columns
missing_columns = [
    col for col in COLUMNS
    if col not in df.columns
]

if missing_columns:
    raise ValueError(
        f"Missing columns in CSV: {missing_columns}"
    )

df = df[COLUMNS].copy()

if df.empty:
    raise ValueError("The Statcast dataset is empty.")

# Convert date to the appropriate type
df["game_date"] = pd.to_datetime(
    df["game_date"],
    errors="raise"
).dt.date

# Request PostgreSQL credentials
password = getpass("Enter PostgreSQL password: ")

engine = create_engine(
    "postgresql+psycopg2://",
    connect_args={
        "host": "localhost",
        "port": 5432,
        "dbname": "baseball_analytics",
        "user": "postgres",
        "password": password,
    },
)

try:
    # Check whether the table exists
    table_exists = inspect(engine).has_table(TABLE_NAME)

    if not table_exists:
        # Create the table using the DataFrame schema
        df.to_sql(
            TABLE_NAME,
            engine,
            if_exists="fail",
            index=False,
            chunksize=1000,
        )

        print(
            f"Created {TABLE_NAME} and "
            f"imported {len(df):,} pitches."
        )

    else:
        # Check existing records
        with engine.connect() as connection:
            existing_rows = connection.execute(
                text(
                    "SELECT COUNT(*) "
                    "FROM ben_rice_pitches"
                )
            ).scalar_one()

        if existing_rows == 0:
            df.to_sql(
                TABLE_NAME,
                engine,
                if_exists="append",
                index=False,
                chunksize=1000,
            )

            print(
                f"Imported {len(df):,} pitches "
                f"into the existing table."
            )

        else:
            print(
                f"Import skipped: {TABLE_NAME} "
                f"already contains {existing_rows:,} pitches."
            )

finally:
    engine.dispose()