# Transformation Rules
1. Grain: `fact_order` = order line, `vw_fact_sla` = order-level rollup.
2. Lead Time: shipped_date - order_date (null if either is null).
3. Late Days: GREATEST(0, shipped_date - required_date); null if either is null.
4. NO_SLA: required_date is null.
5. SLA Status: NO_SLA | PENDING | ON_TIME | LATE.
6. Late Buckets: 0d | 1–3d | 4–7d | 8d+; NO_SLA/PENDING retained.
7. Types: numeric(10,2) for money; dates as date.
8. BI: CSVs with headers, stable column order.
