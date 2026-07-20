with properties as (

    select * from {{ ref('stg_land_registry') }}

),

stations as (

    select * from {{ ref('stg_tfl_stations') }}

),

-- Calculate the distance between every property sale and every station
cross_joined as (

    select
        p.transaction_id,
        p.price,
        p.transfer_date,
        p.postcode,
        p.property_type_code,
        s.station_id,
        s.station_name,
        s.fare_zone,
        s.network_type,
        
        -- Haversine Distance Formula in pure SQL (returns distance in kilometers)
        6371 * acos(
            cos(radians(p.latitude)) 
            * cos(radians(s.latitude)) 
            * cos(radians(s.longitude) - radians(p.longitude)) 
            + sin(radians(p.latitude)) 
            * sin(radians(s.latitude))
        ) as distance_to_station_km

    from properties p
    cross join stations s

),

-- Find only the single closest station for each individual transaction
ranked_distances as (

    select
        *,
        row_number() over (
            partition by transaction_id 
            order by distance_to_station_km asc
        ) as rank_order
    from cross_joined

)

-- Filter for the absolute closest station
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