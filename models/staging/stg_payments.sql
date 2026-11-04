with source as (
    
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_payments') }}

),

renamed as (

    select
        id as payment_id,
        order_id,
        payment_method,

        -- amounts arrive in cents; expose them in dollars with an explicit unit
        amount / 100 as amt_usd

    from source

)

select * from renamed
