/* =========================
INVENTORY MANAGEMENT SYSTEM
========================= */

CREATE DATABASE InventoryDB;
USE InventoryDB;

/* =========================
TABLE CREATION
========================= */

CREATE TABLE Categories (
Category_id INT PRIMARY KEY,
CategoryName VARCHAR(50)
);

CREATE TABLE Product (
Product_id INT PRIMARY KEY,
Product_Name VARCHAR(55),
Category_id INT,
Unit_price DECIMAL(10,2),
Units_instock INT,

```
FOREIGN KEY (Category_id) REFERENCES Categories(Category_id),

CONSTRAINT chk_price CHECK (Unit_price > 0),
CONSTRAINT chk_stock CHECK (Units_instock >= 0)
```

);

CREATE TABLE Sales (
SaleID INT PRIMARY KEY,
Product_id INT,
SaleDate DATE,
QuantitySold INT,

```
FOREIGN KEY (Product_id) REFERENCES Product(Product_id),

CONSTRAINT chk_quantity CHECK (QuantitySold >= 0)
```

);

/* =========================
SAMPLE DATA
========================= */

INSERT INTO Categories VALUES
(101, 'Electronics'),
(102, 'Mobile Devices'),
(103, 'Gaming');

INSERT INTO Product VALUES
(1, 'Laptop', 101, 1200.00, 50),
(2, 'Smartphone', 102, 800.00, 100),
(3, 'Gaming Console', 103, 500.00, 40),
(4, 'Headphones', 101, 150.00, 80),
(5, 'Tablet', 102, 600.00, 60);

INSERT INTO Sales VALUES
(1, 1, '2024-01-01', 3),
(2, 2, '2024-01-03', 5),
(3, 3, '2024-01-05', 2),
(4, 4, '2024-01-06', 4),
(5, 5, '2024-01-07', 3);

/* =========================
UPDATE OPERATIONS
========================= */

UPDATE Product
SET Unit_price = Unit_price * 0.95
WHERE Category_id IN (101,102);

UPDATE Product
SET Units_instock = Units_instock - 5
WHERE Category_id IN (101,102)
AND Units_instock >= 5;

UPDATE Product
SET Product_Name = 'PC'
WHERE Product_Name = 'Laptop';

/* =========================
DELETE OPERATION
========================= */

DELETE FROM Product
WHERE Product_Name = 'Headphones';

/* =========================
INDEXES FOR PERFORMANCE
========================= */

CREATE INDEX idx_product_category
ON Product(Category_id);

CREATE INDEX idx_sales_product
ON Sales(Product_id);

/* =========================
VIEW CREATION
========================= */

CREATE VIEW vw_ProductSales AS
SELECT
p.Product_Name,
c.CategoryName,
SUM(s.QuantitySold) AS Total_Quantity_Sold,
SUM(s.QuantitySold * p.Unit_price) AS Total_Revenue
FROM Product p
JOIN Sales s
ON p.Product_id = s.Product_id
JOIN Categories c
ON p.Category_id = c.Category_id
GROUP BY p.Product_Name, c.CategoryName;

/* =========================
STORED PROCEDURE
========================= */

DELIMITER //

CREATE PROCEDURE GetCategorySales(IN category_name VARCHAR(50))
BEGIN
SELECT
c.CategoryName,
SUM(s.QuantitySold * p.Unit_price) AS Total_Sales
FROM Categories c
JOIN Product p
ON c.Category_id = p.Category_id
JOIN Sales s
ON p.Product_id = s.Product_id
WHERE c.CategoryName = category_name
GROUP BY c.CategoryName;
END //

DELIMITER ;

/* =========================
ANALYTICAL QUERIES
========================= */

-- Top Selling Products
SELECT
p.Product_Name,
SUM(s.QuantitySold) AS Total_Sold
FROM Product p
JOIN Sales s
ON p.Product_id = s.Product_id
GROUP BY p.Product_Name
ORDER BY Total_Sold DESC
LIMIT 5;

-- Monthly Revenue Analysis
SELECT
MONTH(s.SaleDate) AS Sales_Month,
SUM(s.QuantitySold * p.Unit_price) AS Revenue
FROM Sales s
JOIN Product p
ON s.Product_id = p.Product_id
GROUP BY MONTH(s.SaleDate)
ORDER BY Sales_Month;

-- Inventory Status Report
SELECT
Product_Name,
Units_instock
FROM Product
ORDER BY Units_instock ASC;

/* =========================
VIEW EXECUTION
========================= */

SELECT * FROM vw_ProductSales;

/* =========================
STORED PROCEDURE EXECUTION
========================= */

CALL GetCategorySales('Electronics');
