# Snowflake Data Engineering & SQL Analytics Portfolio ❄️

Welcome to my central Snowflake repository! This repository serves as a flexible, growing learning log and engineering portfolio containing hands-on data warehousing, staging pipelines, and advanced analytical SQL projects built using **Snowflake Cloud Data Warehouse**.

---

## 💡 Technical Skills & Core Competencies

Across the exercises and projects in this repository, I systematically practice and implement core cloud data engineering workflows:

### 1. Snowflake Infrastructure & Ingestion Pipelines
* **Warehouse Architecture:** Provisioning and configuring virtual warehouses (`WAREHOUSE`), databases (`DATABASE`), and schemas (`SCHEMA`).
* **Staging & File Formats:** Defining custom file formats (`FILE FORMAT`) and internal stages (`STAGE`) for landing raw data files.
* **Bulk Ingestion:** Executing high-performance batch data loading from staged files into relational tables using `COPY INTO`.

### 2. Advanced SQL & Business Intelligence Analytics
* **Relational Data Modeling:** Building multi-table `INNER JOIN` and `LEFT JOIN` pipelines across normalized relational entities.
* **Window Functions:** Computing running totals (`SUM OVER`), category-level rankings (`DENSE_RANK`, `ROW_NUMBER`), and baseline benchmarks (`AVG OVER`).
* **Modular Logic:** Structuring complex queries using multi-level Common Table Expressions (CTEs) to isolate intermediate data transformations.

### 3. Query Optimization & Performance Tuning
* **Standard Views:** Designing abstract reporting views for downstream Business Intelligence tools.
* **Materialized Views:** Pre-computing expensive aggregate queries to minimize compute resource consumption and speed up query response times.

---

## 🛠️ General Execution Guide

To run any SQL script inside this repository:

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/](https://github.com/)<your-username>/<your-repo-name>.git
   cd <your-repo-name>

2.Navigate to the Desired Folder: Open the target project directory.

3. Execute in Snowflake:

    Open your Snowflake Worksheets interface (Snowsight).
    
    Set your session context (Warehouse, Database, Schema).
    
    Upload any associated raw CSV datasets into your internal stage (@STAGE).
    
    Run the corresponding .sql script sequentially.
