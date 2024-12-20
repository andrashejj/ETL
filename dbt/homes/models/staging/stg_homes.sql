with raw_homes as (
    select
        cast("Sell" as decimal(12,2)) as selling_price,
        cast("__List_" as decimal(12,2)) as list_price,
        cast("__Age_" as integer) as property_age,
        cast("__Beds_" as integer) as bedrooms,
        cast("__Baths_" as decimal(4,1)) as bathrooms,
        cast("__Rooms_" as integer) as total_rooms,
        cast("__Acres_" as decimal(8,2)) as property_size_acres,
        cast("__Living_" as integer) as living_space_sqft,
        cast("__Taxes_" as decimal(10,2)) as annual_taxes,
        current_timestamp as _airbyte_extracted_at
    from {{ source('raw', 'Homes__test_') }}
)

select * from raw_homes
