select
    transaction_id,
    price
from "property_data"."main"."mart_property_transit_accessibility"
where price <= 0