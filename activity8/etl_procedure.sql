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

--Call
CALL dw.run_sales_etl();

--OUTPUT
SELECT * FROM dw.etl_log ORDER BY run_ts DESC;

/*
coffee_db=# SELECT * FROM dw.etl_log ORDER BY run_ts DESC;
 log_id |           run_ts           | status  | rows_loaded | error_message
--------+----------------------------+---------+-------------+---------------
      1 | 2026-03-17 19:11:48.045825 | SUCCESS |      100000 |
(1 row)
*/


