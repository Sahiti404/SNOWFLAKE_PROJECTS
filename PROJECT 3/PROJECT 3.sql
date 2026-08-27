USE WAREHOUSE ENTERPRISE_WH;
USE DATABASE ENTERPRISE_DB;
USE SCHEMA SALES_SCHEMA;

CREATE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

CREATE STAGE ENTERPRISE_STAGE
FILE_FORMAT = CSV_FORMAT;

CREATE TABLE CUSTOMERS (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    membership VARCHAR(50)
);

CREATE TABLE PRODUCTS (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE BRANCHES (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    state VARCHAR(100)
);

CREATE TABLE SALES (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    branch_id INT,
    quantity INT,
    sale_date DATE,
    total_amount DECIMAL(12,2)
);

COPY INTO SALES
FROM @ENTERPRISE_STAGE/sales_history.csv
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

-- COPY INTO CUSTOMERS
-- FROM @ENTERPRISE_STAGE/customers.csv
-- FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

COPY INTO CUSTOMERS
FROM @ENTERPRISE_STAGE/customer2.csv
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);


COPY INTO PRODUCTS
FROM @ENTERPRISE_STAGE/products2.csv
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);


COPY INTO BRANCHES
FROM @ENTERPRISE_STAGE/branches1.csv
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

CREATE OR REPLACE STREAM SALES_STREAM
ON TABLE SALES;

SHOW STREAMS;

COPY INTO SALES
FROM @ENTERPRISE_STAGE/new_sales.csv
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

SELECT * FROM SALES_STREAM;

CREATE TEMPORARY TABLE NEW_SALES_STAGE AS
SELECT sale_id, customer_id, product_id,
    branch_id, quantity, sale_date,
    total_amount FROM SALES_STREAM;

MERGE INTO SALES target
USING NEW_SALES_STAGE source
ON target.sale_id = source.sale_id

WHEN NOT MATCHED THEN
    INSERT (
        sale_id, customer_id, product_id,
        branch_id, quantity, sale_date,
        total_amount
    )
    VALUES (
        source.sale_id, source.customer_id,
        source.product_id, source.branch_id,
        source.quantity, source.sale_date,
        source.total_amount
    );

    SELECT COUNT(*) AS total_sales
FROM SALES;

--  phase 4
SELECT sale_id, COUNT(*) AS record_count
FROM SALES GROUP BY sale_id
HAVING COUNT(*) > 1;

SELECT s.* 
FROM SALES s 
LEFT JOIN CUSTOMERS c ON s.customer_id = c.customer_id 
WHERE c.customer_id IS NULL;

SELECT s.* 
FROM SALES s 
LEFT JOIN PRODUCTS p ON s.product_id = p.product_id 
WHERE p.product_id IS NULL;

SELECT COUNT(*) FROM SALES WHERE sale_id > 5;

-- Preserve query timestamp before deletion
SET timestamp_before_delete = CURRENT_TIMESTAMP()

DELETE FROM SALES WHERE sale_id = 10;

SELECT * FROM SALES WHERE sale_id = 10;

INSERT INTO SALES
SELECT * FROM SALES AT(TIMESTAMP => $timestamp_before_delete)
WHERE sale_id = 10;

SELECT * FROM SALES WHERE sale_id = 10;

CREATE OR REPLACE TABLE SALES_TEST CLONE SALES;

SELECT * FROM SALES_TEST;

INSERT INTO SALES_TEST VALUES (11, 1, 101, 1, 2, '2026-07-11', 120000);

SELECT COUNT(*) AS original_count FROM SALES;

SELECT COUNT(*) AS cloned_count FROM SALES_TEST;

CREATE OR REPLACE TASK INCREMENTAL_SALES_LOAD_TASK
  WAREHOUSE = ENTERPRISE_WH
  SCHEDULE = 'USING CRON 0 0 * * * UTC'
  WHEN SYSTEM$STREAM_HAS_DATA('SALES_STREAM')
AS
  MERGE INTO SALES target
  USING SALES_STREAM src
  ON target.sale_id = src.sale_id
  WHEN NOT MATCHED THEN 
      INSERT (sale_id, customer_id, product_id, branch_id, quantity, sale_date, total_amount)
      VALUES (src.sale_id, src.customer_id, src.product_id, src.branch_id, src.quantity, src.sale_date, src.total_amount);


ALTER TASK INCREMENTAL_SALES_LOAD_TASK RESUME;

SHOW TASKS LIKE 'INCREMENTAL_SALES_LOAD_TASK';

SELECT c.customer_name, SUM(s.total_amount) AS total_revenue
FROM SALES s
JOIN CUSTOMERS c ON s.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_revenue DESC;

SELECT b.branch_name, SUM(s.total_amount) AS total_revenue
FROM SALES s
JOIN BRANCHES b ON s.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY total_revenue DESC;

SELECT p.product_name, SUM(s.total_amount) AS total_revenue
FROM SALES s
JOIN PRODUCTS p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

SELECT DATE_TRUNC('month', sale_date) AS month, SUM(total_amount) AS monthly_revenue
FROM SALES
GROUP BY 1
ORDER BY month;

SELECT c.customer_name, SUM(s.total_amount) AS revenue
FROM SALES s
JOIN CUSTOMERS c ON s.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY revenue DESC
LIMIT 1;

SELECT b.branch_name, SUM(s.total_amount) AS revenue
FROM SALES s
JOIN BRANCHES b ON s.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY revenue DESC
LIMIT 1;

SELECT p.product_name, SUM(s.total_amount) AS revenue
FROM SALES s
JOIN PRODUCTS p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 5;

SELECT c.customer_name, COUNT(s.sale_id) AS purchase_count
FROM SALES s
JOIN CUSTOMERS c ON s.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY purchase_count DESC;

SELECT 
    sale_id,
    sale_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY sale_date, sale_id) AS running_total
FROM SALES;


SELECT 
    c.customer_name,
    SUM(s.total_amount) AS total_spent,
    DENSE_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS customer_rank
FROM SALES s
JOIN CUSTOMERS c ON s.customer_id = c.customer_id
GROUP BY c.customer_name;

CREATE OR REPLACE VIEW CUSTOMER_REVENUE AS
SELECT c.customer_id, c.customer_name, SUM(s.total_amount) AS total_revenue
FROM SALES s
JOIN CUSTOMERS c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;

CREATE OR REPLACE MATERIALIZED VIEW BRANCH_REVENUE AS
SELECT branch_id, SUM(total_amount) AS total_revenue, COUNT(sale_id) AS total_transactions
FROM SALES
GROUP BY branch_id;

SELECT * FROM CUSTOMER_REVENUE;
SELECT * FROM BRANCH_REVENUE;