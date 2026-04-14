
-- ============================================================================
-- STAGING MODEL: stg_orders.sql
-- ============================================================================
-- Amaç: Raw orders table'ı temizle, standardize et
-- Output: Clean, ready-to-use orders datası
-- Materialization: VIEW (her sorgulamada çalışır, hafif)

{{ config(
    tags=["staging"],
    description="Temiz ve standardize edilmiş orders tablosu"
) }}

SELECT 
    -- Primary Key
    order_id,
    
    -- Foreign Keys
    customer_id,
    
    -- Product Info
    product_name,
    category,
    
    -- Transaction Data
    quantity,
    price,
    (quantity * price) as order_line_amount,  -- Hesaplanan alan
    
    -- Dates
    CAST(order_date AS DATE) as order_date,
    
    -- Location
    city,
    
    -- Status (Standardize et: Teslim Edildi = Delivered)
    CASE 
        WHEN status = 'Teslim Edildi' THEN 'Delivered'
        WHEN status = 'İptal Edildi' THEN 'Cancelled'
        WHEN status = 'İade Edildi' THEN 'Returned'
        WHEN status = 'Kargoda' THEN 'In Transit'
        ELSE status
    END as order_status,
    
    -- Metadata
    CURRENT_TIMESTAMP() as _dbt_loaded_at,
    '{{ run_started_at }}' as _dbt_run_timestamp
    
FROM `project-505e76f5-40a4-4295-b57.sepetix.orders`

-- Veri kalitesi kontrolleri
WHERE 1=1
    AND order_id IS NOT NULL
    AND customer_id IS NOT NULL
    AND quantity > 0
    AND price > 0
