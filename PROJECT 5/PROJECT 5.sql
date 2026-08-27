USE WAREHOUSE RETAIL_WH_DI;
USE DATABASE RETAIL_DB_DI;
USE SCHEMA RETAIL_STAR_SCHEMA;

-- 1. Customer-wise Sales Report
SELECT 
    c.customer_id,
    c.customer_name,
    c.membership,
    SUM(f.quantity) AS total_quantity_bought,
    SUM(f.total_amount) AS total_revenue
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.membership
ORDER BY total_revenue DESC;

-- Product-wise Revenue Report
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.price,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.total_amount) AS total_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.brand, p.price
ORDER BY p.product_id;


-- Branch-wise Revenue Report
SELECT 
    b.branch_id,
    b.branch_name,
    b.city,
    b.state,
    b.region,
    b.manager_name,
    SUM(f.total_amount) AS total_branch_revenue
FROM FACT_SALES f
JOIN DIM_BRANCH b ON f.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.state, b.region, b.manager_name
ORDER BY b.branch_id;

-- State-wise Revenue Report
SELECT 
    b.state,
    COUNT(DISTINCT b.branch_id) AS active_branches,
    SUM(f.total_amount) AS state_revenue
FROM FACT_SALES f
JOIN DIM_BRANCH b ON f.branch_id = b.branch_id
GROUP BY b.state
ORDER BY state_revenue DESC;

-- Monthly Revenue Report
SELECT 
    d.year,
    d.month,
    SUM(f.total_amount) AS monthly_revenue,
    SUM(f.quantity) AS total_units_sold
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- Quarterly Revenue Report
SELECT 
    d.year,
    d.quarter,
    SUM(f.total_amount) AS quarterly_revenue,
    COUNT(f.sale_id) AS total_transactions
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_id = d.date_id
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- Top 10 Customers
SELECT 
    c.customer_id,
    c.customer_name,
    c.membership,
    SUM(f.total_amount) AS total_revenue
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.membership
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Products
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(f.total_amount) AS total_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Branches
SELECT 
    b.branch_id,
    b.branch_name,
    b.city,
    b.region,
    SUM(f.total_amount) AS total_revenue
FROM FACT_SALES f
JOIN DIM_BRANCH b ON f.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, b.city, b.region
ORDER BY total_revenue DESC
LIMIT 10;

-- Category-wise Revenue
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(f.quantity) AS units_sold,
    SUM(f.total_amount) AS category_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Customer Purchase Trend
SELECT 
    c.customer_id,
    c.customer_name,
    d.year,
    d.month,
    COUNT(f.sale_id) AS purchase_frequency,
    SUM(f.total_amount) AS monthly_spent
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_id = c.customer_id
JOIN DIM_DATE d ON f.date_id = d.date_id
GROUP BY c.customer_id, c.customer_name, d.year, d.month
ORDER BY c.customer_id, d.year, d.month;

-- Product Performance Dashboard
SELECT 
    p.category,
    p.brand,
    p.product_name,
    p.price AS unit_price,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.total_amount) AS gross_revenue,
    AVG(f.total_amount) AS avg_transaction_value
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_id = p.product_id
GROUP BY p.category, p.brand, p.product_name, p.price
ORDER BY gross_revenue DESC;

-- Branch Performance Dashboard
SELECT 
    b.region,
    b.branch_name,
    b.manager_name,
    COUNT(f.sale_id) AS transaction_count,
    SUM(f.quantity) AS total_items_sold,
    SUM(f.total_amount) AS gross_revenue,
    AVG(f.total_amount) AS avg_order_value
FROM FACT_SALES f
JOIN DIM_BRANCH b ON f.branch_id = b.branch_id
GROUP BY b.region, b.branch_name, b.manager_name
ORDER BY gross_revenue DESC;

