{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
) }}

WITH raw_orders AS (
    SELECT
        o.orderdate::date AS date_day,
        o.customerid,
        o.employeeid,
        o.ordermethod,
        o.ordernumber,
        e.storeid,
        ol.productid,
        ol.orderlineqty,
        ol.orderlineprice,
        ol.pointsearned
    FROM {{ source('final_landing', '"ORDER"') }} o
    INNER JOIN {{ source('final_landing', 'orderdetails') }} ol 
        ON o.ordernumber = ol.ordernumber
    INNER JOIN {{ source('final_landing', 'employee') }} e 
        ON o.employeeid = e.employeeid
),

joined_keys AS (
    SELECT
        d.date_key,
        cu.customer_key,
        e.employeekey,
        s.store_key,
        p.productkey,
        o.ordernumber,
        o.orderlineqty,
        o.orderlineprice,
        o.pointsearned
    FROM raw_orders o
    LEFT JOIN {{ ref('final_dim_date') }} d 
        ON d.date_day = o.date_day
    LEFT JOIN {{ ref('final_dim_customer') }} cu 
        ON cu.customerid = o.customerid
    LEFT JOIN {{ ref('final_dim_employee') }} e 
        ON e.employeeid = o.employeeid
    LEFT JOIN {{ ref('final_dim_store') }} s 
        ON s.storeid = o.storeid
    LEFT JOIN {{ ref('final_dim_product') }} p 
        ON p.productid = o.productid
)

SELECT
    date_key,
    productkey,
    store_key,
    employeekey,
    customer_key,
    ordernumber as order_key,
    orderlineqty,
    orderlineprice,
    orderlineqty * orderlineprice as orderline_total,
    pointsearned
FROM joined_keys
