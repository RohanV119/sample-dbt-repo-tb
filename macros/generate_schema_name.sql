{% macro generate_schema_name(custom_schema_name, node) -%}
  {%- set dev_suffix = var('dev_suffix', '') -%}
  {%- if dev_suffix != '' -%}
    {{ target.schema }}_{{ dev_suffix }}
  {%- elif custom_schema_name is none -%}
    {{ target.schema }}
  {%- else -%}
    {{ custom_schema_name | trim }}
  {%- endif -%}
{%- endmacro %}