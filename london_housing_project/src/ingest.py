import pathlib
import duckdb



project_root = pathlib.Path(__file__).parent.parent
db_path = project_root / "property_data.duckdb"

# Price Paid Data ships as one file per year (pp-<year>.csv). Glob instead of
# hardcoding a year so this keeps working as new yearly files get downloaded.
housing_csvs = sorted((project_root / "data").glob("pp-*.csv"))
if not housing_csvs:
    raise FileNotFoundError("No data/pp-*.csv file found. Download Price Paid Data first.")
csv_path_housing = housing_csvs[-1]
csv_path_station = project_root / "data" / "stations.csv"


print(f"Project root: {project_root}")
print(f"Connecting to database at: {db_path}")
print(f"Loading price paid data from: {csv_path_housing}")

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