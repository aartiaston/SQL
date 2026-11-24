create database SQL_Activity;
use SQL_Activity;

-- DATA IMPORTED INTO SQL --

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

-- FINDING NULL VALUES IN THE DATA --

SELECT * FROM city
WHERE city_id IS NULL
OR city_name IS NULL
OR population IS NULL
OR estimated_rent IS NULL
OR city_rank IS NULL;


SELECT * FROM customers 
WHERE customer_id IS NULL
OR customer_name IS NULL
OR city_id IS NULL;


SELECT * FROM products
WHERE product_id IS NULL
OR product_name IS NULL
OR price IS NULL;


SELECT * FROM sales 
WHERE sale_id IS NULL
OR sale_date IS NULL
OR product_id IS NULL
OR quantity IS NULL
OR customer_id IS NULL
OR total_amount IS NULL
OR rating IS NULL;


-- CHECKING DUPLICATES ENTRIES IN THE CUSTOMERS TABLE --

SELECT customer_id, customer_name, city_id,
COUNT(*) AS duplicate_entries
FROM customers
GROUP BY customer_id, customer_name, city_id
HAVING COUNT(*) > 1;


-- CHECKING FOR MISMATCHES BETWEEN total_amount & THE CALCULATED VALUE OF price × quantity --

SELECT s.sale_id, s.total_amount AS recorded_amount, 
(p.price * s.quantity) AS calculated_amount
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
WHERE s.total_amount != (p.price * s.quantity);


-- COMPREHENSIVE SALES REPORT WITH CUSTOMER & PRODUCT DETAILS --

WITH CustomerProductDetails AS (
SELECT s.sale_date, c.customer_name, p.product_name, s.quantity,
s.total_amount, ci.city_name
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN products AS p ON s.product_id = p.product_id
JOIN city AS ci ON c.city_id = ci.city_id
)
SELECT * FROM CustomerProductDetails
ORDER BY sale_date DESC;

-- OR --
 
SELECT c.city_name, cu.customer_name, p.product_name,
p.price AS unit_price, s.sale_id, s.total_amount, s.sale_date, s.quantity
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN products p ON s.product_id = p.product_id
JOIN city c ON cu.city_id = c.city_id
ORDER BY sale_date DESC;

-- TOTAL SALES PER CITY --

SELECT ci.city_name, SUM(s.total_amount) AS total_sales
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON c.city_id = ci.city_id
GROUP BY ci.city_name;

-- OR --

SELECT c.city_name,
SUM(s.total_amount) AS total_revenue,
COUNT(s.sale_id) AS total_orders,
ROUND(AVG(s.total_amount),2) AS avg_order
FROM sales s
JOIN customers cu ON s.customer_id=cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_revenue DESC;

-- TOTAL TRANSACTIONS PER CITY --

SELECT ci.city_name, COUNT(s.sale_id) AS transaction_count
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS ci ON c.city_id = ci.city_id
GROUP BY ci.city_name;

-- UNIQUE CUSTOMERS PER CITY --

SELECT c.city_name, COUNT(DISTINCT cu.customer_id) AS unique_customers
FROM customers cu
JOIN city c ON cu.city_id= c.city_id
GROUP BY c.city_name
ORDER BY unique_customers;

-- AVERAGE ORDER VALUE PER CITY --

select c.city_name, COUNT(s.sale_id) AS average_orders,
SUM(s.total_amount) AS total_revenue,
ROUND(SUM(s.total_amount)/COUNT(s.sale_id) ,2) AS avg_order
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY c.city_name
ORDER BY avg_order DESC;


-- PRODUCT DEMAND PER CITY --

SELECT c.city_name, p.product_name, SUM(s.quantity) AS product_quantity
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY c.city_name, p.product_name
ORDER BY product_quantity, c.city_name DESC;


-- MONTHLY SALES TREND --

SELECT
YEAR(s.sale_date) AS sales_of_year,
MONTHNAME(s.sale_date) AS sales_month,
SUM(s.total_amount) AS total_revenue
FROM sales s
GROUP BY sales_of_year, MONTHNAME(s.sale_date), sales_month
ORDER BY sales_of_year, MONTHNAME(s.sale_date);


-- CUSTOMER RATING ANALYSIS --

SELECT c.city_name, p.product_name, AVG(s.rating) AS product_rating
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id 
GROUP BY c.city_name, p.product_name
ORDER BY product_rating DESC;


-- TOP CITIES SELECTIONS --

select c.city_name, SUM(s.total_amount) AS total_revenue,
COUNT(DISTINCT s.customer_id) AS unique_customers,
COUNT(s.sale_id) AS order_count
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_revenue DESC
LIMIT 3;


-- FINAL RECOMENDATIONS --

-- 01. Target high growth cities like Bangalore, Delhi, and Mumbai to capitalise on established market demand and superior revenue potential. --
-- 02. Prioritise stocking top performing products such as Coffee Beans and Ground Espresso to ensure high stock turnover and customer satisfaction. --
-- 03. Adopt premium pricing or high volume service models in expensive markets like Mumbai to maintain profitability against higher rental costs. --
-- 04. Scale marketing efforts and service standards in line with peak sales months and successful regional patterns identified in the data. --