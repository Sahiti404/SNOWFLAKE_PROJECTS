# Project 14A — E-Commerce Web Event Analytics

## Overview
This project demonstrates **Data Lake vs Data Warehouse** ingestion in Snowflake using **Schema-on-Read** and **Schema-on-Write** approaches.

## Workflow

JSON Events  
→ Snowflake Stage  
→ `LAKE_RAW_EVENTS`  
→ JSON Extraction & Analysis  
→ `DW_STRUCTURED_EVENTS`

Invalid records → `QUARANTINE_RAW_EVENTS`

## Tasks
- Ingested JSON event data into a Data Lake.
- Extracted semi-structured data using Schema-on-Read.
- Performed revenue and conversion analysis.
- Loaded transformed data into a structured Data Warehouse.
- Implemented data validation and error quarantine.

## Tables
- `LAKE_RAW_EVENTS` — Raw JSON data stored as `VARIANT`
- `DW_STRUCTURED_EVENTS` — Structured and transformed event data
- `QUARANTINE_RAW_EVENTS` — Invalid records

## Technologies
- Snowflake
- Snowflake SQL
- JSON
- VARIANT
- Semi-Structured Data
- Schema-on-Read
- Schema-on-Write
- Data Validation & Quarantine