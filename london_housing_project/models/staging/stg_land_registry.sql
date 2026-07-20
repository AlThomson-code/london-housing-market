with source as (

    select * from {{ source('property_market', 'raw_land_registry') }}

),

renamed_and_cast as (

    select
        -- 1. Identifiers & Core Metrics
        cast(column00 as string) as transaction_id,
        cast(column02 as integer) as price,
        cast(column03 as timestamp) as transfer_date,
        
        -- 2. Location details (Crucial for the TfL mapping)
        upper(trim(cast(column04 as string))) as postcode,
        
        -- 3. Property Attributes
        cast(column05 as string) as property_type_code,
        cast(column06 as string) as is_new_build_code,
        cast(column07 as string) as duration_code, 
        
        -- 4. Address Specifics
        cast(column08 as string) as house_number_or_name, 
        cast(column09 as string) as flat_number,          
        cast(column10 as string) as street,
        cast(column11 as string) as locality,
        cast(column12 as string) as city,
        cast(column13 as string) as district,
        upper(trim(cast(column14 as string))) as county,
        cast(column15 as string) as ppd_category

    from source

),

filtered as (

    -- Filter out non-London data immediately to optimize local DuckDB performance
    select * 
    from renamed_and_cast
    where county = 'GREATER LONDON'

)

select * from filtered