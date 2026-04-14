
-- ============================================================================
-- MARTS MODEL: fct_churn_risk.sql
-- ============================================================================
-- Amaç: Müşterileri inaktivite seviyesine göre segment'le
-- Output: Churn risk seviyeleri (Active, At Risk, Dormant, Churned)
-- Materialization: TABLE

{{ config(
    materialized='table',
    tags=["marts", "customers", "churn"],
    description="Müşteri churn risk segmentasyonu ve davranış metrikleri"
) }}

WITH customer_last_order AS (
    SELECT 
        customer_id,
        MAX(order_date) as last_order_date,
        COUNT(DISTINCT order_id) as lifetime_orders,
        SUM(quantity * price) as lifetime_value
    FROM {{ ref('stg_orders') }}
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),

customer_churn_risk AS (
    SELECT 
        customer_id,
        last_order_date,
        lifetime_orders,
        lifetime_value,
        DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) as days_since_purchase,
        
        -- Risk Segmenti (Business-friendly)
        CASE 
            WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) <= 30 THEN 'Active'
            WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) BETWEEN 31 AND 90 THEN 'At Risk'
            WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) BETWEEN 91 AND 180 THEN 'Dormant'
            ELSE 'Churned'
        END as churn_segment,
        
        -- Dönem Sınıflandırması
        CASE 
            WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) <= 30 THEN 1  -- Active
            WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) BETWEEN 31 AND 90 THEN 2
            WHEN DATE_DIFF(CURRENT_DATE(), last_order_date, DAY) BETWEEN 91 AND 180 THEN 3
            ELSE 4
        END as churn_priority
    FROM customer_last_order
)

SELECT 
    customer_id,
    last_order_date,
    lifetime_orders,
    ROUND(lifetime_value, 2) as lifetime_value,
    days_since_purchase,
    churn_segment,
    churn_priority,
    CURRENT_DATE() as _dbt_loaded_date
FROM customer_churn_risk
ORDER BY churn_priority ASC, days_since_purchase DESC
