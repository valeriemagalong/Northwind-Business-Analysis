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