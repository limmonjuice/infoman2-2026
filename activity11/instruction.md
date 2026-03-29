# Lab Activity 11: SQL to MongoDB & Advanced Querying

**Goal:** Master the transition from relational schemas to document models and practice complex data retrieval using MongoDB Query Operators (MQL).

---

## Part 1: Relational to Document Modeling (20 Points)

### The Scenario: "DevConnect" Blog
You are migrating a developer networking site from PostgreSQL to MongoDB. Below is the current SQL schema:

**SQL Tables:**
1.  **`users`**: `id`, `username`, `email`, `bio`
2.  **`posts`**: `id`, `author_id`, `title`, `body`, `created_at`
3.  **`tags`**: `id`, `name` (e.g., "javascript", "nosql")
4.  **`post_tags`**: `post_id`, `tag_id` (Many-to-Many junction table)

### The Task:
1.  **Model the Schema:** Propose a single `posts` collection structure in JSON format.
2.  **Strategic Choices:** 
    *   Decide whether to **Embed** or **Reference** the `tags`.
    *   Decide whether to **Embed** or **Reference** the `author` (User) data.
3.  **Justification:** Write 2-3 sentences explaining *why* you chose to embed or reference these specific fields based on performance and data growth.

---

## Part 2: Querying with MQL Operators (20 Points)

### The Dataset
**Task:** Manually insert the following data into a collection named `inventory` before proceeding to the challenges.

| Name | Category | Price | Tags | Specs (Nested) | Ratings (Array) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Pro Laptop** | Electronics | 1200 | work, gaming | RAM: 16, CPU: i7 | 5, 4, 5 |
| **Budget Phone** | Electronics | 200 | mobile | RAM: 4, CPU: snapdragon | 3, 2 |
| **Mechanical Keyboard** | Peripherals | 150 | work, wireless | Keys: 104 | 5, 5 |
| **Smart Watch** | Electronics | 350 | mobile, wireless | RAM: 2 | 4, 4, 3 |
| **Desk Lamp** | Home | 45 | office | (none) | 5 |
| **Gaming Monitor** | Peripherals | 450 | gaming, high-refresh | Resolution: 4K, Refresh: 144Hz | 5, 4 |
| **USB-C Hub** | Accessories | 60 | work, connectivity | Ports: 7 | 4, 3, 4 |
| **Ergonomic Mouse** | Peripherals | 85 | work, wireless | DPI: 4000 | 5, 5, 4 |
| **External SSD** | Storage | 120 | backup, fast | Capacity: 1TB | 5, 4 |
| **Web Cam** | Accessories | 110 | work, video | Resolution: 1080p | 4, 4 |
| **NC Headphones** | Audio | 300 | travel, wireless | Battery: 30h | 5, 5, 5 |
| **Smart Bulb** | Home | 25 | lighting, wireless | Color: RGB | 3, 4 |
| **Router** | Networking | 180 | home, wireless | Speed: AX3000 | 4, 5 |
| **Tablet** | Electronics | 650 | mobile, creative | RAM: 8, Storage: 256GB | 5, 4, 4 |
| **BT Speaker** | Audio | 90 | outdoor, wireless | Waterproof: IPX7 | 4, 4 |

### The Challenges:
Write the MQL command for each of the following requirements:

1.  **Price Range:** Find all items priced between $100 and $500 (inclusive).
2.  **Category Match:** Find all items that are in either the "Peripherals" or "Home" categories.
3.  **Tag Power:** Find all items that have **both** the "work" AND "wireless" tags.
4.  **Nested Check:** Find all items where the `specs.ram` is greater than 8GB.
5.  **High Ratings:** Find all items that have at least one `5` in their `ratings` array.

---

## Submission Requirements
1.  Create a file named `solution.md` in your `activity11` folder.
2.  Include your JSON schema and justification for Part 1.
3.  Include the code for all 5 queries for Part 2.
4.  Attach screenshots of the query results from your terminal/shell.

---

## Rubric (Total: 40 Points)

| Criteria | Points |
| :--- | :--- |
| **Part 1: JSON Schema Correctness** | 10 pts |
| **Part 1: Embedding/Referencing Logic** | 5 pts |
| **Part 1: Technical Justification** | 5 pts |
| **Part 2: Query 1 (Price Range)** | 4 pts |
| **Part 2: Query 2 (Category Match)** | 4 pts |
| **Part 2: Query 3 (Tag Power)** | 4 pts |
| **Part 2: Query 4 (Nested Check)** | 4 pts |
| **Part 2: Query 5 (Array Match)** | 4 pts |