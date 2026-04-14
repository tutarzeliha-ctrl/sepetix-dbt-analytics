
-- ============================================================================
-- MARTS MODEL: fct_rfm_segmentation.sql
-- ============================================================================
-- Amaç: Recency-Frequency-Monetary analizi ile müşteri segmentleri oluştur
-- Output: RFM segment'leri (Champions, Loyal, At Risk, Lost, vb.)
-- Materialization: TABLE

{{ config(
    materialized='table',
    tags=["marts", "customers", "segmentation"],
    description="RFM (Recency, Frequency, Monetary) müşteri segmentasyonu"
) }}

WITH customer_rfm AS (
    SELECT 
        customer_id,
        -- RECENCY: Son sipariş kaç gün önce
        DATE_DIFF(CURRENT_DATE(), MAX(order_date), DAY) as days_since_last_purchase,
        
        -- FREQUENCY: Kaç kez sipariş verdi
        COUNT(DISTINCT order_id) as purchase_frequency,
        
        -- MONETARY: Toplam ne kadar harcadı
        SUM(quantity * price) as total_monetary_value,
        
        -- Tarihler
        MIN(order_date) as first_purchase_date,
        MAX(order_date) as last_purchase_date,
        
        -- Location
        ANY_VALUE(city) as customer_city
    FROM {{ ref('stg_orders') }}
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),

rfm_scores AS (
    SELECT 
        customer_id,
        days_since_last_purchase,
        purchase_frequency,
        ROUND(total_monetary_value, 2) as monetary_value,
        customer_city,
        first_purchase_date,
        last_purchase_date,
        
        -- RFM Skorları (1-4): 4 = en iyi
        NTILE(4) OVER (ORDER BY days_since_last_purchase DESC) as recency_score,    -- Ters: az gün = 4
        NTILE(4) OVER (ORDER BY purchase_frequency ASC) as frequency_score,         -- Normal: çok = 4
        NTILE(4) OVER (ORDER BY total_monetary_value ASC) as monetary_score         -- Normal: çok = 4
    FROM customer_rfm
),

rfm_segments AS (
    SELECT 
        customer_id,
        days_since_last_purchase,
        purchase_frequency,
        monetary_value,
        customer_city,
        first_purchase_date,
        last_purchase_date,
        recency_score,
        frequency_score,
        monetary_score,
        
        -- SEGMENT TANIMLAMASI
        CASE 
            -- CHAMPIONS: Yeni, sık, çok harcayan (R4, F3+, M3+)
            WHEN recency_score = 4 AND frequency_score >= 3 AND monetary_score >= 3 
                THEN 'Champions'
            
            -- LOYAL: Sık ve çok harcayan (F3+, M3+)
            WHEN frequency_score >= 3 AND monetary_score >= 3 
                THEN 'Loyal Customers'
            
            -- AT RISK: Eski, az, az harcayan (R1-2, F1-2, M1-2)
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2 
                THEN 'At Risk'
            
            -- LOST: Çok eski (180+ gün)
            WHEN days_since_last_purchase >= 180 
                THEN 'Lost Customers'
            
            -- POTENTIAL: Yeni ama az aktif (R4, F1-2 OR M1-2)
            WHEN recency_score = 4 AND (frequency_score <= 2 OR monetary_score <= 2) 
                THEN 'Potential Customers'
            
            -- OTHERS
            ELSE 'Others'
        END as rfm_segment
    FROM rfm_scores
)

SELECT 
    customer_id,
    rfm_segment,
    days_since_last_purchase,
    purchase_frequency,
    monetary_value,
    customer_city,
    first_purchase_date,
    last_purchase_date,
    recency_score,
    frequency_score,
    monetary_score,
    -- RFM Combined Score (Basit formül)
    ROUND((recency_score + frequency_score + monetary_score) / 3.0, 2) as rfm_combined_score,
    CURRENT_DATE() as _dbt_loaded_date
FROM rfm_segments
ORDER BY rfm_combined_score DESC, monetary_value DESC
