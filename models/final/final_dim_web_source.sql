{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
) }}

with source_data as (
    select
        traffic_source
    from {{ source('final_landing_web', 'web_traffic_events') }}
    where traffic_source is not null
),

deduplicated as (
    select distinct
        {{ dbt_utils.generate_surrogate_key(['traffic_source']) }} as source_key,
        traffic_source as source_name
    from source_data
)

select * from deduplicated
