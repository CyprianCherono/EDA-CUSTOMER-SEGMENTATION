-- Which product categories hold the highest appeal among customers?

SELECT
    product_category,
    COUNT(*) AS sales_count,
    SUM(quantity) AS quantity_sold,
    SUM(total_amount) AS total_revenue
FROM 
    retail_sales
GROUP BY
    product_category
ORDER BY sales_count DESC;

-- What insights can be gleaned from the distribution of product prices within each category?
WITH price_count AS (
    SELECT
        product_category,
        COUNT(transaction_id) AS total_transactions,
        COUNT(CASE WHEN price_per_unit BETWEEN 0 AND 99 THEN transaction_id END) AS tier1_price_count,
        COUNT(CASE WHEN price_per_unit BETWEEN 100 AND 199 THEN transaction_id END) AS tier2_price_count,
        COUNT(CASE WHEN price_per_unit BETWEEN 200 and 299 THEN transaction_id END) AS tier3_price_count,
        COUNT(CASE WHEN price_per_unit BETWEEN 300 AND 399 THEN transaction_id END) AS tier4_price_count,
        COUNT(CASE WHEN price_per_unit>=400 THEN transaction_id END) AS tier5_price_count

    FROM
        retail_sales
    GROUP BY
        product_category
)

SELECT
    product_category,
    ROUND(tier1_price_count*100/total_transactions,2) AS tier1_pct,
    ROUND(tier2_price_count*100/total_transactions,2) AS tier2_pct,
    ROUND(tier3_price_count*100/total_transactions,2) AS tier3_pct,
    ROUND(tier4_price_count*100/total_transactions,2) AS tier4_pct,
    ROUND(tier5_price_count*100/total_transactions,2) AS tier5_pct
FROM
    price_count
