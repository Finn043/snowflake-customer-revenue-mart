USE WAREHOUSE ANALYTICS_WH;
USE DATABASE CUSTOMER_REVENUE_ANALYTICS;

SELECT 'duplicate_order_ids' AS check_name, COUNT(*) AS issue_count
FROM (
  SELECT order_id
  FROM RAW.ORDERS
  GROUP BY order_id
  HAVING COUNT(*) > 1
);

SELECT 'orphan_orders' AS check_name, COUNT(*) AS issue_count
FROM RAW.ORDERS o
LEFT JOIN RAW.CUSTOMERS c
  ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT 'null_customer_keys' AS check_name, COUNT(*) AS issue_count
FROM RAW.CUSTOMERS
WHERE customer_id IS NULL OR customer_name IS NULL;

SELECT
  'revenue_reconciliation' AS check_name,
  SUM(raw_revenue) AS raw_revenue,
  SUM(mart_revenue) AS mart_revenue,
  SUM(raw_revenue) - SUM(mart_revenue) AS variance
FROM (
  SELECT SUM(order_amount) AS raw_revenue, 0 AS mart_revenue FROM RAW.ORDERS
  UNION ALL
  SELECT 0 AS raw_revenue, SUM(revenue) AS mart_revenue FROM MARTS.MART_MONTHLY_REVENUE
);
