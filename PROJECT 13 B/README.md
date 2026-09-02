# Project 13B — Healthcare Analytics Warehouse

## 📌 Overview
Built a Healthcare Analytics Data Warehouse in **Snowflake** using and comparing:

- ⭐ **Star Schema**
- ❄️ **Snowflake Schema**

## 🛠️ Technologies
- Snowflake SQL
- CSV
- Dimensional Modeling

## 📂 Data Sources
- Hospital Hierarchy
- Treatment Hierarchy
- Patients
- Insurance Claims

## 🔹 Key Tasks
- Created RAW/staging tables
- Built Star Schema dimensions and fact table
- Built Snowflake Schema with normalized hierarchies
- Loaded data using SQL transformations
- Performed claims and specialty analytics
- Compared maintenance/update requirements
- Verified final record counts

## 📊 Schema Comparison

| Star Schema | Snowflake Schema |
|---|---|
| Denormalized | Normalized |
| Fewer joins | More joins |
| Simpler queries | Better hierarchy organization |
| More data redundancy | Less redundancy |
| Updates may affect multiple rows | Centralized updates |

## 🎯 Outcome
Successfully implemented both warehouse designs and demonstrated the structural and maintenance differences between **Star Schema and Snowflake Schema**.