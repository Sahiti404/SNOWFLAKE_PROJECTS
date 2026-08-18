USE WAREHOUSE RETAIL_WH;
USE DATABASE RETAIL_DB;
USE SCHEMA SALES_SCHEMA;

CREATE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

CREATE STAGE RETAIL_STAGE
FILE_FORMAT = CSV_FORMAT;

CREATE TABLE CUSTOMERS (
    customer_id NUMBER,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    membership VARCHAR(30)
);
CREATE TABLE PRODUCTS (
    product_id NUMBER,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMBER(10,2)
);

CREATE TABLE BRANCHES (
    branch_id NUMBER,
    branch_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE SALES (
    sale_id NUMBER,
    customer_id NUMBER,
    product_id NUMBER,
    branch_id NUMBER,
    quantity NUMBER,
    sale_date DATE,
    total_amount NUMBER(12,2)
);

COPY INTO CUSTOMERS
FROM @RETAIL_STAGE/customers1.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO PRODUCTS
FROM @RETAIL_STAGE/products.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO BRANCHES
FROM @RETAIL_STAGE/branches.csv
FILE_FORMAT = CSV_FORMAT;

COPY INTO SALES
FROM @RETAIL_STAGE/sales.csv
FILE_FORMAT = CSV_FORMAT;

SELECT * FROM CUSTOMERS;
SELECT * FROM PRODUCTS;
SELECT * FROM BRANCHES;
SELECT * FROM SALES;

SELECT
    SUM(total_amount) AS total_business_revenue
FROM SALES;

SELECT
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_amount_spent
FROM CUSTOMERS c
INNER JOIN SALES s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_amount_spent DESC;


SELECT
    b.branch_id,
    b.branch_name,
    SUM(s.total_amount) AS total_revenue
FROM BRANCHES b
INNER JOIN SALES s
    ON b.branch_id = s.branch_id
GROUP BY
    b.branch_id,
    b.branch_name
ORDER BY total_revenue DESC;

SELECT
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_quantity_sold,
    SUM(s.total_amount) AS total_revenue
FROM PRODUCTS p
INNER JOIN SALES s
    ON p.product_id = s.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC;

SELECT
    p.category,
    SUM(s.total_amount) AS total_revenue
FROM PRODUCTS p
INNER JOIN SALES s
    ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

SELECT
    b.branch_id,
    b.branch_name,
    SUM(s.total_amount) AS total_revenue
FROM BRANCHES b
INNER JOIN SALES s
    ON b.branch_id = s.branch_id
GROUP BY
    b.branch_id,
    b.branch_name
ORDER BY total_revenue DESC
LIMIT 1;

SELECT
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_spending
FROM CUSTOMERS c
INNER JOIN SALES s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spending DESC
LIMIT 1;

SELECT
    p.product_id,
    p.product_name,
    SUM(s.total_amount) AS total_revenue
FROM PRODUCTS p
INNER JOIN SALES s
    ON p.product_id = s.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 3;


SELECT
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_spending
FROM CUSTOMERS c
INNER JOIN SALES s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spending DESC
LIMIT 3;

-- Generate Customer-wise Revenue Using CTE
WITH CUSTOMER_REVENUE AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS total_revenue
    FROM CUSTOMERS c
    INNER JOIN SALES s
        ON c.customer_id = s.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT *
FROM CUSTOMER_REVENUE
ORDER BY total_revenue DESC;

-- Display Customers Whose Spending is Greater
-- Than Average Spending

WITH CUSTOMER_REVENUE AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS total_spending
    FROM CUSTOMERS c
    INNER JOIN SALES s
        ON c.customer_id = s.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
),

AVERAGE_SPENDING AS
(
    SELECT
        AVG(total_spending) AS average_spending
    FROM CUSTOMER_REVENUE
)

SELECT
    cr.customer_id,
    cr.customer_name,
    cr.total_spending
FROM CUSTOMER_REVENUE cr
CROSS JOIN AVERAGE_SPENDING a
WHERE cr.total_spending > a.average_spending
ORDER BY cr.total_spending DESC;

-- Create View named SALES_REPORT
CREATE OR REPLACE VIEW SALES_REPORT AS

SELECT
    s.sale_id,
    s.sale_date,

    c.customer_id,
    c.customer_name,

    p.product_id,
    p.product_name,
    p.category,

    b.branch_id,
    b.branch_name,

    s.quantity,
    s.total_amount

FROM SALES s

INNER JOIN CUSTOMERS c
    ON s.customer_id = c.customer_id

INNER JOIN PRODUCTS p
    ON s.product_id = p.product_id

INNER JOIN BRANCHES b
    ON s.branch_id = b.branch_id;


-- Retrieve all records from SALES_REPORT View
SELECT *
FROM SALES_REPORT;

-- Sort SALES_REPORT by Total Amount
SELECT *
FROM SALES_REPORT
ORDER BY total_amount DESC;

-- Create Materialized View named TOP_CUSTOMERS
CREATE OR REPLACE MATERIALIZED VIEW TOP_CUSTOMERS AS

SELECT
    customer_id,
    SUM(total_amount) AS total_spending
FROM SALES
GROUP BY customer_id;

-- Query TOP_CUSTOMERS Materialized View
SELECT
    tc.customer_id,
    c.customer_name,
    tc.total_spending
FROM TOP_CUSTOMERS tc
INNER JOIN CUSTOMERS c
    ON tc.customer_id = c.customer_id
ORDER BY tc.total_spending DESC;