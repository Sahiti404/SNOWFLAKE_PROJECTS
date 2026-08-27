USE WAREHOUSE RETAIL_WH_DI;
USE DATABASE RETAIL_DB_DI;
USE SCHEMA RETAIL_STAR_SCHEMA;

CREATE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

CREATE STAGE RETAIL_STAR_STAGE
FILE_FORMAT = CSV_FORMAT;

CREATE TABLE DIM_CUSTOMER (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    membership VARCHAR(50)
);

CREATE TABLE DIM_PRODUCT (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE DIM_BRANCH (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50),
    manager_name VARCHAR(100)
);

CREATE OR REPLACE TABLE DIM_DATE (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    day_name VARCHAR(15),
    week_no INT,
    month VARCHAR(20),
    quarter VARCHAR(5),
    year INT,
    is_weekend VARCHAR(3)
);

CREATE OR REPLACE TABLE FACT_SALES (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    branch_id INT,
    date_id INT,
    quantity INT,
    total_amount DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES DIM_CUSTOMER(customer_id),
    FOREIGN KEY (product_id) REFERENCES DIM_PRODUCT(product_id),
    FOREIGN KEY (branch_id) REFERENCES DIM_BRANCH(branch_id),
    FOREIGN KEY (date_id) REFERENCES DIM_DATE(date_id)
);

COPY INTO DIM_CUSTOMER FROM @RETAIL_STAR_STAGE/cust_star.csv 
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

COPY INTO DIM_BRANCH FROM @RETAIL_STAR_STAGE/branch_start.csv 
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

COPY INTO DIM_PRODUCT FROM @RETAIL_STAR_STAGE/products_star.csv 
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

COPY INTO DIM_DATE FROM @RETAIL_STAR_STAGE/calendar_star.csv 
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

COPY INTO FACT_SALES FROM @RETAIL_STAR_STAGE/sales_star.csv 
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

SELECT 
    p.product_name,
    p.category,
    p.brand,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.total_amount) AS total_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_id = p.product_id
GROUP BY p.product_name, p.category, p.brand
ORDER BY total_revenue DESC
LIMIT 5;

SELECT 
    b.region,
    COUNT(DISTINCT b.branch_id) AS total_branches,
    COUNT(f.sale_id) AS total_transactions,
    SUM(f.total_amount) AS regional_revenue
FROM FACT_SALES f
JOIN DIM_BRANCH b ON f.branch_id = b.branch_id
GROUP BY b.region
ORDER BY regional_revenue DESC;

SELECT 
    c.membership,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    SUM(f.total_amount) AS tier_revenue,
    AVG(f.total_amount) AS avg_order_value
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_id = c.customer_id
GROUP BY c.membership
ORDER BY tier_revenue DESC;

SELECT 
    d.is_weekend,
    COUNT(f.sale_id) AS total_orders,
    SUM(f.quantity) AS total_items_sold,
    SUM(f.total_amount) AS total_revenue
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_id = d.date_id
GROUP BY d.is_weekend;

-- View 1: Denormalized Master Sales Reporting View
CREATE OR REPLACE VIEW VW_MASTER_SALES_REPORT AS
SELECT 
    f.sale_id,
    d.full_date,
    d.month,
    d.quarter,
    d.year,
    c.customer_name,
    c.membership,
    c.city AS customer_city,
    p.product_name,
    p.category,
    p.brand,
    b.branch_name,
    b.region,
    f.quantity,
    f.total_amount
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_id = c.customer_id
JOIN DIM_PRODUCT p  ON f.product_id = p.product_id
JOIN DIM_BRANCH b   ON f.branch_id = b.branch_id
JOIN DIM_DATE d     ON f.date_id = d.date_id;

CREATE OR REPLACE VIEW VW_MONTHLY_BRANCH_PERFORMANCE AS
SELECT 
    d.year,
    d.month,
    b.region,
    b.branch_name,
    SUM(f.total_amount) AS monthly_revenue,
    SUM(f.quantity) AS monthly_quantity
FROM FACT_SALES f
JOIN DIM_BRANCH b ON f.branch_id = b.branch_id
JOIN DIM_DATE d   ON f.date_id = d.date_id
GROUP BY d.year, d.month, b.region, b.branch_name;

SELECT * FROM VW_MASTER_SALES_REPORT LIMIT 10;
SELECT * FROM VW_MONTHLY_BRANCH_PERFORMANCE ORDER BY monthly_revenue DESC;