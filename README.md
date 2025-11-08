# Northwind Pricing & Fulfillment SLA — Basic Starter

This minimal project computes SLA metrics (lead time, on-time rate, late-day
buckets, No-SLA flags) and exports Power BI / Excel-friendly CSVs.

## What you get
- Tiny Northwind-like sample data (so you can run without external files)
- Star schema tables + SLA views
- Docker Compose + Makefile (optional)
- Validation SQL and documentation
- Exports for: shipper SLA, late orders by country, employee throughput, and a sample fact

## Quick start
```bash
chmod +x setup_northwind_sla.sh
./setup_northwind_sla.sh
```
- If local `psql` is available, it's used.
- Otherwise, if Docker Compose is available, a Postgres container is started and used.
