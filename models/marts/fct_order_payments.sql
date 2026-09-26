{{
    config(
        materialized='',
        unique_key='order_id',
        on_schema_change='fail',
        contract={'enforced': true}
    )
}}

-- Incremental + enforced contract in one model, because both are severity-escalation
-- paths that upstream jaffle_shop cannot exercise: it has no incremental models and no
-- contracts, so those branches of report.assess were dead code against a real manifest.

with payments as (

    select
        order_id,
        sum(amount) as total_amount

    from {{ ref('stg_payments') }}
    group by 1

)

select
    o.order,
    o.customer_id,
    o.order_date,
    coalesce(p.total_amount, 0) as total_amount

from {{ ref('stg_orders') }} as o
left join payments as p
    on o.order_id = p.order_id

{% if is_incremental() %}
    where o.order_date > (select coalesce(max(order_date), '1900-01-01') from {{ this }})
{% endif %}
