
-- ============================================================================
-- MARTS MODEL: fct_cohort_analysis.sql
-- ============================================================================
-- Amaç: Müşteri cohort'larının (ay bazında) retention'unu izle
-- Output: Cohort retention metrikleri
-- Materialization: TABLE

{{ config(
    materialized='table',
    tags=["marts", "retention", "cohort"],
    description="Müşteri cohort analizi ve retention metrikleri"
) }}

WITH first_purchase AS (
    SELECT 
        customer_id,
        DATE_TRUNC(MIN(order_date), MONTH) as cohort_month
    FROM {{ ref('stg_orders') }}
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),

monthly_activity AS (
    SELECT 
        o.customer_id,
        DATE_TRUNC(o.order_date, MONTH) as purchase_month,
        COUNT(DISTINCT o.order_id) as orders_count,
        SUM(o.quantity * o.price) as revenue
    FROM {{ ref('stg_orders') }} o
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id, DATE_TRUNC(o.order_date, MONTH)
)

SELECT 
    fp.cohort_month,
    ma.purchase_month,
    DATE_DIFF(ma.purchase_month, fp.cohort_month, MONTH) as months_since_first_purchase,
    COUNT(DISTINCT ma.customer_id) as active_customers,
    ROUND(SUM(ma.revenue), 2) as total_revenue,
    ROUND(AVG(ma.orders_count), 2) as avg_orders,
    
    -- Retention rate hesaplama (ilk ay müşterisi sayısına göre yüzde)
    ROUND(
        COUNT(DISTINCT ma.customer_id) / 
        (SELECT COUNT(DISTINCT customer_id) FROM first_purchase WHERE cohort_month = fp.cohort_month) * 100,
        1
    ) as retention_rate_percent,
    
    CURRENT_DATE() as _dbt_loaded_date
FROM first_purchase fp
JOIN monthly_activity ma 
    ON fp.customer_id = ma.customer_id
GROUP BY fp.cohort_month, ma.purchase_month
ORDER BY fp.cohort_month DESC, months_since_first_purchase ASC
