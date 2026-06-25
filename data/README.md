# Walmart Store Sales Analysis
### Demand Forecasting & Sales Performance Dashboard

---

## 📊 Live Dashboard

🔗 **[View Power BI Dashboard](https://app.powerbi.com/view?r=eyJrIjoiOWUyM2E5ZTgtYmNhOC00MDM0LTgzZDItNTFjODk5ZjcxYTRlIiwidCI6IjgyNTNlNjA2LTRkOWYtNGM3MC1hOTUxLWMwOTY5YWYxYWYwNyIsImMiOjh9)**

📓 **[View Full Analysis Notebook (SQL + Excel documentation)](https://www.datacamp.com/datalab/w/c5ca7f2a-b65e-40c7-8883-ea2df6714eee/edit)**

---

## Project Overview

This project analyzes weekly sales data from 45 Walmart stores across 81 departments over a 3-year period (2010–2012), using real data from the [Kaggle Walmart Recruiting competition](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting).

The goal was to identify what drives sales performance — seasonality, holidays, promotions, store type, and macroeconomic conditions — and translate those findings into actionable supply chain and inventory management recommendations.

---

## Business Questions

- How strong is holiday seasonality, and does it affect all store types equally?
- Which stores and departments drive the majority of total sales (ABC/Pareto)?
- Do markdowns (promotions) meaningfully impact weekly sales?
- Do macroeconomic factors (unemployment, CPI, fuel price) correlate with sales — and is that correlation causal?

---

## Tools & Methodology

| Phase | Tool | Purpose |
|---|---|---|
| Data exploration & cleaning | SQL (DuckDB via DataLab) | Joins, aggregations, data quality checks |
| Intermediate analysis | Excel (Power Query + Pivot Tables) | Pareto analysis, seasonality, forecasting |
| Dashboard & visualization | Power BI | Interactive 4-page dashboard |

**Workflow:** SQL → Excel → Power BI. Each phase builds on the previous one; all analytical decisions are documented with reasoning in the notebook.

---

## Dataset

- **Source:** [Walmart Recruiting — Store Sales Forecasting (Kaggle)](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting)
- **Files used:** `train.csv`, `features.csv`, `stores.csv`
- **Scope:** 45 stores · 81 departments · 143 weeks (Feb 2010 – Oct 2012) · 421,570 rows

| File | Description |
|---|---|
| `train.csv` | Weekly sales per store and department |
| `features.csv` | External factors: temperature, fuel price, markdowns, CPI, unemployment |
| `stores.csv` | Store type (A/B/C) and size |

> Note: Raw CSV files are not included in this repository due to size. Download them directly from Kaggle using the link above.

---

## Dashboard Structure

The Power BI dashboard consists of four pages:

**1. Overview**
Total sales KPI ($6.74B), monthly sales trend with 6-month forecast (95% CI), Top 10 stores by sales, year filter.

**2. Seasonality & Holidays**
Monthly sales split by holiday vs non-holiday weeks, average sales by store type during holidays, impact of markdown level on sales.

**3. Stores & Departments**
Full store sales ranking, Top 5 and Worst 5 departments (with Dept 47 anomaly highlighted in red), average sales by store type, store type filter.

**4. Macroeconomic Context**
CPI and unemployment rate trends (2010–2012), average sales by unemployment level broken down by store type (confounding variable visualization), fuel price trend.

---

## Key Findings

**1. Holiday seasonality is strong and consistent.**
December generates ~43% more sales than January (the weakest month) across all three years. The effect is not uniform: Type B stores show the strongest holiday uplift (~9.8%), Type A moderate (~6.4%), and Type C almost none (~0.1%). Implication: pre-holiday inventory increases should be differentiated by store type, not applied uniformly.

**2. Sales concentration is stronger at the department level than the store level.**
29 out of 81 departments (~36%) account for 80% of total sales, vs 27 out of 45 stores (~60%). Inventory prioritization should focus on product category (especially Depts 92, 95, 38, 72, 90) more than geographic location.

**3. Dept 47 is a significant operational anomaly.**
The only department with a negative total sales sum across the entire period (-$4,962.93), driven by 254 weeks of negative weekly sales (20% of all negative cases in the dataset). This pattern suggests a systemic returns issue or reporting error requiring investigation by the merchandising team.

**4. Promotions correlate with higher sales, but with diminishing returns.**
Moving from low to mid markdown level increases average weekly sales by ~36%, but moving from mid to high adds only ~4.7%. The optimal markdown investment band appears to be $5,000–$15,000, above which marginal return declines sharply.

**5. The raw unemployment–sales correlation is misleading.**
Regions with medium unemployment (7–9%) show the highest average sales — not because of unemployment itself, but because 56.9% of data rows in that group belong to large Type A stores. This is a textbook confounding variable: store size, not unemployment level, drives the sales difference. Operational decisions should not rely on this correlation without controlling for store type.

---

## Data Quality Issues Encountered

| Issue | Discovery Method | Resolution |
|---|---|---|
| `MarkDown1-5` stored as text with literal `"NA"` instead of NULL | `SELECT DISTINCT markdown1` in SQL | Filter `!= 'NA'` before CAST; replaced with null in Power Query |
| CPI and Unemployment also stored as text | `AVG()` error in DuckDB | Same approach: filter then CAST |
| 585 rows with missing CPI/Unemployment | Date range check | Rows belong to post-training period (2013); eliminated naturally by INNER JOIN with train |
| 1,285 rows with negative Weekly_Sales | MIN/MAX check | Retained as real business signal (returns); concentrated in Dept 47 |
| American decimal format (`.`) vs Polish Excel locale (`,`) | Type conversion error in Power Query | Used "Change Type Using Locale" (English - United States) |
| Duplicate index column from DataLab CSV export | Visual inspection | Removed in Power Query |

---

## Repository Structure

```
walmart-sales-analysis/
├── README.md                  ← this file
├── notebooks/
│   └── analysis.ipynb         ← full SQL + Excel documentation (DataLab export)
├── sql/
│   └── queries.sql            ← all SQL queries used in the project
├── data/
│   └── README.md              ← dataset description and Kaggle download link
└── screenshots/
    ├── overview.png
    ├── seasonality.png
    ├── stores_departments.png
    └── macroeconomic.png
```

---

## Skills Demonstrated

`SQL` · `DuckDB` · `Excel Power Query` · `Pivot Tables` · `FORECAST.LINEAR` · `Power BI` · `DAX` · `Data Cleaning` · `Exploratory Data Analysis` · `ABC/Pareto Analysis` · `Confounding Variable Detection` · `Supply Chain Analytics`

---

*Dataset source: [Walmart Recruiting — Store Sales Forecasting](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting) · Kaggle (2014)*
