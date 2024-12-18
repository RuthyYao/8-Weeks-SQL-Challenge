# Case Study #6 - Clique Bait
## C. Campaign Analysis

### 1. Generate a table that has 1 single row for every unique visit_id record and has the following columns:

* user_id
* visit_id
* visit_start_time: the earliest event_time for each visit
* page_views: count of page views for each visit
* cart_adds: count of product cart add events for each visit
* purchase: 1/0 flag if a purchase event exists for each visit
* campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
* impression: count of ad impressions for each visit
* click: count of ad clicks for each visit
* (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

### Solution

* Join from `users` to `events` using 'cookie_id' as the join key.
* Join `evnet_identifier` with `evnets` to display `event_name`.
* Join 'campaign_identifier` to 'events` to display `campaign_name ` using  `event_time` as the join key (`event_time` between campaign `start_time` and `end_time`)
* Use `min()` to find the earliest `event_time` for each visit as the visit_start_time
* Use `sum()` and `CASE` statement to calculate the number of `page_views`, `cart_adds  , `impression` and `click` for each `visit_id`.
* To get a comma separated list of products added to cart sorted by sequence_number
  * Use `case` statement to select `Add to Cart` events;
  * Use `group_concat()` to put the products in a list, seperating the products by comma ordered by 'squence_number`
* Store the result in a temporary table campaign_summary for further analysis.

```SQL
CREATE TABLE campaign_summary
SELECT
	users.user_id,
	e.visit_id,
    MIN(e.event_time) AS visit_start_time,
    SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
	SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
    c.campaign_name,
	SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
    SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click,
    GROUP_CONCAT(CASE WHEN ei.event_name = 'Add to Cart' THEN page_name ELSE NULL END ORDER BY e.sequence_number) AS cart_products
FROM events AS e
LEFT JOIN users
	ON e.cookie_id = users.cookie_id
LEFT JOIN event_identifier AS ei
	ON e.event_type = ei.event_type
LEFT JOIN page_hierarchy AS p
	ON e.page_id = p.page_id
LEFT JOIN campaign_identifier AS c
	ON e.event_time BETWEEN c.start_date AND c.end_date
GROUP BY users.user_id, e.visit_id, c.campaign_name;

SELECT * FROM campaign_summary LIMIT 10;
```

| user_id | visit_id | visit_start_time    | page_views | cart_adds | purchase | campaign_name                     | impression | click | cart_products                                                        |
|---------|----------|---------------------|------------|-----------|----------|-----------------------------------|------------|-------|----------------------------------------------------------------------|
| 1       | 02a5d5   | 2020-02-26 16:57:26 | 4          | 0         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | null                                                                 |
| 1       | 0826dc   | 2020-02-26 05:58:38 | 1          | 0         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | null                                                                 |
| 1       | 0fc437   | 2020-02-04 17:49:50 | 10         | 6         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Tuna,Russian Caviar,Black Truffle,Abalone,Crab,Oyster                |
| 1       | 30b94d   | 2020-03-15 13:12:54 | 9          | 7         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon,Kingfish,Tuna,Russian Caviar,Abalone,Lobster,Crab             |
| 1       | 41355d   | 2020-03-25 00:11:18 | 6          | 1         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Lobster                                                              |
| 1       | ccf365   | 2020-02-04 19:16:09 | 7          | 3         | 1        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Lobster,Crab,Oyster                                                  |
| 1       | eaffde   | 2020-03-25 20:06:32 | 10         | 8         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon,Tuna,Russian Caviar,Black Truffle,Abalone,Lobster,Crab,Oyster |
| 1       | f7c798   | 2020-03-15 02:23:26 | 9          | 3         | 1        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Russian Caviar,Crab,Oyster                                           |
| 2       | 0635fb   | 2020-02-16 06:42:43 | 9          | 4         | 1        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Salmon,Kingfish,Abalone,Crab                                         |
| 2       | 1f1198   | 2020-02-01 21:51:55 | 1          | 0         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | null                                                                 |


### 2. Use the subsequent dataset to generate at least 5 insights for the Clique Bait team 

Some ideas you might want to investigate further include:

* Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
* Does clicking on an impression lead to higher purchase rates?
* What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
* What metrics can you use to quantify the success or failure of each campaign compared to eachother?


### Solution 

* Create two customer groups:
	* Group 1: Received impression.
	* Group 2: Didn't receive impression.
* Under Group 1, create two sub-groups:
  	* Sub-group 1: received impressions and also click the impressions.
  	* Sub-group 2: received impressions but didn't click the impressions.
* Create a performance metrics for each group and compare the metrics between the customer groups.
 	* Performance metrics includes the `page_views per user`, `page_views per visit`, `average number of products add to cart`, `purchase rate`. 

##### Customer Group 1 - Received impression (impression > 0)

The number of customer and the visit count in this group.

```
SELECT 
	COUNT(DISTINCT user_id) AS users_count,
    COUNT(DISTINCT visit_id) AS visits
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0;
```

| users_count | visits |
|-------------|--------|
| 417         | 747    |


Calculate the key performance metrics for this user group.

```
SELECT
    SUM(page_views) / COUNT(DISTINCT user_id) page_views_per_user,
    SUM(page_views) / COUNT(*) AS page_views_per_visit,
    AVG(cart_adds) AS cart_adds_per_visit,
    ROUND(100*AVG(purchase),1) AS purchase_rate
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0; 
```

| page_views_per_user | page_views_per_visit | cart_adds_per_visit | purchase_rate |
|---------------------|----------------------|---------------------|---------------|
| 15.3213             | 8.5529               | 5.0482              | 85.0          |

##### Customer Sub-group 1 - Received impressions and clicked the impression (impression > 0 AND click > 0)
 The number of customers and visits in this group.
 ```
 SELECT 
	COUNT(DISTINCT user_id) AS users_count,
    	COUNT(DISTINCT visit_id) AS visits
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0
    	AND click > 0;
```

| users_count | visits |
|-------------|--------|
| 367         | 599    |

The performance metrics of this customer group.
```
SET @received_and_clicked_users = 367;
SET @received_and_clicked_visits = 599;

SELECT 
    SUM(page_views) / @received_and_clicked_users AS page_views_per_user,
    SUM(page_views) / @received_and_clicked_visits AS page_views_per_visit,
    AVG(cart_adds) AS cart_adds_per_visit,
    ROUND(AVG(purchase)*100,1) AS purchase_rate
FROM campaign_summary
WHERE campaign_name IS NOT NULL
 	AND impression > 0
    	AND click > 0;
```

| page_views_per_user | page_views_per_visit | cart_adds_per_visit | purchase_rate |
|---------------------|----------------------|---------------------|---------------|
| 14.8038             | 9.0701               | 5.7162              | 89.6          |



##### Customer Sub-group 2 - Received impressions but didn't click the impression
 The number of customers and visits in this group.

```
Solution structure:
    -- use subquery to define the user group who received and click the impression.
    -- users who are not in the above group are those who received but not clicked the impression.
 SELECT 
	COUNT(DISTINCT user_id) AS users_count,
    	COUNT(DISTINCT visit_id) AS visits
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0
    	AND user_id NOT IN
    (
    SELECT
	user_id
	FROM campaign_summary 
    WHERE campaign_name IS NOT NULL
	AND impression > 0
        AND click > 0);
```

| users_count | visits |
|-------------|--------|
| 50          | 61     |


The performance metrics for this customer group.
```
SET @received_not_clicked_users = 50;
SET @received_not_clicked_visits = 61;

SELECT 
    SUM(page_views) / @received_not_clicked_users AS page_views_per_user,
    SUM(page_views) / @received_not_clicked_visits AS page_views_per_visit,
    AVG(cart_adds) AS cart_adds_per_visit,
    ROUND(AVG(purchase)*100,1) AS purchase_rate
FROM campaign_summary
WHERE campaign_name IS NOT NULL
    AND impression > 0
    AND user_id NOT IN
    (
    SELECT
        user_id
	FROM campaign_summary 
    WHERE campaign_name IS NOT NULL
	AND impression > 0
        AND click > 0);
```

| page_views_per_user | page_views_per_visit | cart_adds_per_visit | purchase_rate |
|---------------------|----------------------|---------------------|---------------|
| 7.6200              | 6.2459               | 2.2295              | 65.6          |


##### Customer Group 2 - didn't receive impressions

The number of customers in this group.
```
solution structure:
-- Note: We can't use impression = 0 as the condition to filter the data as a user could have visited the website for twice during the campaign but recieved the impression only once. In this case, when you count the users using the condition of impression is 0, this customer will be counted in which is incorrect.
-- The right way is to use subquery to create a group who received impression; users who do not fall into this group will be the group who didn't receive impressions.

SELECT 
      COUNT(DISTINCT user_id) AS users_count,	  
      COUNT(DISTINCT visit_id) AS visits
FROM campaign_summary
WHERE campaign_name IS NOT NULL
      AND user_id NOT IN
    (
    SELECT
	user_id 
	FROM campaign_summary
    WHERE impression > 0
	AND campaign_name IS NOT NULL
    );
```

| users_count | visits |
|-------------|--------|
| 78          | 368    |


The performance metrics for this customer group.

```
SET @not_received_users = 56;
SET @not_received_visits = 268;

SELECT 
    SUM(page_views) / @not_received_users AS page_views_per_user,
    SUM(page_views) / @not_received_visits AS page_views_per_visit,
    AVG(cart_adds) AS cart_adds,
    ROUND(AVG(purchase)*100,1) AS purchase_rate
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND user_id NOT IN
    (
    SELECT
	user_id 
	FROM campaign_summary
    WHERE impression > 0
	AND campaign_name IS NOT NULL
    );
```

| page_views_per_user | page_views_per_visit | cart_adds | purchase_rate |
|---------------------|----------------------|-----------|---------------|
| 26.4821             | 5.5336               | 1.1848    | 27.2          |


Now put all the four customer groups together.


| **Customer Group**                     | **user_count** | **visits** | **page_views_per_user** | **page_views_per_visit** | **cart_adds** | **purchase_rate %** |
|----------------------------------------|----------------|------------|-------------------------|--------------------------|---------------|---------------------|
| Received impressions                   | 417            | 747        | 15.3213                 | 8.5529                   | 5.0482        | 85                  |
| Received impressions and clicked       | 367            | 599        | 14.8038                 | 9.0701                   | 5.7162        | 89.6                |
| Received impressions but didn't  click | 50             | 61         | 7.62                    | 6.2459                   | 2.2295        | 65.6                |
| Didn't receive impressions             | 56             | 268        | 26.4821                 | 5.5336                   | 1.1848        | 27.2                |


* Receiving impression drove 3 more page views for each visit (8.6 vs 5.5 page_views) and 3.8 more products added to cart (average 5 cart-add vs 1.2). The purchase conversion rate is substantially higher in customer group who received impressions (85% vs 27.2%). 

* Customers who clicked the ad sees higher page views than customer who didn't click the ad (9.1 vs 6.2 page views per visit). Those who click the ad also has higher purchase rate than customer who didn't click the ad (89.6% vs 65.6%). Also note 88% of the users who received the promotion clicked the promotion ad with only 12% didn't click. 


### 3. Compare the performance between the three campaigns.

I'll use `ad click rate` and `products purchase rate` to quantify the successs or failure of each campaign. 

```SQL
WITH campaign_performance AS(
SELECT
    campaign_name,
    SUM(impression) AS no_of_impressions,
    SUM(click) AS no_of_clicks,
    SUM(click) / SUM(impression) AS click_rate
FROM campaign_summary
WHERE campaign_name IS NOT NULL
GROUP BY campaign_name
),
campaign_purchase_rate AS(
SELECT 
    campaign_name,
    AVG(purchase) AS purchase_rate
FROM campaign_summary
WHERE impression > 0
    AND campaign_name IS NOT NULL
GROUP BY campaign_name
)
SELECT
    campaign_performance.*,
    campaign_purchase_rate.purchase_rate
FROM campaign_performance
LEFT JOIN campaign_purchase_rate
    ON campaign_performance.campaign_name = campaign_purchase_rate.campaign_name;
```


| campaign_name                     | no_of_impressions | no_of_clicks | click_rate | purchase_rate |
|-----------------------------------|-------------------|--------------|------------|---------------|
| Half Off - Treat Your Shellf(ish) | 578               | 463          | 0.8010     | 0.8529        |
| 25% Off - Living The Lux Life     | 104               | 81           | 0.7788     | 0.8365        |
| BOGOF - Fishing For Compliments   | 65                | 55           | 0.8462     | 0.8462        |


* Half Off campaign has the broadest reach of users and achieved the highest purchase rate. 
* BOGOF had the highest click rate. The purchase rate is also very impressive. Clique Bait could consider run this campaign in a larger scale in future.
* 25% Off campaign has the lowest click rate among the three campaigns. However the purchase rate is not too far off compared with the other two campaigns. 


