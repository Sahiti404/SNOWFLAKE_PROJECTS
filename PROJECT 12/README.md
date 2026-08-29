# Project 12 — Enterprise Retail Analytics Data Warehouse

## 📌 Project Explanation

This project builds an **Enterprise Retail Analytics Data Warehouse** using **Snowflake** and **Kimball Dimensional Modeling**.

### Key Areas Covered

- **Data Architecture** — RAW, Dimension, and Fact tables
- **Dimensional Modeling** — Fact and Dimension table design
- **Slowly Changing Dimensions** — SCD Type 1, Type 2, Type 3, and Type 6
- **Historical Data Tracking** — Maintaining customer and store changes
- **Point-in-Time Analytics** — Analyzing sales using historical customer attributes
- **Data Validation** — Record count and warehouse auditing

## 🛠️ Technology Used

- **Snowflake** — Cloud Data Warehouse
- **Snowflake SQL** — Data loading, transformation, joins, updates, and analytics
- **Kimball Dimensional Modeling** — Fact and Dimension design
- **CSV** — Source data format

## 📂 Source Files

The project uses four CSV source files:

- **`stores.csv`** — Store details including Store ID, Name, City, State, and Manager
- **`products.csv`** — Product details including Product ID, Name, Category, and Unit Price
- **`customers_initial.csv`** — Initial customer information including City, State, Membership, and Segment
- **`customer_updates.csv`** — Customer changes including updated City, Membership, Segment, and Effective Date
