USE WAREHOUSE ANALYTICS_WH;
USE DATABASE CUSTOMER_REVENUE_ANALYTICS;

CREATE OR REPLACE VIEW STAGING.STG_CUSTOMERS AS
SELECT
  customer_id,
  INITCAP(customer_name) AS customer_name,
  acquisition_channel,
  signup_date,
  region
FROM RAW.CUSTOMERS;

CREATE OR REPLACE VIEW STAGING.STG_ORDERS AS
SELECT
  order_id,
  customer_id,
  order_date,
  DATE_TRUNC('month', order_date)::DATE AS order_month,
  product_line,
  order_amount
FROM RAW.ORDERS
WHERE order_amount > 0;

CREATE OR REPLACE VIEW STAGING.STG_MARKETING_SPEND AS
SELECT
  month,
  acquisition_channel,
  spend_amount
FROM RAW.MARKETING_SPEND
WHERE spend_amount >= 0;

CREATE OR REPLACE TABLE MARTS.FCT_ORDERS AS
SELECT
  o.order_id,
  o.customer_id,
  c.customer_name,
  c.acquisition_channel,
  c.region,
  o.order_date,
  o.order_month,
  o.product_line,
  o.order_amount
FROM STAGING.STG_ORDERS o
JOIN STAGING.STG_CUSTOMERS c
  ON o.customer_id = c.customer_id;

CREATE OR REPLACE TABLE MARTS.MART_MONTHLY_REVENUE AS
SELECT
  order_month,
  COUNT(*) AS total_orders,
  COUNT(DISTINCT customer_id) AS active_customers,
  SUM(order_amount) AS revenue,
  ROUND(AVG(order_amount), 2) AS average_order_value
FROM MARTS.FCT_ORDERS
GROUP BY order_month
ORDER BY order_month;

CREATE OR REPLACE TABLE MARTS.MART_CUSTOMER_REVENUE AS
SELECT
  customer_id,
  customer_name,
  region,
  acquisition_channel,
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  COUNT(*) AS orders,
  SUM(order_amount) AS lifetime_revenue,
  IFF(COUNT(*) > 1, TRUE, FALSE) AS is_repeat_customer
FROM MARTS.FCT_ORDERS
GROUP BY customer_id, customer_name, region, acquisition_channel;

CREATE OR REPLACE TABLE MARTS.MART_CHANNEL_PERFORMANCE AS
WITH revenue AS (
  SELECT
    order_month,
    acquisition_channel,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(order_amount) AS revenue
  FROM MARTS.FCT_ORDERS
  GROUP BY order_month, acquisition_channel
)
SELECT
  r.order_month,
  r.acquisition_channel,
  r.customers,
  r.revenue,
  COALESCE(s.spend_amount, 0) AS marketing_spend,
  ROUND(r.revenue / NULLIF(s.spend_amount, 0), 2) AS roas,
  ROUND(s.spend_amount / NULLIF(r.customers, 0), 2) AS cac
FROM revenue r
LEFT JOIN STAGING.STG_MARKETING_SPEND s
  ON r.order_month = s.month
 AND r.acquisition_channel = s.acquisition_channel
ORDER BY r.order_month, r.acquisition_channel;
