with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

menu as (
    select * from {{ ref('int_menu_with_margins') }}
),

-- join orders to menu via menu_type_id to get item-level revenue
order_items as (
    select
        o.order_id,
        o.order_date,
        o.order_year,
        o.order_month,
        o.global_region,
        o.is_apac,
        m.menu_item_id,
        m.menu_item_name,
        m.item_category,
        m.item_subcategory,
        m.truck_brand_name,
        m.cuisine_type,
        m.sale_price_usd,
        m.cost_of_goods_usd,
        m.profit_per_item,
        m.margin_pct,
        m.margin_band
    from orders o
    inner join menu m on o.menu_type_id = m.menu_type_id
),

aggregated as (
    select
        menu_item_id,
        menu_item_name,
        item_category,
        item_subcategory,
        truck_brand_name,
        cuisine_type,
        margin_band,
        margin_pct,
        sale_price_usd,
        cost_of_goods_usd,
        profit_per_item,

        count(distinct order_id)                                        as total_orders,
        sum(sale_price_usd)                                             as total_revenue_usd,
        sum(profit_per_item)                                            as total_profit_usd,
        round({{ safe_divide('sum(profit_per_item)', 'sum(sale_price_usd)') }} * 100, 2)
                                                                        as realized_margin_pct,

        -- convenience breakdowns
        count(distinct case when is_apac then order_id end)             as apac_orders,
        count(distinct case when not is_apac then order_id end)         as non_apac_orders,
        min(order_date)                                                 as first_sold_date,
        max(order_date)                                                 as last_sold_date

    from order_items
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
)

select
    {{ generate_surrogate_key(['menu_item_id']) }}   as menu_profitability_key,
    *
from aggregated
