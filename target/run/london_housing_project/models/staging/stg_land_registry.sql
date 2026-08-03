
  
  create view "property_data"."main"."stg_land_registry__dbt_tmp" as (
    with source as (

    select * from "property_data"."main"."raw_land_registry"

),
renamed_and_cast as (

    select
        -- 1. Identifiers & Core Metrics
        cast(column00 as string) as transaction_id,
        cast(column01 as integer) as price,
        cast(column02 as timestamp) as transfer_date,
        
        -- 2. Location details (Crucial for TfL mapping)
        upper(trim(cast(column03 as string))) as postcode,

        -- Remove whitespace in the middle
        upper(replace(cast(column03 as string), ' ', '')) as clean_postcode,
        
        -- 3. Property Attributes
        cast(column04 as string) as property_type_code,
        cast(column05 as string) as is_new_build_code,
        cast(column06 as string) as duration_code, 

        -- format boroughs as title case
        
(
            select list_aggr(
                [upper(x[1]) || lower(x[2:]) for x in string_split(trim(cast(column11 as string)), ' ')], 
                'string_agg', 
                ' '
            )
        ) as borough,

        -- Keeping county in UPPERCASE so your downstream filter (county = 'GREATER LONDON') still works smoothly
        upper(trim(cast(column13 as string))) as county

    from source

),

filtered_london as (

    -- Filter out non-London data immediately to optimize local DuckDB performance
    select * 
    from renamed_and_cast
    where county = 'GREATER LONDON'

), geolocated as (

    select 
    l.*,
    pl.latitude,
    pl.longitude

    from filtered_london as l
    left join "property_data"."main"."stg_postcode_lookup" as pl
    on l.clean_postcode = pl.postcode_key


)

select * from geolocated
  );
