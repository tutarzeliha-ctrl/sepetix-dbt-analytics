
-- ============================================================================
-- MARTS MODEL: fct_repeat_customers.sql
-- ============================================================================
-- Amaç: En az 2 kez sipariş veren müşterileri analiz et
-- Output: Repeat customer metrics (Business ready)
-- Materialization: TABLE (performans için)

{{ config(
    materialized='table',
    tags=["marts", "customers"],
    description="Tekrar alış yapan müşterilerin detaylı analizi"
) }}

WITH customer_orders AS (
    SELECT 
        customer_id,
        order_id,
        category,
        quantity,
        price,
        order_date,
        city
    FROM {{ ref('stg_orders') }}
    WHERE order_status = 'Delivered'  -- Sadece başarılı siparişler
),

customer_metrics AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) as total_orders,              -- Kaç sipariş
        COUNT(DISTINCT category) as unique_categories,         -- Kaç kategori
        SUM(quantity) as total_quantity,                       -- Toplam ürün
        SUM(quantity * price) as total_spent,                  -- Toplam harcama
        AVG(quantity * price) as avg_order_value,              -- Ort. sipariş değeri
        STRING_AGG(DISTINCT category, ', ') as preferred_categories,
        ANY_VALUE(city) as customer_city,
        MIN(order_date) as first_purchase_date,
        MAX(order_date) as last_purchase_date
    FROM customer_orders
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) >= 2  -- EN AZ 2 SIPARIŞ
)

SELECT 
    customer_id,
    total_orders,
    ROUND(total_spent, 2) as total_spent_lira,
    ROUND(avg_order_value, 2) as avg_order_value,
    total_quantity,
    unique_categories,
    customer_city,
    preferred_categories,
    first_purchase_date,
    last_purchase_date,
    DATE_DIFF(last_purchase_date, first_purchase_date, DAY) as days_as_customer,
    CURRENT_DATE() as _dbt_loaded_date
FROM customer_metrics
ORDER BY total_spent_lira DESC
