{% test is_positive(model, column_name) %}
-- Custom generic test: asserts that all values in the specified column are > 0.
-- Wire into schema.yml with:   tests: [is_positive]
-- Returns failing rows (any row where the value is negative or zero).

select
    {{ column_name }} as failing_value
from {{ model }}
where {{ column_name }} < 0

{% endtest %}
