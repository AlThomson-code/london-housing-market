with source as (

    select * from {{ source('property_market', 'raw_tfl_stations') }}

),


renamed as (

select
        cast(objectid as integer) as station_id,
        cast(name as string) as station_name,
        cast(y as double) as latitude,      -- y is Latitude
        cast(x as double) as longitude,     -- x is Longitude
        cast(zone as string) as fare_zone,
        cast(network as string) as network_type
    from source


)

select * 
from renamed