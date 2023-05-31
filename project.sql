-- This scale cars model database contains eight tables with some information as below
/* a. Customers: customer data
	b. Employees: all employee information
	c. Offices: sales office information
	d. Orders: customer's sales order
	e. OrderDetails: sales order line for each sales order
	f. Payments: customer's payment records
	g. Products: a list of scale model cars
	h. productLines: a list of products line catefories */

SELECT 'Customers' AS table_name, 
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Customers
  
UNION ALL

SELECT 'Products' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Products

UNION ALL

SELECT 'ProductLines' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM ProductLines

UNION ALL

SELECT 'Orders' AS table_name, 
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Orders

UNION ALL

SELECT 'OrderDetails' AS table_name, 
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM OrderDetails

UNION ALL

SELECT 'Payments' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Payments

UNION ALL

SELECT 'Employees' AS table_name, 
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Employees

UNION ALL

SELECT 'Offices' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Offices;

-- Q1: Which products should we order more or less of?
-- OD is orderdetails, P is products
-- low stock
SELECT productCode, 
       ROUND(SUM(quantityOrdered) * 1.0 / (SELECT quantityInStock
                                             FROM products p
                                            WHERE od.productCode = p.productCode), 2) AS low_stock
  FROM orderdetails od
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10;

-- To identify which product with highest performance
SELECT P.productCode, P.productName, P.productLine, SUM(OD.quantityOrdered * OD.priceEach) AS productPerformance
FROM products P
JOIN orderDetails OD ON P.productCode = OD.productCode
GROUP BY P.productCode, P.productName, P.productLine
ORDER BY productPerformance DESC
LIMIT 10;

-- Q2: How should we match marketing and communication strategies to customer behaviour
-- P is products, OD os orderdetails, O is orders
SELECT O.customerNumber, SUM(OD.quantityOrdered * (OD.priceEach - P.buyPrice)) AS profit
FROM orders O
JOIN orderDetails OD ON O.orderNumber = OD.orderNumber
JOIN products P ON OD.productCode = P.productCode
GROUP BY O.customerNumber;

-- Query below to identify top 5 VIP customers and top 5 as less customers who involved
-- To indicate top 5 VIP customers 
WITH customerProfit AS (
    SELECT O.customerNumber, SUM(OD.quantityOrdered * (OD.priceEach - P.buyPrice)) AS profit
    FROM orders O
    JOIN orderDetails OD ON O.orderNumber = OD.orderNumber
    JOIN products P ON OD.productCode = P.productCode
    GROUP BY O.customerNumber
)
SELECT C.contactLastName, C.contactFirstName, C.city, C.country, CP.profit
-- C is customers
FROM customers C
JOIN customerProfit CP ON C.customerNumber = CP.customerNumber
ORDER BY CP.profit DESC
LIMIT 5

-- To indicate top 5 less customers 
WITH customerProfit AS (
    SELECT O.customerNumber, SUM(OD.quantityOrdered * (OD.priceEach - P.buyPrice)) AS profit
    FROM orders O
    JOIN orderDetails OD ON O.orderNumber = OD.orderNumber
    JOIN products P ON OD.productCode = P.productCode
    GROUP BY O.customerNumber
)
SELECT C.contactLastName, C.contactFirstName, C.city, C.country, CP.profit
FROM customers C
JOIN customerProfit CP ON C.customerNumber = CP.customerNumber
ORDER BY CP.profit ASC
LIMIT 5;

-- Q3: How Much Can We Spend on Acquiring New Customers?
-- Calculate customer profit average/customer LTV = 39039.5943877551
WITH customerProfit AS (
    SELECT O.customerNumber, SUM(OD.quantityOrdered * (OD.priceEach - P.buyPrice)) AS profit
    FROM orders O
    JOIN orderDetails OD ON O.orderNumber = OD.orderNumber
    JOIN products P ON OD.productCode = P.productCode
    GROUP BY O.customerNumber
)
SELECT AVG(profit) AS averageProfit
FROM customerProfit;

