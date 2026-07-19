/*
====================================================
Amazon Sales Analysis Project

Author: Kangjun Lee

Tools:
- MySQL
- Tableau

Skills Demonstrated:
- Data Cleaning
- Joins
- Aggregate Functions
- CASE Statements
- CTEs
- Window Functions
- Business KPI Analysis
====================================================
*/

-- CREATE DATABASE AND TABLES --

CREATE DATABASE ecommerce_project;
USE ecommerce_project;

CREATE TABLE amazon_sales_raw (
    idx INT,
    order_id VARCHAR(50),
    order_date VARCHAR(20),
    status VARCHAR(100),
    fulfilment VARCHAR(50),
    sales_channel VARCHAR(50),
    ship_service_level VARCHAR(50),
    style VARCHAR(100),
    sku VARCHAR(100),
    category VARCHAR(50),
    size VARCHAR(20),
    asin VARCHAR(50),
    courier_status VARCHAR(50),
    qty VARCHAR(10),
    currency VARCHAR(10),
    amount VARCHAR(20),
    ship_city VARCHAR(100),
    ship_state VARCHAR(100),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(20),
    promotion_ids TEXT,
    b2b VARCHAR(10),
    fulfilled_by VARCHAR(50)
);

-- PHASE 1: DATA CLEANING AND PREPARATION --

-- Overview of the table 
SELECT * FROM amazon_sales_raw
LIMIT 15;

-- How many rows are in the table?
SELECT COUNT(*) AS total_rows
FROM amazon_sales_raw;

-- How many unique order IDs are there?
SELECT COUNT(DISTINCT order_id) AS unique_order_ids
FROM amazon_sales_raw;

-- Order IDs with amount less than 800, sorted by amount in descending order, limited to the top 10 results
SELECT order_id, amount 
FROM amazon_sales_raw
WHERE amount < 800
ORDER BY amount DESC
LIMIT 10;

-- Check column types
DESCRIBE amazon_sales_raw;

-- Checking the order date format
SELECT DISTINCT order_date
FROM amazon_sales_raw
LIMIT 20; 

-- Lets convert the date into standard format using STR_TO_DATE function
SELECT order_date, STR_TO_DATE(order_date, '%m-%d-%y') AS converted_date
FROM amazon_sales_raw
LIMIT 10;

-- checking quantity column
SELECT DISTINCT qty
FROM amazon_sales_raw
ORDER BY qty;

-- COMMENT amount
SELECT DISTINCT amount
FROM amazon_sales_raw
ORDER BY amount
LIMIT 20;

-- Checking if there are still any null values in amount column
SELECT COUNT(*)
FROM amazon_sales_raw
WHERE amount IS NULL;

-- Check #2
SELECT COUNT(*)
FROM amazon_sales_raw
WHERE amount = '';

-- Updating the empty values into NULL
UPDATE amazon_sales_raw
SET amount = NULL
WHERE amount = '';

-- Create a new cleaned table 
CREATE TABLE amazon_sales_cleaned AS
SELECT
    idx,
    order_id,
    STR_TO_DATE(order_date, '%m-%d-%y') AS order_date,
    status,
    fulfilment,
    sales_channel,
    ship_service_level,
    style,
    sku,
    category,
    size,
    asin,
    courier_status,
    qty,
    currency,
    CAST(NULLIF(amount, '') AS DECIMAL(10,2)) AS amount,
    ship_city,
    ship_state,
    ship_postal_code,
    ship_country,
    promotion_ids,
    b2b,
    fulfilled_by
FROM amazon_sales_raw;

-- View table    
SELECT * FROM amazon_sales_cleaned
LIMIT 10;

DESCRIBE amazon_sales_cleaned;

-- convert qty from varchar to int
SELECT DISTINCT qty
FROM amazon_sales_cleaned
ORDER BY qty;

ALTER TABLE amazon_sales_cleaned
MODIFY COLUMN qty INT;


-- PHASE 2: EXPLORATORY DATA ANALYSIS (EDA) --

-- =======================================================================================================
-- 1. Business Overview
-- =======================================================================================================

-- Total Revenue
SELECT currency, SUM(amount) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY currency;

-- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM amazon_sales_cleaned;

-- Total Units Sold
SELECT SUM(qty) AS total_units_sold
FROM amazon_sales_cleaned;

--Average Order Value
SELECT ROUND(SUM(amount) / COUNT(DISTINCT order_id),2) AS average_order_value
FROM amazon_sales_cleaned;

-- Average Units per Order
SELECT SUM(qty) / COUNT(DISTINCT order_id) AS average_units_per_order
FROM amazon_sales_cleaned;


-- =======================================================================================================
-- 2. Product Analysis
-- =======================================================================================================

-- Number of unique categories
SELECT COUNT(DISTINCT category) AS num_categories
FROM amazon_sales_cleaned;

-- Top Revenue by category
SELECT category, SUM(amount) AS revenue
FROM amazon_sales_cleaned
GROUP BY category
ORDER BY revenue DESC;

-- Top Units sold by category
SELECT category, SUM(qty) AS units_sold
FROM amazon_sales_cleaned
GROUP BY category
ORDER BY units_sold DESC;

-- Top products by revenue
SELECT
    category,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value
FROM amazon_sales_cleaned
GROUP BY category
ORDER BY total_revenue DESC;

-- Top revenue generating SKUs
SELECT
    sku,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value
FROM amazon_sales_cleaned
GROUP BY sku
ORDER BY total_revenue DESC;

-- Most frequently sold SKUs
SELECT
    sku,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value
FROM amazon_sales_cleaned
GROUP BY sku
ORDER BY total_orders DESC;

-- Most frequently sold sizes
SELECT 
    size,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value
FROM amazon_sales_cleaned
GROUP BY size
ORDER BY total_orders DESC;


-- =======================================================================================================
-- 3. Geographical Analysis
-- =======================================================================================================

-- Revenue by state
SELECT
    ship_state,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY ship_state
ORDER BY total_revenue DESC
LIMIT 20;

-- Orders by state
SELECT
    ship_state,
    COUNT(order_id) AS total_orders
FROM amazon_sales_cleaned
GROUP BY ship_state
ORDER BY total_orders DESC;

-- Top cities
SELECT
    ship_city,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY ship_city
ORDER BY total_revenue DESC
LIMIT 10;

-- State Summary
SELECT
    ship_state,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value
FROM amazon_sales_cleaned
GROUP BY ship_state
ORDER BY total_revenue DESC;


-- =======================================================================================================
-- 4. Operations Analysis
-- =======================================================================================================

-- Order Status Distribution
SELECT
    status,
    COUNT(order_id) AS total_orders
FROM amazon_sales_cleaned
GROUP BY status
ORDER BY total_orders DESC;

-- Revenue by Order Status
SELECT 
    status,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY status
ORDER BY total_revenue DESC;

-- Fulfilment analysis
SELECT 
    fulfilment,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY fulfilment
ORDER BY total_revenue DESC;

-- Shipped Status 
SELECT
    fulfilment, status
FROM amazon_sales_cleaned
WHERE status LIKE ('Shipped%') 

-- Cancellation Rate
SELECT
    ROUND(SUM(CASE WHEN status  = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
    AS cancellation_rate
FROM amazon_sales_cleaned;

-- Cancellation Rate by Fulfilment
SELECT
    fulfilment,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM amazon_sales_cleaned
GROUP BY fulfilment
ORDER BY cancellation_rate DESC;


-- =======================================================================================================
-- 5. Time Series Analysis
-- =======================================================================================================

-- 1. Revenue by Month
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY month
ORDER BY month;

-- 2. Revenue by Weekday
SELECT
    DAYNAME(order_date) AS weekday,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY weekday
ORDER BY total_revenue DESC;

-- 3. Revenue by Month Name 
SELECT MONTHNAME(order_date) AS month,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY total_revenue DESC;

-- 4. Revenue for March and May
SELECT MONTHNAME(order_date) AS month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales_cleaned
WHERE MONTHNAME(order_date) IN ('March', 'May')
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY total_revenue DESC;

-- 5. Weekend vs Weekday Revenue
SELECT
    CASE 
        WHEN DAYOFWEEK(order_date) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value
FROM amazon_sales_cleaned
GROUP BY day_type
ORDER BY total_revenue DESC;

-- 6. Cumulative Revenue Using CTEs and Window functions
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM amazon_sales_cleaned
    GROUP BY month
)
SELECT
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM monthly_sales;

-- 7. Month over month growth
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM amazon_sales_cleaned
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month
FROM monthly_sales;


-- =======================================================================================================
-- 6. Advanced SQL Analysis
-- =======================================================================================================

-- 1. Rank SKUs by Revenue
WITH sku_sales AS (
    SELECT
        sku,
        COUNT(order_id) AS total_orders,
        ROUND(SUM(amount), 2) AS total_revenue
    FROM amazon_sales_cleaned
    GROUP BY sku
)
SELECT
    sku,
    total_orders,
    total_revenue,
    RANK() OVER(ORDER BY total_revenue DESC) AS revenue_rank
FROM sku_sales;

-- 2. Top 10 SKUs by Revenue
WITH 
    sku_sales AS(
    SELECT
        sku,
        COUNT(order_id) AS total_orders,
        ROUND(SUM(amount), 2) AS total_revenue
    FROM amazon_sales_cleaned
    GROUP BY sku
),
    ranked_skus AS(
    SELECT
        sku,
        total_orders,
        total_revenue,
        RANK() OVER(ORDER BY total_revenue DESC) AS revenue_rank
    FROM sku_sales
    )
SELECT *
FROM ranked_skus
WHERE revenue_rank <= 10;

-- 3. Rank Top 5 SKUs within each Category
WITH
    sku_sales AS(
    SELECT
        category,
        sku,
        COUNT(order_id) AS total_orders,
        ROUND(SUM(amount), 2) AS total_revenue
    FROM amazon_sales_cleaned
    GROUP BY category, sku
),
    ranked_skus AS(
    SELECT
        category,
        sku,
        total_orders,
        total_revenue,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
    FROM sku_sales
)
SELECT * 
FROM ranked_skus
WHERE category_rank <= 5
ORDER BY category, category_rank;


-- =======================================================================================================
-- 7. Analysis using Joins
-- =======================================================================================================

-- 1. Creating products table
CREATE TABLE products AS
SELECT DISTINCT
    sku,
    style,
    category,
    size
FROM amazon_sales_cleaned;

-- 2. Create order_items table
CREATE TABLE order_items AS
SELECT
    order_id,
    order_date,
    status,
    sku,
    asin,
    qty,
    amount,
    currency,
    fulfilled_by,
    sales_channel,
    ship_service_level,
    courier_status,
    promotion_ids
FROM amazon_sales_cleaned;

-- 3. Checking both tables
SELECT * FROM order_items
LIMIT 10;

SELECT * FROM products
LIMIT 10;

SELECT COUNT(*) AS product_rows FROM products;
SELECT COUNT(*) AS order_items_rows FROM order_items;

SELECT sku, COUNT(*) AS row_count
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;

-- 4. INNER JOIN
SELECT
    oi.order_id,
    oi.order_date,
    oi.sku,
    p.style,
    p.category,
    p.size,
    oi.qty,
    oi.amount
FROM order_items oi
INNER JOIN products p ON p.sku = oi.sku
LIMIT 20;

-- 5. Checking whether any order item SKUs failed to match using LEFT JOIN
SELECT 
    oi.sku,
    COUNT(*) AS unmatched_rows
FROM order_items oi
LEFT JOIN products p ON oi.sku = p.sku
WHERE p.sku IS NULL
GROUP BY oi.sku;
-- If no rows returned, every SKU in order_items has a matching product

-- 6. Business analysis after joining
SELECT
    p.category,
    COUNT(oi.order_id) AS total_orders,
    SUM(oi.qty) AS total_quantity,
    ROUND(SUM(oi.amount), 2) AS total_revenue
FROM order_items oi
INNER JOIN products p
    ON oi.sku = p.sku
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 7. Add shipping table
CREATE TABLE shipping AS
SELECT DISTINCT
    order_id,
    ship_city,
    ship_state,
    ship_postal_code,
    ship_country,
    b2b
FROM amazon_sales_cleaned;

-- Checking for duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS row_count
FROM shipping
GROUP BY order_id
HAVING COUNT(*) > 1;

-- preview table
SELECT *
FROM shipping
LIMIT 10;

-- Three table Join
SELECT
    oi.order_id,
    oi.order_date,
    oi.sku,
    p.category,
    p.style,
    p.size,
    oi.qty,
    oi.amount,
    s.ship_city,
    s.ship_state,
    s.ship_country,
    s.b2b
FROM order_items oi
LEFT JOIN products p
    ON oi.sku = p.sku
LEFT JOIN shipping s
    ON oi.order_id = s.order_id
LIMIT 20;

-- Checking for unmatched rows
SELECT COUNT(*) AS unmatched_product_rows
FROM order_items oi
LEFT JOIN products p
    ON oi.sku = p.sku
WHERE p.sku IS NULL;

-- Revenue by state, category
SELECT
    s.ship_state,
    p.category,
    COUNT(oi.order_id) AS total_orders,
    SUM(oi.qty) AS total_quantity,
    ROUND(SUM(oi.amount), 2) AS total_revenue
FROM order_items oi
LEFT JOIN products p
    ON oi.sku = p.sku
LEFT JOIN shipping s
    ON oi.order_id = s.order_id
GROUP BY
    s.ship_state,
    p.category
ORDER BY total_revenue DESC;

-- =======================================================================================================
-- Business Questions
-- =======================================================================================================

-- 1. What are the top N products in every category?
WITH 
product_sales AS (
    SELECT 
        category,
        sku,
        COUNT(order_id) AS total_orders,
        SUM(qty) AS total_quantity,
        ROUND(SUM(amount), 2) AS total_revenue
    FROM amazon_sales_cleaned 
    GROUP BY category, sku
),
ranked_products AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_revenue DESC) AS total_rank
    FROM product_sales
)
SELECT *
FROM ranked_products
WHERE total_rank <= 3;

-- Using the normalized tables we created to answer the question
WITH product_sales AS (
    SELECT
        p.category,
        oi.sku,
        COUNT(oi.order_id) AS total_orders,
        SUM(oi.qty) AS total_quantity,
        ROUND(SUM(oi.amount), 2) AS total_revenue
    FROM order_items oi
    INNER JOIN products p
        ON oi.sku = p.sku
    GROUP BY
    p.category,
    oi.sku
),
ranked_products AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
    FROM product_sales
)
SELECT * FROM ranked_products
WHERE category_rank <= 3
ORDER BY category, category_rank;

-- 2. Which categories generate the most revenue?
WITH category_sales AS( 
    SELECT
        p.category,
        ROUND(SUM(oi.amount), 2) AS total_revenue
    FROM order_items oi
    INNER JOIN products p
        ON oi.sku = p.sku
    GROUP BY p.category
)
SELECT
    category,
    total_revenue,
    RANK() OVER(ORDER BY total_revenue DESC) AS revenue_rank,
    DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS dense_revenue_rank
FROM category_sales
ORDER BY total_revenue DESC;

-- 3. How did cumulative revenue grow over time?
WITH monthly_sales AS(
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        ROUND(SUM(amount), 2) AS monthly_revenue
    FROM order_items
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER(ORDER BY month), 2) AS cumulative_revenue
FROM monthly_sales
ORDER BY month;

-- running revenue within each category
WITH monthly_category_sales AS(
    SELECT
        DATE_FORMAT(oi.order_date, '%Y-%m') AS month,
        p.category,
        ROUND(SUM(oi.amount), 2) AS monthly_revenue
    FROM order_items oi
    INNER JOIN products p
        ON oi.sku = p.sku
    GROUP BY
        DATE_FORMAT(oi.order_date, '%Y-%m'),
        p.category
)
SELECT
    month,
    category,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER(PARTITION BY category ORDER BY month), 2) AS cumulative_category_revenue
FROM monthly_category_sales
ORDER BY category, month;

-- 4. How much did revenue increase or decrease compared to the previous month?
WITH 
monthly_sales AS(
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        ROUND(SUM(amount), 2) AS monthly_revenue
    FROM order_items
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
monthly_comparison AS(
    SELECT
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER(ORDER BY month) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    month,
    monthly_revenue,
    ROUND((monthly_revenue - previous_month_revenue), 2) AS revenue_change,
    ROUND((monthly_revenue - previous_month_revenue) * 100.0 / NULLIF(previous_month_revenue, 0), 2) AS growth_rate_percent
FROM monthly_comparison
ORDER BY month;

-- 5. What percentage of total_revenue comes from each category?
WITH category_sales AS(
    SELECT
        p.category,
        ROUND(SUM(oi.amount), 2) AS category_revenue
    FROM order_items oi
    INNER JOIN products p
        ON oi.sku = p.sku
    GROUP BY p.category
)
SELECT 
    category,
    category_revenue,
    ROUND(category_revenue * 100.0 / SUM(category_revenue) OVER(), 2) AS revenue_share_percent
FROM category_sales
ORDER BY category_revenue DESC;

-- 6. Which SKUs generate more revenue than the average SKU?
SELECT
    sku,
    total_revenue
FROM (
    SELECT
        oi.sku,
        ROUND(SUM(oi.amount), 2) AS total_revenue
    FROM order_items oi
    GROUP BY oi.sku
) AS sku_sales
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT
            SUM(amount) AS total_revenue
        FROM order_items
        GROUP BY sku
    ) AS average_source
)
ORDER BY total_revenue DESC;

-- Cleaner version using CTEs
WITH sku_sales AS (
    SELECT
        oi.sku,
        ROUND(SUM(oi.amount), 2) AS total_revenue
    FROM order_items oi
    GROUP BY oi.sku
)

SELECT
    sku,
    total_revenue
FROM sku_sales
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM sku_sales
)
ORDER BY total_revenue DESC;


-- returning the top 5 product by category
WITH category_sales AS(
    SELECT
        p.category,
        oi.sku,
        ROUND(SUM(oi.amount), 2) AS total_revenue
    FROM order_items oi
    INNER JOIN products p
        ON oi.sku = p.sku
    GROUP BY 
        p.category, oi.sku
),
category_revenue_partitioned AS (
    SELECT
    category,
    sku,
    total_revenue,
    SUM(total_revenue) OVER(PARTITION BY category) AS total_category_revenue,
    ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
FROM category_sales
ORDER BY total_revenue DESC
)
SELECT * FROM category_revenue_partitioned
WHERE category_rank <= 5;

-- Nested window function
SELECT
    p.category,
    p.sku,
    SUM(oi.amount) AS product_revenue,
    SUM(SUM(oi.amount)) OVER(PARTITION BY p.category) AS category_revenue
FROM order_items oi
JOIN products p
    ON oi.sku = p.sku
GROUP BY
    p.category,
    p.sku;


-- revenue and revenue percentage within category
SELECT
    p.sku,
    SUM(oi.amount) AS revenue,
    ROUND(SUM(oi.amount) / 
    (SUM(SUM(oi.amount)) OVER(PARTITION BY p.category))
    * 100.0,
    2) AS revenue_share
FROM order_items oi
JOIN products p
    ON oi.sku = p.sku
GROUP BY p.sku, p.category;


-- Highest revenue product in each category
WITH 
product_sales AS(
    SELECT
        p.sku,
        p.category,
        COUNT(oi.order_id) AS total_orders,
        SUM(oi.amount) AS product_revenue
    FROM order_items oi
    JOIN products p
        ON oi.sku = p.sku
    GROUP BY p.sku, p.category
),
ranked_products AS(
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY product_revenue DESC) AS category_rank
    FROM product_sales
)
SELECT * FROM ranked_products
WHERE category_rank = 1;


-- =======================================================================================================
-- Getting Ready For Tableau dashboards
-- =======================================================================================================

SHOW TABLES;

CREATE VIEW tableau_sales AS
SELECT *
FROM amazon_sales_cleaned;

DESCRIBE tableau_sales;

SELECT *
FROM tableau_sales
LIMIT 10;

-- Four main questions
-- 1. How is the business performing?
-- 2. Which products make the most money?
-- 3. Where are the sales coming from?
-- 4. How is the operation performing?
 

SELECT MIN(order_date), MAX(order_date)
FROM amazon_sales_cleaned;

SELECT
    ROUND(SUM(amount) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM amazon_sales_cleaned;