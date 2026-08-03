with borough_value_index as (
    select 
        borough,
        count(*) as sample_size,
        round(avg(price), 0) as avg_price,
        round(avg(commuter_score), 1) as avg_commuter_score,
        -- Commuter Score points per £100,000 spent
        round(avg(commuter_score) / (avg(price) / 100000.0), 2) as value_score
    from property_data.mart_property_transit_accessibility
    where borough is not null
    group by 1
    -- having count(*) >= 10
)
select 
    borough,
    avg_price,
    avg_commuter_score,
    value_score,
    -- Calculate ratio compared to the lowest value borough in London
    round(value_score / min(value_score) over(), 2) as ratio_vs_lowest
from borough_value_index
order by value_score desc;