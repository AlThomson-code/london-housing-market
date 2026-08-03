with property_distances as (

    select * 
    from "property_data"."main"."int_property_station_distance"
)


-- This assumes the average adult walks at roungly 4.8-5 km/h (which works out at around 12km per kilometer)
select 
    pd.*,

    case
        when pd.closest_station_distance_km <= 0.50 then 'Walker''s Paradise (<6 min walk)'
        when pd.closest_station_distance_km <= 1.00 then 'Commuter Friendly (6-12 min walk)'
        when pd.closest_station_distance_km <= 2.00 then 'Moderate Access (12-24 min walk)'
        else 'Transit Reliant (>24 min walk)'
    end as transit_accessibility_tier,


-- calcute the commuter score
greatest(
    0, 
    round(100 - (pd.closest_station_distance_km / 2.0) * 100, 0)
) as commuter_score

from property_distances as pd