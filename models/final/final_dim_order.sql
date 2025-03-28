{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
    )
}}


select
{{ dbt_utils.generate_surrogate_key(['ordernumber']) }} as orderkey,
ordernumber,
ordermethod
FROM {{ source('final_landing', '"ORDER"') }}