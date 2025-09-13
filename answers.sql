-- ================================================
-- 🛠️ Answer 1: Transform ProductDetail into 1NF
-- ================================================

-- The original ProductDetail table contains multi-valued Products.
-- We'll create a SELECT query to normalize this into 1NF
-- by splitting the Products column into multiple rows.

-- ✅ Using CTE and string splitting (for MySQL 8.0+)
-- Note: MySQL doesn't have a built-in split-to-rows function,
-- so we simulate it using JSON_TABLE for comma-separated values.

-- Assumes Products are comma-separated with proper spacing (e.g., 'Laptop, Mouse')

SELECT
    OrderID,
    CustomerName,
    TRIM(Product) AS Product
FROM
    ProductDetail,
    JSON_TABLE(
        CONCAT('["', REPLACE(Products, ', ', '","'), '"]'),
        '$[*]' COLUMNS (Product VARCHAR(100) PATH '$')
    ) AS ProductList;

-- ✅ This produces a normalized view of the data:
-- Each row has one product per order — now in 1NF.

-- ================================================
-- 🧩 Answer 2: Transform OrderDetails into 2NF
-- ================================================

-- The original OrderDetails table contains partial dependency:
-- CustomerName depends only on OrderID, not (OrderID, Product)

-- ✅ Step 1: Create a separate Orders table (OrderID -> CustomerName)
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- ✅ Step 2: Create OrderProducts table (OrderID, Product, Quantity)
INSERT INTO OrderProducts (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- ✅ Now:
-- Orders table holds data that depends on OrderID (CustomerName)
-- OrderProducts table holds data that depends on the full key (OrderID + Product)
-- => The schema is now in 2NF.
