# Snowflake Customer Revenue Mart

This is a beginner-friendly Snowflake analytics engineering project. It shows how to turn raw customer, order, and marketing spend data into clean, BI-ready marts for revenue reporting.

The project is intentionally small so you can understand every step before scaling it into a bigger portfolio case study.

## Final Result

After completing this project, you will have:

- A Snowflake database called `CUSTOMER_REVENUE_ANALYTICS`.
- Three schemas: `RAW`, `STAGING`, and `MARTS`.
- Raw source tables for customers, orders, and marketing spend.
- Clean staging views.
- BI-ready mart tables for monthly revenue, customer revenue, and channel performance.
- Quality checks for duplicates, orphan records, null keys, and revenue reconciliation.

![Snowflake revenue mart preview](assets/snowflake-revenue-mart-preview.svg)

## Business Problem

A business has customer orders and marketing spend stored as raw extracts. The data is useful, but it is not ready for reporting because:

- Customer, order, and spend data live in separate tables.
- Business metrics such as revenue, average order value, CAC, and ROAS are not modeled yet.
- Analysts need repeatable checks before trusting the numbers.
- Dashboard users need simple reporting tables instead of raw operational data.

This project solves that by building a small warehouse model:

```text
Source CSVs -> RAW tables -> STAGING views -> MART tables -> BI dashboard
```

## Tools Used

- Snowflake
- SQL
- Snowsight Worksheets or Workspaces
- CSV sample data
- Optional: Power BI, Tableau, Looker Studio, or Snowsight dashboards

## Cost Notes

You can do this with a Snowflake trial account. Keep the warehouse size as `XSMALL` and keep `AUTO_SUSPEND = 60`, which means the warehouse suspends after 60 seconds of inactivity.

Snowflake credits are consumed when a virtual warehouse runs queries. Storage can also use a small amount of trial balance. For this project, the sample data is tiny, so usage should be minimal if you suspend the warehouse when finished.

Official Snowflake docs:

- Trial accounts: https://docs.snowflake.com/en/user-guide/admin-trial-account
- Snowsight: https://docs.snowflake.com/en/user-guide/ui-snowsight
- Worksheets: https://docs.snowflake.com/en/user-guide/ui-snowsight-worksheets
- Workspaces: https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-working
- Warehouses and auto-suspend: https://docs.snowflake.com/en/user-guide/warehouses-overview

## Repo Structure

```text
data/
  customers.csv
  orders.csv
  marketing_spend.csv

sql/
  01_setup.sql
  02_seed_sample_data.sql
  03_transform_marts.sql
  04_quality_checks.sql

assets/
  snowflake-revenue-mart-preview.svg
```

## Step 1: Create a Snowflake Trial Account

1. Go to the Snowflake trial page from the official Snowflake website.
2. Sign up with your email.
3. Choose a cloud provider and region.
4. For a beginner project, choose a common region close to you.
5. After your account is created, sign in to Snowsight.

You do not need payment details for the standard trial flow, but always check the current Snowflake trial terms before starting.

## Step 2: Open a SQL Editor

Snowflake is moving accounts from Worksheets to Workspaces, so your account may show either option.

Use whichever your account shows:

- If you see `Projects -> Worksheets`, create a new SQL Worksheet.
- If you see `Projects -> Workspaces`, create a new SQL file.

You will run the files in the `sql/` folder one by one.

## Step 3: Run the Setup Script

Open `sql/01_setup.sql` and run it.

This creates:

- `ANALYTICS_WH`: the compute warehouse.
- `CUSTOMER_REVENUE_ANALYTICS`: the database.
- `RAW`: schema for source data.
- `STAGING`: schema for cleaned views.
- `MARTS`: schema for reporting tables.

The important warehouse settings are:

```sql
WAREHOUSE_SIZE = XSMALL
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
```

These settings keep the project simple and cost-aware.

## Step 4: Seed the Sample Data

Open `sql/02_seed_sample_data.sql` and run it.

This creates and fills three raw tables:

- `RAW.CUSTOMERS`
- `RAW.ORDERS`
- `RAW.MARKETING_SPEND`

The repo also includes the same sample data as CSV files in `data/`. The SQL insert script is included so beginners can run the project without learning Snowflake file stages first.

Check that the data loaded:

```sql
SELECT COUNT(*) FROM RAW.CUSTOMERS;
SELECT COUNT(*) FROM RAW.ORDERS;
SELECT COUNT(*) FROM RAW.MARKETING_SPEND;
```

Expected counts:

```text
RAW.CUSTOMERS         8
RAW.ORDERS            16
RAW.MARKETING_SPEND   12
```

## Step 5: Build Staging Views and Marts

Open `sql/03_transform_marts.sql` and run it.

This creates:

### Staging Views

`STAGING.STG_CUSTOMERS`

- Standardizes customer names.
- Keeps customer ID, acquisition channel, signup date, and region.

`STAGING.STG_ORDERS`

- Adds `order_month`.
- Filters out invalid negative or zero order amounts.

`STAGING.STG_MARKETING_SPEND`

- Keeps valid monthly channel spend.
- Filters out negative spend.

### Mart Tables

`MARTS.FCT_ORDERS`

- Joins orders to customers.
- Produces an analytics-ready fact table.

`MARTS.MART_MONTHLY_REVENUE`

- Revenue by month.
- Total orders.
- Active customers.
- Average order value.

`MARTS.MART_CUSTOMER_REVENUE`

- Customer lifetime revenue.
- First and last order dates.
- Repeat-customer flag.

`MARTS.MART_CHANNEL_PERFORMANCE`

- Revenue by acquisition channel.
- Marketing spend.
- CAC.
- ROAS.

## Step 6: Query the Marts

Run these examples after the marts are created.

Monthly revenue:

```sql
SELECT *
FROM MARTS.MART_MONTHLY_REVENUE
ORDER BY order_month;
```

Best customers:

```sql
SELECT *
FROM MARTS.MART_CUSTOMER_REVENUE
ORDER BY lifetime_revenue DESC;
```

Channel performance:

```sql
SELECT *
FROM MARTS.MART_CHANNEL_PERFORMANCE
ORDER BY order_month, acquisition_channel;
```

Best ROAS:

```sql
SELECT
  acquisition_channel,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(marketing_spend), 2) AS spend,
  ROUND(SUM(revenue) / NULLIF(SUM(marketing_spend), 0), 2) AS blended_roas
FROM MARTS.MART_CHANNEL_PERFORMANCE
GROUP BY acquisition_channel
ORDER BY blended_roas DESC;
```

## Step 7: Run Quality Checks

Open `sql/04_quality_checks.sql` and run it.

The checks answer four questions:

- Are there duplicate order IDs?
- Are there orders that do not match a customer?
- Are there null customer keys?
- Does raw revenue match mart revenue?

Expected result:

- Duplicate order IDs: `0`
- Orphan orders: `0`
- Null customer keys: `0`
- Revenue reconciliation variance: `0`

If any issue count is above `0`, inspect the raw data before trusting the dashboard.

## Step 8: Create a Simple Dashboard

You can use Snowsight charts first, then later connect Power BI, Tableau, or Looker Studio.

Beginner dashboard layout:

```text
Top KPI cards:
- Total revenue
- Total orders
- Average order value
- Repeat customer rate

Charts:
- Monthly revenue trend
- Revenue by acquisition channel
- ROAS by channel
- Top customers by lifetime revenue
```

Example KPI queries:

```sql
SELECT
  SUM(revenue) AS total_revenue,
  SUM(total_orders) AS total_orders,
  ROUND(SUM(revenue) / NULLIF(SUM(total_orders), 0), 2) AS average_order_value
FROM MARTS.MART_MONTHLY_REVENUE;
```

```sql
SELECT
  ROUND(
    COUNT_IF(is_repeat_customer) / NULLIF(COUNT(*), 0) * 100,
    2
  ) AS repeat_customer_rate
FROM MARTS.MART_CUSTOMER_REVENUE;
```

## Step 9: Suspend the Warehouse

When you finish running the project, suspend the warehouse:

```sql
ALTER WAREHOUSE ANALYTICS_WH SUSPEND;
```

This stops compute usage after your queries are done.

## Step 10: Explain the Project in an Interview

Short version:

> I built a Snowflake-ready revenue mart that turns raw customer, order, and marketing spend data into reporting tables. The model separates raw, staging, and mart layers, includes quality checks, and produces monthly revenue, customer lifetime value, CAC, and ROAS metrics for BI dashboards.

Technical version:

> The project uses an XSMALL Snowflake warehouse with auto-suspend, raw source tables, staging views for type cleanup and filtering, and mart tables for dimensional reporting. I added reconciliation checks so the final marts can be validated against raw revenue before dashboarding.

Business impact version:

> Instead of asking stakeholders to query raw operational tables, the project creates trusted BI-ready marts that make revenue trends, customer value, and marketing efficiency easier to monitor.

## How to Extend This Project

Good next improvements:

- Load CSV files through an internal Snowflake stage instead of insert statements.
- Add dbt models and tests.
- Add a date dimension.
- Add product margin and gross profit.
- Connect the marts to Power BI or Tableau.
- Add screenshots from the finished dashboard.

Skip these until the basic SQL version works. A simple finished project is better than a complex unfinished one.

## Project Status

Active work. The SQL and sample data are ready to run in Snowflake. The next step is to execute the scripts inside a Snowflake trial workspace and capture dashboard screenshots for the portfolio.
