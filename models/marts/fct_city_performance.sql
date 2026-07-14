with orders as (
    select * from {{ ref('stg_orders') }}
),

locations as (
    select * from {{ ref('stg_locations') }}
),

city_metrics as (
    select
        l.city,
        l.country,
        l.region,
        count(distinct o.truck_id) as trucks_served,
        count(o.order_id) as total_orders,
        sum(o.order_total) as total_revenue,
        round(avg(o.order_total), 2) as avg_order_value,
        min(o.order_ts)::date as first_order_date,
        max(o.order_ts)::date as last_order_date
    from orders o
    inner join locations l on o.location_id = l.location_id
    group by 1, 2, 3
)

select
    *,
    round(total_revenue / nullif(total_orders, 0), 2) as revenue_per_order,
    datediff('day', first_order_date, last_order_date) as active_days
from city_metrics
