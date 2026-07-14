select
    truck_id,
    menu_type_id,
    primary_city,
    region,
    country,
    franchise_flag,
    year as truck_year,
    make,
    model,
    ev_flag,
    franchise_id,
    truck_opening_date
from {{ source('raw_pos', 'TRUCK') }}
