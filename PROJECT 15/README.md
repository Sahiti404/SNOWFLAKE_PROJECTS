# Project 15 — Cross-Border Logistics & Fleet Telematics Lakehouse

## Overview
Built a **Snowflake Medallion Lakehouse** to process IoT telematics and customs clearance JSON data using Bronze, Silver, and Gold layers.

## Key Features
- Bronze layer with **VARIANT** for Schema-on-Read.
- Batch ingestion of JSON payloads using Snowflake stages.
- Malformed JSON detection and **quarantine/dead-letter handling**.
- Silver layer with Schema-on-Write transformations and duty calculations.
- Schema evolution handling using `border_clearance_code`.
- Gold layer with country-level customs duty aggregations.
- Snowflake **Time Travel** for data auditing and recovery.
- End-to-end Bronze → Silver → Gold reconciliation.

## Technologies
- Snowflake SQL
- JSON / Semi-Structured Data
- Medallion Architecture
- Schema-on-Read & Schema-on-Write
- Snowflake Time Travel

