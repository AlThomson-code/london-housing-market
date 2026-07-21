-- Custom test: Distance cannot be negative.
-- dbt tests pass if 0 rows are returned.

select
    transaction_id,
    closest_station_distance_km
from "property_data"."main"."fct_property_station_distance"
where closest_station_distance_km < 0