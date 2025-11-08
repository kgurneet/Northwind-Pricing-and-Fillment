SHELL := /bin/bash
export PGHOST ?= localhost
export PGPORT ?= 5432
export PGUSER ?= postgres
export PGPASSWORD ?= postgres
export PGDATABASE ?= northwind_sla

.PHONY: up down logs psql load export reset all

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

psql:
	psql -h $(PGHOST) -p $(PGPORT) -U $(PGUSER) -d $(PGDATABASE)

load:
	../setup_northwind_sla.sh

export:
	PGHOST=$(PGHOST) PGPORT=$(PGPORT) PGUSER=$(PGUSER) PGDATABASE=$(PGDATABASE) \
		../setup_northwind_sla.sh

reset:
	docker compose down -v
	rm -rf _data/db
	mkdir -p _data/db

all: up load export
