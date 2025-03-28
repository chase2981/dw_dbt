{{ config(
    materialized = 'table',
    schema = 'dw_samssubs'
) }}

SELECT
    f.date_key,
    d.day_of_week,
    d.month_of_year,
    d.month_name,
    d.quarter_of_year,
    d.year_number,

    f.event_key,
    e.event_name,

    f.source_key,
    s.source_name AS traffic_source,

    f.page_key,
    p.page_url,

    f.countofinteractions

FROM {{ ref('fact_web_events') }} f
LEFT JOIN {{ ref('final_dim_date') }} d ON f.date_key = d.date_key
LEFT JOIN {{ ref('final_dim_web_event') }} e ON f.event_key = e.event_key
LEFT JOIN {{ ref('final_dim_web_source') }} s ON f.source_key = s.source_key
LEFT JOIN {{ ref('final_dim_web_page') }} p ON f.page_key = p.page_key
