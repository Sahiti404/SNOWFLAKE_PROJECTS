USE WAREHOUSE PROJECT_8_WH;
USE DATABASE PROJECT_8_DB;
USE SCHEMA SCD_SCHEMA_8;

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
TYPE='CSV'
SKIP_HEADER=1;

CREATE OR REPLACE STAGE SCD_STAGE
FILE_FORMAT=CSV_FORMAT;

-- =====================================================
-- PHASE 5: INITIAL STAGING TABLE
-- =====================================================

CREATE OR REPLACE TABLE STG_CUSTOMERS_INITIAL (
    CUSTOMER_ID INTEGER,
    CUSTOMER_NAME VARCHAR(100),
    CITY VARCHAR(100),
    STATE VARCHAR(100),
    MEMBERSHIP VARCHAR(50),
    SEGMENT VARCHAR(50)
);


-- =====================================================
-- PHASE 6: LOAD INITIAL FILE
-- =====================================================

COPY INTO STG_CUSTOMERS_INITIAL
FROM @SCD_STAGE/customer_initial.csv
FILE_FORMAT = CSV_FORMAT;


-- =====================================================
-- PHASE 7: DIMENSION TABLE
-- =====================================================

CREATE OR REPLACE TABLE DIM_CUSTOMER (
    CUSTOMER_KEY INTEGER,
    CUSTOMER_ID INTEGER,
    CUSTOMER_NAME VARCHAR(100),
    CITY VARCHAR(100),
    STATE VARCHAR(100),
    MEMBERSHIP VARCHAR(50),
    SEGMENT VARCHAR(50)
);


-- =====================================================
-- PHASE 8: LOAD INITIAL DIMENSION
-- =====================================================

INSERT INTO DIM_CUSTOMER
(
    CUSTOMER_KEY,
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CITY,
    STATE,
    MEMBERSHIP,
    SEGMENT
)
SELECT
    ROW_NUMBER() OVER (ORDER BY CUSTOMER_ID),
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CITY,
    STATE,
    MEMBERSHIP,
    SEGMENT
FROM STG_CUSTOMERS_INITIAL;


-- =====================================================
-- PHASE 9: UPDATE TABLE
-- =====================================================

CREATE OR REPLACE TABLE CUSTOMER_UPDATES (
    CUSTOMER_ID INTEGER,
    CUSTOMER_NAME VARCHAR(100),
    CITY VARCHAR(100),
    STATE VARCHAR(100),
    MEMBERSHIP VARCHAR(50),
    SEGMENT VARCHAR(50)
);


-- =====================================================
-- PHASE 10: LOAD UPDATE FILE
-- =====================================================

COPY INTO CUSTOMER_UPDATES
FROM @SCD_STAGE/customer_updates.csv
FILE_FORMAT = CSV_FORMAT;


-- =====================================================
-- PHASE 11: IDENTIFY CHANGES
-- =====================================================

SELECT
    d.CUSTOMER_ID,
    d.CITY AS OLD_CITY,
    u.CITY AS NEW_CITY,
    d.MEMBERSHIP AS OLD_MEMBERSHIP,
    u.MEMBERSHIP AS NEW_MEMBERSHIP
FROM DIM_CUSTOMER d
JOIN CUSTOMER_UPDATES u
    ON d.CUSTOMER_ID = u.CUSTOMER_ID
WHERE
       d.CITY <> u.CITY
    OR d.STATE <> u.STATE
    OR d.MEMBERSHIP <> u.MEMBERSHIP
    OR d.SEGMENT <> u.SEGMENT
ORDER BY d.CUSTOMER_ID;


-- =====================================================
-- PHASE 12: OVERWRITE DIMENSION
-- Demonstrating the SCD problem
-- =====================================================

UPDATE DIM_CUSTOMER d
SET
    d.CUSTOMER_NAME = u.CUSTOMER_NAME,
    d.CITY = u.CITY,
    d.STATE = u.STATE,
    d.MEMBERSHIP = u.MEMBERSHIP,
    d.SEGMENT = u.SEGMENT
FROM CUSTOMER_UPDATES u
WHERE d.CUSTOMER_ID = u.CUSTOMER_ID;


-- =====================================================
-- PHASE 13: DISPLAY UPDATED DIMENSION
-- =====================================================

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CITY,
    STATE,
    MEMBERSHIP,
    SEGMENT
FROM DIM_CUSTOMER
ORDER BY CUSTOMER_ID;


-- =====================================================
-- PHASE 14: DEMONSTRATE DATA LOSS
-- =====================================================

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CITY,
    STATE,
    MEMBERSHIP
FROM DIM_CUSTOMER
WHERE CUSTOMER_ID = 101;
