# sample_dbt_project

A production-realistic dbt project built on [Snowflake Tasty Bytes](https://www.snowflake.com/en/data-cloud/workload/retail/tasty-bytes/) food truck POS data. Designed as a learning reference for dbt best practices and for demonstrating Snowflake's native dbt Git integration.

---

## Data Model

```
FROSTBYTE_TASTY_BYTES.RAW_POS  (source)
        │
        ▼
┌─────────────────────────────────┐
│           STAGING               │  materialized: view
│  stg_trucks                     │
│  stg_orders                     │
│  stg_menu                       │
│  stg_locations                  │
└───────────────┬─────────────────┘
                │     + seeds (country_codes, truck_brands)
                ▼
┌─────────────────────────────────┐
│         INTERMEDIATE            │  materialized: view
│  int_orders_enriched            │  ← orders + trucks + locations + regions
│  int_menu_with_margins          │  ← menu items + margin pcts + brand info
└───────────────┬─────────────────┘
                ▼
┌─────────────────────────────────┐
│            MARTS                │  materialized: table
│  fct_daily_truck_sales          │
│  fct_city_performance           │
│  fct_menu_profitability         │
└─────────────────────────────────┘
        consumed by exposures (Power BI, Tableau)

SNAPSHOTS:  snap_trucks  (SCD Type 2 — truck attribute history)
```

---

## Project Structure

```
sample_dbt_project/
├── analyses/              # Ad-hoc SQL compiled but not materialised
├── macros/                # Reusable Jinja/SQL macros
├── models/
│   ├── staging/           # 1:1 source cleans — views
│   ├── intermediate/      # Business-logic joins — views
│   └── marts/             # Aggregated facts — tables
├── seeds/                 # Static reference CSVs loaded into Snowflake
├── snapshots/             # SCD Type 2 history capture
├── tests/
│   └── generic/           # Custom generic tests (is_positive)
├── dbt_project.yml
├── packages.yml
└── profiles.yml           # ← NOT committed (.gitignore'd)
```

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| dbt Core ≥ 1.8 with `dbt-snowflake` adapter | `pip install dbt-snowflake` |
| Snowflake account with `FROSTBYTE_TASTY_BYTES` database | Available via Snowflake Marketplace (free sample) |
| A target database + warehouse | Default: `DBT_DEMO_DB` / `COMPUTE_WH` |

---

## Getting Started

### 1. Set up your profile

Copy `profiles.yml` and fill in your Snowflake credentials. The file is `.gitignore`'d — never commit it.

```yaml
sample_dbt_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your-account>        # e.g. myorg-myaccount
      user: <your-username>
      password: "{{ env_var('DBT_SNOWFLAKE_PASSWORD') }}"
      role: ACCOUNTADMIN
      database: DBT_DEMO_DB
      warehouse: COMPUTE_WH
      schema: DBT_DEMO
      threads: 4
```

Export your password before running any dbt command:

```bash
export DBT_SNOWFLAKE_PASSWORD=your_password_here
```

### 2. Install dbt packages

```bash
dbt deps
```

### 3. Load seed data

```bash
dbt seed
```

Loads `country_codes` and `truck_brands` CSV files into `DBT_DEMO_DB.seeds`.

### 4. Run all models

```bash
dbt run
```

Runs staging → intermediate → marts in dependency order.

### 5. Run all tests

```bash
dbt test
```

Runs:
- Built-in generic tests: `not_null`, `unique`, `accepted_values`, `relationships`
- Custom generic test: `is_positive` (defined in `tests/generic/is_positive.sql`)
- Singular test: `assert_positive_order_totals` (defined in `tests/assert_positive_order_totals.sql`)

### 6. Run snapshots

```bash
dbt snapshot
```

Captures SCD Type 2 history for the TRUCK source table into a `snapshots` schema.

### 7. Generate and serve docs

```bash
dbt docs generate
dbt docs serve
```

Opens a local web server at `http://localhost:8080` with the full lineage graph, column descriptions, and test coverage.

### 8. Full pipeline (one command)

```bash
dbt build
```

Runs seeds → models → snapshots → tests in the correct order.

---

## Key Concepts Demonstrated

| Concept | Where |
|---------|-------|
| Source definitions | `models/staging/sources.yml` |
| Staging → Intermediate → Mart layers | `models/` subdirectories |
| `ref()` and `source()` | All model SQL files |
| Project variables (`var()`) | `dbt_project.yml` + `int_orders_enriched.sql` |
| Custom macros | `macros/safe_divide.sql`, `macros/date_spine_filter.sql` |
| Surrogate key macro | `macros/generate_surrogate_key.sql` |
| Seeds (static CSVs) | `seeds/country_codes.csv`, `seeds/truck_brands.csv` |
| Column-level documentation | All `schema.yml` files |
| Built-in generic tests | `not_null`, `unique`, `accepted_values`, `relationships` |
| Custom generic test | `tests/generic/is_positive.sql` |
| Singular test | `tests/assert_positive_order_totals.sql` |
| SCD Type 2 snapshot | `snapshots/snap_trucks.sql` |
| Exposures (downstream dependencies) | `models/exposures.yml` |
| Analyses (ad-hoc SQL) | `analyses/revenue_by_brand.sql` |
| on-run-start / on-run-end hooks | `dbt_project.yml` |

---

## Snowflake Git Integration

This project is designed to be connected to Snowflake via the native dbt Git integration. Follow the steps in [RODE_dbt101_and_github_integration.md](../RODE_dbt101_and_github_integration.md) to:

1. Push this repo to GitHub
2. Create a Snowflake API integration for GitHub
3. Create a Git repository object in Snowflake
4. Create a dbt project object in Snowflake Workspaces
5. Execute models directly from Snowsight with `EXECUTE DBT PROJECT`

---

## Useful dbt Commands

```bash
# Run only staging models
dbt run --select staging

# Run a single model and all its upstream dependencies
dbt run --select +fct_daily_truck_sales

# Run only models tagged 'intermediate'
dbt run --select tag:intermediate

# Test a single model
dbt test --select stg_orders

# Override a project variable at runtime
dbt run --vars '{"start_date": "2022-01-01"}'

# Compile SQL without running (useful for debugging)
dbt compile --select fct_menu_profitability
```
