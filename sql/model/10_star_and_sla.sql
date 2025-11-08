-- Star schema + SLA views (compatible with minimal/full Northwind)

-- Drop previous
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_shipper;
DROP TABLE IF EXISTS dim_employee;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS fact_order;

-- Date Dimension
CREATE TABLE dim_date(
  date_key date PRIMARY KEY,
  year int,
  month int,
  day int,
  month_name varchar(10)
);

WITH dates AS (
  SELECT CAST('1994-01-01' AS date) AS d
  UNION ALL
  SELECT DATEADD(day, 1, d)
  FROM dates
  WHERE d < CAST('1998-12-31' AS date)
)
INSERT INTO dim_date(date_key, year, month, day, month_name)
SELECT
  d AS date_key,
  YEAR(d) AS year,
  MONTH(d) AS month,
  DAY(d) AS day,
  FORMAT(d, 'MMM') AS month_name
FROM dates
OPTION (MAXRECURSION 0);

-- Dimensions
-- Dimensions (use SELECT INTO in SQL Server)
SELECT DISTINCT
  c.customer_id,
  c.company_name,
  c.country
INTO dim_customer
FROM customers c;
ALTER TABLE dim_customer ADD CONSTRAINT pk_dim_customer PRIMARY KEY (customer_id);

SELECT
  s.shipper_id, s.company_name
INTO dim_shipper
FROM shippers s;
ALTER TABLE dim_shipper ADD CONSTRAINT pk_dim_shipper PRIMARY KEY (shipper_id);

SELECT
  e.employee_id,
  ISNULL(e.first_name,'') + ' ' + ISNULL(e.last_name,'') AS employee_name
INTO dim_employee
FROM employees e;
ALTER TABLE dim_employee ADD CONSTRAINT pk_dim_employee PRIMARY KEY (employee_id);

-- Fact (order line)
SELECT
  od.order_id,
  o.customer_id,
  o.employee_id,
  o.ship_via       AS shipper_id,
  o.order_date,
  o.required_date,
  o.shipped_date,
  od.product_id,
  od.quantity,
  od.unit_price,
  od.discount
INTO fact_order
FROM orders o
JOIN order_details od ON od.order_id = o.order_id;

CREATE INDEX idx_fact_order_order_id ON fact_order(order_id);
CREATE INDEX idx_fact_order_order_date ON fact_order(order_date);

-- SLA facts (order-level)
IF OBJECT_ID('vw_fact_sla','V') IS NOT NULL DROP VIEW vw_fact_sla;
GO
CREATE VIEW vw_fact_sla AS
WITH order_level AS (
  SELECT
    fo.order_id,
    MIN(fo.order_date)    AS order_date,
    MIN(fo.required_date) AS required_date,
    MIN(fo.shipped_date)  AS shipped_date,
    MIN(fo.shipper_id)    AS shipper_id,
    MIN(fo.employee_id)   AS employee_id,
    MIN(fo.customer_id)   AS customer_id
  FROM fact_order fo
  GROUP BY fo.order_id
)
SELECT
  ol.order_id,
  ol.customer_id,
  ol.employee_id,
  ol.shipper_id,
  ol.order_date,
  ol.required_date,
  ol.shipped_date,
  CASE WHEN ol.shipped_date IS NOT NULL AND ol.order_date IS NOT NULL
       THEN DATEDIFF(day, ol.order_date, ol.shipped_date)
       ELSE NULL
  END AS lead_time_days,
  CASE WHEN ol.required_date IS NOT NULL AND ol.shipped_date IS NOT NULL
       THEN CASE WHEN DATEDIFF(day, ol.required_date, ol.shipped_date) > 0
                 THEN DATEDIFF(day, ol.required_date, ol.shipped_date)
                 ELSE 0 END
       ELSE NULL
  END AS late_days,
  CASE WHEN ol.required_date IS NULL THEN 1 ELSE 0 END AS no_sla_flag,
  CASE
    WHEN ol.required_date IS NULL THEN 'NO_SLA'
    WHEN ol.shipped_date IS NULL THEN 'PENDING'
    WHEN ol.shipped_date <= ol.required_date THEN 'ON_TIME'
    ELSE 'LATE'
  END AS sla_status,
  CASE
    WHEN ol.required_date IS NULL THEN 'NO_SLA'
    WHEN ol.shipped_date IS NULL THEN 'PENDING'
    WHEN ol.shipped_date <= ol.required_date THEN '0d'
    WHEN DATEDIFF(day, ol.required_date, ol.shipped_date) BETWEEN 1 AND 3 THEN '1–3d'
    WHEN DATEDIFF(day, ol.required_date, ol.shipped_date) BETWEEN 4 AND 7 THEN '4–7d'
    ELSE '8d+'
  END AS late_bucket
FROM order_level ol;
GO

DROP VIEW IF EXISTS vw_shipper_sla;
GO
CREATE VIEW vw_shipper_sla AS
SELECT
  ds.company_name AS shipper,
  COUNT(*) AS orders,
  AVG(CAST(lead_time_days AS FLOAT)) AS avg_lead_days,
  AVG(CASE WHEN sla_status='ON_TIME' THEN 1.0 ELSE 0.0 END) AS on_time_rate,
  SUM(CASE WHEN sla_status='LATE' THEN 1 ELSE 0 END) AS late_orders,
  SUM(CASE WHEN no_sla_flag = 1 THEN 1 ELSE 0 END) AS no_sla_orders
FROM vw_fact_sla f
LEFT JOIN dim_shipper ds ON ds.shipper_id = f.shipper_id
GROUP BY ds.company_name;
GO

DROP VIEW IF EXISTS vw_late_orders_by_country;
GO
CREATE VIEW vw_late_orders_by_country AS
SELECT
  dc.country,
  SUM(CASE WHEN sla_status='LATE' THEN 1 ELSE 0 END) AS late_orders,
  COUNT(*) AS total_orders,
  CASE WHEN COUNT(*) = 0 THEN NULL ELSE CAST(SUM(CASE WHEN sla_status='LATE' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) END AS late_rate
FROM vw_fact_sla f
LEFT JOIN dim_customer dc ON dc.customer_id = f.customer_id
GROUP BY dc.country;
GO

DROP VIEW IF EXISTS vw_employee_throughput;
GO
CREATE VIEW vw_employee_throughput AS
SELECT
  de.employee_id,
  de.employee_name,
  CAST(DATEADD(month, DATEDIFF(month, 0, f.order_date), 0) AS date) AS order_month,
  COUNT(*) AS orders,
  AVG(CAST(lead_time_days AS FLOAT)) AS avg_lead_days,
  AVG(CASE WHEN sla_status='ON_TIME' THEN 1.0 ELSE 0.0 END) AS on_time_rate
FROM vw_fact_sla f
LEFT JOIN dim_employee de ON de.employee_id = f.employee_id
GROUP BY de.employee_id, de.employee_name, CAST(DATEADD(month, DATEDIFF(month, 0, f.order_date), 0) AS date)
ORDER BY order_month, de.employee_id;
GO
