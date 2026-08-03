with source as (

    select * from {{ source('property_market', 'raw_postcode_lookup') }}

),

cleaned as (
select
        upper(trim(clean_postcode)) as postcode_key,
        cast(latitude as double) as latitude,
        cast(longitude as double) as longitude
    from source
    where latitude is not null 
      and longitude is not null


)

select * 
from cleaned