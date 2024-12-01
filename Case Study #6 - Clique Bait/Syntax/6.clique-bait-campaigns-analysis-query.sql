---------------------------------
-- CASE STUDY #3 - Clique Bait --
---------------------------------

-- Author: Ruthy Yao
-- Date: 21/11/2024
-- Tool used: MYSQL

-- Part III - Campaigns Analysis
-- Generate a table that has 1 single row for every unique `visit_id` record and has the following columns:
	-- user_id
	-- visit_id
	-- visit_start_time: the earliest event_time for each visit
	-- page_views: count of page views for each visit
	-- cart_adds: count of product cart add events for each visit
	-- purchase: 1/0 flag if a purchase event exists for each visit
	-- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
	-- impression: count of ad impressions for each visit
	-- click: count of ad clicks for each visit
	-- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

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

SELECT * FROM campaign_summary;

-- Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

-- Some ideas you might want to investigate further include:
	-- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
	-- Does clicking on an impression lead to higher purchase rates?
	-- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
	-- What metrics can you use to quantify the success or failure of each campaign compared to each other?

--	Solution Structure
	-- Create two customer groups:
		-- Group 1 : Received impressions
        -- Group 2: didn't received impressions.
	-- Under Group 1, create two sub-groups.
		-- Sub-group 1: received impressions and also click the impressions.
        -- sub-group 2: received impressions but didn't click the impressions.
	-- Create a performance metrics for each group and compare with each other.
		-- Performance metrics includes the page_views per user, page_views per visit, average number of products add to cart, purchase rate. 

-- Calculate the number of users who received impressions (impression > 0);
-- Calculate the key performance metrics for this user group, including the average page views per user, average page views per visit, average number of products added to cart per visit, purchase rate.
SELECT 
	COUNT(DISTINCT user_id) AS users_count,
    COUNT(DISTINCT visit_id) AS visits
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0;

SELECT
	SUM(page_views) / COUNT(DISTINCT user_id) page_views_per_user,
    SUM(page_views) / COUNT(*) AS page_views_per_visit,
    AVG(cart_adds) AS cart_adds_per_visit,
    ROUND(100*AVG(purchase),1) AS purchase_rate
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0; 
 
-- Calculate the number of users who received impressions and click the impression - impression > 0 AND click > 0;
-- Calculate the key performance metrics for this user group, including the average page views per user, average page views per visit, average number of products added to cart per visit, purchase rate.
 SELECT 
	COUNT(DISTINCT user_id) AS users_count,
    COUNT(DISTINCT visit_id) AS visits
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0
    AND click > 0;

SET @received_and_clicked_users = 367;
SET	@received_and_clicked_visits = 599;

SELECT 
    SUM(page_views) / @received_and_clicked_users AS page_views_per_user,
    SUM(page_views) / @received_and_clicked_visits AS page_views_per_visit,
    AVG(cart_adds) AS cart_adds_per_visit,
    ROUND(AVG(purchase)*100,1) AS purchase_rate
FROM campaign_summary
WHERE campaign_name IS NOT NULL
	AND impression > 0
    AND click > 0;
    

-- Calculate the number of users who received impressions but didn't click the impression 
	-- use subquery to define the user group who received and click the impression.
    -- users who are not in the above group are those who received but not clicked the impression.
-- Calculate the key performance metrics for this user group, including the average page views per user, average page views per visit, average number of products added to cart per visit, purchase rate.    
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

SET @received_not_clicked_users = 50;
SET	@received_not_clicked_visits = 61;

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


-- Calculate the number of users who didn't receive impressions
	-- Note: We can't use impression = 0 as the condition to filter the data as a user could have visited the website for twice during the campaign but recieved the impression only once. In this case, when you count the users using the condition of impression is 0, this customer will be incorrectly included in this group.
		-- The right way to use subquery to create a group who received impression; users who do not fall into this group will be the group who didn't receive impressions.
-- Calculate the key performance metrics for this user group, including the average page views per user, average page views per visit, average number of products added to cart per visit, purchase rate.
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

SET @not_received_users = 56;
SET	@not_received_visits = 268;

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


-- Compare the performance of the three campaigns.
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

