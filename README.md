# London Housing & Commuter Value

An analytics engineering project evaluating London property prices against Transport for London (TfL) transit accessibility, built to demonstrate a full modern data stack: **Python -> DuckDB -> dbt -> Evidence.dev**.

**Live report:** https://althomson-code.github.io/london-housing-market/
**dbt docs & lineage graph:** https://althomson-code.github.io/london-housing-market/dbt-docs/

## Stack

| Layer | Tool |
|---|---|
| Ingestion | Python (`src/ingest.py`, `src/download_geocodes.py`) |
| Storage / compute | DuckDB |
| Transformation & testing | dbt |
| Reporting | [Evidence.dev](https://evidence.dev/) |
| Deployment | GitHub Actions -> GitHub Pages |

## Data sources

All raw data is fetched fresh by the pipeline, nothing is committed except the small static TfL station reference file:

- **HM Land Registry Price Paid Data** - downloaded per-run from `price-paid-data.publicdata.landregistry.gov.uk`
- **UK postcode -> lat/long lookup** - downloaded per-run from Free Map Tools
- **TfL station locations** (`data/stations.csv`) - static reference data, checked into the repo

## Pipeline

```
src/ingest.py            -> loads Price Paid Data + stations into DuckDB
src/download_geocodes.py -> loads UK postcode lat/long into DuckDB
dbt build                -> staging -> intermediate -> marts, with tests
dashboard/ (Evidence)    -> queries the marts and renders the report
```

### Run it yourself

```bash
pip install -r requirements.txt

python src/ingest.py
python src/download_geocodes.py

dbt build --profiles-dir .

cd dashboard
npm install
npm run sources
npm run dev
```

## Deployment

[.github/workflows/deploy.yml](.github/workflows/deploy.yml) runs the full pipeline above end-to-end - download raw data, `dbt build`, `dbt docs generate`, `evidence build` - and publishes the static report plus the dbt docs site to GitHub Pages. It runs on every push to `main`, on demand, and on a monthly schedule so the report picks up new Price Paid Data releases automatically.

## Repo layout

```
models/       dbt models (staging, intermediate, marts)
tests/        dbt data tests
src/          Python ingestion scripts
dashboard/    Evidence.dev report
```
