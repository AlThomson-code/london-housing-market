import urllib.request
from pathlib import Path
import zipfile
import duckdb
import os

project_root = Path(__file__).resolve().parent
if project_root.name == "src":
    project_root = project_root.parent

zip_output_path = project_root / "data" / "ukpostcodes.zip"
csv_output_path = project_root / "data" / "ukpostcodes.csv"
db_path = project_root / "property_data.duckdb"

# Ensure data directory exists
csv_output_path.parent.mkdir(parents=True, exist_ok=True)

print("Downloading complete UK postcode reference database (~20MB compressed)...")
# Official, reliable download archive from Free Map Tools
url = "https://data.freemaptools.com/download/full-uk-postcodes/ukpostcodes.zip"

# Add a user-agent header to ensure the server accepts the python download request
opener = urllib.request.build_opener()
opener.addheaders = [('User-agent', 'Mozilla/5.0')]
urllib.request.install_opener(opener)

urllib.request.urlretrieve(url, str(zip_output_path))
print("Download complete. Extracting CSV archive...")

# Extract the zip file contents directly into the data folder
with zipfile.ZipFile(zip_output_path, 'r') as zip_ref:
    zip_ref.extractall(zip_output_path.parent)

print(f"Extracted database to: {csv_output_path}")

print("Connecting to DuckDB to inject full geolocation mapping...")
con = duckdb.connect(str(db_path))

# The extracted CSV contains columns: id, postcode, latitude, longitude
con.execute(f"""
    CREATE OR REPLACE TABLE raw_postcode_lookup AS 
    SELECT 
        upper(replace(postcode, ' ', '')) as clean_postcode,  
        cast(latitude as double) as latitude,
        cast(longitude as double) as longitude
    FROM read_csv_auto('{str(csv_output_path)}');
""")

total_loaded = con.execute("SELECT COUNT(*) FROM raw_postcode_lookup;").fetchone()[0]
print(f"Success! Map populated: {total_loaded:,} postcodes successfully loaded.")

con.close()

# Optional: Clean up the temporary zip file to save space
if zip_output_path.exists():
    os.remove(zip_output_path)