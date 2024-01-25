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
	  FLOOR(s.average_income) as average_income
FROM employees AS e
INNER JOIN sales_avg AS s

-- sales by salesmans an weekdays

WITH weekday_sales AS (
	  SELECT
		    CONCAT(e.first_name, ' ', e.last_name) AS name,
		    TO_CHAR(s.sale_date, 'day') AS weekday,
		    EXTRACT(ISODOW FROM s.sale_date) AS day_number,
		    FLOOR(SUM(p.price * s.quantity)) AS income
	  FROM sales AS s
	  INNER JOIN employees AS e
		    ON s.sales_person_id = e.employee_id
	  INNER JOIN products AS p
		    ON s.product_id = p.product_id
	  GROUP BY e.first_name, e.last_name, s.sale_date
)

SELECT
	  name,
	  weekday,
	  SUM(income) AS income
FROM weekday_sales
GROUP BY name, weekday, day_number
ORDER BY name, day_number;
