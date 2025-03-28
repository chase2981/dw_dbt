{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
) }}

SELECT
    f.date_key,
    dd.day_of_week,
    dd.month_of_year,
    dd.month_name,
    dd.quarter_of_year,
    dd.year_number,

    f.customer_key,
    cu.customerfname || ' ' || cu.customerlname AS customer_name,
    cu.customerbday,
    cu.customerphone,

    f.store_key,
    st.address || ', ' || st.city || ', ' || st.state AS store_location,
    st.zip,

    f.productkey,
    pr.productname,
    pr.producttype,
    pr.productcalories,
    pr.length,
    pr.breadtype,

    f.employeekey,
    em.employeefname || ' ' || em.employeelname AS employee_name,
    em.employeebday,

    f.order_key,
    f.orderlineqty AS quantity,
    f.orderlineprice AS unit_price,
    f.orderline_total AS dollars_sold,
    f.pointsearned

FROM {{ ref('fact_order_details') }} f
LEFT JOIN {{ ref('final_dim_date') }} dd ON f.date_key = dd.date_key
LEFT JOIN {{ ref('final_dim_customer') }} cu ON f.customer_key = cu.customer_key
LEFT JOIN {{ ref('final_dim_store') }} st ON f.store_key = st.store_key
LEFT JOIN {{ ref('final_dim_product') }} pr ON f.productkey = pr.productkey
LEFT JOIN {{ ref('final_dim_employee') }} em ON f.employeekey = em.employeekey
