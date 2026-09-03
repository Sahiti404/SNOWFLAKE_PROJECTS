USE WAREHOUSE PROJECT_14_WH;
USE DATABASE PROJECT_14_DB;
USE SCHEMA PROJECT_14_SCHEMA;

CREATE OR REPLACE FILE FORMAT JSON_FORMAT
TYPE='JSON'


------STAGE CREATION
CREATE OR REPLACE STAGE ecomm_stage
FILE_FORMAT=JSON_FORMAT;

-------------CREATING LAKE_RAW_EVENTS
-- CREATE OR REPLACE TABLE LAKE_RAW_EVENTS(
-- RAW_DATA VARIANT,
-- INGESTED_AT TIMESTAMP_NTZ DEFALUT CURRENT_TIMESTAMP()
-- );

CREATE OR REPLACE TABLE LAKE_RAW_EVENTS (
    RAW_DATA VARIANT,
    INGESTED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

DESC TABLE LAKE_RAW_EVENTS;

COPY INTO LAKE_RAW_EVENTS (RAW_DATA)
FROM (
    SELECT $1
    FROM @ecomm_stage/batch1.json
)
FILE_FORMAT = JSON_FORMAT;

-------------VALIDATING COUNT
SELECT COUNT(*) AS RECORD_COUNT
FROM LAKE_RAW_EVENTS;

-------------LOADING BATCH2
COPY INTO LAKE_RAW_EVENTS (RAW_DATA)
FROM (
    SELECT $1
    FROM @ecomm_stage/batch2.json
)
FILE_FORMAT=JSON_FORMAT;

---------------VALIDATING COUNT
SELECT COUNT(*) AS RECORD_COUNT
FROM LAKE_RAW_EVENTS;

--------------VALIDATING BATCH 3 FILES

 -----------a.creating a temporary raw landing table
 CREATE OR REPLACE TABLE RAW_LANDING_EVENTS (
    RAW_RECORD_TEXT VARCHAR,
    SOURCE_FILE VARCHAR,
    INGESTED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

------------b. text file creationn
CREATE OR REPLACE FILE FORMAT RAW_TEXT_FORMAT 
TYPE = CSV
FIELD_DELIMITER = NONE
RECORD_DELIMITER = '\n'
FIELD_OPTIONALLY_ENCLOSED_BY = NONE;

-----------c.Load Batch 3 as text
COPY INTO RAW_LANDING_EVENTS (RAW_RECORD_TEXT)
FROM @ecomm_stage/batch3.json
FILE_FORMAT = RAW_TEXT_FORMAT;

-----------d.validating count
SELECT COUNT(*) AS BATCH3_RECORD_COUNT
FROM RAW_LANDING_EVENTS;

-------------e.Finally valid data ingestion
INSERT INTO LAKE_RAW_EVENTS (RAW_DATA)
SELECT
    TRY_PARSE_JSON(RAW_RECORD_TEXT)
FROM RAW_LANDING_EVENTS
WHERE TRY_PARSE_JSON(RAW_RECORD_TEXT) IS NOT NULL;

-------------f.validating count but getting 12 so not working
SELECT COUNT(*) AS TOTAL_RAW_RECORD_CT
FROM LAKE_RAW_EVENTS;

SELECT
    RAW_DATA:event_id::STRING AS EVENT_ID,
    RAW_DATA
FROM LAKE_RAW_EVENTS
ORDER BY EVENT_ID;

-----------g.Quarentine table(Creating ,Inserting and deleting from main table)
CREATE OR REPLACE TABLE QUARANTINE_RAW_EVENTS (
    RAW_RECORD_TEXT VARCHAR,
    REASON VARCHAR,
    INGESTED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO QUARANTINE_RAW_EVENTS (RAW_RECORD_TEXT, REASON)
SELECT
    RAW_RECORD_TEXT,
    'Missing required action field'
FROM RAW_LANDING_EVENTS
WHERE TRY_PARSE_JSON(RAW_RECORD_TEXT) IS NOT NULL
  AND TRY_PARSE_JSON(RAW_RECORD_TEXT):action IS NULL;

  DELETE FROM LAKE_RAW_EVENTS
WHERE RAW_DATA:event_id::STRING = 'INVALID_JSON_PAYLOAD_MALFORMED_STRING';

------------h.validating final count
SELECT COUNT(*) AS TOTAL_RAW_RECORD_CT
FROM LAKE_RAW_EVENTS;

------------------SCHEMA-ON-READ-PHASE(STORE THE json and then decide which field we need while we query it)
SELECT
    RAW_DATA:event_id::STRING AS EVENT_ID,
    RAW_DATA:user_id::STRING AS USER_ID,
    RAW_DATA:action::STRING AS ACTION,
    RAW_DATA:event_timestamp::TIMESTAMP_NTZ AS EVENT_TIMESTAMP,
    RAW_DATA:order_total::NUMBER(12,2) AS ORDER_TOTAL,
    RAW_DATA:promo_code::STRING AS PROMO_CODE,
    RAW_DATA:discount_amount::NUMBER(12,2) AS DISCOUNT_AMOUNT
FROM LAKE_RAW_EVENTS
ORDER BY EVENT_ID;

---------------Here Why are PROMO_CODE and DISCOUNT_AMOUNT NULL for some records?

-- This is very important for your project.

-- Batch 1 has the older structure.

-- Batch 2 introduced:

-- promo_code
-- discount_amount

-- That's exactly the flexibility we want to demonstrate.


----a.Demonstrate Schema Evolution
SELECT
    RAW_DATA:event_id::STRING AS EVENT_ID,
    RAW_DATA:promo_code::STRING AS PROMO_CODE,
    RAW_DATA:discount_amount::NUMBER(12,2) AS DISCOUNT_AMOUNT
FROM LAKE_RAW_EVENTS
ORDER BY EVENT_ID;

-- This is the key concept:

-- We didn't change the table structure when new fields appeared.

-- That is Schema-on-Read + schema flexibility.

------------SCHEMA ANALYSIS

    ------------a.Calculate Net Revenue from the Lake

    SELECT
    RAW_DATA:event_id::STRING AS EVENT_ID,

    RAW_DATA:order:total::NUMBER(12,2) AS ORDER_TOTAL,

    RAW_DATA:order:shipping_cost::NUMBER(12,2) AS SHIPPING_COST,

    RAW_DATA:order:tax::NUMBER(12,2) AS TAX,

    COALESCE(
        RAW_DATA:discount_amount::NUMBER(12,2),
        0
    ) AS DISCOUNT_AMOUNT,

    RAW_DATA:order:total::NUMBER(12,2)
    - RAW_DATA:order:shipping_cost::NUMBER(12,2)
    - RAW_DATA:order:tax::NUMBER(12,2)
    - COALESCE(
        RAW_DATA:discount_amount::NUMBER(12,2),
        0
    ) AS NET_REVENUE

FROM LAKE_RAW_EVENTS

WHERE RAW_DATA:order:total::NUMBER(12,2) > 0

ORDER BY EVENT_ID;


------------------FUNNEL AND CONVERSION KEY METRICS
SELECT
    COUNT(*) AS TOTAL_EVENTS,

    COUNT_IF(
        RAW_DATA:action::STRING = 'purchase'
        AND RAW_DATA:order:total::NUMBER(12,2) > 0
    ) AS TOTAL_PURCHASES,

    ROUND(
        100.0 *
        COUNT_IF(
            RAW_DATA:action::STRING = 'purchase'
            AND RAW_DATA:order:total::NUMBER(12,2) > 0
        )
        / COUNT(*),
        2
    ) AS CONVERSION_RATE_PCT,

    SUM(
        CASE
            WHEN RAW_DATA:action::STRING = 'purchase'
                 AND RAW_DATA:order:total::NUMBER(12,2) > 0
            THEN RAW_DATA:order:total::NUMBER(12,2)
            ELSE 0
        END
    ) AS TOTAL_GROSS_REVENUE,

    ROUND(
        SUM(
            CASE
                WHEN RAW_DATA:action::STRING = 'purchase'
                     AND RAW_DATA:order:total::NUMBER(12,2) > 0
                THEN RAW_DATA:order:total::NUMBER(12,2)
                ELSE 0
            END
        )
        /
        COUNT_IF(
            RAW_DATA:action::STRING = 'purchase'
            AND RAW_DATA:order:total::NUMBER(12,2) > 0
        ),
        2
    ) AS AVERAGE_ORDER_VALUE

FROM LAKE_RAW_EVENTS;

------------------DATA WAREHOUSE BACKFILL(SCHEMA-ON-WRITE)
-- So far:

-- LAKE_RAW_EVENTS
--       │
--       │ JSON / VARIANT
--       │
--       ▼
-- Schema-on-Read

-- Now we create:

-- DW_STRUCTURED_EVENTS

-- with predefined columns and data types.

-- This is Schema-on-Write.

-------------a.Table creation
CREATE OR REPLACE TABLE DW_STRUCTURED_EVENTS (
    EVENT_ID VARCHAR,
    EVENT_TIME TIMESTAMP_NTZ,
    USER_ID NUMBER,
    ACTION VARCHAR,
    ORDER_TOTAL NUMBER(12,2),
    SHIPPING_COST NUMBER(12,2),
    TAX NUMBER(12,2),
    PROMO_CODE VARCHAR,
    DISCOUNT_AMOUNT NUMBER(12,2),
    NET_REVENUE NUMBER(12,2)
);

----------------b.inserting data into table
INSERT INTO DW_STRUCTURED_EVENTS (
    EVENT_ID,
    EVENT_TIME,
    USER_ID,
    ACTION,
    ORDER_TOTAL,
    SHIPPING_COST,
    TAX,
    PROMO_CODE,
    DISCOUNT_AMOUNT,
    NET_REVENUE
)
SELECT
    RAW_DATA:event_id::STRING,

    RAW_DATA:event_timestamp::TIMESTAMP_NTZ,

    RAW_DATA:user_id::NUMBER,

    RAW_DATA:action::STRING,

    RAW_DATA:order:total::NUMBER(12,2),

    RAW_DATA:order:shipping_cost::NUMBER(12,2),

    RAW_DATA:order:tax::NUMBER(12,2),

    RAW_DATA:promo_code::STRING,

    COALESCE(
        RAW_DATA:discount_amount::NUMBER(12,2),
        0
    ),

    CASE
        WHEN RAW_DATA:order:total::NUMBER(12,2) > 0
        THEN
            RAW_DATA:order:total::NUMBER(12,2)
            - RAW_DATA:order:shipping_cost::NUMBER(12,2)
            - RAW_DATA:order:tax::NUMBER(12,2)
            - COALESCE(
                RAW_DATA:discount_amount::NUMBER(12,2),
                0
            )
        ELSE 0
    END

FROM LAKE_RAW_EVENTS;

-------------------c.validating against the required output
SELECT
    COUNT(*) AS STORED_RECORDS_QTY,
    SUM(NET_REVENUE) AS TOTAL_NET_REVENUE
FROM DW_STRUCTURED_EVENTS;

