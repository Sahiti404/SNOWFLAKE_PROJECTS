**Project 12 — Enterprise Retail Analytics Data Warehouse**

📌 **Project Explanation**

This project focuses on building an Enterprise Retail Analytics Data Warehouse using Snowflake. The retail data is organized into RAW tables, Dimension tables, and a Fact table following Kimball Dimensional Modeling.

The project demonstrates Slowly Changing Dimensions (SCD Type 1, Type 2, Type 3, and Type 6) to manage customer and store changes while preserving required historical information. It also includes point-in-time sales analysis and data validation/auditing.

🛠️ **Technology Used**
Snowflake — Cloud Data Warehouse
Snowflake SQL — Data loading, transformation, joins, updates, and analytics
Kimball Dimensional Modeling — Fact and Dimension design
CSV — Source data format

📂 **Source Files**

The project uses four CSV source files:
stores.csv — Store details including Store ID, Name, City, State, and Manager.
products.csv — Product details including Product ID, Name, Category, and Unit Price.
customers_initial.csv — Initial customer information including City, State, Membership, and Segment.
customer_updates.csv — Customer changes including updated City, Membership, Segment, and Effective Date.
