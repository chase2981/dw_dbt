{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
) }}

with page_data as (
    select
        page_url
    from {{ source('final_landing_web', 'web_traffic_events') }}
    where page_url is not null
),

deduplicated as (
    select distinct
        {{ dbt_utils.generate_surrogate_key(['page_url']) }} as page_key,
        page_url as page_url
    from page_data
)

select * from deduplicated
