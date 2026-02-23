
# Lab Activity: Optimizing Query Performance with Indexes

## Objective

This activity will guide you through understanding the impact of database indexes on query performance. You will generate a large dataset, measure query execution times on non-indexed and indexed columns, and analyze the results.

## Instructions

### Part 1: Data Generation and Initial Insertion

1.  **Generate Mock Data:**
    *   Go to [FillDB](https://filldb.info/).
    *   Create a schema for a table of your choice (e.g., `employees`, `products`, `sales`).
    *   Your table must include at least the following columns:
        *   An `id` column (using the "ID" type).
        *   A column with random string data (e.g., `first_name`, `product_name`).
        *   A column with random numerical data (e.g., `salary`, `price`).
        *   A date column.
    *   Generate **100,000 (one hundred thousand)** rows. For the "Output type," select **SQL (PostgreSQL)**. Download the generated `.sql` file.
    *   The generator uses MySQL so make sure to convert the CREATE statement to make it PostgreSQL-compatible

2.  **Create Table and Insert Data:**
    *   Connect to your PostgreSQL database using `psql` or another client.
    *   Create the table you defined in the previous step.
    *   To quickly insert 100,000 records, execute the downloaded SQL script **10 times**. This simulates a large data insertion process.
        *   *Tip for `psql` users:* You can run `\i path/to/your/downloaded_file.sql` ten consecutive times.
    *   **Record the total time it takes to complete all 10 insertions.**

3.  **Verify Row Count:**
    *   Run the following query to ensure you have 100,000 rows.
        ```sql
        SELECT COUNT(*) FROM your_table_name;
        ```
    *   Take a screenshot of the output.

### Part 2: Querying Without an Index

1.  **Run a SELECT Query:**
    *   Choose a column that is **not** a primary key to query against (e.g., the random string or numerical column).
    *   Run a `SELECT` statement with a `WHERE` clause on this column. For example:
        ```sql
        SELECT * FROM your_table_name WHERE your_string_column = 'some_random_value';
        ```
        *Hint: Pick a value that you know exists in your dataset.*
    *   Using `EXPLAIN ANALYZE`, measure the execution time of this query.
        ```sql
        EXPLAIN ANALYZE SELECT * FROM your_table_name WHERE your_string_column = 'some_random_value';
        ```
    *   **Record the execution time.**
    *   Take a screenshot of the query plan and execution time.

### Part 3: Creating an Index and Querying

1.  **Create an Index:**
    *   Create an index on the column you just queried.
        ```sql
        CREATE INDEX idx_your_column_name ON your_table_name(your_column_name);
        ```

2.  **Run the SELECT Query Again:**
    *   Run the *exact same* `SELECT` query as in Part 2.
    *   Again, use `EXPLAIN ANALYZE` to measure the execution time.
        ```sql
        EXPLAIN ANALYZE SELECT * FROM your_table_name WHERE your_string_column = 'some_random_value';
        ```
    *   **Record the execution time.**
    *   Take a screenshot of the new query plan and execution time.

### Part 4: Analyzing Insertion with an Index

1.  **Insert a Single Row:**
    *   Insert one additional row into your table.
        ```sql
        INSERT INTO your_table_name (id, ...) VALUES (...);
        ```
    *   **Record the time it takes to insert this single row.**

## Analysis Questions

Fill in the following with your recorded measurements.

*   **Initial Data Insertion Time (100,000 rows):** 6m 10s 70ms 
*   **Query Execution Time (Non-Indexed):** 24.140 ms
*   **Query Execution Time (Indexed):** 1.538 ms
*   **Single Row Insertion Time (With Index):** 33.066 ms

**Answer the following questions:**

1.  How did the query execution time change after creating the index? Was it faster or slower? By approximately how much?  
    After creating the index, the query became noticeably faster. The execution time decreased from 24.140 ms (non-indexed) to 1.538 ms (indexed). That’s an improvement of about 22.602 ms, which means the query ran roughly 15–16 times faster with the index. Even though milliseconds seem small, in large systems with many users or repeated queries, this performance gain is very significant.
2.  Why do you think the query performance changed as you observed?  
    I think the performance improved because the database no longer needed to scan rows one by one or do a full table scan. Without an index, the database performs a sequential scan, checking many rows until it finds the correct data. After creating the index, the system used the index structure like a shortcut to directly locate the needed rows. This reduced the number of operations required, which explains why the query execution time became much shorter.
3.  What is the trade-off of having an index on a table? (Hint: Compare the initial bulk insertion time with the single row insertion time after the index was created).  
    From my observation, the main trade-off is slower insertion performance once an index is present. During the initial bulk insertion of 100,000 rows, each insert only took around 1.1–1.3 ms because the database was simply writing data to the table. After the index was created, however, inserting even a single row took 33.066 ms. This happened because the database now had to update both the table and the index structure at the same time. This shows that indexes significantly improve data retrieval speed, but introduce extra overhead during write operations like insert, update, and delete, making write speeds slower.

## What to Submit

*   A single Markdown file (`.md`) containing:
    1.  The completed **Analysis Questions** section with your recorded times.
    2.  Your answers to the analysis questions.
    3.  Screenshots linked within the document for:
        *   Row count verification (`SELECT COUNT(*)`).
            ![](images/INFOMAN_Act5_count.png)
        *   The `EXPLAIN ANALYZE` output for the non-indexed query.
            ![](images/INFOMAN_Act5_non_index.png)
        *   The `EXPLAIN ANALYZE` output for the indexed query.
            ![](images/INFOMAN_Act5_index.png)

## Grading Rubric (Total: 20 Points)

*   **Part 1: Data Generation and Initial Insertion (5 points)**
    *   100,000 rows successfully inserted (2 points)
    *   Initial insertion time recorded (1 point)
    *   Screenshot of row count verification (2 points)

*   **Part 2: Querying Without an Index (5 points)**
    *   Non-indexed query executed correctly (2 points)
    *   Non-indexed query execution time recorded (1 point)
    *   Screenshot of `EXPLAIN ANALYZE` output for non-indexed query (2 points)

*   **Part 3: Creating an Index and Querying (5 points)**
    *   Index created on appropriate column (2 points)
    *   Indexed query execution time recorded (1 point)
    *   Screenshot of `EXPLAIN ANALYZE` output for indexed query (2 points)

*   **Part 4: Analyzing Insertion with an Index (5 points)**
    *   Single row insertion time recorded (1 point)
    *   Answers to analysis questions (3 questions x 1 point each = 3 points)
    *   Clarity and completeness of the submitted Markdown file (1 point)
