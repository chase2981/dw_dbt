{{ config(
    materialized = 'table',
    schema = 'dw_oliver'
    )
}}


select
employee_id as employee_key,
employee_id,
first_name,
last_name,
email,
phone_number,
hire_date,
position
FROM {{ source('oliver_landing', 'employee') }}