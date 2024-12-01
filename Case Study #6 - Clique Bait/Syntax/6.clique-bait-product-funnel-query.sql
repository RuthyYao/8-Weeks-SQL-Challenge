---------------------------------
-- CASE STUDY #3 - Clique Bait --
---------------------------------

-- Author: Ruthy Yao
-- Date: 20/11/2024
-- Tool used: MYSQL

-- Part II - Product Funnel Analysis

-- 1. Using a single SQL query - create a new output table which has the following details:

	-- How many times was each product viewed?
	-- How many times was each product added to cart?
	-- How many times was each product added to a cart but not purchased (abandoned)?
	-- How many times was each product purchased?

-- Solution Structure
	-- Create a CTE prod_view: calculate the number of views and number of cart_adds for each product using CASE() and SUM()
	-- Create a CTE prod_abandon: calculate the number of abandoned products (Note: use the solution for Q9 in the Digital Analysis section. Only need to replace IN by NOT IN in the subquery).
	-- Create a CTE prod_purchased: calculate the number of purchased products (solution for Q9 in the Digital Analysis section)
	-- JOIN the above three CTEs using product_id, product_name and product_category of each product
	-- Store the result in a temporary table product_summary for further analysis

CREATE TABLE product_summary
WITH prod_view AS (
SELECT 
    p.product_id,
    p.page_name,
    p.product_category,
    SUM(CASE WHEN e.page_id NOT IN (1,2,12,13) AND e.event_type = 1 THEN 1 ELSE 0 END) AS views,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
LEFT JOIN page_hierarchy as p
	ON e.page_id = p.page_id
WHERE product_id IS NOT NULL
GROUP BY  p.product_id, p.page_name, p.product_category
),
prod_abandon AS(
SELECT
    p.product_id,
    p.page_name,
    p.product_category,
    COUNT(e.visit_id) AS abandoned
FROM events AS e 
LEFT JOIN page_hierarchy AS p
	ON p.page_id = e.page_id
WHERE e.event_type = 2  -- 1st layer - products are add to cart.
AND e.visit_id NOT IN 
	(SELECT
		visit_id
	FROM events
    WHERE event_type = 3) -- 2nd layer - products NOT purchased.
GROUP BY p.product_id, p.page_name, p.product_category
),
prod_purchased AS(
SELECT
    p.product_id,
    p.page_name,
    p.product_category,
    COUNT(e.visit_id) AS purchases
FROM events AS e 
LEFT JOIN page_hierarchy AS p
	ON p.page_id = e.page_id
WHERE e.event_type = 2  -- 1st layer - products are add to cart.
AND e.visit_id IN 
	(SELECT
		visit_id
	FROM events
    WHERE event_type = 3) -- 2nd layer - products are purchased.
GROUP BY p.product_id, p.page_name, p.product_category
)
SELECT
	pv.*,
    pa.abandoned,
    pp.purchases
FROM prod_view AS pv
LEFT JOIN prod_abandon AS pa
	ON pv.product_id = pa.product_id
LEFT JOIN prod_purchased AS pp
	ON pv.product_id = pp.product_id
ORDER BY pv.product_id;
;

SELECT
	*
fROM product_summary;

-- Convert the value in the above table to percentage.
SELECT
    page_name,
    product_category,
    ROUND(100*views/views,1) AS views,
    ROUND(100*add_to_cart/views,1) AS add_to_cart_rate,
    ROUND(100*purchases/views,1) AS purchase_rate,
    ROUND(100*abandoned/views,1) AS fallout_rate
FROM product_summary
ORDER BY fallout_rate DESC;


-- 2. Create another table which further aggregates the data for the above points but for each product category instead of individual products.
CREATE TABLE category_summary
WITH cat_view AS (
SELECT 
    p.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS views,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS add_to_cart
FROM events AS e
LEFT JOIN page_hierarchy as p
	ON e.page_id = p.page_id
WHERE p.product_id IS NOT NULL
GROUP BY  p.product_category
),
cat_abandon AS(
SELECT
    p.product_category,
    COUNT(e.visit_id) AS abandoned
FROM events AS e 
LEFT JOIN page_hierarchy AS p
	ON p.page_id = e.page_id
WHERE e.event_type = 2  -- 1st layer - products are add to cart.
AND e.visit_id NOT IN 
	(SELECT
		visit_id
	FROM events
    WHERE event_type = 3) -- 2nd layer - products NOT purchased.
GROUP BY p.product_category
),
cat_purchased AS(
SELECT
    p.product_category,
    COUNT(e.visit_id) AS purchases
FROM events AS e 
LEFT JOIN page_hierarchy AS p
	ON p.page_id = e.page_id
WHERE e.event_type = 2  -- 1st layer - products are add to cart.
AND e.visit_id IN 
	(SELECT
		visit_id
	FROM events
    WHERE event_type = 3) -- 2nd layer - products are purchased.
GROUP BY p.product_category
)
SELECT
	cv.*,
    ca.abandoned,
    cp.purchases
FROM cat_view AS cv
LEFT JOIN cat_abandon AS ca
	ON cv.product_category = ca.product_category
LEFT JOIN cat_purchased AS cp
	ON cv.product_category = cp.product_category
;

SELECT
	*
FROM category_summary;

-- Convert the value in the above table to percentage.
SELECT
	product_category,
    ROUND(100*views/views,1) AS views,
    ROUND(100*add_to_cart/views,1) AS add_to_cart_rate,
    ROUND(100*purchases/views,1) AS purchase_rate,
    ROUND(100*abandoned/views,1) AS fallout_rate
FROM category_summary;


-- Use the two new output tables answer the following questions.
-- 1. Which product had the most views, cart adds and purchases?
SELECT
	(SELECT page_name FROM product_summary ORDER BY views DESC LIMIT 1) AS most_view,
	(SELECT page_name FROM product_summary ORDER BY add_to_cart DESC LIMIT 1) AS most_add_to_cart,
    (SELECT page_name FROM product_summary ORDER BY purchases DESC LIMIT 1) AS most_purchases;
    
-- 2. Which product was most likely to be abandoned?
SELECT
	*
FROM product_summary
ORDER BY abandoned DESC
LIMIT 1;


-- 3. Which product had the highest view to purchase percentage?
SELECT
	page_name,
	ROUND(100*purchases / views,2) AS conversion_rate
FROM product_summary
ORDER BY conversion_rate DESC
LIMIT 1;

-- 4.  What is the average conversion rate from view to cart add?
SELECT 
    ROUND(100*AVG(add_to_cart / views),2) AS conversion_rate
FROM product_summary;

-- 5.What is the average conversion rate from cart add to purchase?
SELECT 
    ROUND(100*AVG(purchases / add_to_cart),2) AS conversion_rate
FROM product_summary;
