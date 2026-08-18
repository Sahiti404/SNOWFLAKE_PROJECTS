# Project 2: Retail Sales Analytics using Snowflake 🛒❄️

An enterprise retail sales analytics project leveraging **Snowflake Cloud Data Warehouse** to analyze branch sales, customer purchasing behavior, and product revenue performance.

---

## 📌 Project Overview

A nationwide retail chain migrated daily branch sales data to Snowflake. This project sets up the warehouse infrastructure, stages multi-source CSV files, executes multi-table relational joins, and implements advanced analytical techniques including **Window Functions**, **Common Table Expressions (CTEs)**, and **Materialized Views**.

---

## 📂 Project Files

- `customers.csv`: Customer demographics and membership levels (Gold, Silver, Platinum).
- `products.csv`: Product catalog, categories, and pricing.
- `branches.csv`: Retail branch locations across cities.
- `sales.csv`: Daily sales transaction data.
- `project2.sql`: Complete DDL, data staging, COPY commands, analytics, CTEs, window functions, and view definitions.

---

## 🚀 Execution Instructions

1. Log in to your **Snowflake Console**.
2. Upload `customers.csv`, `products.csv`, `branches.csv`, and `sales.csv` into `RETAIL_STAGE`.
3. Run `project2.sql` sequentially in a Snowflake Worksheet.