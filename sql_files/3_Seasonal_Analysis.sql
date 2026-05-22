-- Are there discernible patterns in sales across different time periods?
WITH total_product_quarterly_sales AS(
    SELECT
        EXTRACT(QUARTER FROM transaction_date) AS quarter,
        SUM(CASE WHEN product_category='Electronics' THEN total_amount ELSE 0 END) AS electronic_total,
        SUM(CASE WHEN product_category='Clothing' THEN total_amount ELSE 0 END)AS clothing_total,
        SUM(CASE WHEN product_category='Beauty' THEN total_amount ELSE 0 END) AS beauty_total,
        SUM(total_amount) AS total_sales
    FROM
        retail_sales
    GROUP BY
        quarter
)
SELECT*
FROM total_product_quarterly_sales;


--Are there distinct purchasing behaviors based on the number of items bought per transaction?
SELECT
    EXTRACT(QUARTER FROM transaction_date) AS quarter,

    CASE
        WHEN quantity = 1 THEN 'Single Item'
        WHEN quantity BETWEEN 2 AND 3 THEN 'Small Basket'
        ELSE 'Bulk Purchase'
    END AS purchase_behavior,

    product_category,

    COUNT(*) AS transaction_count,

    ROUND(AVG(total_amount), 2) AS avg_transaction_spend,

    ROUND(AVG(price_per_unit), 2) AS avg_price_per_unit,

    SUM(total_amount) AS total_revenue

FROM retail_sales

GROUP BY
    quarter,
    purchase_behavior,
    product_category

ORDER BY
    quarter,
    purchase_behavior,
    total_revenue DESC;