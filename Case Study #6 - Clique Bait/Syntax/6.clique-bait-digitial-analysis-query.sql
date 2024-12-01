--------------------------------
-- CASE STUDY #3 - Clique Bait--
--------------------------------

-- Author: Ruthy Yao
-- Date: 18/11/2024
-- Tool used: MYSQL

-- Part I - Digital Analysis

-- 1. How many users are there?
SELECT 
	COUNT(DISTINCT user_id) AS customer_count
FROM users;

-- 2. How many cookies does each user have on average?
WITH cte_cookies AS (
SELECT
	user_id,
	COUNT(DISTINCT cookie_id) AS num_cookies
FROM users
GROUP BY user_id
)
SELECT 
	AVG(num_cookies) AS cookies_per_customer
FROM cte_cookies;

-- 3. What is the unique number of visits by all users per month?
SELECT 
	DATE_FORMAT(event_time,'%Y-%m') As period,
    COUNT(DISTINCT visit_id) AS visits
FROM events
GROUP BY period;

-- 4. What is the number of events for each event type?
SELECT
	e.event_type,
    ei.event_name,
    COUNT(DISTINCT visit_id) AS event_count
FROM events AS e
LEFT JOIN event_Identifier AS ei
	ON e.event_type = ei.event_type
GROUP BY e.event_type, ei.event_name;

WITH event_count AS(
SELECT
	DISTINCT DATE_FORMAT(e.event_time, '%Y-%m') AS period,
    e.event_type,
    ei.event_name,
    COUNT(DISTINCT visit_id)  AS event_count
FROM events AS e
LEFT JOIN event_Identifier AS ei
	ON e.event_type = ei.event_type
GROUP BY period, e.event_type, ei.event_name
ORDER BY period, e.event_type, ei.event_name
)
SELECT
	period,
    MAX(CASE WHEN event_name = 'Page View' THEN event_count ELSE 0 END) AS page_view,
	MAX(CASE WHEN event_name = 'Add to Cart' THEN event_count ELSE 0 END) AS add_to_cart,   
    MAX(CASE WHEN event_name = 'Purchase' THEN event_count ELSE 0 END) AS purchase,   
    MAX(CASE WHEN event_name = 'Ad Impression' THEN event_count ELSE 0 END) AS impression,   
    MAX(CASE WHEN event_name = 'Ad Click' THEN event_count ELSE 0 END) AS clicks
FROM event_count
GROUP BY period;


-- 5. What is the percentage of visits which have a purchase event?
SELECT
	ROUND(COUNT(DISTINCT visit_id) * 100 / (SELECT COUNT(DISTINCT visit_id) FROM events),1) AS purchase_percentage
FROM events AS e
LEFT JOIN event_Identifier AS ei
	ON e.event_type = ei.event_type
WHERE event_name = 'Purchase';

-- About half of the time customers visiting the store made a purchase.
 
 -- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
    
-- Method 1: Breakdown the question into two steps.
	-- Step 1 - create a cte that count the number of visits which view the checkout page;
	-- Step 2 - count the number of visits that make purchases divided by the visits in Step 1 (use subquery) 
    
WITH cte AS(
SELECT 
	COUNT(DISTINCT e.visit_id) AS checkout_page_visits
FROM events AS e
LEFT JOIN event_Identifier AS ei
	ON e.event_type = ei.event_type
LEFT JOIN page_hierarchy AS p
	ON e.page_id = p.page_id
WHERE ei.event_name = 'Page View'
	AND p.page_name = 'Checkout'
)
SELECT
	ROUND((1- COUNT(DISTINCT e.visit_id) /  (SELECT checkout_page_visits FROM cte)) * 100,2)  AS checkout_page_no_purchase
FROM events AS e
LEFT JOIN event_Identifier AS ei
	ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';
    

-- Method 2 - Break the question into two steps.
	-- Step 1 - Create a cte and use CASE statement to tag each event on a page visit with 1 or 0. 
		-- visit-checkout (the denomitor): Tag 1 for event_type = 1 (Page View) and page_id = 12 (checkout). These are the events where users visit the checkout page; "0" stands for event_type = 3(Purchase). All else '0'.
        -- Made-purchase (The numerator): Tag 1 for event_type = 3 (Purchase). These are users who make a purchase. All else '0'.
        -- Note: we use Max() because we just want to tag each row rather than aggregate. Because there are two groups, we can't aggregate at this stage.
	-- Step 2  - Aggregate and calculate the percentage using SUM(). Sum all the "1" for visit-check group and made-purchase group respectively and use the later divided by the former to get the percentage.
					
WITH cte AS(
SELECT 
  visit_id,
  event_type,
  page_id,
  CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END AS checkout,
  CASE WHEN event_type = 3 THEN 1 ELSE 0 END AS purchase
FROM events
GROUP BY visit_id, event_type, page_id
ORDER BY visit_id, event_type, page_id
) 
SELECT
	SUM(purchase) AS purchases,
    SUM(checkout) AS checkout,
	1- SUM(purchase)/sum(checkout) AS  checkout_page_no_purchase
FROM cte;


-- 7. What are the top 3 pages by number of views?
SELECT
    p.page_name,
    COUNT(e.visit_id) AS num_views
FROM events AS e
LEFT JOIN page_hierarchy AS p
	ON	e.page_id = p.page_id
WHERE e.event_type = 1
GROUP BY p.page_name
ORDER BY num_views DESC
LIMIT 3;

-- Top 3 products pages by number of views.
SELECT
    p.page_name,
    COUNT(e.visit_id) AS num_views
FROM events AS e
LEFT JOIN page_hierarchy AS p
	ON	e.page_id = p.page_id
WHERE e.event_type = 1
	AND p.product_category IS NOT NULL
GROUP BY p.page_name
ORDER BY num_views DESC
LIMIT 3;


-- 8. What is the number of views and cart adds for each product category?
SELECT
	p.product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS num_views,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS num_add_cart
FROM events AS e
LEFT JOIN page_hierarchy AS p
	ON	e.page_id = p.page_id
WHERE product_category IS NOT NULL
GROUP BY p.product_category;

-- 9. What are the top 3 products by purchases?

-- Solution structure: 
	-- Purchased products are those which are add to the cart in the product page AND are purchased in the confirmation page.
    -- Hence break down the question into two layers:
		-- 1. products are add to cart.
		-- 2. products are purchased (use subquery)
SELECT
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
ORDER BY purchases DESC
LIMIT 3;

-- 10. How many times did each customer visit the online store averagely?
WITH visit_cte AS(
SELECT 
	users.user_id,
    COUNT(DISTINCT events.visit_id) AS visits
FROM users
LEFT JOIN events
	ON users.cookie_id = events.cookie_id
GROUP BY users.user_id
)
SELECT
	AVG(visits) AS avg_visits_per_customer
FROM visit_cte;

-- average customer visits 7.1 times over the five months period.

-- 11. What are the customer count distribution by visits freqeuncy? 
WITH visit_cte AS(
SELECT 
	users.user_id,
    COUNT(DISTINCT events.visit_id) AS visits
FROM users
LEFT JOIN events
	ON users.cookie_id = events.cookie_id
GROUP BY users.user_id
)
SELECT
	visits AS visit_freqency,
    COUNT(DISTINCT user_id) AS customer_count
FROM visit_cte
GROUP BY visits;

-- 12.  How many purchases did each customer make averagely?
WITH purchase_cte AS(
SELECT 
	users.user_id,
    COUNT(DISTINCT events.visit_id) AS visits
FROM users
LEFT JOIN events
	ON users.cookie_id = events.cookie_id
WHERE event_type = 3
GROUP BY users.user_id
)
SELECT
	AVG(visits) AS avg_purchases_per_customer
FROM purchase_cte;

-- Averagely customers made 3.7 times of purchases over five months period.
