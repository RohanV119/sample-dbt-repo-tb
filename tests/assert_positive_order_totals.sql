-- Singular test: assert that no rows in stg_orders have a zero or negative order_total.
-- A failing row is any order that passes the staging filter but has a non-positive total.
-- If this query returns any rows the test fails.

select
    order_id,
    order_total
from {{ ref('stg_orders') }}
where order_total <= 0
