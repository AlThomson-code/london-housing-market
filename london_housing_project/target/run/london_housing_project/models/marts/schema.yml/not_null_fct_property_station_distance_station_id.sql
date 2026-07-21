
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select station_id
from "property_data"."main"."fct_property_station_distance"
where station_id is null



  
  
      
    ) dbt_internal_test