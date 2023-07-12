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


/*
 * 
 * EDA - Customers
 * 
 * */

-- How many customers do we have?
	-- 91 customers
SELECT COUNT(customer_id) AS total_customers
FROM customers;

-- How many countries to we sell/export to?
	-- 21 countries
SELECT COUNT(DISTINCT country) AS unique_countries
FROM customers;

-- What are the countries that we sell/export to?
SELECT DISTINCT country FROM customers
ORDER BY country;

-- How many customers do we have in each continent?
	-- 54 in Europe, 21 in North America, 16 in South America
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
	COUNT(customer_id) OVER(PARTITION BY continent)
	AS total_cust_per_continent
FROM customer_locations
ORDER BY total_cust_per_continent, country;


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

