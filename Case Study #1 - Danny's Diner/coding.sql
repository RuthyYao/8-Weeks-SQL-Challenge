------------------------
--CASE STUDY QUESTIONS--
------------------------

--Author: Ruthy Yao
--Date: 07/11/2024
--Tool used: MYSQL

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	sales.customer_id,
    SUM(menu.price) AS total_spend
FROM sales 
JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id ASC;

-- 2. How many days has each customer visited the restaurant?
SELECT 
	customer_id,
    COUNT(DISTINCT order_date) AS visit_count
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH order_rank_cte AS(
	SELECT 
		sales.customer_id,
		DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date ASC)  -- DENSE_RANK assign the same rank to rows with equal value without gaps, resulting in consecutive ranks.
			AS order_date_rank,
		menu.product_name
	FROM sales
	JOIN menu 	
		ON sales.product_id = menu.product_id
)
SELECT 
	customer_id,
    product_name
FROM order_rank_cte
WHERE order_date_rank = 1
GROUP BY customer_id, product_name;  -- If the product was ordered twice, GROUP BY ensures it will return only one row, avoid duplicate in the output.

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
	menu.product_name,
    COUNT(sales.order_date) AS quantity_sold
FROM menu
JOIN sales 
	ON menu.product_id = sales.product_id
GROUP BY menu.product_name
ORDER BY quantity_sold DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH cte AS (
SELECT
	sales.customer_id,
    menu.product_name,
    COUNT(sales.product_id) AS quantity_sold,
    RANK() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC)
		AS quantity_sold_rank
FROM sales
JOIN menu 
	ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name
)
SELECT 
	customer_id,
    product_name,
    quantity_sold
FROM cte
WHERE quantity_sold_rank = 1;
	
-- 6. Which item was purchased first by the customer after they became a member?
WITH cte AS (
  SELECT 
	sales.customer_id,
    members.join_date,
    sales.order_date,
    sales.product_id,
    menu.product_name,
  	DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date ASC)
  		AS order_date_rank
FROM sales
LEFT JOIN members 
	ON members.customer_id = sales.customer_id
LEFT JOIN menu
  	ON sales.product_id = menu.product_id
WHERE sales.order_date >= members.join_date
  )
SELECT 
	customer_id,
    join_date,
    product_name,
    order_date
FROM cte
WHERE order_date_rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH cte AS (
  SELECT 
	sales.customer_id,
    members.join_date,
    sales.order_date,
    sales.product_id,
    menu.product_name,
  	DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC)
  		AS order_date_rank
FROM sales
LEFT JOIN members 
	ON members.customer_id = sales.customer_id
LEFT JOIN menu
  	ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
  )
SELECT 
	customer_id,
    join_date,
    product_name,
    order_date
FROM cte
WHERE order_date_rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
	members.customer_id,
    COUNT(sales.product_id) AS total_items,
    SUM(menu.price) AS total_spend
FROM members
LEFT JOIN sales
	ON	members.customer_id = sales.customer_id
LEFT JOIN menu
	ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY members.customer_id
ORDER BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
	-- Note: Customers earn points when they make purchases only after they become members. 
WITH customer_points AS (
	SELECT
		sales.customer_id,
    	sales.order_date,
    	menu.product_name,
    	menu.price,
    	(CASE
    		WHEN sales.customer_id IN (SELECT customer_id FROM members) AND menu.product_name = 'sushi' THEN 2 * menu.price * 10
     		WHEN sales.customer_id IN (SELECT customer_id FROM members) AND menu.product_name != 'sushi' THEN 1 * menu.price * 10
        	ELSE 0
    	END) AS points
	FROM sales
	LEFT JOIN menu
		ON sales.product_id = menu.product_id
	)
SELECT
	customer_id,
    SUM(points)
FROM customer_points
GROUP BY customer_id
ORDER BY customer_id;  

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
--  METHOD 1 
WITH cte AS (
	SELECT 
		sales.customer_id,
		menu.product_name,
		menu.price,
		sales.order_date,
		members.join_date,
        (CASE 
			WHEN 
				sales.order_date - members.join_date BETWEEN 0 AND 6
				OR menu.product_name = 'sushi'
			THEN 20 * menu.price
			ELSE 10 * menu.price
		END) AS total_points
	FROM sales
	LEFT JOIN members 
		ON sales.customer_id = members.customer_id
	LEFT JOIN menu 
		ON sales.product_id = menu.product_id
	ORDER BY sales.customer_id,sales.order_date
	)
SELECT
	customer_id,
	SUM(total_points) AS total_points
FROM cte
WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
	AND customer_id IN (SELECT customer_id FROM members)
GROUP BY customer_id
ORDER BY customer_id;

-- Method 2
WITH cte AS(
SELECT 
	sales.customer_id,
	members.join_date,
	sales.order_date,
	menu.product_name,
    menu.price,
    sales.order_date - members.join_date as days_membership
FROM sales
LEFT JOIN members 
	ON sales.customer_id = members.customer_id
LEFT JOIN menu 
	ON sales.product_id = menu.product_id
ORDER BY sales.customer_id,sales.order_date
	)
SELECT 
	customer_id,
    SUM(CASE
    	WHEN days_membership BETWEEN 0 AND 6 
        	OR product_name = 'sushi' THEN 20 * price        	
        ELSE 10 * price
    END) AS total_points
FROM cte
WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
	AND customer_id IN (SELECT customer_id FROM members)
GROUP BY customer_id
ORDER by customer_id;

-- Bonus Q1: Join All The Things - Create a table that has these columns: customer_id, order_date, product_name, price, member (Y/N).
SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    (CASE 
		WHEN 
			sales.customer_id IN (SELECT customer_id FROM members)
				AND sales.order_date >= members.join_date 
		THEN 'Y'
        ELSE 'N'
	END) AS member
FROM sales
LEFT JOIN members 
	ON sales.customer_id = members.customer_id
LEFT JOIN menu 
	ON sales.product_id = menu.product_id
ORDER BY customer_id, order_date;

-- Bonus Q2: Rank All The Things - Based on the table above, add one column: ranking.

WITH cte AS(
SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    (CASE 
        WHEN 
            sales.order_date >= members.join_date 
        THEN 'Y'
        ELSE 'N'
    END) AS member
FROM sales
LEFT JOIN members 
    ON sales.customer_id = members.customer_id
LEFT JOIN menu 
    ON sales.product_id = menu.product_id
ORDER BY customer_id, order_date
  )
SELECT
    *,
    (CASE
        WHEN member = 'Y' 
        THEN RANK() OVER(PARTITION BY customer_id ORDER BY order_date) 
        ELSE 'null'
    END) AS ranking
FROM cte;