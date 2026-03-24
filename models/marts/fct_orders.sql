{{ config(materialized='table') }}

SELECT 
  order_id,
  customer_id,
  status,
  amount,
  CASE 
    WHEN status = 'completed' THEN amount 
    ELSE 0 
  END as revenue,
  CASE 
    WHEN status = 'completed' THEN 1 
    ELSE 0 
  END as is_completed
FROM {{ ref('stg_sepetix_orders') }}