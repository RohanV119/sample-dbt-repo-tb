with orders as (
    select * from {{ ref('stg_orders') }}
    where {{ date_spine_filter('order_ts') }}
),

trucks as (
    select * from {{ ref('stg_trucks') }}
),

locations as (
    select * from {{ ref('stg_locations') }}
),

country_codes as (
    select * from {{ ref('country_codes') }}
),

enriched as (
    select
        -- order identifiers
        o.order_id,
        o.truck_id,
        o.location_id,
        o.customer_id,
        o.order_ts,
        date_trunc('day', o.order_ts)::date as order_date,
        date_part('year', o.order_ts)        as order_year,
        date_part('month', o.order_ts)       as order_month,
        date_part('dow', o.order_ts)         as order_day_of_week,

        -- financials
        o.order_currency,
        o.order_amount,
        o.order_tax_amount,
        o.order_discount_amount,
        o.order_total,

        -- truck attributes
        t.menu_type_id,
        t.primary_city        as truck_city,
        t.region              as truck_region,
        t.country             as truck_country,
        t.franchise_flag,
        t.ev_flag,
        t.truck_year,
        t.make                as truck_make,
        t.model               as truck_model,

        -- location attributes
        l.city                as order_city,
        l.region              as order_region,
        l.iso_country_code,
        l.country             as order_country,

        -- enriched region flags
        c.region              as global_region,
        c.is_apac

    from orders o
    left join trucks    t  on o.truck_id    = t.truck_id
    left join locations l  on o.location_id = l.location_id
    left join country_codes c on l.iso_country_code = c.iso_country_code
)

select * from enriched
