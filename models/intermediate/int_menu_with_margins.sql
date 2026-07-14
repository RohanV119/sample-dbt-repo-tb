with menu as (
    select * from {{ ref('stg_menu') }}
),

brands as (
    select * from {{ ref('truck_brands') }}
),

with_margins as (
    select
        m.menu_item_id,
        m.menu_type_id,
        m.menu_type,
        m.truck_brand_name,
        m.menu_item_name,
        m.item_category,
        m.item_subcategory,
        m.cost_of_goods_usd,
        m.sale_price_usd,
        m.profit_per_item,

        -- calculated margin metrics
        round(
            {{ safe_divide('m.profit_per_item', 'm.sale_price_usd') }} * 100,
            2
        )                                                               as margin_pct,

        -- margin band classification
        case
            when {{ safe_divide('m.profit_per_item', 'm.sale_price_usd') }} >= 0.5
                then 'High'
            when {{ safe_divide('m.profit_per_item', 'm.sale_price_usd') }} >= 0.25
                then 'Medium'
            else 'Low'
        end                                                             as margin_band,

        -- brand metadata from seed
        b.cuisine_type,
        b.founding_year                                                 as brand_founding_year,
        b.is_active                                                     as brand_is_active

    from menu m
    left join brands b on m.truck_brand_name = b.truck_brand_name
)

select * from with_margins
