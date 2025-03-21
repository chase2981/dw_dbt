{{ config(
    materialized = 'table',
    schema = 'dw_oliver'
) }}


SELECT
    s.date_key,
    dd.day_of_week,
    dd.month_of_year,
    dd.month_name,
    dd.quarter_of_year,
    dd.year_number,
    s.customer_key,
    cu.first_name || ' ' || cu.last_name as customer_name,
    s.store_key,
    st.store_name,
    s.product_key,
    pr.product_name,
    s.employee_key,
    em.first_name || ' ' || em.last_name as employee_name,
    s.quantity,
    s.unit_price,
    s.dollars_sold
FROM {{ ref('fact_sales') }} s
LEFT JOIN {{ ref('oliver_dim_date') }} dd ON s.date_key = dd.date_key
LEFT JOIN {{ ref('oliver_dim_customer') }} cu ON s.customer_key = cu.customer_key
LEFT JOIN {{ ref('oliver_dim_store') }} st ON s.store_key = st.store_key
LEFT JOIN {{ ref('oliver_dim_product') }} pr ON s.product_key = pr.product_key
LEFT JOIN {{ ref('oliver_dim_employee') }} em ON s.employee_key = em.employee_key
