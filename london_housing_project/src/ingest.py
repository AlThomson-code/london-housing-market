import pathlib
import duckdb
import geopandas as gpd
import pandas as pd



project_root = pathlib.Path(__file__).parent.parent
db_path = project_root / "property_data.duckdb"
csv_path_housing = project_root / "data" / "pp-2026.csv"
csv_path_station = project_root / "data" / "stations.csv"


print(f"Project root: {project_root}")
print(f"Connecting to database at: {db_path}")

con = duckdb.connect(str(db_path))

con.execute(f"""
    DROP TABLE IF EXISTS raw_land_registry;
    CREATE OR REPLACE TABLE raw_land_registry AS 
    SELECT * FROM read_csv_auto(
        '{csv_path_housing}',
        header=False
    );
""")

con.execute(f"""
    DROP TABLE IF EXISTS raw_tfl_stations;
    CREATE OR REPLACE TABLE raw_tfl_stations AS
    SELECT * FROM read_csv_auto(
        '{csv_path_station}'
    );
""")

print("Success!")
con.close()