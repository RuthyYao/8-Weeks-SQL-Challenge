# Case Study #1 - Danny's Diner
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/1.png" align="center" width="400" height="400" >
  
## Table of Contents
* [Bussiness Task](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#bussiness-task)
* [Entity Relationship Diagram](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#entity-relationship-diagram)
* [Case Study Questions](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#case-study-questions)
* [My Solution](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#my-solution)

---
## Bussiness Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

---
## Entity Relationship Diagram
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/e1.PNG" align="center" width="500" height="250" >

---
## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
  not just sushi - how many points do customer A and B have at the end of January?

#### Bonus Questions
1. Join All The Things - Create a table that has these columns: customer_id, order_date, product_name, price, member (Y/N).
2. Rank All The Things - Based on the table above, add one column: ranking.  

---
## My Solution
*View the complete syntax [HERE](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/coding.sql).*
  
### Q1. What is the total amount each customer spent at the restaurant?
```TSQL
SELECT
  sales.customer_id,
  SUM(menu.price) AS total_spend
FROM sales 
JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id ASC;
```
|  customer_id | total_spend  |
|---|---|
|A	|76|
|B	|74|
|C	|36|

  
---
### Q2. How many days has each customer visited the restaurant?
```TSQL
SELECT 
  customer_id,
  COUNT(DISTINCT order_date) AS visit_count
FROM sales 
GROUP BY customer_id;
```
|  customer_id | visit_count  |
|---|---|
|A	|4|
|B	|6|
|C	|2|

  
---
### Q3. What was the first item from the menu purchased by each customer?
```TSQL
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
    product_name,
    COUNT(product_name) AS quantity_ordered
FROM order_rank_cte
WHERE order_date_rank = 1
GROUP BY customer_id, product_name;  -- If the product was ordered twice, GROUP BY ensures it will return only one row, avoid duplicate in the output.
```
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |
  
  
---
### Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```SQL
SELECT 
    menu.product_name,
    COUNT(sales.order_date) AS quantity_sold
FROM menu
JOIN sales 
	ON menu.product_id = sales.product_id
GROUP BY menu.product_name
ORDER BY quantity_sold DESC
LIMIT 1;

```
| product_name | quantity_sold |
| ------------ | ------------- |
| ramen        | 8             |
  
  
---
### Q5. Which item was the most popular for each customer?
```TSQL
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
```
| customer_id | product_name | purch_freq |
|-------------|--------------|------------|
| A           | ramen        | 3          |
| B           | sushi        | 2          |
| B           | curry        | 2          |
| B           | ramen        | 2          |
| C           | ramen        | 3          |
  
  
---
### Q6. Which item was purchased first by the customer after they became a member?
```TSQL
WITH orderAfterMember AS (
  SELECT 
    s.customer_id,
    mn.product_name,
    s.order_date,
    m.join_date,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
  FROM sales s
  JOIN members m 
    ON s.customer_id = m.customer_id
  JOIN menu mn 
    ON s.product_id = mn.product_id
  WHERE s.order_date >= m.join_date
)

SELECT 
  customer_id,
  product_name,
  order_date,
  join_date
FROM orderAfterMember
WHERE rnk = 1;

```
| customer_id | join_date  | product_name | order_date |
| ----------- | ---------- | ------------ | ---------- |
| A           | 2021-01-07 | curry        | 2021-01-07 |
| B           | 2021-01-09 | sushi        | 2021-01-11 |


---
### Q7. Which item was purchased just before the customer became a member?
```TSQL
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
```  

| customer_id | join_date  | product_name | order_date |
| ----------- | ---------- | ------------ | ---------- |
| A           | 2021-01-07 | sushi        | 2021-01-01 |
| A           | 2021-01-07 | curry        | 2021-01-01 |
| B           | 2021-01-09 | sushi        | 2021-01-04 |

                                  
---
### Q8. What is the total items and amount spent for each member before they became a member?
```TSQL
SELECT
	members.customer_id,
    	COUNT(sales.product_id) AS total_items,
    	SUM(menu.price) AS total_spend
FROM members
LEFT JOIN sales
	ON members.customer_id = sales.customer_id
LEFT JOIN menu
	ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY members.customer_id
ORDER BY customer_id;
```
| customer_id | total_items | total_spend |
|-------------|-------------|-------------|
| A           | 2           | 25          |
| B           | 3           | 40          |

  
---
### Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Note: Customers earn points when they make purchases only after they become members.
```TSQL
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
```
| customer_id | total_points |
|-------------|--------------|
| A           | 860          |
| B           | 940          |
| C           | 0            |
  
--- 
### Q10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```TSQL
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
```
| customer_id | total_points |
|-------------|--------------|
| A           | 1370         |
| B           | 820          |          
                              
---
### Bonus Q1. Join All The Things 
```TSQL
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
```
| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

---
### Bonus Q2. Rank All The Things

```TSQL
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
```
| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N      | NULL    |
