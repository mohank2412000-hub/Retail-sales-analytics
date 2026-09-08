# 🛒 Retail Sales & Customer Analytics
### A MySQL + Python + Power BI Project


<img width="1062" height="863" alt="powerbidashboard_screenshot" src="https://github.com/user-attachments/assets/85f99db7-34bc-41de-a36d-524f6971a028" />

📁 [SQL Queries](sql/) · 📓 [Python Notebook](python/retail_analysis.ipynb) · 📊 [Dashboard Files](powerbi/) · 📄 [Full Report (Word)](docs/Retail-Sales-Analytics-Report.docx)

---

## Business Question

Superstore's leadership wants to know: **where is the business losing money, which customers are at risk of leaving, and why?**

Specifically, this project set out to answer three things:
1. Is revenue growing, and how volatile is it month to month?
2. Which customers are most valuable — and which are at risk of churning?
3. Which product categories are least profitable, and why?

---

## Approach

**1. Database Design (MySQL)**
Rather than working off a single flat CSV, I designed a normalized relational schema with four related tables — `customers`, `products`, `orders`, and `order_details` — connected via primary and foreign keys. Raw data was staged, cleaned (handling mixed date formats and encoding issues), and loaded into the normalized structure using a mix of SQL and a Python-based ETL script, built after working through Windows-specific MySQL import/driver issues.

**2. Analysis (SQL + Python)**
- Wrote SQL queries using joins, `GROUP BY`, and window functions (`NTILE`) to calculate monthly revenue trends, top products by profit, and category/region profit margins
- Built an **RFM (Recency, Frequency, Monetary) customer segmentation model** using CTEs and window functions, classifying all 793 customers into five segments: Best Customers, New Customers, At Risk, Lost/Churned, and Regular
- In Python, pulled this data via SQLAlchemy into Pandas to run a **discount-vs-profit correlation analysis** and build a **cohort retention heatmap** tracking repeat purchase behavior over 47 months

**3. Dashboard (Power BI)**
Connected Power BI directly to the MySQL database via ODBC, built a relational data model matching the MySQL schema, wrote DAX measures (Total Revenue, Profit Margin %, Total Orders), and built an interactive, cross-filterable dashboard combining all findings into one page.

---

## Key Findings

**📈 Revenue is growing but volatile.** Total revenue reached $2.30M across the dataset, growing steadily year-over-year (2014→2017), but with sharp month-to-month swings — e.g., a drop from $82K to $12K within a few months — indicating seasonality or inconsistent demand rather than steady growth.

**⚠️ ~30% of the customer base is churned or at risk.** RFM segmentation revealed 181 customers (23%) as fully churned and 60 (8%) as "at risk" — previously loyal customers who have gone quiet. Combined, that's nearly a third of the customer base representing a retention opportunity.

**📉 Furniture is the weakest category, driven by discounting.** Furniture showed negative profit margins in 2 of 4 regions (Central: -67%, East: -9%), with average discounts of 17.4% — the highest of any category — compared to just 13.2% for Technology, which remained the most profitable category despite lower average discounts. A discount-vs-profit correlation of -0.22 confirmed this relationship holds across the dataset, though it's notably stronger within Furniture specifically.

---

## Recommendations

1. **Cap Furniture discounts** below the ~30% threshold where profit consistently turns negative, particularly for Tables and Bookcases (the two least profitable sub-categories, at -$18K and -$3K respectively)
2. **Launch a win-back campaign** targeted at the 241 customers in the At-Risk and Lost/Churned segments, prioritizing At-Risk customers first since they have a proven purchase history
3. **Investigate revenue volatility** further — determine whether the sharp monthly swings are seasonal (predictable) or indicate inconsistent demand generation that could be smoothed with better marketing cadence

---

## Repository Structure

```
retail-sales-analytics/
├── README.md
├── sql/
│   ├── 01_schema.sql              # Table creation + relationships
│   ├── 02_data_import.sql         # Staging table + normalized load
│   └── 03_analysis_queries.sql    # Revenue, RFM, discount/profit queries
├── python/
│   └── retail_analysis.ipynb      # RFM pull, correlation, cohort heatmap
├── powerbi/
│   ├── dashboard_screenshot.png
│   └── retail_dashboard.pbix
└── docs/
    └── Retail-Sales-Analytics-Report.docx
```

---

## Tools & Skills Demonstrated
`MySQL` (schema design, joins, CTEs, window functions) · `Python` (Pandas, SQLAlchemy, Seaborn, correlation & cohort analysis) · `Power BI` (DAX, data modeling, ODBC connectivity, interactive dashboards)

---

*Part of a data analyst portfolio — see also: [HR Attrition Analysis](https://github.com/mohank2412000-hub/HR-attrition-analysis)*
