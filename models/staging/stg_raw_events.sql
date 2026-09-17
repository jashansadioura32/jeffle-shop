-- Reads from a source rather than a seed, so the compiled manifest contains a real
-- source -> model edge for the eval fixtures to exercise.

with source as (

    select * from {{ source('ecom', 'raw_orders') }}

),

renamed as (

    select
        id as event_id,
        user_id as customer_id,
        order_date as event_date,
        status as event_status

    from source

)

select * from renamed
