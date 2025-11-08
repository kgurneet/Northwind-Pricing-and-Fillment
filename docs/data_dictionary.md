# Data Dictionary (BI-Friendly)

## Dimensions
### dim_customer
- customer_id (PK): Text. Business key from source `customers`.
- company_name: Text.
- country: Text.

### dim_shipper
- shipper_id (PK): Integer.
- company_name: Text.

### dim_employee
- employee_id (PK): Integer.
- employee_name: Text (first + last).

### dim_date
- date_key (PK): Date.
- year, month, day: Int.
- month_name: Text (e.g., "Jul").

## Facts & Views
### fact_order (order line grain)
- order_id, product_id: Int.
- customer_id, employee_id, shipper_id: FKs.
- order_date, required_date, shipped_date: Date.
- quantity: Int; unit_price: Numeric(10,2); discount: Numeric.

### vw_fact_sla (order grain)
- lead_time_days, late_days, no_sla_flag
- sla_status: {NO_SLA, PENDING, ON_TIME, LATE}
- late_bucket: {NO_SLA, PENDING, 0d, 1–3d, 4–7d, 8d+}

### Aggregations
- vw_shipper_sla(shipper, orders, avg_lead_days, on_time_rate, late_orders, no_sla_orders)
- vw_late_orders_by_country(country, late_orders, total_orders, late_rate)
- vw_employee_throughput(employee_id, employee_name, order_month, orders, avg_lead_days, on_time_rate)
