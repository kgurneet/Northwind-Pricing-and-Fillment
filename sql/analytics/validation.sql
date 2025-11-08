-- Validation & QA checks
SELECT 'orders' AS "table", COUNT(*) AS rows FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL
SELECT 'vw_fact_sla', COUNT(*) FROM vw_fact_sla;

SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date
FROM vw_fact_sla;

SELECT sla_status, COUNT(*) AS orders
FROM vw_fact_sla
GROUP BY sla_status
ORDER BY orders DESC;

SELECT late_bucket, COUNT(*) AS orders
FROM vw_fact_sla
WHERE late_bucket NOT IN ('NO_SLA','PENDING')
GROUP BY late_bucket
ORDER BY orders DESC;

SELECT 'customer_fk_missing' AS issue, COUNT(*) AS rows
FROM fact_order f
LEFT JOIN dim_customer dc ON dc.customer_id = f.customer_id
WHERE dc.customer_id IS NULL
UNION ALL
SELECT 'shipper_fk_missing', COUNT(*)
FROM fact_order f
LEFT JOIN dim_shipper ds ON ds.shipper_id = f.shipper_id
WHERE ds.shipper_id IS NULL
UNION ALL
SELECT 'employee_fk_missing', COUNT(*)
FROM fact_order f
LEFT JOIN dim_employee de ON de.employee_id = f.employee_id
WHERE de.employee_id IS NULL;

SELECT * FROM vw_shipper_sla ORDER BY shipper;
