{% macro generate_surrogate_key(field_list) %}
    {# Thin wrapper around dbt_utils.generate_surrogate_key.
       Falls back to a manual MD5 concat if dbt_utils is unavailable. #}
    {% if execute %}
        {{ return(dbt_utils.generate_surrogate_key(field_list)) }}
    {% else %}
        md5(
            {% for field in field_list %}
                coalesce(cast({{ field }} as varchar), '')
                {% if not loop.last %} || '-' || {% endif %}
            {% endfor %}
        )
    {% endif %}
{% endmacro %}
