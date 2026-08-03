
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    property_station_pk as unique_field,
    count(*) as n_records

from "property_data"."main"."fct_property_station_distance"
where property_station_pk is not null
group by property_station_pk
having count(*) > 1



  
  
      
    ) dbt_internal_test