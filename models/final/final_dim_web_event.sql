{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
) }}

with source_data as (
    select
        event_name
    from {{ source('final_landing_web', 'web_traffic_events') }}
    where event_name is not null
),

deduplicated as (
    select distinct
        {{ dbt_utils.generate_surrogate_key(['event_name']) }} as event_key,
        event_name
    from source_data
)

select * from deduplicated
