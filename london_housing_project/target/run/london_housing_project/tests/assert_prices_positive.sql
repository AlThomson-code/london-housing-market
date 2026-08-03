
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  select
    transaction_id,
    price
from "property_data"."main"."mart_property_transit_accessibility"
where price <= 0
  
  
      
    ) dbt_internal_test