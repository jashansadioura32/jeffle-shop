{{ config(materialized='table', access='public') }}

-- A public model downstream of the contracted mart. Gives the eval fixtures a real
-- public-access node and a second hop, so blast radius has depth beyond 1.

select
    customer_id,
    count(*) as order_count,
    sum(total_amount) as lifetime_value,
    min(order_date) as first_order_date

from {{ ref('fct_order_payments') }}
group by 1
