

## Query Analysis and Optimization


### Scenario 1: The Slow Author Profile Page

**Before Query Plan and Execution times**
```txt
                                                 QUERY PLAN
-------------------------------------------------------------------------------------------------------------
 Sort  (cost=625.58..625.64 rows=25 width=52) (actual time=3.341..3.346 rows=25.00 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 26kB
   Buffers: shared hit=500
   ->  Seq Scan on posts  (cost=0.00..625.00 rows=25 width=52) (actual time=0.072..3.310 rows=25.00 loops=1)
         Filter: (author_id = 27)
         Rows Removed by Filter: 9975
         Buffers: shared hit=500
 Planning Time: 0.177 ms
 Execution Time: 3.394 ms
(10 rows)

```


**Query:**
```sql
explain analyze
select id,title
from posts
where author_id = '27'
order by date desc;
                                                              QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=88.60..88.66 rows=25 width=52) (actual time=0.361..0.364 rows=25.00 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 26kB
   Buffers: shared hit=24 read=2
   ->  Bitmap Heap Scan on posts  (cost=4.48..88.02 rows=25 width=52) (actual time=0.262..0.325 rows=25.00 loops=1)
         Recheck Cond: (author_id = 27)
         Heap Blocks: exact=24
         Buffers: shared hit=24 read=2
         ->  Bitmap Index Scan on idx_posts_date_desc  (cost=0.00..4.47 rows=25 width=0) (actual time=0.206..0.206 rows=25.00 loops=1)
               Index Cond: (author_id = 27)
               Index Searches: 1
               Buffers: shared read=2
 Planning:
   Buffers: shared hit=22 read=1
 Planning Time: 3.755 ms
 Execution Time: 0.433 ms
(16 rows)
```

**Analysis Questions:**
*   What is the primary node causing the slowness in the initial execution plan?

        The primary cause of the slowness was the combination of a sequential scan and a separate sort operation. PostgreSQL had to scan through many rows in the posts table to find all entries matching the specific author_id, and after retrieving those rows, it still needed to sort them by date in descending order.
*   How can you optimize both the `WHERE` clause filtering and the `ORDER BY` operation with a single change?

        To optimize both the WHERE filtering and the ORDER BY operation with a single change, I created an index on (author_id, date desc). This index allowed postgre to quickly locate all posts belonging to the specific author_id and retrieve them already sorted from newest to oldest.
*   Implement your fix and record the new plan. How much faster is the query now?

        After implementing the index, the execution time dropped from 3.394 ms to 0.443 ms. The optimized query is about 7.7 times faster than the original version, saving about 2.951 ms per execution.


### Scenario 2: The Unsearchable Blog

**Before Query Plan and Execution times**
```txt
                                               QUERY PLAN
---------------------------------------------------------------------------------------------------------
 Seq Scan on posts  (cost=0.00..625.00 rows=505 width=44) (actual time=0.123..9.376 rows=220.00 loops=1)
   Filter: ((title)::text ~~ '%perspiciatis%'::text)
   Rows Removed by Filter: 9780
   Buffers: shared hit=500
 Planning:
   Buffers: shared hit=7
 Planning Time: 2.063 ms
 Execution Time: 9.454 ms
(8 rows)

```


**Query:**
```sql
create index idx_posts_title on posts(title);

 Index Only Scan using idx_posts_title on posts  (cost=0.29..515.28 rows=505 width=44) (actual time=0.481..9.445 rows=220.00 loops=1)
   Filter: ((title)::text ~~ '%perspiciatis%'::text)
   Rows Removed by Filter: 9780
   Heap Fetches: 0
   Index Searches: 1
   Buffers: shared hit=1 read=84
 Planning:
   Buffers: shared hit=22 read=1 dirtied=3
 Planning Time: 4.178 ms
 Execution Time: 9.509 ms
(10 rows)

---prefix
Index Only Scan using idx_posts_title on posts  (cost=0.29..515.28 rows=1 width=44) (actual time=4.829..4.830 rows=0.00 loops=1)
   Filter: ((title)::text ~~ 'perspiciatis%'::text)
   Rows Removed by Filter: 10000
   Heap Fetches: 0
   Index Searches: 1
   Buffers: shared hit=85
 Planning:
   Buffers: shared hit=4
 Planning Time: 0.827 ms
 Execution Time: 4.879 ms
(10 rows)
```

**Analysis Questions:**
*   First, try adding a standard B-Tree index on the `title` column. Run `EXPLAIN ANALYZE` again. Did the planner use your index? Why or why not?


        Technically, the planner did use the index, as shown by the Index Only Scan in the execution plan. However, the search pattern '%perspiciatis%' still required postgre to examine all entries because perspiciatis could appear anywhere in the title.So even though the index was used, it did not significantly reduce the amount of data postgre checked, which is the index was practically useless since the execution time was still relatively high at 9.509 ms.
*   The business team agrees that searching by a *prefix* is acceptable for the first version. Rewrite the query to use a prefix search (e.g., `database%`).

    ```sql
    select title
    from posts
    where title like 'perspiciatis%';
    ```
*   Does the index work for the prefix-style query? Explain the difference in the execution plan.

        For the prefix search, the index was again used, and the execution time jumped from 9.509 ms to 4.879 ms. This happened because the postgre narrowed down the possible matches more effectively when perspiciatis appeared at the beginning of the title. Though it was faster, the plan still showed that many entries were examined, meaning the optimization helped but was not fully as efficient as it could be.

### Scenario 3: The Monthly Performance Report

**Before Query Plan and Execution times**
```txt
                                              QUERY PLAN
-------------------------------------------------------------------------------------------------------
 Seq Scan on posts  (cost=0.00..650.00 rows=16 width=52) (actual time=0.228..7.584 rows=22.00 loops=1)
   Filter: ((date > '2014-12-31'::date) AND (date <= '2015-01-31'::date))
   Rows Removed by Filter: 9978
   Buffers: shared hit=500
 Planning:
   Buffers: shared hit=6
 Planning Time: 1.887 ms
 Execution Time: 7.640 ms
(8 rows)

```


**Query:**
```sql
explain analyze
select id,title,date
from posts
where date > '2014-12-31' and date <= '2015-01-31';
                                                         QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on posts  (cost=4.45..60.10 rows=16 width=52) (actual time=0.342..0.430 rows=22.00 loops=1)
   Recheck Cond: ((date > '2014-12-31'::date) AND (date <= '2015-01-31'::date))
   Heap Blocks: exact=22
   Buffers: shared hit=22 read=2
   ->  Bitmap Index Scan on idx_posts_date  (cost=0.00..4.45 rows=16 width=0) (actual time=0.264..0.264 rows=22.00 loops=1)
         Index Cond: ((date > '2014-12-31'::date) AND (date <= '2015-01-31'::date))
         Index Searches: 1
         Buffers: shared read=2
 Planning:
   Buffers: shared hit=16 read=1
 Planning Time: 3.780 ms
 Execution Time: 0.484 ms
(12 rows)
```

**Analysis Questions:**
*   This query is not S-ARGable. What does that mean in the context of this query? Why can't the query planner use a simple index on the `date` column effectively?

        In this query, “not S-ARGable” means the condition is written in a way that forces postgre to do operations from the date column for every row before it matches a row. Because postgre must compute and transform values first, it cannot efficiently jump to just the January 2015 rows using a normal index on date, it ends up checking many rows instead of quickly narrowing down to a date range.
*   Rewrite the query to use a direct date range comparison, making it S-ARGable.

    ```sql
    select id,title,date
    from posts
    where date > '2014-12-31' and date <= '2015-01-31';
    ```
<u>Place your answer here</u>
*   Create an appropriate index to support your rewritten query.
    ```sql
    create index idx_posts_date on posts(date);
    ```
*   Compare the performance of the original query and your optimized version.

        The original query took 7.640 ms because it could not use the date index efficiently and had to compute many rows. After rewriting the query to be sargable and supporting it with an index, the execution time dropped to 0.484 ms, which clearly shows the optimization was successful.

---

## Submission and Rubric (20 Points Total)

Please submit the following:

1.  Your final `schema_postgres.sql` file.
2.  A separate SQL file named `indexes.sql` containing all the `CREATE INDEX` statements you used to optimize the queries.
3.  A Markdown document containing your analysis for each of the four scenarios. This document must include:
    *   The "before" and "after" execution plans from `EXPLAIN ANALYZE`.
    *   The provided queries for each scenario with EXPLAIN ANALYZE
    *   Your answers to the analysis questions for each scenario.

