WITH customer_recency AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date,
        DATE_DIFF('day', MAX(order_date), CURRENT_DATE) AS days_since_last_order
    FROM {{ ref('stg_sepetix_orders') }}
    GROUP BY customer_id
)

SELECT
    customer_id,
    last_order_date,
    days_since_last_order,
    CASE
        WHEN days_since_last_order > 30 THEN 'At Risk'
        WHEN days_since_last_order BETWEEN 8 AND 30 THEN 'Regular'
        ELSE 'Active'
    END AS segment
FROM customer_recency