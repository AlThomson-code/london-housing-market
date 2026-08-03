
    
    

select
    transaction_id as unique_field,
    count(*) as n_records

from "property_data"."main"."int_property_station_distance"
where transaction_id is not null
group by transaction_id
having count(*) > 1


