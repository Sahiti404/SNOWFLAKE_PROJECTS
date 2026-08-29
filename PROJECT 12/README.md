Project 12 — Enterprise Retail Analytics Data Warehouse
📌 Overview

An end-to-end Retail Data Warehouse built using Snowflake SQL and Kimball Dimensional Modeling.

The project demonstrates:

Fact & Dimension Modeling
Surrogate Keys
Fact Table Grain
Conformed Dimensions
SCD Type 1, Type 2, Type 3 & Type 6
Point-in-Time Analytics
Data Validation & Auditing
🛠️ Technology
Platform: Snowflake
Language: Snowflake SQL
Modeling: Kimball Dimensional Modeling
Source: CSV Files
🏗️ Architecture
CSV Files
    ↓
Snowflake Stage
    ↓
RAW Tables
    ↓
Dimensions
    ↓
FACT_SALES
    ↓
Analytics & Audit
RAW Tables
RAW_STORES
RAW_PRODUCTS
RAW_CUSTOMERS_INITIAL
RAW_CUSTOMER_UPDATES
Dimension Tables
DIM_STORE
DIM_PRODUCT
DIM_CUSTOMER_HYBRID
Fact Table
FACT_SALES
🔄 SCD Implementation
Attribute	SCD Type	Implementation
Store Manager	Type 1	Old value overwritten
Customer Segment	Type 2	Historical row versions
Customer City	Type 3	Current + previous city
Membership	Type 6	Current + previous + historical membership
📊 Fact Table Grain

FACT_SALES follows:

One row per individual item line in a sales transaction.

It contains:

TRANSACTION_ID
TRANSACTION_DATE
CUSTOMER_KEY
STORE_KEY
PRODUCT_KEY
QUANTITY
UNIT_PRICE
TOTAL_AMOUNT
🗓️ Business Scenario
Initial Sales
TXN-1001 → Customer 101 → Laptop Pro → ₹75,000
TXN-1002 → Customer 103 → Wireless Mouse × 2 → ₹3,000
Customer Updates
101: Hyderabad → Bengaluru
    Silver → Gold
    Regular → Premium

103: Vijayawada → Chennai
    Silver → Gold
    Regular → Premium

104: Gold → Platinum
Post-Update Sale
TXN-2001 → Customer 101 → Ergonomic Chair → ₹12,000
🔎 Point-in-Time Analysis

Customer 101's purchase history demonstrates historical attribute tracking:

Transaction	Membership	Segment
TXN-1001	Silver	Regular
TXN-2001	Gold	Premium
✅ Final Validation

Expected warehouse counts:

Store Records                  3
Product Records                4
Customer Dimension Records     8
Current Customer Records       5
Historical Customer Records    3
Fact Sales Records             3
📁 Repository Structure
PROJECT-12-RETAIL-DATA-WAREHOUSE/
│
├── README.md
├── sql/
│   └── project_12_retail_dw.sql
├── data/
│   ├── stores.csv
│   ├── products.csv
│   ├── customers_initial.csv
│   └── customer_updates.csv
└── screenshots/
🎯 Key Concepts

Kimball Modeling • Snowflake SQL • Fact & Dimensions • Surrogate Keys • SCD Type 1 • SCD Type 2 • SCD Type 3 • SCD Type 6 • Point-in-Time Analytics • Data Auditing