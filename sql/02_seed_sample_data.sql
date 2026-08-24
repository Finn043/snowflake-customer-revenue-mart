USE WAREHOUSE ANALYTICS_WH;
USE DATABASE CUSTOMER_REVENUE_ANALYTICS;

CREATE OR REPLACE TABLE RAW.CUSTOMERS (
  customer_id STRING,
  customer_name STRING,
  acquisition_channel STRING,
  signup_date DATE,
  region STRING
);

INSERT INTO RAW.CUSTOMERS VALUES
  ('C001', 'Aster Finance', 'LinkedIn Ads', '2024-01-12', 'VIC'),
  ('C002', 'Northline Health', 'Organic Search', '2024-01-18', 'NSW'),
  ('C003', 'Harbour Retail', 'Partner Referral', '2024-02-04', 'VIC'),
  ('C004', 'Vertex Education', 'LinkedIn Ads', '2024-02-21', 'QLD'),
  ('C005', 'Atlas Mobility', 'Email Campaign', '2024-03-03', 'NSW'),
  ('C006', 'Clearview Labs', 'Organic Search', '2024-03-15', 'VIC'),
  ('C007', 'Nova Grants', 'Partner Referral', '2024-04-11', 'SA'),
  ('C008', 'Metro Insight', 'Email Campaign', '2024-04-29', 'VIC');

CREATE OR REPLACE TABLE RAW.ORDERS (
  order_id STRING,
  customer_id STRING,
  order_date DATE,
  product_line STRING,
  order_amount NUMBER(12, 2)
);

INSERT INTO RAW.ORDERS VALUES
  ('O1001', 'C001', '2024-02-03', 'Analytics Retainer', 4200),
  ('O1002', 'C002', '2024-02-16', 'Dashboard Sprint', 3100),
  ('O1003', 'C003', '2024-03-01', 'Data Quality Audit', 2600),
  ('O1004', 'C001', '2024-03-18', 'Analytics Retainer', 4200),
  ('O1005', 'C004', '2024-03-22', 'Warehouse Setup', 5400),
  ('O1006', 'C005', '2024-04-02', 'Dashboard Sprint', 3500),
  ('O1007', 'C002', '2024-04-19', 'Data Quality Audit', 2200),
  ('O1008', 'C006', '2024-04-28', 'Analytics Retainer', 4100),
  ('O1009', 'C003', '2024-05-08', 'Dashboard Sprint', 3300),
  ('O1010', 'C007', '2024-05-20', 'Warehouse Setup', 6100),
  ('O1011', 'C001', '2024-05-29', 'Analytics Retainer', 4200),
  ('O1012', 'C008', '2024-06-05', 'Data Quality Audit', 2400),
  ('O1013', 'C004', '2024-06-16', 'Dashboard Sprint', 3600),
  ('O1014', 'C006', '2024-06-22', 'Analytics Retainer', 4100),
  ('O1015', 'C007', '2024-07-03', 'Warehouse Setup', 6100),
  ('O1016', 'C005', '2024-07-14', 'Dashboard Sprint', 3500);

CREATE OR REPLACE TABLE RAW.MARKETING_SPEND (
  month DATE,
  acquisition_channel STRING,
  spend_amount NUMBER(12, 2)
);

INSERT INTO RAW.MARKETING_SPEND VALUES
  ('2024-02-01', 'LinkedIn Ads', 2600),
  ('2024-02-01', 'Organic Search', 900),
  ('2024-03-01', 'Partner Referral', 600),
  ('2024-03-01', 'Email Campaign', 850),
  ('2024-04-01', 'LinkedIn Ads', 2800),
  ('2024-04-01', 'Organic Search', 950),
  ('2024-05-01', 'Partner Referral', 650),
  ('2024-05-01', 'Email Campaign', 900),
  ('2024-06-01', 'LinkedIn Ads', 3000),
  ('2024-06-01', 'Organic Search', 1000),
  ('2024-07-01', 'Partner Referral', 700),
  ('2024-07-01', 'Email Campaign', 950);
