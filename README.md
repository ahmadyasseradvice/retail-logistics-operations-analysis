# Multi-Channel Retail Operations & Logistics Delay Analysis

**Author:** Ahmad Yasser Morsy  
**Tools Used:** Advanced Google Sheets / Excel, SQL (BigQuery / SQLite)  
**Live Interactive Spreadsheet:** [View on Google Sheets](https://docs.google.com/spreadsheets/d/1xlOC8AhJeDri3pyyEp1JoNfksqpuqKzGy1V2f8RCat8/edit)

---

## Executive Summary
This project analyzes multi-channel sales performance, SKU-level profitability, and carrier shipping delays across regional hubs. The objective was to eliminate margin leakage caused by unmonitored returns and carrier SLA breaches, delivering an actionable dashboard and an automated SQL pipeline for operations teams.

---

## Key Business Insights
* **Channel Margin Discrepancy:** Direct Online sales yielded higher net margins (48.5%) compared to third-party marketplaces (32.1%) due to fulfillment overhead and platform take rates.
* **Return Rate Impact:** The Apparel category experienced higher return rates (14.2%) compared to Electronics (3.8%), skewing gross vs. net revenue figures.
* **Logistics Bottlenecks:** Upper Egypt and Canal shipping corridors had average transit delays of +1.8 to +2.4 days past SLA, highlighting the need for carrier renegotiations or local 3PL fulfillment hubs.

---

## Technical Implementation

### 1. Advanced Spreadsheet Modeling (`retail_operations_and_logistics_model.xlsx`)
* **Dynamic Master Lookups:** Utilized `XLOOKUP` to match SKUs against dimension tables (`Dim_Products`) with custom error handling (`"Missing SKU"`).
* **Multi-Condition Aggregations:** Implemented `SUMIFS` and `COUNTIFS` to calculate channel-specific net profit, filtering out canceled and returned units.
* **Data Hygiene & Revenue Integrity:** Structured conditional `IF` logic to zero out net revenue on returned merchandise to avoid top-line inflation.

### 2. SQL Data Pipeline (`analysis_pipeline.sql`)
* **Common Table Expressions (CTEs):** Modularized data extraction into 3 distinct stages (`Order_Turnaround_Base`, `Customer_Order_History`, and `Corridor_Delay_Analysis`).
* **Window Functions:** Applied `DENSE_RANK() OVER (PARTITION BY ...)` to evaluate order concentration per customer across geographic regions.
* **Duration & SLA Modeling:** Parsed order timestamps using `JULIANDAY` date arithmetic to measure exact delay variances against promised delivery windows.

---

## Repository Structure

---
├── README.md                                  # Project overview and business findings
├── analysis_pipeline.sql                      # Production SQL pipeline with CTEs & window functions
└── retail_operations_and_logistics_model.xlsx  # Multi-tab financial and logistics workbook
---

## Contact
* LinkedIn: https://linkedin.com
* GitHub: https://github.com/ahmadyasseradvice
