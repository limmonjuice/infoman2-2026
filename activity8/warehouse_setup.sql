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