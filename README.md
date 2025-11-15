Northwind Pricing & Fulfillment SLA

A compact analytics project that computes lead time, on-time rate, late-day buckets, and No-SLA flags using a small Northwind-style dataset. Outputs are optimized for Power BI, Excel, and CSV-based workflows.

Features

Minimal built-in sample data (no external files required)

Star-schema tables + SLA analytic views

Clean exports: shipper SLA, late orders by country, employee throughput, and a sample fact

Runs with local psql or Docker Compose

Includes schema, ETL SQL, and validation queries

Quick Start
chmod +x setup_northwind_sla.sh
./setup_northwind_sla.sh


If psql is installed, it is used automatically; otherwise a Postgres Docker container is started.

Generated Outputs

shipper_sla.csv

late_orders_by_country.csv

employee_throughput.csv

sample_fact_with_sla.csv

Project Structure
sql/             → schema, ETL, SLA views, validation
data/            → minimal sample dataset
exports/         → generated CSVs
docker-compose.yml
setup_northwind_sla.sh

Purpose

A quick demonstration of ETL, SLA computation, and analytics-ready data modeling using a reproducible Postgres environment.
