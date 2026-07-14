{% macro date_spine_filter(timestamp_column, start_date_var='start_date') %}
    {{ timestamp_column }} >= '{{ var(start_date_var) }}'::date
{% endmacro %}
