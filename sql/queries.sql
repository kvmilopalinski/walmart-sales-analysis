-- ============================================================
-- Walmart Store Sales Analysis
-- SQL Queries (DuckDB / SQLite compatible)
-- Dataset: Walmart Recruiting - Store Sales Forecasting (Kaggle)
-- Tables: train.csv, features.csv, stores.csv
-- ============================================================


-- ============================================================
-- SECTION 1: DATA EXPLORATION & QUALITY CHECKS
-- ============================================================

-- Query 1: Date range and dataset dimensions
-- How many weeks, stores and departments does the dataset cover?
SELECT
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT store) AS store_count,
    COUNT(DISTINCT dept) AS dept_count
FROM train.csv;


-- Query 2: Weekly_Sales quality check
-- What is the range of sales values, and how many rows have negative sales?
SELECT
    MIN(weekly_sales) AS min_weekly_sales,
    MAX(weekly_sales) AS max_weekly_sales,
    AVG(weekly_sales) AS avg_weekly_sales,
    SUM(CASE WHEN weekly_sales < 0 THEN 1 ELSE 0 END) AS negative_sales_count
FROM train.csv;


-- Query 3: Concentration of negative Weekly_Sales by department
-- Are negative values random noise or concentrated in specific departments?
SELECT
    dept,
    COUNT(*) AS negative_values_qty
FROM train.csv
WHERE weekly_sales < 0
GROUP BY dept
ORDER BY negative_values_qty DESC;


-- ============================================================
-- SECTION 2: SALES TREND ANALYSIS
-- ============================================================

-- Query 4: Monthly sales trend
-- How does total sales evolve month by month across the full period?
SELECT
    strftime('%Y-%m', date) AS year_month,
    SUM(weekly_sales) AS total_sales
FROM train.csv
GROUP BY year_month
ORDER BY year_month ASC;


-- Query 5: Average weekly sales by store type
-- Do larger stores (Type A) significantly outperform smaller ones (B, C)?
SELECT
    s.type AS store_type,
    AVG(t.weekly_sales) AS avg_weekly_sales
FROM train.csv t
INNER JOIN stores.csv s ON t.store = s.store
GROUP BY store_type
ORDER BY avg_weekly_sales DESC;


-- Query 6: Impact of holidays by store type
-- Is the holiday sales uplift consistent across store types?
SELECT
    s.type AS store_type,
    t.isholiday,
    AVG(t.weekly_sales) AS avg_weekly_sales
FROM train.csv t
INNER JOIN stores.csv s ON t.store = s.store
GROUP BY store_type, isholiday
ORDER BY store_type, avg_weekly_sales DESC;


-- ============================================================
-- SECTION 3: MARKDOWN (PROMOTION) ANALYSIS
-- ============================================================

-- Query 7: Detecting data type issue in MarkDown columns
-- MarkDown columns were loaded as text due to literal "NA" values
-- This query checks the actual distinct values
SELECT DISTINCT markdown1
FROM features.csv
LIMIT 10;


-- Query 8: True fill rate of MarkDown1
-- How many rows actually have a real (non-NA) markdown value?
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN markdown1 != 'NA' THEN 1 ELSE 0 END) AS markdown1_filled
FROM features.csv;


-- Query 9: First date with real MarkDown1 data
-- When did Walmart start reporting markdown values?
SELECT MIN(date) AS first_markdown_date
FROM features.csv
WHERE markdown1 != 'NA';


-- Query 10: Range and anomalies in MarkDown1 values
-- Are there negative markdown values? What is the overall range?
SELECT
    MIN(CAST(markdown1 AS REAL)) AS min_markdown1,
    MAX(CAST(markdown1 AS REAL)) AS max_markdown1,
    COUNT(*) AS rows_checked
FROM features.csv
WHERE markdown1 != 'NA';


-- Query 11: Distribution of MarkDown1 values (negative / zero / positive)
SELECT
    SUM(CASE WHEN CAST(markdown1 AS REAL) < 0 THEN 1 ELSE 0 END) AS negative_count,
    SUM(CASE WHEN CAST(markdown1 AS REAL) = 0 THEN 1 ELSE 0 END) AS zero_count,
    SUM(CASE WHEN CAST(markdown1 AS REAL) > 0 THEN 1 ELSE 0 END) AS positive_count
FROM features.csv
WHERE markdown1 != 'NA';


-- Query 12: Impact of markdown level on average weekly sales
-- Does a higher markdown correlate with higher sales?
-- Note: limited to post-November 2011 period when markdowns were reported
SELECT
    CASE
        WHEN CAST(f.markdown1 AS REAL) < 5000 THEN 'Low (<5000)'
        WHEN CAST(f.markdown1 AS REAL) < 15000 THEN 'Mid (5000-15000)'
        ELSE 'High (>15000)'
    END AS markdown_tier,
    COUNT(*) AS row_qty,
    AVG(t.weekly_sales) AS avg_weekly_sales
FROM train.csv t
INNER JOIN features.csv f ON t.store = f.store AND t.date = f.date
WHERE f.markdown1 != 'NA'
    AND CAST(f.markdown1 AS REAL) >= 0
GROUP BY markdown_tier
ORDER BY avg_weekly_sales DESC;


-- ============================================================
-- SECTION 4: MACROECONOMIC FACTORS ANALYSIS
-- ============================================================

-- Query 13: Checking for NA values in CPI and Unemployment
-- These columns also contain literal "NA" strings (same issue as MarkDown)
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN cpi = 'NA' THEN 1 ELSE 0 END) AS cpi_na_count,
    SUM(CASE WHEN unemployment = 'NA' THEN 1 ELSE 0 END) AS unemployment_na_count
FROM features.csv;


-- Query 14: Date range of missing CPI/Unemployment values
-- Are the NAs concentrated in a specific time period?
SELECT
    MIN(date) AS min_date_na,
    MAX(date) AS max_date_na
FROM features.csv
WHERE cpi = 'NA';


-- Query 15: Verifying that NA rows are outside the training period
-- After INNER JOIN with train, how many NA rows remain?
SELECT COUNT(*) AS na_rows_after_join
FROM train.csv t
INNER JOIN features.csv f ON t.store = f.store AND t.date = f.date
WHERE f.cpi = 'NA';


-- Query 16: CPI and Unemployment statistics within the training period
SELECT
    MIN(CAST(f.cpi AS REAL)) AS min_cpi,
    MAX(CAST(f.cpi AS REAL)) AS max_cpi,
    AVG(CAST(f.cpi AS REAL)) AS avg_cpi,
    MIN(CAST(f.unemployment AS REAL)) AS min_unemployment,
    MAX(CAST(f.unemployment AS REAL)) AS max_unemployment,
    AVG(CAST(f.unemployment AS REAL)) AS avg_unemployment
FROM train.csv t
INNER JOIN features.csv f ON t.store = f.store AND t.date = f.date;


-- Query 17: Average sales by unemployment tier
-- Does unemployment level correlate with weekly sales?
SELECT
    CASE
        WHEN CAST(f.unemployment AS REAL) < 7 THEN 'Low (<7%)'
        WHEN CAST(f.unemployment AS REAL) < 9 THEN 'Mid (7-9%)'
        ELSE 'High (>9%)'
    END AS unemployment_tier,
    COUNT(*) AS row_qty,
    AVG(t.weekly_sales) AS avg_weekly_sales
FROM train.csv t
INNER JOIN features.csv f ON t.store = f.store AND t.date = f.date
GROUP BY unemployment_tier
ORDER BY avg_weekly_sales DESC;


-- ============================================================
-- SECTION 5: FINAL BASE QUERY
-- ============================================================

-- Query 18: Final combined dataset (train + features + stores)
-- This query produces the base table exported to Excel and Power BI
-- All three tables joined; CPI and Unemployment cast to numeric
-- MarkDown columns retained as text (NA handling done in Power Query)
SELECT
    t.store,
    t.dept,
    t.date,
    t.weekly_sales,
    t.isholiday,
    s.type AS store_type,
    s.size AS store_size,
    f.temperature,
    f.fuel_price,
    f.markdown1,
    f.markdown2,
    f.markdown3,
    f.markdown4,
    f.markdown5,
    CAST(f.cpi AS REAL) AS cpi,
    CAST(f.unemployment AS REAL) AS unemployment
FROM train.csv t
INNER JOIN features.csv f
    ON t.store = f.store AND t.date = f.date
INNER JOIN stores.csv s
    ON t.store = s.store
ORDER BY t.store, t.dept, t.date;
