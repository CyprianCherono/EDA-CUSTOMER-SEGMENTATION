-- Which customers are the highest-value customers?
WITH lifetime_value AS(
    SELECT 
        customer_id,
        product_category,
        SUM(total_amount) AS lifetime_spend,
        ROUND(AVG(total_amount),2) AS avg_spend,
        COUNT(transaction_id) AS transactions_num,
        SUM(quantity) AS num_items
    FROM
        retail_sales
    GROUP BY
        customer_id,product_category
)
SELECT
    customer_id,
    lifetime_spend,
    avg_spend,
    transactions_num,
    num_items,
    product_category,
    CASE 
        WHEN lifetime_spend BETWEEN 0 AND 499 THEN 'regular_customer'
        WHEN lifetime_spend BETWEEN 500 AND 999 THEN 'premium_customer' 
        WHEN lifetime_spend >=1000 THEN 'super_customer'
        ELSE '' 
    END AS customer_category
            
FROM
    lifetime_value
ORDER BY
    lifetime_spend DESC



-- Can customers be grouped into distinct spending segments?
WITH customer_spend AS(
    SELECT 
        customer_id,
        SUM(total_amount) AS total_customer_spend
    FROM retail_sales
    GROUP BY
        customer_id
),

 Customer_seg AS(
    SELECT
        customer_id,
        CASE
            WHEN total_customer_spend>=1500 THEN 'VIP_Customers'
            WHEN total_customer_spend BETWEEN 1000 AND 1499 THEN  'High_Value_Customers'
            WHEN total_customer_spend Between 500 and 999 THEN 'Mid_Customers'
            WHEN total_customer_spend < 500 THEN 'Low_Value_Customers'
            ELSE ''
        END AS Customer_Value_Category
    FROM customer_spend
)

SELECT
    COUNT(CASE WHEN Customer_Value_Category = 'VIP_Customers' THEN customer_id END) AS VIP_count,
    COUNT(CASE WHEN Customer_Value_Category = 'High_Value_Customers' THEN customer_id END) AS High_Value_Count,
    COUNT(CASE WHEN Customer_Value_Category = 'Mid_Customers' THEN customer_id END) AS Mid_Value_Count,
    COUNT(CASE WHEN Customer_Value_Category = 'Low_Value_Customers' THEN customer_id END) AS Low_Value_Count
FROM
    customer_seg;



-- Which customer segments contribute most revenue?
WITH customer_spend AS(
    SELECT
        gender,
        SUM(CASE WHEN age BETWEEN 0 AND 24 THEN total_amount ELSE 0 END) AS total_teen_spend,
        SUM(CASE WHEN age BETWEEN 25 AND 34 THEN total_amount ELSE 0 END) AS total_young_adult_spend,
        SUM(CASE WHEN age BETWEEN 35 AND 44 THEN total_amount ELSE 0 END) AS total_midage_adult_spend,
        SUM(CASE WHEN age BETWEEN 45 AND 54 THEN total_amount ELSE 0 END) AS total_matureadult_spend,
        SUM(CASE WHEN age>=55 THEN total_amount ELSE 0 END) AS total_senior_spend,
        SUM(total_amount) AS total_spend
    FROM
        retail_sales
    GROUP BY
        gender
)
SELECT
    gender,
    ROUND(total_teen_spend*100/total_spend,2) AS teen_pct,
    ROUND(total_young_adult_spend*100/total_spend,2) AS adult_pct,
    ROUND(total_midage_adult_spend*100/total_spend,2) AS midage_adult_pct,
    ROUND(total_matureadult_spend*100/total_spend,2) AS mature_adult_pct,
    ROUND(total_senior_spend*100/total_spend,2) AS senior_pct
FROM 
    customer_spend



-- Which customer segment is most valuable to the business?
WITH c_metric AS(
    SELECT
        customer_id,
        SUM(total_amount) AS total_spend
    FROM
        retail_sales
    GROUP BY
        customer_id
),
category_total AS(
    SELECT
        customer_id,
        total_spend,
        CASE
            WHEN total_spend>=1500 THEN 'high_spenders'
            WHEN total_spend BETWEEN 1000 AND 1499 THEN 'mid_spenders'
            WHEN total_spend BETWEEN 500 and 999 THEN 'mid_low_spenders'
            WHEN total_spend < 500  THEN 'low_spenders'
        END category
    FROM
        c_metric
) 
SELECT
    category,
    COUNT(customer_id ) AS customer_count,
    SUM(total_spend) AS category_spend,
    ROUND(AVG(total_spend),2) AS category_avg
   
FROM 
    category_total
GROUP BY
    category
