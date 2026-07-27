# London Property & Transport Value Engine

<p class="text-slate-500 text-lg -mt-2 mb-4">
    An analytics engineering showcase analyzing residential property valuations relative to Transport for London (TfL) accessibility.
</p>
<!-- ARCHITECTURE & PORTFOLIO LINKS -->
<div class="flex flex-wrap gap-2 items-center mb-8 text-xs">
    <a href="https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME" target="_blank" class="no-underline px-3 py-1.5 rounded-md bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 font-medium transition-colors flex items-center gap-1.5">
        💻 GitHub Repository
    </a>
    <a href="https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/dbt_docs" target="_blank" class="no-underline px-3 py-1.5 rounded-md bg-orange-50 dark:bg-orange-950/40 hover:bg-orange-100 text-orange-700 dark:text-orange-300 font-medium transition-colors border border-orange-200 dark:border-orange-900 flex items-center gap-1.5">
        📙 dbt Lineage & Docs
    </a>
    <span class="text-slate-400">|</span>
    <span class="text-slate-500 dark:text-slate-400">
        Engineered with <strong>DuckDB</strong>, <strong>dbt Core</strong>, & <strong>Evidence.dev</strong>
    </span>
</div>

---


```sql kpi_data
select 
    count(*) as total_properties,
    round(avg(price), 0) as avg_price,
    round(avg(commuter_score), 1) as avg_commuter_score,
    round(avg(closest_station_distance_km), 2) as avg_distance
from london_property.mart_property_transit_accessibility
where borough is not null
```
---
<!-- SECTION 1: CORE KPI METRICS -->
<!-- SECTION 1: CORE KPI METRICS -->
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
    <!-- Card 1: Total Properties -->
    <div class="p-5 rounded-xl border border-slate-200 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/50 shadow-sm hover:shadow-md hover:border-slate-300 transition-all">
        <BigValue 
            data={kpi_data} 
            value=total_properties 
            title="Total Properties Analyzed" 
            fmt="num0"
        />
    </div>

    <!-- Card 2: Avg Market Price -->
    <div class="p-5 rounded-xl border border-slate-200 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/50 shadow-sm hover:shadow-md hover:border-slate-300 transition-all">
        <BigValue 
            data={kpi_data} 
            value=avg_price 
            title="Avg Market Price" 
            fmt=gbp 
        />
    </div>

    <!-- Card 3: Avg Commuter Score -->
    <div class="p-5 rounded-xl border border-slate-200 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/50 shadow-sm hover:shadow-md hover:border-slate-300 transition-all">
        <BigValue 
            data={kpi_data} 
            value=avg_commuter_score 
            title="Avg Commuter Score" 
            fmt="0.0"
        />
    </div>

    <!-- Card 4: Avg Distance -->
    <div class="p-5 rounded-xl border border-slate-200 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/50 shadow-sm hover:shadow-md hover:border-slate-300 transition-all">
        <BigValue 
            data={kpi_data} 
            value=avg_distance 
            title="Avg Dist to Station" 
            fmt='0.0 "km"'
        />
    </div>
</div>

---
<!-- SECTION 2: MAP & BOROUGH FILTER -->
## Interactive Property & Transport Map

```sql borough_options
select 'All' as borough
union all
(
    select distinct borough 
    from london_property.mart_property_transit_accessibility
    where borough is not null
    order by borough asc
)
```

```sql map_data
select 
    latitude,
    longitude,
    postcode,
    commuter_score,
    transit_accessibility_tier,
    price,
    borough
from london_property.mart_property_transit_accessibility
where latitude is not null
  and (
    '${inputs.borough.value}' = 'All' 
    or '${inputs.borough.value}' = 'undefined'
    or borough = '${inputs.borough.value}'
  )

```

```sql stations_data
select 
    station_id,
    station_name,
    latitude,
    longitude
from london_property.stg_tfl_stations
where latitude is not null
```
<div class="grid grid-cols-1 md:grid-cols-12 gap-6 my-6">
    <!-- LEFT PANEL -->
    <div class="md:col-span-4 lg:col-span-3 bg-slate-50 dark:bg-slate-900 p-4 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm flex flex-col space-y-6">
        <div>
            <h3 class="text-xs font-bold uppercase tracking-wider text-slate-700 dark:text-slate-200 mb-2 pl-0.5">
                Borough Filter
            </h3>

            <!-- Removed built-in title to pull control flush to the left -->
            <div class="w-full -ml-1">
                <Dropdown
                    name=borough
                    data={borough_options}
                    value=borough
                    defaultValue="All"
                />
            </div>
        </div>

        <div class="pt-4 border-t border-slate-200 dark:border-slate-800 text-xs text-slate-600 dark:text-slate-400 space-y-2.5">
            <span class="font-semibold block text-slate-700 dark:text-slate-300">Map Layer Legend</span>
            <div class="flex items-center gap-2">
                <span class="inline-block w-3 h-3 rounded-full bg-emerald-500 shrink-0"></span>
                <span>High Commuter Accessibility</span>
            </div>
            <div class="flex items-center gap-2">
                <span class="inline-block w-3 h-3 rounded-full bg-amber-500 shrink-0"></span>
                <span>Medium Accessibility</span>
            </div>
            <div class="flex items-center gap-2">
                <span class="inline-block w-3 h-3 rounded-full bg-rose-500 shrink-0"></span>
                <span>Low Accessibility</span>
            </div>
            <div class="flex items-center gap-2 pt-1">
                <span class="inline-block w-2.5 h-2.5 rounded-full bg-slate-900 dark:bg-white shrink-0"></span>
                <span>TfL Transit Hub</span>
            </div>
        </div>
    </div>

    <!-- RIGHT MAP CONTAINER -->
    <div class="md:col-span-8 lg:col-span-9 rounded-xl overflow-hidden border border-slate-200 dark:border-slate-800 shadow-sm">
        <BaseMap title="London Commuter Accessibility & Station Network" height=520>
            <Points 
                data={stations_data} 
                lat=latitude 
                long=longitude 
                pointName=station_name
                color="#000000" 
                size=4
            />

            <Points 
                data={map_data} 
                lat=latitude 
                long=longitude 
                value=commuter_score 
                legend=false 
                colorPalette={['#ef4444', '#f59e0b', '#10b981']}
                tooltip={[
                    {id: 'price', title: 'Property Price', fmt: 'gbp'},
                    {id: 'commuter_score', title: 'Commuter Score'},
                    {id: 'borough', title: 'Borough'}
                ]}
            />
        </BaseMap>
    </div>
</div>

---

<!-- SECTION 3: BOROUGH VALUE ANALYTICS -->
## Value Quadrant: Price vs. Station Proximity

<p class="text-sm text-slate-500 mb-4">
    Boroughs located in the <strong>bottom-left quadrant</strong> offer optimal commuting efficiency relative to lower median housing prices.
</p>

```sql borough_metrics
select 
    borough,
    count(*) as total_sales,
    round(avg(price), 0) as avg_price,
    round(avg(closest_station_distance_km), 2) as avg_station_distance_km,
    round(avg(commuter_score), 1) as avg_commuter_score,
    round(avg(price) / nullif(avg(closest_station_distance_km), 0), 0) as price_per_km_to_station
from london_property.mart_property_transit_accessibility
where borough is not null
group by 1
having count(*) >= 10
order by avg_price asc
```

<div class="p-4 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 shadow-sm">

    <ScatterPlot 
        data={borough_metrics} 
        x=avg_station_distance_km 
        y=avg_price 
        title="London Borough Housing Prices vs. Station Distance"
        pointName=borough
        tooltipTitle=borough
        xTitle="Average Distance to Nearest Station (km)"
        yTitle="Average Property Price (£)"
        yFmt=gbp
        tooltip_fields={['borough', 'avg_price', 'avg_station_distance_km', 'avg_commuter_score']}
    />
    
</div>
<Alert status="info">
    <strong>Analytical Takeaway:</strong> Barking, Croydon and Wembley represent the high-effieciency commuter 'Sweet Spots'."
</Alert>

---

<!-- SECTION 4: RANKINGS -->
## High Value Rankings


<Alert status="info" class="mb-4">
    <strong>How to read this chart:</strong> This index measures <em>"Transit Bang for Your Buck."</em> It calculates how much commuter accessibility a borough offers per £100,000 of home price. 
    Boroughs at the <strong>top of the chart</strong> give you the best access to TfL stations at the most affordable relative price point.
</Alert>

```sql top_value
with borough_metrics as (
    select 
        borough,
        count(*) as total_sales,
        round(avg(price), 0) as avg_price,
        round(avg(closest_station_distance_km), 2) as avg_station_distance_km,
        round(avg(commuter_score), 1) as avg_commuter_score
    from london_property.mart_property_transit_accessibility
    where borough is not null
    group by 1
    having count(*) >= 10
)
select 
    borough,
    total_sales,
    avg_price,
    avg_station_distance_km,
    avg_commuter_score,
    round((avg_commuter_score / nullif(avg_price / 100000.0, 0)), 2) as value_score
from borough_metrics
order by value_score desc
limit 10
```

<div class="p-4 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 shadow-sm">
    <BarChart 
        data={top_value} 
        x=borough 
        y=value_score 
        title="Commuter Accessibility Index per £100,000 Property Expenditure"
        yTitle="Value Index"
        color="#10b981"
        swapXY=true
    />
</div>

---

<!-- SECTION 5: DATA TABLE -->
## Comprehensive Borough Breakdown

<div class="p-2 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 shadow-sm">
    <DataTable data={borough_metrics} search=true sort=price_per_km_to_station>
        <Column id=borough title="Borough" />
        <Column id=total_sales title="Total Sales" />
        <Column id=avg_price title="Avg Price" fmt=gbp />
        <Column id=avg_station_distance_km title="Avg Dist (km)" />
        <Column id=avg_commuter_score title="Commuter Score" />
        <Column id=price_per_km_to_station title="Price / Distance Ratio" fmt=gbp />
    </DataTable>
</div>

---
<!-- SECTION 6: CITATIONS & PIPELINE ARCHITECTURE -->
<div class="mt-12 pt-6 border-t border-slate-200 dark:border-slate-800">
    <h3 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-4">Pipeline Architecture & Data Sources</h3>
    <Grid cols=3 gap=m>
        <div class="p-4 rounded-lg bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800">
            <h4 class="font-semibold text-slate-800 dark:text-slate-200 text-sm mb-1">🚆 Transit API</h4>
            <p class="text-xs text-slate-500 leading-relaxed">
                <strong>Source:</strong> TfL Unified API<br/>
                Coordinates & network mapping for Underground, Overground, and DLR stations.
            </p>
        </div>

        <div class="p-4 rounded-lg bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800">
            <h4 class="font-semibold text-slate-800 dark:text-slate-200 text-sm mb-1">🏡 Property Sales</h4>
            <p class="text-xs text-slate-500 leading-relaxed">
                <strong>Source:</strong> <a href="https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads#may-2026-data-current-month" target="_blank" class="text-emerald-600 dark:text-emerald-400 hover:underline font-medium">HM Land Registry Price Paid Data for the month of May.
            </p>
        </div>

        <div class="p-4 rounded-lg bg-slate-50 dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800">
            <h4 class="font-semibold text-slate-800 dark:text-slate-200 text-sm mb-1">🛠 Data Transformation</h4>
            <p class="text-xs text-slate-500 leading-relaxed">
                <strong>Pipeline:</strong> DuckDB & dbt Core<br/>
                Spatial joins, distance calculations, and aggregation into analytical data marts.
            </p>
        </div>
    </Grid>
</div>