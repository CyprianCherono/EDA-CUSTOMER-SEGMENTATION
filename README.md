# RETAIL SALES ANALYSIS USING SQL

# Introduction

This project explores customer purchasing behavior, product performance, seasonal trends, customer segmentation, and retention strategies using SQL.

The goal of this analysis was to uncover actionable business insights from retail transaction data and answer real-world business questions around:

- Customer purchasing behavior
- Seasonal sales trends
- Product performance
- Customer segmentation
- Customer loyalty and promotions
- Churn risk analysis

## Tools Used

- **SQL:** The backbone of this analysis, enabling me to query the retail sales database, analyze customer purchasing behavior, and uncover actionable business insights.
- **PostgreSQL:** The chosen database management system, ideal for storing and analyzing transactional retail data efficiently.
- **Visual Studio Code:** My go-to environment for writing, organizing, and executing SQL queries throughout the analysis process.
- **Git & GitHub:** Essential for version control, project tracking, and sharing SQL scripts and analysis in a structured and collaborative manner.

## Dataset Information

The dataset used for this project was sourced from Kaggle.

[Click here to view the dataset](https://www.kaggle.com/datasets/mohammadtalib786/retail-sales-dataset)

*Below is a quick overview*

| Column             | Description                   |
| ------------------ | ----------------------------- |
| `customer_id`      | Unique customer identifier    |
| `transaction_id`   | Unique transaction identifier |
| `transaction_date` | Date of purchase              |
| `gender`           | Customer gender               |
| `age`              | Customer age                  |
| `product_category` | Product purchased             |
| `quantity`         | Number of items purchased     |
| `price_per_unit`   | Unit price                    |
| `total_amount`     | Total transaction value       |




# THE  ANALYSIS

## 1. Customer Behavior & Demographics

### How does customer age and gender influence purchasing behavior?

To understand how age and gender influence customer purchasing behavior, I segmented spending by gender and age groups across product categories using conditional aggregation (CASE WHEN) and grouped the results by gender and product category. This analysis was designed to identify demographic spending patterns and uncover category preferences among different customer groups.

```sql
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
    product_category
```
#### Insights

Purchasing behavior varied across age and gender segments. Female customers aged 25–44 spent most on Clothing (19,975) and Beauty (18,080), while male customers showed stronger spending on Clothing at ages 25–34 (21,665) and Electronics among seniors 55+ (21,770). Electronics spending generally increased with age among men, while Clothing remained a consistently high-performing category across most demographic groups.

## 2. Product & Sales Performance

### Which product categories hold the highest appeal among customers?

To determine which product categories hold the highest appeal among customers, I analyzed product performance by measuring transaction frequency, total units sold, and revenue generated across categories. The query groups sales data by product category and evaluates customer demand using purchase count (sales_count), quantity sold, and total revenue. This helps identify the most popular and commercially valuable product categories.

```sql
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
```

#### Insights
Clothing was the most frequently purchased category, recording the highest sales count (351) and units sold (894), indicating strong customer appeal. However, Electronics generated the highest revenue (156,905), suggesting customers spent more per transaction on electronic products. Beauty showed comparatively lower demand across transactions, quantity sold, and revenue.

### What insights can be gleaned from the distribution of product prices within each category?

To understand the distribution of product prices within each category, I grouped transactions by product category and segmented products into price tiers based on unit price ranges. Using conditional aggregation (CASE WHEN), I calculated the percentage of transactions falling within each price tier, allowing me to compare pricing patterns across categories and identify whether products are concentrated in low, mid, or premium price ranges.

```sql
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
```

#### Insights

Across all categories, the majority of purchases (59–61%) occurred in the lowest price tier (0–99), indicating strong demand for affordable products. No purchases were recorded in the 100–299 price range, suggesting a pricing gap or limited demand in mid-range products. Beauty had the highest share of premium-priced purchases (22% in the 400+ tier), while Electronics and Clothing showed similar distributions across higher price tiers.


## 3. Seasonal & Time-Based Analysis

### Are there discernible patterns in sales across different time periods?

To identify seasonal sales patterns across product categories, I analyzed quarterly sales performance by extracting the quarter from each transaction date and aggregating total revenue by product category. Using conditional aggregation (CASE WHEN), the query calculates quarterly revenue for Electronics, Clothing, and Beauty, alongside overall sales. This allows for comparison of category performance over time and helps uncover seasonal trends or shifts in customer demand.

```sql
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
```

#### Insights

Sales showed clear seasonal variation, with Quarter 4 generating the highest revenue (126,190) and Quarter 3 recording the lowest (96,045). Clothing and Beauty performed strongest in Quarter 1, while Electronics saw substantial growth throughout the year, becoming the top-performing category in Quarter 4 (48,150). These patterns suggest shifting customer demand across seasons and product categories.

### Are there distinct purchasing behaviors based on the number of items bought per transaction?

To identify purchasing behaviors based on the number of items bought per transaction, I categorized purchases into three basket types: Single Item, Small Basket (2–3 items), and Bulk Purchase (4+ items). The query analyzes these behaviors across product categories and quarters, measuring transaction frequency, average spending, average price per unit, and total revenue. This helps uncover how basket size influences customer spending patterns and product purchasing behavior over time.

``` sql
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
```

#### Insights

Customers most commonly purchased products in small baskets (2–3 items), which consistently recorded the highest transaction counts across categories. However, bulk purchases generated the highest average spending, particularly in Electronics during Q2 (avg spend: 1,036.67). Single-item purchases contributed the least revenue, while purchasing behavior varied seasonally, with Electronics bulk purchases and Beauty small baskets driving strong quarterly performance.

## 4. Customer Segmentation & CRM Analytics

### Which customers are the highest-value customers?

To identify the highest-value customers, I calculated each customer’s lifetime spending by aggregating total purchase value across transactions and product categories. The query also evaluates average spend per transaction, purchase frequency, and total items purchased to provide a broader view of customer value. Customers were then segmented into spending tiers (Regular, Premium, and Super Customers) based on their cumulative spending, helping identify the most valuable customers for retention and loyalty strategies.

```sql
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
```

#### Insights
From the results we can see that the super customers buy items in bulk as compared to the regular customer

### Can customers be grouped into distinct spending segments?

To determine whether customers can be grouped into distinct spending segments, I first calculated each customer’s total lifetime spending by aggregating all transaction values. Customers were then categorized into four spending tiers (Low, Mid, High Value, and VIP Customers) based on predefined spending thresholds. Finally, the query counts the number of customers in each segment, helping identify the distribution of customer value and enabling more targeted marketing, retention, and loyalty strategies.

```sql
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
```

#### Insights

Customer spending is highly concentrated among lower-value segments, with 650 customers classified as low value. Mid-value customers (148) represent a growth opportunity for upselling, while high-value (103) and VIP customers (99) form a smaller but strategically important group likely contributing disproportionately to revenue. This segmentation highlights opportunities for targeted retention and customer value growth strategies.

### Which customer segments contribute most revenue?

To determine which customer segments contribute the most revenue, I segmented customers by both age group and gender using conditional aggregation (CASE WHEN). The query calculates the percentage contribution of each age segment to total spending within each gender group, allowing for comparison of revenue-driving customer demographics. This helps identify the most valuable customer segments and supports targeted marketing and customer retention strategies.

``` sql
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
```

#### Insights

Female revenue was primarily driven by adults aged 25–44, each contributing 22% of total female spending, while mature adult males (45–54) generated the highest share of male spending at 22%. Teen customers contributed the least revenue across both genders, and overall spending remained relatively balanced across age groups, indicating a diversified customer base.

### Which customer segment is most valuable to the business?

To determine which customer segment is most valuable to the business, I first calculated each customer’s total lifetime spending by aggregating all purchases. Customers were then grouped into spending tiers (Low, Mid-Low, Mid, and High Spenders) based on their cumulative spend. Finally, the query evaluates each segment by measuring customer count, total revenue contribution, and average spending, helping identify which customer groups generate the greatest business value and where retention efforts should be prioritized.

```sql
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
```

#### Insights
High spenders emerged as the most valuable segment, generating the highest revenue (173,000) despite comprising only 99 customers, with an average spend of 1,747.47. In contrast, low spenders formed the largest segment (650 customers) but contributed the least revenue (66,900). Mid and mid-low spenders showed strong revenue potential, highlighting opportunities for targeted upselling and retention strategies.

## 5. Retention, Loyalty & Promotions

### Which customers may be at risk of churn?

To identify customers at risk of churn, I applied a simplified RFM (Recency, Frequency, Monetary) approach by analyzing each customer’s purchasing history. The query calculates recency using the number of days since a customer’s last purchase, frequency through total transaction count, and monetary value through cumulative customer spending. Customers were then categorized into churn risk levels (Low, Medium, and High Risk) based on purchase inactivity and lifetime spending, helping identify customers who may require retention strategies or re-engagement campaigns.

```sql
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
```
### Which customer segment should receive loyalty rewards?

To determine which customer segments should receive loyalty rewards, I analyzed customer spending and purchase frequency on a quarterly basis. The query calculates each customer’s total spend and number of transactions per quarter, then segments customers into value tiers (VIP, High Value, Mid, and Low Value) based on spending levels. Finally, loyalty reward eligibility is assigned using a combination of customer value and purchase frequency, helping identify highly engaged and high-spending customers who are most likely to benefit from retention and loyalty programs.

``` sql
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
```
### Which customer segment should receive promotions?

To determine which customer segments should receive promotions, I analyzed customer purchasing behavior using recency, frequency, and spending metrics. The query calculates the number of days since each customer’s last purchase, total purchase frequency, and cumulative spending, then segments customers into value tiers (VIP, High Value, Mid, and Low Value) based on total spend. Promotional offers are then assigned according to customer behavior and value, with premium incentives targeting high-value customers, re-engagement offers for inactive customers, and discounts aimed at encouraging repeat purchases among less frequent buyers.

```sql
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
```

# CONCLUSIONS

This project analyzed retail sales data using SQL to uncover insights into customer behavior, product performance, seasonal trends, customer segmentation, and retention opportunities.

The analysis showed that Clothing was the most frequently purchased category, while Electronics generated the highest revenue. Sales performance also varied across quarters, with Q4 producing the highest revenue overall.

Customer segmentation revealed that a small group of high-value customers contributed disproportionately to total revenue, while most customers fell into lower-value segments. The project also identified potential retention opportunities among inactive customers.

Overall, this analysis demonstrates how SQL can transform raw transactional data into actionable business insights that support better business and marketing decisions

# RECOMMENDATIONS

Based on the findings from this analysis, the following business recommendations are proposed:

- **Strengthen retention efforts for high-value customers:** Since high spenders contribute the largest share of revenue despite representing a smaller customer base, implementing VIP programs, exclusive offers, and personalized rewards could improve retention.
- **Upsell mid-value customers:** Mid and mid-low spending customers represent strong growth opportunities. Personalized promotions, bundle offers, and loyalty incentives could help move these customers into higher spending segments.
- **Target promotions by customer behavior:** Re-engagement campaigns such as discounts and personalized coupons should be directed toward inactive customers identified as churn risks.
- **Leverage seasonal demand patterns:** Increase inventory and marketing efforts during stronger sales periods (particularly Quarter 4) while introducing promotions during weaker quarters to stimulate demand.
- **Capitalize on category-specific strengths:** Clothing should continue to be promoted for volume sales, while Electronics can be positioned as a premium revenue-driving category with higher-margin strategies.
- **Optimize product pricing strategy:** Since most purchases fall within lower price tiers and the mid-price range showed little activity, the business should evaluate whether there is an opportunity to reposition products or introduce offerings in underserved pricing bands.
- **Enhance loyalty programs:** Reward highly engaged customers based on both spending and purchase frequency to encourage repeat purchases and long-term customer retention.
