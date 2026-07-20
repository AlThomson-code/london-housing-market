
  
  create view "property_data"."main"."stg_postcode_lookup__dbt_tmp" as (
    with source as (

    select * from "property_data"."main"."raw_postcode_lookup"

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
  );
