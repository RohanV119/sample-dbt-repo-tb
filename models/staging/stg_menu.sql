select
    menu_item_id,
    menu_type_id,
    menu_type,
    truck_brand_name,
    menu_item_name,
    item_category,
    item_subcategory,
    cost_of_goods_usd,
    sale_price_usd,
    round(sale_price_usd - cost_of_goods_usd, 2) as profit_per_item
from {{ source('raw_pos', 'MENU') }}
