/*
 * 
 * EDA - Company History
 * 
 * */

-- When was the company's first order?
	-- July 4, 1996
SELECT order_date FROM orders
ORDER BY order_date
LIMIT 1;

-- When was the company's last order?
	-- May 6, 1998
SELECT order_date FROM orders
ORDER BY order_date DESC
LIMIT 1;

-- How many non-stakeholder employees do we have?
	-- 9 employees
SELECT COUNT(employee_id) AS total_employees
FROM employees;

-- How many orders have been placed in the company's history?
	-- 830 orders
SELECT COUNT(order_id) AS total_orders
FROM orders;


/*
 * 
 * EDA - Customers
 * 
 * */

-- How many customers do we have?
	-- 91 customers
SELECT COUNT(customer_id) AS total_customers
FROM customers;

-- Our customers are from how many unique countries?
	-- 21 countries
SELECT COUNT(DISTINCT country) AS unique_customer_countries
FROM customers;

-- What are these countries?
SELECT DISTINCT country FROM customers
ORDER BY country;

-- How many customers do we have in each country? In each continent?
	-- country: see total_cust_per_country column
	-- continent: see total_cust_per_continent column
WITH customer_locations AS (
	SELECT customer_id, country,
		CASE 
			WHEN country IN ('Canada', 'Mexico', 'USA') THEN 'North America'
			WHEN country IN ('Argentina', 'Brazil', 'Venezuela') THEN 'South America'
			ELSE 'Europe'
		END AS continent
	FROM customers
)
SELECT *,
	COUNT(customer_id) OVER(PARTITION BY country)
		AS total_cust_per_country,
	COUNT(customer_id) OVER(PARTITION BY continent)
		AS total_cust_per_continent
FROM customer_locations
ORDER BY total_cust_per_continent, country;

-- How many unique countries do we ship to?
	-- 21 countries
SELECT COUNT(DISTINCT ship_country) AS unique_ship_countries
FROM orders;

-- Are there any cases where a customer country doesn't match the ship country?
	-- No, all customers are ordering products that are shipped within their country
SELECT *
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.country != o.ship_country;


/*
 * 
 * EDA - Products
 * 
 * */

-- How many unique products do we sell?
	-- 77 products
SELECT COUNT(product_id) AS total_products
FROM products;

-- How many unique products fall into each product category?
SELECT c.category_name, COUNT(p.product_id) AS total_products
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY total_products;

-- What products have been ordered, but not shipped?
SELECT o.order_id, o.order_date, o.customer_id, o.shipped_date,
	p.product_id, p.product_name, c.category_name 
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id 
WHERE o.shipped_date IS NULL
ORDER BY o.order_date;


/*
 * 
 * Query for .csv raw data export
 * 
 * */

SELECT c.customer_id, c.company_name, c.country,
	CASE 
		WHEN c.country IN ('Canada', 'Mexico', 'USA') THEN 'North America'
		WHEN c.country IN ('Argentina', 'Brazil', 'Venezuela') THEN 'South America'
		ELSE 'Europe'
	END AS continent,
	o.order_id, EXTRACT(YEAR FROM o.order_date) AS order_year,
	CASE
		WHEN EXTRACT(MONTH FROM o.order_date) IN (1, 2, 3) THEN 'Q1'
		WHEN EXTRACT(MONTH FROM o.order_date) IN (4, 5, 6) THEN 'Q2'
		WHEN EXTRACT(MONTH FROM o.order_date) IN (7, 8, 9) THEN 'Q3'
		WHEN EXTRACT(MONTH FROM o.order_date) IN (10, 11, 12) THEN 'Q4'
	END AS fiscal_quarter,
	o.order_date, o.required_date, o.shipped_date, o.ship_name,
	o.shipped_date - o.order_date AS lead_time,
	o.required_date - o.order_date AS requested_lead_time,
	od.unit_price AS order_unit_price, od.quantity, od.discount,
	od.unit_price * od.quantity * (1 - od.discount) AS revenue,
	p.product_id, p.product_name, p.reorder_level,
	p.unit_price AS product_unit_price, p.product_cost,
	CASE 
		WHEN od.unit_price = p.unit_price
		THEN (od.unit_price * (1 - od.discount) - p.product_cost) * od.quantity
		ELSE NULL
	END AS gross_profit,
	cat.category_name, cat.description
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
ORDER BY order_id;

