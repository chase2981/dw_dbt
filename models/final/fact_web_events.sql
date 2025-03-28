{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
) }}

with raw_events as (
    select
        event_name,
        traffic_source,
        page_url,
        event_timestamp::date as date_key
    from {{ source('final_landing_web', 'web_traffic_events') }}
    where event_name is not null 
      and traffic_source is not null 
      and page_url is not null
),

with_keys as (
    select
        r.date_key,

        e.event_key,
        s.source_key,
        p.page_key

    from raw_events r
    left join {{ ref('final_dim_web_event') }} e 
        on r.event_name = e.event_name
    left join {{ ref('final_dim_web_source') }} s 
        on r.traffic_source = s.source_name
    left join {{ ref('final_dim_web_page') }} p 
        on r.page_url = p.source_name
),

aggregated as (
    select
        date_key,
        event_key,
        source_key,
        page_key,
        count(*) as countofinteractions
    from with_keys
    group by 1, 2, 3, 4
)

select * from aggregated
