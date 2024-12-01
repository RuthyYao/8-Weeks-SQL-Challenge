# Case Study #6 - Clique Bait
## B. PRoduct Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

* How many times was each product viewed?
* How many times was each product added to cart?
* How many times was each product added to a cart but not purchased (abandoned)?
* How many times was each product purchased?

### Solution

The output table will look like this


| **Column   Name** | **Description**                                                         |
|-------------------|-------------------------------------------------------------------------|
| product_id        | Id of each product                                                      |
| page_name         | Name of each product                                                    |
| product_category  | Category of each product                                                |
| views             | Number of times a product page was viewed                               |
| add_to_cart       | Number of times a product was add to cart                               |
| abandoned         | Number of times a product was add to cart but not purchased (abandoned) |
| purchases         | Number of times a product was purchased                                 |


Solution Structure
* Create a CTE `prod_view`: calculate the number of views and number of cart_adds for each product using CASE() and SUM()
* Create a CTE `prod_abandon`: calculate the number of abandoned products (Note: use the solution for Q9 in the Digital Analysis section. Only need to replace IN by NOT IN in the subquery).
* Create a CTE `prod_purchased`: calculate the number of purchased products (solution for Q9 in the Digital Analysis section)
* JOIN the above three CTEs using `product_id`, `product_name` and `product_category` of each product
* Store the result in a temporary table product_summary for further analysis

```SQL
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
```


| product_id | page_name      | product_category | views | add_to_cart | abandoned | purchases |
|------------|----------------|------------------|-------|-------------|-----------|-----------|
| 1          | Salmon         | Fish             | 1559  | 938         | 227       | 711       |
| 2          | Kingfish       | Fish             | 1559  | 920         | 213       | 707       |
| 3          | Tuna           | Fish             | 1515  | 931         | 234       | 697       |
| 4          | Russian Caviar | Luxury           | 1563  | 946         | 249       | 697       |
| 5          | Black Truffle  | Luxury           | 1469  | 924         | 217       | 707       |
| 6          | Abalone        | Shellfish        | 1525  | 932         | 233       | 699       |
| 7          | Lobster        | Shellfish        | 1547  | 968         | 214       | 754       |
| 8          | Crab           | Shellfish        | 1564  | 949         | 230       | 719       |
| 9          | Oyster         | Shellfish        | 1568  | 943         | 217       | 726       |


#### Convert the value in the above table to percentage.
```
SELECT
    page_name,
    product_category,
    ROUND(100*views/views,1) AS views,
    ROUND(100*add_to_cart/views,1) AS add_to_cart_rate,
    ROUND(100*purchases/views,1) AS purchase_rate,
    ROUND(100*abandoned/views,1) AS fallout_rate
FROM product_summary
ORDER BY fallout_rate DESC;
```

| page_name    | product_category | views | add_to_cart_rate | purchase_rate | fallout_rate |
|----------------|------------------|-------|------------------|---------------|--------------|
| Russian Caviar | Luxury           | 100.0 | 60.5             | 44.6          | 15.9         |
| Tuna           | Fish             | 100.0 | 61.5             | 46.0          | 15.4         |
| Abalone        | Shellfish        | 100.0 | 61.1             | 45.8          | 15.3         |
| Black Truffle  | Luxury           | 100.0 | 62.9             | 48.1          | 14.8         |
| Crab           | Shellfish        | 100.0 | 60.7             | 46.0          | 14.7         |
| Salmon         | Fish             | 100.0 | 60.2             | 45.6          | 14.6         |
| Lobster        | Shellfish        | 100.0 | 62.6             | 48.7          | 13.8         |
| Oyster         | Shellfish        | 100.0 | 60.1             | 46.3          | 13.8         |
| Kingfish       | Fish             | 100.0 | 59.0             | 45.3          | 13.7         |

#### Create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

```SQL
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
	(
	SELECT
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
```

| product_category | views | add_to_cart | abandoned | purchases |
|------------------|-------|-------------|-----------|-----------|
| Luxury           | 3032  | 1870        | 466       | 1404      |
| Shellfish        | 6204  | 3792        | 894       | 2898      |
| Fish             | 4633  | 2789        | 674       | 2115      |

#### Convert the value in the above table to percentage.

```SQL
SELECT
    product_category,
    ROUND(100*views/views,1) AS views,
    ROUND(100*add_to_cart/views,1) AS add_to_cart_rate,
    ROUND(100*purchases/views,1) AS purchase_rate,
    ROUND(100*abandoned/views,1) AS fallout_rate
FROM category_summary;
```

| product_category | views | add_to_cart_rate | purchase_rate | fallout_rate |
|------------------|-------|------------------|---------------|--------------|
| Luxury           | 100.0 | 61.7             | 46.3          | 15.4         |
| Shellfish        | 100.0 | 61.1             | 46.7          | 14.4         |
| Fish             | 100.0 | 60.2             | 45.7          | 14.5         |

Luxury products has higher fallout rate than the other two categories.

Use your 2 new output tables - answer the following questions:

### 1. Which product had the most views, cart adds and purchases?

```SQL
SELECT
	(SELECT page_name FROM product_summary ORDER BY views DESC LIMIT 1) AS most_view,
	(SELECT page_name FROM product_summary ORDER BY add_to_cart DESC LIMIT 1) AS most_add_to_cart,
        (SELECT page_name FROM product_summary ORDER BY purchases DESC LIMIT 1) AS most_purchases;
 ```

| # most_view | most_add_to_cart | most_purchases |
|-------------|------------------|----------------|
| Oyster      | Lobster          | Lobster        |

   
### 2. Which product was most likely to be abandoned?

```SQL
SELECT
	*
FROM product_summary
ORDER BY abandoned DESC
LIMIT 1;
```

| # product_id | page_name      | product_category | views | add_to_cart | abandoned | purchases |
|--------------|----------------|------------------|-------|-------------|-----------|-----------|
| 4            | Russian Caviar | Luxury           | 1563  | 946         | 249       | 697       |

### 3. Which product had the highest view to purchase percentage?

```SQL
SELECT
	page_name,
	ROUND(100*purchases / views,2) AS conversion_rate
FROM product_summary
ORDER BY conversion_rate DESC
LIMIT 1;
```

| page_name | conversion_rate |
|-----------|-----------------|
| Lobster   | 48.74           |

### 4.  What is the average conversion rate from view to cart add?

```SQL
SELECT 
    ROUND(100*AVG(add_to_cart / views),2) AS conversion_rate
FROM product_summary;
```

| conversion_rate |
|-----------------|
| 60.95           |

### 5.What is the average conversion rate from cart add to purchase?

```SQL
SELECT 
    ROUND(100*AVG(purchases / add_to_cart),2) AS conversion_rate
FROM product_summary;
```

| conversion_rate |
|-----------------|
| 75.93           |
