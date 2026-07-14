select
    order_id,
    truck_id,
    location_id,
    customer_id,
    order_ts,
    order_currency,
    order_amount,
    order_tax_amount,
    order_discount_amount,
    order_total
from {{ source('raw_pos', 'ORDER_HEADER') }}
where order_total > 0
