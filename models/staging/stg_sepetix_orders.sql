{{ config(materialized='view') }}

SELECT 
  CAST(order_id AS INT) as order_id,
  CAST(customer_id AS STRING) as customer_id,
  CAST(status AS STRING) as status,
  CAST(amount AS DECIMAL) as amount
FROM {{ ref('sepetix_orders') }}
WHERE status IN ('completed', 'pending', 'cancelled')