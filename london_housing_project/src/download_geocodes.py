import urllib.request
from pathlib import Path
import duckdb

project_root = Path(__file__).resolve().parent
if project_root.name == "src":
    project_root = project_root.parent

csv_output_path = project_root / "data" / "ukpostcodes.csv"
db_path = project_root / "property_data.duckdb"

print("Downloading UK postcode coordinate reference mapping...")
# Using a clean, direct public mirror for postcode geocodes
url = "https://raw.githubusercontent.com/Gibbs/UK-Postcodes/master/postcodes.csv"
urllib.request.urlretrieve(url, str(csv_output_path))
print(f"Downloaded raw reference to: {csv_output_path}")

print("Connecting to DuckDB to inject geolocation mapping...")
con = duckdb.connect(str(db_path))

# The Gibbs dataset uses standard headers: postcode, latitude, longitude
con.execute(f"""
    CREATE OR REPLACE TABLE raw_postcode_lookup AS 
    SELECT 
        upper(replace(postcode, ' ', '')) as clean_postcode,  
        cast(latitude as double) as latitude,
        cast(longitude as double) as longitude
    FROM read_csv_auto('{str(csv_output_path)}');
""")

print(f"Success! Map populated: {con.execute('SELECT COUNT(*) FROM raw_postcode_lookup;').fetchone()[0]} postcodes loaded.")
con.close()