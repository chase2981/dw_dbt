{{ config(materialized='view', schema='dw_samssubs') }}

-- Step 1: Base aggregation by customer-product-store-employee
with order_agg as (
    select
        cu.customer_key,
        cu.customerfname || ' ' || cu.customerlname as customer_name,
        pr.productname,
        st.address || ' ' || st.state as store_name,
        em.employeefname || ' ' || em.employeelname as employee_name,
        sum(f.orderlineqty * pr.length) as inches_eaten,
        count(*) as total_orders,
        sum(f.pointsearned) as total_points_earned,
        sum(f.orderlineqty * f.orderlineprice) as total_spent,
        min(f.date_key) as first_visit
    from {{ ref('fact_order_details') }} f
    join {{ ref('final_dim_customer') }} cu on f.customer_key = cu.customer_key
    join {{ ref('final_dim_product') }} pr on f.productkey = pr.productkey
    join {{ ref('final_dim_store') }} st on f.store_key = st.store_key
    join {{ ref('final_dim_employee') }} em on f.employeekey = em.employeekey
    group by cu.customer_key, customer_name, pr.productname, store_name, employee_name
),

-- Step 2: Rank within each customer by product, store, and employee
ranked as (
    select *,
        row_number() over (partition by customer_key order by total_orders desc) as rn_product,
        row_number() over (partition by customer_key, store_name order by total_orders desc) as rn_store,
        row_number() over (partition by customer_key, employee_name order by total_orders desc) as rn_employee
    from order_agg
),

-- Step 3: One row per customer with window rollups + favorites
favorite as (
    select
        customer_key,
        customer_name,
        first_value(productname) over (partition by customer_key order by rn_product) as favorite_sandwich,
        first_value(store_name) over (partition by customer_key order by rn_store) as most_visited_store,
        first_value(employee_name) over (partition by customer_key order by rn_employee) as favorite_employee,
        sum(inches_eaten) over (partition by customer_key) as total_inches_eaten,
        sum(total_orders) over (partition by customer_key) as total_orders,
        sum(total_points_earned) over (partition by customer_key) as total_points_earned,
        sum(total_spent) over (partition by customer_key) as total_money_spent,
        min(first_visit) over (partition by customer_key) as first_visit
    from ranked
    where rn_product = 1
),

-- Step 4: Attach last visit date
final as (
    select
        f.customer_key,
        f.customer_name,
        f.favorite_sandwich,
        f.most_visited_store,
        f.favorite_employee,
        f.total_inches_eaten,
        f.total_orders,
        f.total_points_earned,
        f.total_money_spent,
        f.first_visit,
        max(o.date_key) as last_order_date
    from favorite f
    join {{ ref('fact_order_details') }} o on f.customer_key = o.customer_key
    group by 
        f.customer_key, f.customer_name, f.favorite_sandwich, f.most_visited_store, f.favorite_employee,
        f.total_inches_eaten, f.total_orders, f.total_points_earned, f.total_money_spent, f.first_visit
)

select * from final
