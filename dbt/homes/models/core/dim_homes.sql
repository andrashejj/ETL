with stg_homes as (
    select * from {{ ref('stg_homes') }}
)

select
    selling_price,
    list_price,
    property_age,
    bedrooms,
    bathrooms,
    total_rooms,
    property_size_acres,
    living_space_sqft,
    annual_taxes,
    -- Calculated metrics
    round(selling_price / nullif(living_space_sqft, 0), 2) as price_per_sqft,
    round(selling_price / nullif(list_price, 0), 3) as price_to_list_ratio,
    round(annual_taxes / nullif(selling_price, 0) * 100, 2) as tax_rate_pct
from stg_homes
