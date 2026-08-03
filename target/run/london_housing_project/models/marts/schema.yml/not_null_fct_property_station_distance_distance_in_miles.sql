
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select distance_in_miles
from "property_data"."main"."fct_property_station_distance"
where distance_in_miles is null



  
  
      
    ) dbt_internal_test