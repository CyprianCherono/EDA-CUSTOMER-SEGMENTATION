--How does customer age and gender influence their purchasing behavior?S
SELECT
    gender,
    product_category,
    SUM(CASE WHEN age BETWEEN 0 AND 24 THEN total_amount ELSE 0 END) AS young_adult_spend,
    SUM(CASE WHEN age BETWEEN 25 AND 34 THEN total_amount ELSE 0 END) AS adult_spend,
    SUM(CASE WHEN age BETWEEN 35 AND 44 THEN total_amount ELSE 0 END) AS midage_adult_spend,
    SUM(CASE WHEN age BETWEEN 45 AND 54 THEN total_amount ELSE 0 END) AS mature_adult_spend,
    SUM(CASE WHEN age >55 THEN total_amount ELSE 0 END) AS senior_spend
    

FROM 
    retail_sales

GROUP BY
    gender,
    product_category;
    