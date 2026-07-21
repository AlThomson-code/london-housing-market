with properties as (

    select * from {{ ref('stg_land_registry') }}

),

stations as (

    select * from {{ ref('stg_tfl_stations') }}

),

-- Cross join to evaluate every property against every station
cross_joined as (

    select
        p.transaction_id,
        p.price,
        p.transfer_date,
        p.clean_postcode as postcode,
        p.borough,
        p.property_type_code,
        s.station_id,
        s.station_name,
        s.fare_zone,
        s.network_type,
        
        -- Haversine formula in DuckDB SQL (returns distance in km)
        6371 * acos(
            cos(radians(p.latitude)) 
            * cos(radians(s.latitude)) 
            * cos(radians(s.longitude) - radians(p.longitude)) 
            + sin(radians(p.latitude)) 
            * sin(radians(s.latitude))
        ) as distance_to_station_km

    from properties p
    cross join stations s
    -- Filter out rows missing geocodes to prevent mathematical errors
    where p.latitude is not null 
      and s.latitude is not null

),

-- Rank stations by proximity for each property sale
ranked_distances as (

    select
        *,
        row_number() over (
            partition by transaction_id 
            order by distance_to_station_km asc
        ) as rank_order
    from cross_joined

)

-- Select the absolute closest transit point
select
    transaction_id,
    price,
    transfer_date,
    postcode,
    property_type_code,
    station_id,
    station_name,
    fare_zone,
    network_type,
    round(distance_to_station_km, 3) as closest_station_distance_km
from ranked_distances
where rank_order = 1