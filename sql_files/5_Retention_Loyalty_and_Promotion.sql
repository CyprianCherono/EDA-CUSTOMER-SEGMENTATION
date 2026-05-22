-- Which customers may be at risk of churn?, use RFM analysis, recency, frequency and monetary value
WITH customer_data AS (
    SELECT
        customer_id,
        MAX(transaction_date) AS recent_transaction,
        CURRENT_DATE - MAX(transaction_date) AS days_since_purchase,
        COUNT(transaction_id) AS purchase_frequency,
        SUM(total_amount) AS customer_life_spend

    FROM
        retail_sales
    GROUP BY
        customer_id
)

SELECT
    *,
    CASE 
        WHEN days_since_purchase < 360  THEN 'low_risk'
        WHEN days_since_purchase >=360  AND customer_life_spend < 1000 THEN 'medium_risk' 
        WHEN days_since_purchase >=360  AND customer_life_spend >= 1000 THEN 'high_risk'
    END AS churn_category
FROM
    customer_data


-- Which customer segment should receive loyalty rewards?
WITH customers AS(
    SELECT
        customer_id,
        SUM(total_amount) AS total_spend,
        EXTRACT(quarter FROM transaction_date) AS quarter,
        COUNT(transaction_id) AS purchase_count

    FROM 
        retail_sales
    GROUP BY
        customer_id,quarter
),
Customer_seg AS(
    SELECT
        customer_id,
        quarter,
        purchase_count,
        total_spend,
        CASE
            WHEN total_spend>=1500 THEN 'VIP_Customer'
            WHEN total_spend BETWEEN 1000 AND 1499 THEN  'High_Value_Customer'
            WHEN total_spend Between 500 and 999 THEN 'Mid_Customer'
            WHEN total_spend < 500 THEN 'Low_Value_Customer'
            ELSE ''
        END AS Customer_Value_Category
    FROM customers
)
SELECT 
    customer_id,
    quarter,
    purchase_count,
    total_spend,
    Customer_Value_Category,
    CASE 
        WHEN Customer_Value_Category='VIP_Customer' THEN true
        WHEN Customer_Value_Category = 'High_Value_Customer' AND purchase_count>=10 THEN true
        WHEN purchase_count >=20 THEN true
        ELSE false
    END AS loyalty_points_eligibility
FROM
    customer_seg


-- Which customer segment should receive promotions?
WITH customer_metric AS(
    SELECT
        customer_id,
        CURRENT_DATE - MAX(transaction_date) AS days_since_last_purchase,
        COUNT(transaction_id) AS purchase_count,
        SUM(total_amount) AS total_spend
    FROM
        retail_sales
    GROUP BY
        customer_id
),
Customer_seg AS(
    SELECT
        customer_id,
        days_since_last_purchase,
        purchase_count,
        total_spend,
        CASE
            WHEN total_spend>=1500 THEN 'VIP_Customer'
            WHEN total_spend BETWEEN 1000 AND 1499 THEN  'High_Value_Customer'
            WHEN total_spend Between 500 and 999 THEN 'Mid_Customer'
            WHEN total_spend < 500 THEN 'Low_Value_Customer'
            ELSE ''
        END AS Customer_Value_Category
    FROM customer_metric
)
SELECT
    customer_id,
    days_since_last_purchase,
    purchase_count,
    total_spend,
    CASE 
        WHEN Customer_Value_Category='VIP_Customer' OR Customer_Value_Category='High_Value_Customer' THEN 'Free Shipping'
        WHEN days_since_last_purchase > 100 THEN 'Personalized Coupons'
        WHEN purchase_count <2 THEN '10% discount on your next purchase'
        ELSE ''
    END AS promotion_eligibility
FROM 
    Customer_seg

