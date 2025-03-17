-- was told to wait and just submit

{{ config(
    materialized='table',
    schema='dw_insurance_claims'
) }}

WITH customers AS (
    SELECT
        customer_id,
        first_name AS customer_first_name
    FROM {{ ref('stg_customers') }}
),
claims AS (
    SELECT
        claim_id,
        customer_id,
        claim_date AS date,
        claim_status,
        claim_amount,
        policy_id
    FROM {{ ref('stg_claims') }}
),
policies AS (
    SELECT
        policy_id,
        policy_type,
        policy_start_date,
        policy_end_date
    FROM {{ ref('stg_policies') }}
)

SELECT
    cl.claim_id,
    c.customer_first_name,
    cl.date,
    cl.claim_status,
    cl.claim_amount,
    cl.policy_id,
    p.policy_type,
    p.policy_start_date,
    p.policy_end_date
FROM claims cl
LEFT JOIN customers c ON cl.customer_id = c.customer_id
LEFT JOIN policies p ON cl.policy_id = p.policy_id;
