# Activity 8 Answer Template

## Part 1: Star Schema Design

### 1. Fact Table Grain

The grain is one row per sales transaction line per transaction date.

### 2. Fact Measures

The fact table stores numeric values used for analysis:

- `qty` – quantity sold

- `unit_price` – selling price per unit at the time of transaction

- `total_amount` – computed as qty * unit_price

### 3. Dimension Tables and Attributes

- `dim_date`: 

  - date_key (surrogate-friendly integer key in YYYYMMDD form)

  - actual_date

  - year_num

  - quarter_num

  - month_num

  - day_of_month

  - week_of_year

- `dim_customer`: 
  - customer_key (surrogate key)

  - source_id

  - full_name

  - region_code

- `dim_product`: 
  - product_key (surrogate key)

  - source_id

  - product_name

  - category

  - unit_price

- `dim_branch`:
  - branch_key (surrogate key)

  - source_id

  - branch_name

  - city

  - region
  

### 4. Relationship Summary

`dw.fact_sales` links to all four dimensions:

  - `fact_sales.date_key` → `dim_date.date_key`

  - `fact_sales.customer_key` → `dim_customer.customer_key`

  - `fact_sales.product_key` → `dim_product.product_key`

  - `fact_sales.branch_key` → `dim_branch.branch_key`

## Part 2: Warehouse DDL

```sql
CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key INT PRIMARY KEY,
    actual_date DATE NOT NULL UNIQUE,
    year_num INT NOT NULL,
    quarter_num INT NOT NULL,
    month_num INT NOT NULL,
    day_of_month INT NOT NULL,
    week_of_year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    source_id INT NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    region_code VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dw.dim_product (
    product_key BIGSERIAL PRIMARY KEY,
    source_id INT NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    unit_price NUMERIC(12,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_branch (
    branch_key BIGSERIAL PRIMARY KEY,
    source_id INT NOT NULL UNIQUE,
    branch_name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dw.fact_sales (
    fact_sales_key BIGSERIAL PRIMARY KEY,
    source_txn_id INT NOT NULL UNIQUE,
    date_key INT NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    branch_key BIGINT NOT NULL,
    qty INT NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    total_amount NUMERIC(14,2) NOT NULL,
    load_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key) REFERENCES dw.dim_date(date_key),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key) REFERENCES dw.dim_customer(customer_key),

    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_key) REFERENCES dw.dim_product(product_key),

    CONSTRAINT fk_fact_branch
        FOREIGN KEY (branch_key) REFERENCES dw.dim_branch(branch_key),

    CONSTRAINT chk_fact_qty_positive CHECK (qty > 0),
    CONSTRAINT chk_fact_unit_price_positive CHECK (unit_price > 0)
);

CREATE TABLE IF NOT EXISTS dw.etl_log (
    log_id BIGSERIAL PRIMARY KEY,
    run_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    rows_loaded INT NOT NULL DEFAULT 0,
    error_message TEXT
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_date_key
    ON dw.fact_sales(date_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_branch_key
    ON dw.fact_sales(branch_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_product_key
    ON dw.fact_sales(product_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_key
    ON dw.fact_sales(customer_key);

CREATE INDEX IF NOT EXISTS idx_dim_customer_source_id
    ON dw.dim_customer(source_id);

CREATE INDEX IF NOT EXISTS idx_dim_product_source_id
    ON dw.dim_product(source_id);

CREATE INDEX IF NOT EXISTS idx_dim_branch_source_id
    ON dw.dim_branch(source_id);

CREATE INDEX IF NOT EXISTS idx_dim_date_actual_date
    ON dw.dim_date(actual_date);
```

## Part 3: ETL Procedure

### 1. Procedure Code

```sql
CREATE OR REPLACE PROCEDURE dw.run_sales_etl()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_loaded INT := 0;
BEGIN
    INSERT INTO dw.dim_date (
    date_key,
    actual_date,
    year_num,
    quarter_num,
    month_num,
    day_of_month,
    week_of_year
)
    SELECT DISTINCT
        TO_CHAR(s.txn_date, 'YYYYMMDD')::INT AS date_key,
        s.txn_date::DATE AS actual_date,
        EXTRACT(YEAR FROM s.txn_date)::INT AS year_num,
        EXTRACT(QUARTER FROM s.txn_date)::INT AS quarter_num,
        EXTRACT(MONTH FROM s.txn_date)::INT AS month_num,
        EXTRACT(DAY FROM s.txn_date)::INT AS day_of_month,
        EXTRACT(WEEK FROM s.txn_date)::INT AS week_of_year
    FROM public.sales_txn s
    WHERE s.txn_date IS NOT NULL
    ON CONFLICT (date_key) DO UPDATE
    SET
        actual_date = EXCLUDED.actual_date,
        year_num = EXCLUDED.year_num,
        quarter_num = EXCLUDED.quarter_num,
        month_num = EXCLUDED.month_num,
        day_of_month = EXCLUDED.day_of_month,
        week_of_year = EXCLUDED.week_of_year;

    INSERT INTO dw.dim_customer (
        source_id,
        full_name,
        region_code
    )
    SELECT
        c.id,
        c.full_name,
        c.region_code
    FROM public.customers c
    ON CONFLICT (source_id) DO UPDATE
    SET
        full_name = EXCLUDED.full_name,
        region_code = EXCLUDED.region_code;

    INSERT INTO dw.dim_product (
        source_id,
        product_name,
        category,
        unit_price
    )
    SELECT
        p.id,
        p.product_name,
        p.category,
        p.unit_price
    FROM public.products p
    ON CONFLICT (source_id) DO UPDATE
    SET
        product_name = EXCLUDED.product_name,
        category = EXCLUDED.category,
        unit_price = EXCLUDED.unit_price;

    INSERT INTO dw.dim_branch (
        source_id,
        branch_name,
        city,
        region
    )
    SELECT
        b.id,
        b.branch_name,
        b.city,
        b.region
    FROM public.branches b
    ON CONFLICT (source_id) DO UPDATE
    SET
        branch_name = EXCLUDED.branch_name,
        city = EXCLUDED.city,
        region = EXCLUDED.region;

    INSERT INTO dw.fact_sales (
        source_txn_id,
        date_key,
        customer_key,
        product_key,
        branch_key,
        qty,
        unit_price,
        total_amount
    )
    SELECT
        s.id AS source_txn_id,
        d.date_key,
        c.customer_key,
        p.product_key,
        b.branch_key,
        s.qty,
        s.unit_price,
        (s.qty * s.unit_price)::NUMERIC(14,2) AS total_amount
    FROM public.sales_txn s
    JOIN dw.dim_date d
        ON d.actual_date = s.txn_date::DATE
    JOIN dw.dim_customer c
        ON c.source_id = s.customer_id
    JOIN dw.dim_product p
        ON p.source_id = s.product_id
    JOIN dw.dim_branch b
        ON b.source_id = s.branch_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM dw.fact_sales f
        WHERE f.source_txn_id = s.id
    )
      AND s.qty > 0
      AND s.unit_price > 0
      AND s.txn_date IS NOT NULL
      AND s.customer_id IS NOT NULL
      AND s.product_id IS NOT NULL
      AND s.branch_id IS NOT NULL;

    GET DIAGNOSTICS v_rows_loaded = ROW_COUNT;

    INSERT INTO dw.etl_log (
        run_ts,
        status,
        rows_loaded,
        error_message
    )
    VALUES (
        CURRENT_TIMESTAMP,
        'SUCCESS',
        v_rows_loaded,
        NULL
    );

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO dw.etl_log (
            run_ts,
            status,
            rows_loaded,
            error_message
        )
        VALUES (
            CURRENT_TIMESTAMP,
            'FAIL',
            0,
            SQLERRM
        );
END;
$$;
```

### 2. Procedure Execution

```sql
CALL dw.run_sales_etl();
```

### 3. ETL Log Output

```sql
SELECT * FROM dw.etl_log ORDER BY run_ts DESC;
```

```txt
coffee_db=# SELECT * FROM dw.etl_log ORDER BY run_ts DESC;
 log_id |           run_ts           | status  | rows_loaded | error_message
--------+----------------------------+---------+-------------+---------------
      1 | 2026-03-17 19:11:48.045825 | SUCCESS |      100000 |
(1 row)
```

## Part 4: Analytical Queries

### Query 1: Monthly Revenue by Branch Region

```sql
SELECT
    d.year_num,
    d.month_num,
    b.region,
    SUM(f.total_amount) AS monthly_revenue
FROM dw.fact_sales f
JOIN dw.dim_date d
    ON f.date_key = d.date_key
JOIN dw.dim_branch b
    ON f.branch_key = b.branch_key
GROUP BY
    d.year_num,
    d.month_num,
    b.region
ORDER BY
    d.year_num,
    d.month_num,
    b.region;
```

Interpretation:

This query shows how much revenue each branch region earned for every month in the warehouse. It helps management compare regional sales performance over time, identify which regions are consistently strong, and spot months where sales increased or declined.

### Query 2: Top 5 Products by Total Revenue

```sql
SELECT
    p.product_name,
    p.category,
    SUM(f.qty) AS total_units_sold,
    SUM(f.total_amount) AS total_revenue
FROM dw.fact_sales f
JOIN dw.dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_name,
    p.category
ORDER BY
    total_revenue DESC
LIMIT 5;
```

Interpretation:

This query points out the five products that bring in the most revenue, giving a clear sense of what’s actually driving sales. It helps management focus on these high-performing items when deciding what to promote more heavily or keep consistently available.

### Query 3: Customer Region Contribution to Sales

```sql
SELECT
    c.region_code,
    SUM(f.total_amount) AS region_sales,
    ROUND(
        100.0 * SUM(f.total_amount)
        / SUM(SUM(f.total_amount)) OVER (),
        2
    ) AS percentage_contribution
FROM dw.fact_sales f
JOIN dw.dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.region_code
ORDER BY
    region_sales DESC;
```

Interpretation:

This query breaks down total sales by customer region and shows how much each one contributes to the overall revenue. It gives a clearer picture of which markets matter most, making it easier to decide where to focus marketing or expansion efforts.
