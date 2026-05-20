# Lab Activity: MongoDB Aggregation Framework (Grouping & Summarization)

## Objective
At the end of this activity, students should be able to:
1. Use the `$group` stage to categorize data and calculate summaries.
2. Apply various accumulators such as `$sum`, `$avg`, `$min`, `$max`, `$push`, and `$addToSet`.
3. Perform grouping by multiple fields using an object in the `_id`.
4. Calculate global totals using `_id: null`.

---

## Scenario: Stellar Retail Analytics
You are a Senior Data Analyst for "Stellar Retail," a global chain of electronics stores. The management wants to understand their sales performance across different branches, product lines, and customer segments. You have been provided with a collection of sales transactions from the last quarter.

### Fields:

* **`orderId`**: (String) Unique transaction identifier.
* **`branch`**: (String) Branch ID (e.g., "A", "B", "C").
* **`city`**: (String) City where the branch is located.
* **`customerType`**: (String) "Member" or "Normal".
* **`gender`**: (String) "Female" or "Male".
* **`productLine`**: (String) e.g., "Electronic accessories", "Fashion accessories", "Food and beverages", "Health and beauty", "Home and lifestyle", "Sports and travel".
* **`unitPrice`**: (Number) Price per unit.
* **`quantity`**: (Number) Number of units purchased.
* **`total`**: (Number) Total cost of the transaction (unitPrice * quantity + tax).
* **`payment`**: (String) "Cash", "Credit card", or "Ewallet".
* **`rating`**: (Number) Customer satisfaction rating (1–10).

---

## Setup
Connect to your MongoDB instance and import the following documents into a collection named `sales`:

```json
[
  { "orderId": "101-01", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 74.69, "quantity": 7, "total": 548.97, "payment": "Ewallet", "rating": 9.1 },
  { "orderId": "101-02", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Female", "productLine": "Electronic accessories", "unitPrice": 15.28, "quantity": 5, "total": 80.22, "payment": "Cash", "rating": 9.6 },
  { "orderId": "101-03", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Male", "productLine": "Home and lifestyle", "unitPrice": 46.33, "quantity": 7, "total": 340.53, "payment": "Credit card", "rating": 7.4 },
  { "orderId": "101-04", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 58.22, "quantity": 8, "total": 489.05, "payment": "Ewallet", "rating": 8.4 },
  { "orderId": "101-05", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Male", "productLine": "Sports and travel", "unitPrice": 86.31, "quantity": 7, "total": 634.38, "payment": "Ewallet", "rating": 5.3 },
  { "orderId": "101-06", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Male", "productLine": "Electronic accessories", "unitPrice": 85.39, "quantity": 7, "total": 627.62, "payment": "Ewallet", "rating": 4.1 },
  { "orderId": "101-07", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Female", "productLine": "Electronic accessories", "unitPrice": 68.84, "quantity": 6, "total": 433.69, "rating": 5.8 },
  { "orderId": "101-08", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Female", "productLine": "Home and lifestyle", "unitPrice": 73.56, "quantity": 10, "total": 772.38, "payment": "Ewallet", "rating": 8.0 },
  { "orderId": "101-09", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 36.25, "quantity": 2, "total": 76.13, "payment": "Cash", "rating": 6.8 },
  { "orderId": "101-10", "branch": "B", "city": "Mandalay", "customerType": "Member", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 54.84, "quantity": 3, "total": 172.75, "payment": "Credit card", "rating": 5.9 },
  { "orderId": "101-11", "branch": "B", "city": "Mandalay", "customerType": "Member", "gender": "Female", "productLine": "Sports and travel", "unitPrice": 14.48, "quantity": 4, "total": 60.82, "payment": "Ewallet", "rating": 4.5 },
  { "orderId": "101-12", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Male", "productLine": "Electronic accessories", "unitPrice": 25.51, "quantity": 4, "total": 107.14, "payment": "Cash", "rating": 6.8 },
  { "orderId": "101-13", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Female", "productLine": "Electronic accessories", "unitPrice": 54.11, "quantity": 2, "total": 113.63, "payment": "Ewallet", "rating": 4.6 },
  { "orderId": "101-14", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 43.19, "quantity": 10, "total": 453.50, "payment": "Cash", "rating": 4.7 },
  { "orderId": "101-15", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 23.66, "quantity": 2, "total": 49.69, "payment": "Cash", "rating": 4.4 },
  { "orderId": "101-16", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Female", "productLine": "Home and lifestyle", "unitPrice": 52.86, "quantity": 2, "total": 111.01, "payment": "Cash", "rating": 5.2 },
  { "orderId": "101-17", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 75.89, "quantity": 7, "total": 557.79, "payment": "Credit card", "rating": 6.7 },
  { "orderId": "101-18", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 62.14, "quantity": 6, "total": 391.48, "payment": "Credit card", "rating": 5.1 },
  { "orderId": "101-19", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 88.36, "quantity": 5, "total": 463.89, "payment": "Cash", "rating": 6.1 },
  { "orderId": "101-20", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Female", "productLine": "Home and lifestyle", "unitPrice": 40.12, "quantity": 7, "total": 294.88, "payment": "Ewallet", "rating": 5.2 },
  { "orderId": "101-21", "branch": "B", "city": "Mandalay", "customerType": "Member", "gender": "Male", "productLine": "Home and lifestyle", "unitPrice": 66.28, "quantity": 1, "total": 69.59, "payment": "Ewallet", "rating": 9.2 },
  { "orderId": "101-22", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Male", "productLine": "Food and beverages", "unitPrice": 60.91, "quantity": 8, "total": 511.64, "payment": "Cash", "rating": 5.0 },
  { "orderId": "101-23", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Male", "productLine": "Electronic accessories", "unitPrice": 33.20, "quantity": 2, "total": 69.72, "payment": "Credit card", "rating": 6.4 },
  { "orderId": "101-24", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Male", "productLine": "Electronic accessories", "unitPrice": 34.32, "quantity": 1, "total": 36.04, "payment": "Credit card", "rating": 9.9 },
  { "orderId": "101-25", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 67.70, "quantity": 8, "total": 568.68, "payment": "Cash", "rating": 5.1 },
  { "orderId": "101-26", "branch": "B", "city": "Mandalay", "customerType": "Member", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 14.83, "quantity": 2, "total": 31.14, "payment": "Cash", "rating": 4.1 },
  { "orderId": "101-27", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Male", "productLine": "Sports and travel", "unitPrice": 75.61, "quantity": 9, "total": 714.51, "payment": "Cash", "rating": 8.0 },
  { "orderId": "101-28", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Male", "productLine": "Sports and travel", "unitPrice": 32.74, "quantity": 4, "total": 137.51, "payment": "Ewallet", "rating": 4.1 },
  { "orderId": "101-29", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 88.04, "quantity": 2, "total": 184.88, "payment": "Ewallet", "rating": 9.0 },
  { "orderId": "101-30", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Female", "productLine": "Home and lifestyle", "unitPrice": 38.05, "quantity": 1, "total": 39.95, "payment": "Cash", "rating": 6.7 },
  { "orderId": "101-31", "branch": "B", "city": "Mandalay", "customerType": "Member", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 29.84, "quantity": 7, "total": 219.32, "payment": "Ewallet", "rating": 5.8 },
  { "orderId": "101-32", "branch": "C", "city": "Naypyitaw", "customerType": "Member", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 48.01, "quantity": 3, "total": 151.23, "payment": "Cash", "rating": 9.9 },
  { "orderId": "101-33", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Male", "productLine": "Electronic accessories", "unitPrice": 96.01, "quantity": 6, "total": 604.86, "payment": "Credit card", "rating": 7.7 },
  { "orderId": "101-34", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Male", "productLine": "Sports and travel", "unitPrice": 53.68, "quantity": 7, "total": 394.55, "payment": "Ewallet", "rating": 6.8 },
  { "orderId": "101-35", "branch": "C", "city": "Naypyitaw", "customerType": "Member", "gender": "Female", "productLine": "Sports and travel", "unitPrice": 45.92, "quantity": 1, "total": 48.22, "payment": "Credit card", "rating": 5.6 },
  { "orderId": "101-36", "branch": "C", "city": "Naypyitaw", "customerType": "Normal", "gender": "Female", "productLine": "Electronic accessories", "unitPrice": 54.43, "quantity": 1, "total": 57.15, "payment": "Ewallet", "rating": 9.1 },
  { "orderId": "101-37", "branch": "B", "city": "Mandalay", "customerType": "Member", "gender": "Male", "productLine": "Home and lifestyle", "unitPrice": 53.75, "quantity": 10, "total": 564.38, "payment": "Ewallet", "rating": 4.1 },
  { "orderId": "101-38", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Female", "productLine": "Electronic accessories", "unitPrice": 83.18, "quantity": 3, "total": 262.02, "payment": "Cash", "rating": 6.0 },
  { "orderId": "101-39", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 46.59, "quantity": 3, "total": 146.76, "payment": "Cash", "rating": 9.7 },
  { "orderId": "101-40", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 41.52, "quantity": 6, "total": 261.58, "payment": "Ewallet", "rating": 8.0 },
  { "orderId": "101-41", "branch": "C", "city": "Naypyitaw", "customerType": "Member", "gender": "Male", "productLine": "Home and lifestyle", "unitPrice": 14.13, "quantity": 1, "total": 14.84, "payment": "Cash", "rating": 6.2 },
  { "orderId": "101-42", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 19.34, "quantity": 5, "total": 101.54, "payment": "Ewallet", "rating": 7.0 },
  { "orderId": "101-43", "branch": "C", "city": "Naypyitaw", "customerType": "Member", "gender": "Male", "productLine": "Health and beauty", "unitPrice": 52.89, "quantity": 5, "total": 277.67, "payment": "Ewallet", "rating": 6.6 },
  { "orderId": "101-44", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Male", "productLine": "Electronic accessories", "unitPrice": 38.35, "quantity": 5, "total": 201.34, "payment": "Ewallet", "rating": 7.3 },
  { "orderId": "101-45", "branch": "B", "city": "Mandalay", "customerType": "Member", "gender": "Female", "productLine": "Sports and travel", "unitPrice": 99.71, "quantity": 10, "total": 1046.96, "payment": "Credit card", "rating": 8.5 },
  { "orderId": "101-46", "branch": "C", "city": "Naypyitaw", "customerType": "Member", "gender": "Female", "productLine": "Sports and travel", "unitPrice": 12.01, "quantity": 9, "total": 113.49, "payment": "Cash", "rating": 7.3 },
  { "orderId": "101-47", "branch": "A", "city": "Yangon", "customerType": "Normal", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 22.13, "quantity": 1, "total": 23.24, "payment": "Cash", "rating": 8.2 },
  { "orderId": "101-48", "branch": "B", "city": "Mandalay", "customerType": "Normal", "gender": "Male", "productLine": "Home and lifestyle", "unitPrice": 62.72, "quantity": 7, "total": 461.00, "payment": "Credit card", "rating": 4.1 },
  { "orderId": "101-49", "branch": "C", "city": "Naypyitaw", "customerType": "Member", "gender": "Male", "productLine": "Sports and travel", "unitPrice": 99.85, "quantity": 8, "total": 838.74, "payment": "Cash", "rating": 5.1 },
  { "orderId": "101-50", "branch": "A", "city": "Yangon", "customerType": "Member", "gender": "Female", "productLine": "Health and beauty", "unitPrice": 88.35, "quantity": 7, "total": 649.37, "payment": "Ewallet", "rating": 4.1 }
]
```

---

## Instructions
Write the MongoDB Aggregation queries for the following requirements. Ensure you use the **Aggregation Pipeline** (`db.collection.aggregate([])`).

### Task 1: Branch Performance Summary
Management wants a high-level overview of how each branch is performing.
*   **Requirement:** Group the sales by `branch`.
*   **Calculations:**
    1.  `totalRevenue`: The sum of all `total` values for that branch.
    2.  `averageRating`: The average `rating` for that branch.
    3.  `transactionCount`: The total number of transactions in that branch.

### Task 2: Product Line Insights (Min/Max/Avg)
Find the price range and popularity of each product line.
*   **Requirement:** Group by `productLine`.
*   **Calculations:**
    1.  `minUnitPrice`: The lowest unit price in this category.
    2.  `maxUnitPrice`: The highest unit price in this category.
    3.  `avgQuantity`: The average number of units sold per transaction.

### Task 3: Demographic & Branch Analysis (Multiple Fields)
Stellar Retail wants to know which gender spends more in which branch.
*   **Requirement:** Group by both `branch` AND `gender`.
*   **Calculations:** 
    1.  `totalSales`: Sum of `total`.
*   **Output Format:** Your `_id` should look like `{ b: "$branch", g: "$gender" }`.

### Task 4: Loyalty Program Deep Dive (Push/AddToSet)
The Marketing team wants to see which product lines are favored by "Member" customers in each city.
*   **Requirement:** Group by `city`.
*   **Calculations:**
    1.  `uniqueProductLines`: A list of **unique** `productLine` values purchased in that city (Use `$addToSet`).
    2.  `allPaymentMethods`: A list of **all** `payment` methods used in that city (Use `$push`).
*   **Hint:** Only include transactions where `customerType` is "Member". You might need a `$match` stage before `$group`.

### Task 5: Global Company Totals
Calculate the total revenue and total quantity sold across **all branches** combined.
*   **Requirement:** Use a single group bucket.
*   **Hint:** Set `_id` to `null`.

---

## Submission
Save your queries in a file named `solution.js`. Add a screenshot of the output into a separate file `output.md`. Save all files under the `activity14` directory.