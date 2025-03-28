{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
    )
}}


select
{{ dbt_utils.generate_surrogate_key(['p.productid']) }} as productkey,
p.productid,
p.producttype,
p.productname,
p.productcalories,
s.length,
s.breadtype
FROM {{ source('final_landing', 'product') }} p join {{ source('final_landing', 'sandwich') }} s on p.productid = s.productid