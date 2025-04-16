{{ config(materialized='view', schema='dw_samssubs') }}

with order_agg as (
    select
        cu.customer_key,
        cu.customerfname || ' ' || cu.customerlname as customer_name,
        pr.productname,
        sum(f.orderlineqty * pr.length) as inches_eaten,
        count(*) as total_orders,
        sum(f.pointsearned) as total_points_earned
    from {{ ref('fact_order_details') }} f
    join {{ ref('final_dim_customer') }} cu on f.customer_key = cu.customer_key
    join {{ ref('final_dim_product') }} pr on f.productkey = pr.productkey
    group by cu.customer_key, customer_name, pr.productname
),

ranked as (
    select *,
        row_number() over (partition by customer_key order by total_orders desc) as rn
    from order_agg
),

favorite as (
    select
        customer_key,
        customer_name,
        productname as favorite_sandwich,
        sum(inches_eaten) over (partition by customer_key) as total_inches_eaten,
        sum(total_orders) over (partition by customer_key) as total_orders,
        sum(total_points_earned) over (partition by customer_key) as total_points_earned
    from ranked
    where rn = 1
),

final as (
    select
        f.customer_key,
        f.customer_name,
        f.favorite_sandwich,
        f.total_inches_eaten,
        f.total_orders,
        f.total_points_earned,
        max(o.date_key) as last_order_date
    from favorite f
    join {{ ref('fact_order_details') }} o on f.customer_key = o.customer_key
    group by f.customer_key, f.customer_name, f.favorite_sandwich, f.total_inches_eaten, f.total_orders, f.total_points_earned
)

select * from final
