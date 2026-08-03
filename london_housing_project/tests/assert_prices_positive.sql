select
    transaction_id,
    price
from {{ ref('mart_property_transit_accessibility') }}
where price <= 0