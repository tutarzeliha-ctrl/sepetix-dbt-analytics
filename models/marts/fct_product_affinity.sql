
-- ============================================================================
-- MARTS MODEL: fct_product_affinity.sql
-- ============================================================================
-- Amaç: Hangi ürün kategorilerinin birlikte alındığını anla (cross-sell fırsatları)
-- Output: Kategori çiftleri ve müşteri sayıları
-- Materialization: TABLE

{{ config(
    materialized='table',
    tags=["marts", "products", "cross-sell"],
    description="Ürün kategorisi affinity analizi (beraber satış)"
) }}

WITH customer_categories AS (
    SELECT 
        customer_id,
        ARRAY_AGG(DISTINCT category) as bought_categories
    FROM {{ ref('stg_orders') }}
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
    HAVING ARRAY_LENGTH(ARRAY_AGG(DISTINCT category)) >= 2  -- En az 2 kategori alanlar
)

SELECT 
    'Elektronik + Ev Aletleri' as category_pair,
    COUNTIF('Elektronik' IN UNNEST(bought_categories) AND 'Ev Aletleri' IN UNNEST(bought_categories)) as customer_count
FROM customer_categories

UNION ALL

SELECT 
    'Elektronik + Giyim',
    COUNTIF('Elektronik' IN UNNEST(bought_categories) AND 'Giyim' IN UNNEST(bought_categories))
FROM customer_categories

UNION ALL

SELECT 
    'Giyim + Kitap',
    COUNTIF('Giyim' IN UNNEST(bought_categories) AND 'Kitap' IN UNNEST(bought_categories))
FROM customer_categories

UNION ALL

SELECT 
    'Elektronik + Kitap',
    COUNTIF('Elektronik' IN UNNEST(bought_categories) AND 'Kitap' IN UNNEST(bought_categories))
FROM customer_categories

UNION ALL

SELECT 
    'Aksesuar + Giyim',
    COUNTIF('Aksesuar' IN UNNEST(bought_categories) AND 'Giyim' IN UNNEST(bought_categories))
FROM customer_categories

UNION ALL

SELECT 
    'Aksesuar + Elektronik',
    COUNTIF('Aksesuar' IN UNNEST(bought_categories) AND 'Elektronik' IN UNNEST(bought_categories))
FROM customer_categories

UNION ALL

SELECT 
    'Ev Aletleri + Kitap',
    COUNTIF('Ev Aletleri' IN UNNEST(bought_categories) AND 'Kitap' IN UNNEST(bought_categories))
FROM customer_categories

ORDER BY customer_count DESC
