select
    location_id,
    placekey,
    location,
    city,
    region,
    iso_country_code,
    country
from {{ source('raw_pos', 'LOCATION') }}
