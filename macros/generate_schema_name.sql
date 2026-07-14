{% macro generate_schema_name(custom_schema_name, node) -%}
  {%- set dev_suffix = var('dev_suffix', '') -%}
  {%- set schema = custom_schema_name | trim if custom_schema_name else target.schema -%}
  {%- if dev_suffix != '' -%}
    {{ dev_suffix }}_{{ schema }}
  {%- else -%}
    {{ schema }}
  {%- endif -%}
{%- endmacro %}