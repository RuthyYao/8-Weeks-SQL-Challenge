# Case Study #6 - Clique Bait
## A. Digital Analysis

### 1. How many users are there?

```SQL
SELECT 
	COUNT(DISTINCT user_id) AS customer_count
FROM users;
```

| customer_count |
|----------------|
| 500            |


### 2. How many cookies does each user have on average?

```SQL
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
```

| cookies_per_customer |
|----------------------|
| 3.5640               |


### 3. What is the unique number of visits by all users per month?

```SQL
SELECT 
    DATE_FORMAT(event_time,'%Y-%m') As period,
    COUNT(DISTINCT visit_id) AS visits
FROM events
GROUP BY period;
```

| period  | visits |
|---------|--------|
| 2020-01 | 876    |
| 2020-02 | 1488   |
| 2020-03 | 916    |
| 2020-04 | 248    |
| 2020-05 | 36     |

### 4. What is the number of events for each event type?

```SQL
SELECT
    e.event_type,
    ei.event_name,
    COUNT(DISTINCT visit_id) AS event_count
FROM events AS e
LEFT JOIN event_Identifier AS ei
    ON e.event_type = ei.event_type
GROUP BY e.event_type, ei.event_name;
```
| event_type | event_name    | event_count |
|------------|---------------|-------------|
| 1          | Page View     | 3564        |
| 2          | Add to Cart   | 2510        |
| 3          | Purchase      | 1777        |
| 4          | Ad Impression | 876         |
| 5          | Ad Click      | 702         |

### Breakdown the number of events by months

```SQL
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
```

| period  | page_view | add_to_cart | purchase | impression | clicks |
|---------|-----------|-------------|----------|------------|--------|
| 2020-01 | 876       | 614         | 430      | 216        | 173    |
| 2020-02 | 1488      | 1054        | 744      | 371        | 291    |
| 2020-03 | 916       | 635         | 448      | 214        | 178    |
| 2020-04 | 248       | 177         | 134      | 63         | 48     |
| 2020-05 | 36        | 30          | 21       | 12         | 12     |

Jan to March has more website activities than April and May. This was because Clique Bait run three campaigns in Q1. 


### 5. What is the percentage of visits which have a purchase event?

```SQL
SELECT
	ROUND(COUNT(DISTINCT visit_id) * 100 / (SELECT COUNT(DISTINCT visit_id) FROM events),1) AS purchase_percentage
FROM events AS e
LEFT JOIN event_Identifier AS ei
	ON e.event_type = ei.event_type
WHERE event_name = 'Purchase';
```

| purchase_percentage |
|---------------------|
| 49.9                |

About half of the visits lead to a purchase. 

### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

```SQL
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
```

| checkout_page_no_purchase |
|---------------------------|
| 15.50                     |


```SQL
- Method 2 - Break the question into two steps.
	-- Step 1 - Create a cte and use CASE statement to tag each event on a page visit with 1 or 0. 
		 -- visit-checkout (the denomitor): Tag 1 for event_type = 1 (Page View) and page_id = 12 (checkout). These are the events where users visit the checkout page; "0" stands for event_type = 3(Purchase). All else '0'.
     -- Made-purchase (The numerator): Tag 1 for event_type = 3 (Purchase). These are users who make a purchase. All else '0'.
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
```

| purchases | checkout | checkout_page_no_purchase |
|-----------|----------|---------------------------|
| 1777      | 2103     | 0.1550                    |

15.5% of the visits abandoned the checkout.

### 7. What are the top 3 product pages by number of views?

```SQL
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
```

| page_name      | num_views |
|----------------|-----------|
| Oyster         | 1568      |
| Crab           | 1564      |
| Russian Caviar | 1563      |


### 8. What is the number of views and cart adds for each product category?

```SQL
SELECT
	p.product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS num_views,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS num_add_cart
FROM events AS e
LEFT JOIN page_hierarchy AS p
	ON	e.page_id = p.page_id
WHERE product_category IS NOT NULL
GROUP BY p.product_category;
```

| product_category | num_views | num_add_cart |
|------------------|-----------|--------------|
| Luxury           | 3032      | 1870         |
| Shellfish        | 6204      | 3792         |
| Fish             | 4633      | 2789         |


### 9. What are the top 3 products by purchases?

```SQL
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
```

| page_name | product_category | purchases |
|-----------|------------------|-----------|
| Lobster   | Shellfish        | 754       |
| Oyster    | Shellfish        | 726       |
| Crab      | Shellfish        | 719       |

