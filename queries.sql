-- count all customers

SELECT COUNT(customer_id)
FROM customers;

-- count salesmans income - top 10

SELECT
	  CONCAT(e.first_name, ' ', e.last_name) AS name,
	  COUNT(s.sales_id) AS operations,
	  FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN employees AS e
	  ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
	  ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;

-- salesmans whos income is lower than average
WITH overall_avg AS (
	  SELECT
		    AVG(p.price * s.quantity) AS all_avg
	  FROM sales AS s
	  INNER JOIN products AS p
		    ON s.product_id = p.product_id
),
sales_avg AS (
	  SELECT
		    s.sales_person_id AS sales_person_id,
		    AVG(p.price * s.quantity) AS average_income
	  FROM sales AS s
	  INNER JOIN products AS p
		    ON s.product_id = p.product_id
	  GROUP BY sales_person_id
)

SELECT
	  CONCAT(e.first_name, ' ', e.last_name) AS name,
	  ROUND(s.average_income) as average_income
FROM employees AS e
INNER JOIN sales_avg AS s
  ON e.employee_id = s.sales_person_id
CROSS JOIN overall_avg AS ova
WHERE average_income < ova.all_avg
ORDER BY average_income;

-- sales by salesmans an weekdays

WITH weekday_sales AS (
	  SELECT
		    CONCAT(e.first_name, ' ', e.last_name) AS name,
		    TO_CHAR(s.sale_date, 'day') AS weekday,
		    EXTRACT(ISODOW FROM s.sale_date) AS day_number,
		    ROUND(SUM(p.price * s.quantity)) AS income
	  FROM sales AS s
	  INNER JOIN employees AS e
		    ON s.sales_person_id = e.employee_id
	  INNER JOIN products AS p
		    ON s.product_id = p.product_id
	  GROUP BY e.first_name, e.last_name, weekday, day_number
)

SELECT
	  name,
	  weekday,
	  income
FROM weekday_sales
ORDER BY day_number, name;

-- customers categories

SELECT
	  CASE
		    WHEN age > 40 THEN '40+'
		    WHEN age <= 40 AND age >= 26 THEN '26-40'
		    WHEN age >= 16 AND age < 26 THEN '16-25'
		    ELSE 'small'
	  END AS age_category,
		count(customer_id) AS count
FROM customers
GROUP BY age_category
ORDER BY age_category;

-- customers by months

SELECT
	  TO_CHAR(sale_date, 'YYYY-MM') AS date,
	  COUNT(DISTINCT(s.customer_id)) AS total_customers,
	  FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
INNER JOIN products p
	  ON s.product_id = p.product_id
GROUP BY date
ORDER BY date;

-- sales in special offers

WITH first_sale AS (
	  SELECT DISTINCT
		    c.customer_id AS customer_id,
		    s.sales_person_id AS sales_person_id, 
		    CONCAT(c.first_name, ' ', c.last_name) AS customer,
		    FIRST_VALUE(s.sale_date) OVER (PARTITION BY s.customer_id) AS first_sale,
		    p.price AS price
	  FROM sales AS s
	  INNER JOIN products AS p
		    ON s.product_id = p.product_id 
	  INNER JOIN customers AS c 
		    ON s.customer_id  = c.customer_id
)

SELECT
	  f.customer AS customer,
	  f.first_sale AS sale_date,
	  CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_sale AS f
INNER JOIN employees AS e
	  ON f.sales_person_id = e.employee_id
WHERE f.price = 0
ORDER BY customer_id;
