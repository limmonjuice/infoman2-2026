# Lab Activity: Star Schema Design and ETL Pipeline Implementation


## Objective

This activity applies Week 7 and Week 8 concepts by requiring you to:
1. Design a Star Schema from an OLTP-style business scenario.
2. Build a PostgreSQL ETL pipeline using PL/pgSQL.
3. Validate data quality and produce analytical outputs from your warehouse.

## Scenario

You are the data engineering team for a multi-branch coffee chain. Branch systems store daily transactions in OLTP tables. Management wants a small data warehouse for analytics.

Your task is to build and load a **Sales Star Schema** and generate BI-ready queries.

## Source Tables (OLTP)

Assume these tables exist in the `public` schema:

- `customers(id, full_name, region_code)`
- `products(id, product_name, category, unit_price)`
- `branches(id, branch_name, city, region)`
- `sales_txn(id, txn_date, customer_id, product_id, branch_id, qty, unit_price)`

## Part 1: Star Schema Design (5 points)

Design a star schema in `dw` schema with the following requirements:

1. Define the **grain** of the fact table.
> Format: One row per [Noun] per [Time Frequency].
> Example: The grain is one row per customer per month. 
> This grain is to track monthly active users in a subscription platform like netflix
2. Create dimensions:
   - `dim_date`
   - `dim_customer`
   - `dim_product`
   - `dim_branch`
3. Create one fact table:
   - `fact_sales`
4. Use **surrogate keys** for dimensions.
5. Keep source business keys as `source_id` columns in dimensions for ETL lookup.

### Deliverable for Part 1

A short write-up (or diagram) describing:
- Fact table grain
- Measures in fact table
- Dimension attributes
- Relationships

## Part 2: Warehouse DDL Setup (4 points)

Write SQL to create:

1. `dw` schema.
2. All dimension and fact tables.
3. `dw.etl_log` table for run logging (`run_ts`, `status`, `rows_loaded`, `error_message`).
4. Constraints and indexes needed for ETL lookup and query performance.

### Minimum technical expectations

- `ON CONFLICT`-ready uniqueness on `source_id` in dimensions.
- Foreign keys from fact table to dimensions.
- At least one index that helps analytical filtering (for example on `date_key` or `branch_key`).

## Part 3: ETL Procedure with PL/pgSQL (8 points)

Create a stored procedure: `dw.run_sales_etl()`

### Required ETL behavior

1. **Load dimensions first** using upsert pattern (`INSERT ... ON CONFLICT ... DO UPDATE`).
2. **Load fact table** by joining source rows to dimensions to resolve surrogate keys.
3. **Data quality checks** before fact load:
   - `qty > 0`
   - `unit_price > 0`
   - no null required foreign references
4. **Incremental loading rule**:
   - load only rows from `sales_txn` not yet loaded to `fact_sales` using a deterministic rule (example: based on source transaction id tracking).
5. **Logging**:
   - insert `SUCCESS` row in `etl_log` with row count when completed.
   - on error, catch exception and insert `FAIL` with `SQLERRM`.

### Deliverable for Part 3

- Full SQL code of your procedure.
- One sample `CALL dw.run_sales_etl();`
- A query showing ETL log entries.

## Part 4: Analytical Queries (3 points)

Write and run at least **three** OLAP-style queries from the warehouse, such as:

1. Monthly revenue by branch region.
2. Top 5 products by total revenue.
3. Customer-region contribution to total sales.

For each query, include:
- SQL statement
- brief interpretation (1-2 sentences)

## Submission Format

Submit one folder `activity8` containing:

1. `star_schema_etl_class_activity.md` (this activity file)
2. `answer_template.md` (your completed answers)
3. `warehouse_setup.sql` (DDL + indexes)
4. `etl_procedure.sql` (procedure + sample call)

## Grading Rubric (20 Points)

| Criteria | Excellent | Satisfactory | Needs Improvement | Points |
|---|---|---|---|---|
| Star Schema Design | Clear grain, correct fact/dim split, proper surrogate key strategy | Minor modeling gaps but mostly correct | Confused grain or incorrect fact/dim design | 5 |
| Warehouse DDL | Complete schema, keys, constraints, and useful indexes | Mostly complete with minor missing constraints/indexes | Incomplete or invalid DDL | 4 |
| ETL Procedure (PL/pgSQL) | Correct upserts, key lookups, data-quality checks, incremental load, and logging | Procedure runs but misses one major required behavior | ETL logic largely incorrect or non-functional | 8 |
| Analytical Queries | 3 meaningful OLAP queries with correct SQL and interpretation | 3 queries provided with limited analysis depth | Fewer than 3 or incorrect queries | 3 |

## Notes

- Use the Week 8 ETL handout pattern for upserts, key lookups, and error logging.
- Favor readability and correctness over over-engineering.
- You may add assumptions if clearly documented.