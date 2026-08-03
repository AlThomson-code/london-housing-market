# London Housing & Commuter Value Report

<p class="text-slate-500 text-lg -mt-2 mb-4">
    An analytical breakdown evaluating property price efficiency against Transport for London (TfL) transit accessibility.
</p>

```sql kpi_data
select 
    count(*) as total_properties,
    round(avg(price), 0) as avg_price,
    round(avg(commuter_score), 1) as avg_commuter_score,
    round(avg(closest_station_distance_km), 2) as avg_distance
from london_property.mart_property_transit_accessibility
where borough is not null
```

<!-- 1. CORE KPI METRICS -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    <div class="p-5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm relative overflow-hidden">
        <div class="absolute top-0 left-0 right-0 h-1 bg-blue-500"></div>
        <BigValue data={kpi_data} value=total_properties title="Properties Analyzed" subtitle="Geocoded market sample" />
    </div>

    <div class="p-5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm relative overflow-hidden">
        <div class="absolute top-0 left-0 right-0 h-1 bg-emerald-500"></div>
        <BigValue data={kpi_data} value=avg_price title="Avg Market Price" fmt=gbp subtitle="Across all London boroughs" />
    </div>

    <div class="p-5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm relative overflow-hidden">
        <div class="absolute top-0 left-0 right-0 h-1 bg-indigo-500"></div>
        <BigValue data={kpi_data} value=avg_commuter_score title="Avg Commuter Score" subtitle="Index rating (1 - 100)" />
    </div>

    <div class="p-5 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 shadow-sm relative overflow-hidden">
        <div class="absolute top-0 left-0 right-0 h-1 bg-amber-500"></div>
        <BigValue data={kpi_data} value=avg_distance title="Avg Station Proximity" fmt='0.0 "km"' subtitle="Distance to nearest TfL hub" />
    </div>
</div>

<!-- EXECUTIVE SUMMARY BANNER -->
<div class="p-5 rounded-xl bg-emerald-50/80 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800 mb-8">
    <h3 class="text-sm font-bold uppercase tracking-wider text-emerald-800 dark:text-emerald-300 mb-1">
        Key Executive Finding
    </h3>
    <p class="text-sm text-emerald-900 dark:text-emerald-200 leading-relaxed">
        While proximity to TfL stations commands a premium in central boroughs, select Outer London boroughs deliver superior transit access per pound spent. Outer regions achieve up to <strong>3x higher commuter scores per £100k</strong> compared to central prime property zones.
    </p>
</div>

---

<!-- 2. THE MACRO STORY: PRICE VS DISTANCE -->
## The Macro Trade-off: Housing Cost vs. Station Proximity

<p class="text-sm text-slate-500 mb-4">
    Evaluating average property prices against distance to the nearest station. Boroughs in the <strong>bottom-left quadrant</strong> represent high-value opportunities (lower costs + shorter station walks).
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

<div class="p-4 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 shadow-sm mb-8">
    <ScatterPlot 
        data={borough_metrics} 
        x=avg_station_distance_km 
        y=avg_price 
        pointName=borough
        tooltipTitle=borough
        xTitle="Average Distance to Nearest Station (km)"
        yTitle="Average Property Price (£)"
        yFmt=gbp
        tooltip_fields={['borough', 'avg_price', 'avg_station_distance_km', 'avg_commuter_score']}
    />
</div>

---

<!-- 3. LOCAL EXPLORATION: MAP AND RANKINGS -->
## Geographic Deep Dive: Mapping Accessibility & Value

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
limit 1000
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

<Grid cols=4 gap=l class="my-6">
    <div class="bg-slate-50 dark:bg-slate-900 p-5 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm flex flex-col justify-between">
        <div>
            <h3 class="text-base font-semibold text-slate-900 dark:text-slate-100 mb-3">
                Focus Borough
            </h3>

            <Dropdown
                name=borough
                data={borough_options}
                value=borough
                defaultValue="All"
                title="Select Region"
            />
        </div>

        <div class="mt-6 pt-4 border-t border-slate-200 dark:border-slate-800 text-xs text-slate-600 dark:text-slate-400 space-y-2">
            <span class="font-semibold block text-slate-700 dark:text-slate-300">Map Legend:</span>
            <div class="flex items-center gap-2">
                <span class="inline-block w-3 h-3 rounded-full bg-emerald-500"></span>
                <span>High Commuter Score</span>
            </div>
            <div class="flex items-center gap-2">
                <span class="inline-block w-3 h-3 rounded-full bg-amber-500"></span>
                <span>Medium Score</span>
            </div>
            <div class="flex items-center gap-2">
                <span class="inline-block w-3 h-3 rounded-full bg-rose-500"></span>
                <span>Low Score</span>
            </div>
            <div class="flex items-center gap-2 pt-1">
                <span class="inline-block w-2.5 h-2.5 rounded-full bg-black dark:bg-white"></span>
                <span>TfL Station</span>
            </div>
        </div>
    </div>

    <div style="grid-column: span 3;" class="rounded-xl overflow-hidden border border-slate-200 dark:border-slate-800 shadow-sm">
        <BaseMap title="London Property Listings & TfL Network" height=500>
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
                colorPalette={['#ef4444', '#f59e0b', '#10b981']}
                tooltip={[
                    {id: 'price', title: 'Property Price', fmt: 'gbp'},
                    {id: 'commuter_score', title: 'Commuter Score'},
                    {id: 'borough', title: 'Borough'}
                ]}
            />
        </BaseMap>
    </div>
</Grid>

---

<!-- 4. VALUE RANKINGS -->
## Value Rankings: Maximizing Transit Accessibility per £100k

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
```

<div class="p-4 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 shadow-sm mb-8">
    <BarChart 
        data={top_value} 
        x=borough 
        y=value_score 
        title="Value Score Index (Commuter Score achieved per £100,000 spent)"
        yTitle="Value Index Score"
        color="#10b981"
        swapXY=true
    />
</div>

---

<!-- 5. DETAILED DATA BREAKDOWN -->
## Complete Borough Metrics

<div class="p-2 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-950 shadow-sm mb-8">
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

<!-- 6. DATA PROVENANCE -->
<div class="mt-12 pt-6 border-t border-slate-200 dark:border-slate-800 text-xs text-slate-500">
    <h3 class="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-2">Data Provenance</h3>
    <p>
        Data combined from <strong>Transport for London (TfL) Open Data API</strong> (station coordinates and network topology) and <strong>HM Land Registry Price Paid Data</strong> geocoded against UK Office for National Statistics (ONS) Postcode centroids.
    </p>
</div>