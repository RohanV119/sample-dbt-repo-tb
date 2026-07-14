with orders as (
    select * from {{ ref('stg_orders') }}
),

trucks as (
    select * from {{ ref('stg_trucks') }}
),

menu as (
    select * from {{ ref('stg_menu') }}
),

truck_daily_sales as (
    select
        o.truck_id,
        t.primary_city,
        t.country,
        t.truck_year,
        t.make,
        t.model,
        m.truck_brand_name,
        date_trunc('day', o.order_ts)::date as order_date,
        count(o.order_id) as daily_order_count,
        sum(o.order_total) as daily_revenue
    from orders o
    inner join trucks t on o.truck_id = t.truck_id
    inner join menu m on t.menu_type_id = m.menu_type_id
    group by 1, 2, 3, 4, 5, 6, 7, 8
)

select
    *,
    round(daily_revenue / nullif(daily_order_count, 0), 2) as avg_order_value
from truck_daily_sales
