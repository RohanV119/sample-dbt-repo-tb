-- Ad-hoc analysis: Revenue and margin by truck brand
-- This file is compiled by dbt but never materialised as a table/view.
-- Use it for exploratory SQL, one-off reporting, or sharing queries with stakeholders.
-- Run with: dbt compile  (output appears in target/compiled/)

select
    m.truck_brand_name,
    m.cuisine_type,
    m.margin_band,

    count(distinct o.order_id)                                          as total_orders,
    sum(o.order_total)                                                  as total_revenue_usd,
    round(avg(o.order_total), 2)                                        as avg_order_value,

    -- margin metrics from the enriched menu intermediate model
    round(avg(m.margin_pct), 2)                                         as avg_margin_pct,
    sum(m.profit_per_item * count(distinct o.order_id))                 as estimated_total_profit,

    -- time range
    min(o.order_date)                                                   as first_order_date,
    max(o.order_date)                                                   as last_order_date

from {{ ref('int_orders_enriched') }}   o
join {{ ref('int_menu_with_margins') }} m  on o.menu_type_id = m.menu_type_id

where o.order_date >= '{{ var("start_date") }}'::date

group by 1, 2, 3
order by total_revenue_usd desc
