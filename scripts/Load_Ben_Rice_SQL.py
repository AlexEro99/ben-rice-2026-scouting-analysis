
import pandas as pd
from sqlalchemy import create_engine
from getpass import getpass
from pathlib import Path

# Locate the main project folder
PROJECT_DIR = Path(__file__).resolve().parent.parent

# Locate the Statcast CSV
csv_path = PROJECT_DIR / "data" / "ben_rice_2026_statcast.csv"

# Load the CSV
df = pd.read_csv(csv_path)

# Select columns matching our SQL table
columns = [
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
    "estimated_woba_using_speedangle"
]

df = df[columns].copy()

# Connect to PostgreSQL securely
password = getpass("Enter PostgreSQL password: ")

engine = create_engine(
    "postgresql+psycopg2://",
    connect_args={
        "host": "localhost",
        "port": 5432,
        "dbname": "baseball_analytics",
        "user": "postgres",
        "password": password
    }
)

# Check whether the database already contains data
with engine.connect() as connection:
    from sqlalchemy import text

    existing_rows = connection.execute(
        text("SELECT COUNT(*) FROM ben_rice_pitches")
    ).scalar()

# Import only if the table is empty
if existing_rows == 0:
    df.to_sql(
        "ben_rice_pitches",
        engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )

    print(f"Successfully imported {len(df)} pitches!")

else:
    print(
        f"Import skipped: database already contains "
        f"{existing_rows} pitches."
    )

engine.dispose()
