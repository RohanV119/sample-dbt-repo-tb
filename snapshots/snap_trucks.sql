{% snapshot snap_trucks %}

{{
    config(
        target_schema='snapshots',
        unique_key='truck_id',
        strategy='check',
        check_cols=['primary_city', 'region', 'country', 'franchise_flag', 'ev_flag', 'truck_opening_date']
    )
}}

/*
  SCD Type 2 snapshot of the TRUCK source table.

  Captures changes to key truck attributes over time using dbt's `check` strategy.
  A new snapshot record is created whenever any of the check_cols change.

  Useful for:
    - Auditing when a truck moved cities or changed franchise status
    - Historical reporting that needs the attribute as-of a specific date
    - Debugging unexpected changes to truck metadata

  Fields added by dbt:
    dbt_scd_id        — surrogate key for this specific version of the record
    dbt_updated_at    — when this snapshot record was last written
    dbt_valid_from    — start of the period this version was active
    dbt_valid_to      — end of the period (NULL for the current / latest version)
*/

select
    truck_id,
    menu_type_id,
    primary_city,
    region,
    country,
    franchise_flag,
    year        as truck_year,
    make,
    model,
    ev_flag,
    franchise_id,
    truck_opening_date,
    current_timestamp() as snapshotted_at

from {{ source('raw_pos', 'TRUCK') }}

{% endsnapshot %}
