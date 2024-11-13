------------------------------
-- CASE STUDY #3 - FOODIE-FI--
------------------------------

-- Author: Ruthy Yao
-- Date: 08/11/2024
-- Tool used: MYSQL

-- 1. How many customers has Foodie-Fi ever had?
SELECT
	COUNT(DISTINCT customer_id ) AS total_customers
FROM subscriptions;


-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT 
    DATE_FORMAT(
		DATE_ADD(
			subscriptions.start_date, INTERVAL 1-DAYOFMONTH(subscriptions.start_date) DAY
            ),
		'%Y-%m'
    ) AS start_month,
    plans.plan_name,
    COUNT(subscriptions.customer_id) AS customer_count
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
WHERE plans.plan_name = 'trial'
GROUP BY start_month
ORDER BY start_month;
    

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.
SELECT 
	subscriptions.plan_id,
    plans.plan_name,
    COUNT(customer_id) AS subs_count
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
WHERE YEAR(subscriptions.start_date) > 2020
GROUP BY subscriptions.plan_id, plans.plan_name
ORDER BY subscriptions.plan_id;


-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
-- Method 1 - SUM by plans first and divid by total. Using nested query. 
WITH cte AS (
SELECT	
	plans.plan_name,
    COUNT(subscriptions.customer_id) AS customer_count
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
GROUP BY plans.plan_name
)
SELECT
	plan_name,
    customer_count,
    ROUND( 100 * customer_count / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS churn_rate -- subquery to work out the total subscriptions
FROM cte
WHERE plan_name = 'churn';

-- Method 2 - Label each row with 1 or 0 based on the plan name (churn) and sum all the values with 1 divided by total
SELECT
	SUM(CASE WHEN plans.plan_name = 'churn' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN plans.plan_name = 'churn' THEN 1 ELSE 0 END) *100 / COUNT(DISTINCT customer_id),1) AS churn_percentage
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id;
    

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- Method 1 - Using row_number
WITH cte AS (
SELECT
	subscriptions.customer_id,
    subscriptions.plan_id,
    plans.plan_name,
    ROW_NUMBER() OVER(PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) AS row_num
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
 )
SELECT 
	SUM(CASE WHEN row_num = 2 AND plan_id = 4 THEN 1 ELSE 0 END) AS churn_after_trial,
    ROUND(
		SUM(CASE WHEN row_num = 2 AND plan_id = 4 THEN 1 ELSE 0 END) * 100/
		COUNT(DISTINCT customer_id), 0) AS churn_percentage
FROM cte;
    
-- Method 2 - Using Lead Function
WITH cte AS (
	SELECT 
		subscriptions.customer_id,
		subscriptions.plan_id,
		plans.plan_name AS current_plan,
        LEAD(plans.plan_name) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) AS next_plan
	FROM subscriptions
	LEFT JOIN plans
		ON subscriptions.plan_id = plans.plan_id
  )
SELECT	
	COUNT(customer_id) AS churn_after_trial,
    ROUND(COUNT(customer_id) *100 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),0) AS churn_percentage
FROM cte
WHERE current_plan = 'trial' AND next_plan = 'churn';

 

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH cte AS (
	SELECT 
		subscriptions.customer_id,
		subscriptions.plan_id,
		plans.plan_name AS current_plan,
        LEAD(plans.plan_name) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) AS next_plan
	FROM subscriptions
	LEFT JOIN plans
		ON subscriptions.plan_id = plans.plan_id
 )
 SELECT
	next_plan AS post_trial_plan,
    COUNT(customer_id) AS count,
    ROUND(COUNT(customer_id) *100 / (SELECT COUNT(customer_id) FROM subscriptions WHERE plan_id = 0),1) AS percentage
from cte
WHERE current_plan = 'trial'
GROUP BY next_plan;

 
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH cte AS (	
    SELECT 
		subscriptions.customer_id,
		subscriptions.plan_id,
		plans.plan_name AS current_plan,
        LEAD(plans.plan_name) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) AS next_plan
	FROM subscriptions
		LEFT JOIN plans
			ON subscriptions.plan_id = plans.plan_id
	WHERE subscriptions.start_date <= '2020-12-31'
	)
SELECT 
    plan_id,
    current_plan,
    COUNT(customer_id) AS customer_count,
	ROUND(COUNT(customer_id) *100 / (SELECT COUNT(DISTINCT customer_ID) FROM subscriptions WHERE start_date <= '2020-12-31'),1) AS percentage 
FROM cte
WHERE next_plan IS NULL
GROUP BY plan_id, current_plan
ORDER BY plan_id;
    
    
-- 8. How many customers have upgraded to an annual plan in 2020?
WITH cte AS (
SELECT
	subscriptions.customer_id,
    subscriptions.plan_id,
    plans.plan_name AS current_plan,
    subscriptions.start_date AS current_start_date,
    LEAD(plans.plan_name) OVER(PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) AS next_plan,
    LEAD(subscriptions.start_date) OVER(PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) AS next_start_date
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
    )
SELECT
	next_plan,
    COUNT(customer_id) AS customer_count
FROM cte
WHERE next_plan = 'pro annual'
	AND YEAR(next_start_date) = 2020
GROUP BY next_plan;

SELECT 
	plans.plan_name AS current_plan,
    COUNT(subscriptions.customer_id) AS customer_count
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
WHERE plans.plan_name = 'pro annual'
	AND YEAR(subscriptions.start_date) = 2020;
    
-- Method 2 - we don't need to care what previous plan is. only look at customers who activate the pro annual in 2020
SELECT 
  plans.plan_name,
  COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions
JOIN plans ON subscriptions.plan_id = plans.plan_id
WHERE plans.plan_name = 'pro annual'
  AND YEAR(subscriptions.start_date) = 2020;
    
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- Note: all customers started with trial on their first join.  
---- Create two cte and join together using customer_id
WITH AnnualPlan AS (
SELECT
	subscriptions.customer_id,
    subscriptions.start_date AS annualplan_start_date
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id    
WHERE plans.plan_name = 'pro annual'
),
JoinDate AS (
SELECT
	subscriptions.customer_id,
    subscriptions.start_date AS join_date
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
WHERE plans.plan_name = 'trial'
 )
 SELECT 
	ROUND(AVG(DATEDIFF(annualplan_start_date,join_date)),0) AS avg_days_to_annual
FROM AnnualPlan
JOIN JoinDate
WHERE AnnualPlan.customer_id = JoinDate.customer_id;
    
    
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH RECURSIVE 
AnnualPlan AS (
SELECT
	subscriptions.customer_id,
    subscriptions.start_date AS annual_date
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id    
WHERE plans.plan_name = 'pro annual'
),
JoinDate AS (
SELECT
	subscriptions.customer_id,
    subscriptions.start_date AS join_date
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
WHERE plans.plan_name = 'trial'
 ),
DayDiff AS(
SELECT
	AnnualPlan.customer_id,
    DATEDIFF(annual_date,join_date) AS days_to_annual
FROM AnnualPlan
JOIN JoinDate
	ON AnnualPlan.customer_id = JoinDate.customer_id
),
days_bucket AS(
SELECT
	0 AS lower_lmt,
    30 AS upper_lmt
UNION ALL
SELECT
	upper_lmt + 1 AS lower_lmt,
    upper_lmt + 30 AS upper_lmt
FROM days_bucket
WHERE upper_lmt < 360
)

SELECT 
	days_bucket.lower_lmt,
    days_bucket.upper_lmt,
    COUNT(DayDiff.customer_id) AS num_of_customers
FROM days_bucket
LEFT JOIN DayDiff
	ON DayDiff.days_to_annual >lower_lmt AND DayDiff.days_to_annual <= upper_lmt
GROUP BY days_bucket.lower_lmt, days_bucket.upper_lmt
ORDER BY days_bucket.lower_lmt, days_bucket.upper_lmt;



-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? 
WITH cte AS(
SELECT
	customer_id,
    plan_id AS current_plan,
    start_date,
    LEAD (plan_id) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
FROM subscriptions
WHERE Year(start_date) = 2020
)
SELECT
	COUNT(customer_id) AS downgrade_count
FROM cte
WHERE current_plan = 2 AND next_plan = 1
GROUP BY current_plan;

-- Challenge Payment Question 
-- Create a payment table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
	-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
	-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
	-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
	-- once a customer churns they will no longer make payments

SELECT *
FROM subscriptions
WHERE customer_id IN (6,7);

-- Solution structure:
	-- Using revursive cte to create a table that list out all the monthly payment shedule 2020
		-- Use CASE statement to calculate the last date of their current plan.
        -- If the customer stay in the current plan until the end of 2020, the last date will be 2020-12-31.
        -- If the customer change the plan during the year, the last date will be last payment cycle date before he change to the next plan i.e the start_date + the month difference between the new plan start_date and the current plan start_date.
		-- Annual plan is not applicable.
	-- Select all the required columns to create a new table. 

CREATE TABLE payment
WITH RECURSIVE payment_schedule AS (
SELECT
	subscriptions.customer_id,
	subscriptions.plan_id,
    plans.plan_name,
    subscriptions.start_date AS payment_date,
	CASE WHEN LEAD(subscriptions.start_date) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) IS NULL THEN '2020-12-31'  -- if there is no next plan, the last_date would be the end of the year.
		 ELSE DATE_ADD(
					subscriptions.start_date,
                    INTERVAL TIMESTAMPDIFF(
						MONTH,
                        subscriptions.start_date,
                        LEAD(subscriptions.start_date) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date)
                        ) MONTH
                    )
	END AS last_date,  -- work out the last_date - the last day of the current plan.
    plans.price AS amount
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id
WHERE plans.plan_name != 'trial'  -- exclude trial as trial doesn't generate payments.
	AND YEAR(subscriptions.start_date) = 2020

UNION ALL
-- expand the table with one row for each payment month
SELECT 
	customer_id,
    plan_id,
    plan_name,
    DATE_ADD(payment_date, INTERVAL 1 MONTH) AS payment_date,
    last_date,
    amount
FROM payment_schedule
WHERE DATE_ADD(payment_date, INTERVAL 1 MONTH) <= last_date  -- stop adding new rows once the payment_date reach the limit - last_date
	AND plan_name != 'Pro Annual'  -- annual plan has only one payment for the year hence it doesn't need to expand.
)	
SELECT
	customer_id,
    plan_id,
    plan_name,
    payment_date,
    amount,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM payment_schedule
WHERE amount IS NOT NULL  -- exclude churns
ORDER BY customer_id;

SELECT * FROM PAYMENT LIMIT 10;	

-- Calculate monthly revenue and revenue growth.
WITH mth_rev AS(
SELECT 
	MONTH(payment_date) AS month,
    SUM(amount) AS revenue
FROM payment
GROUP by month
ORDER BY month
)
SELECT
	*,
    ROUND((revenue/LAG(revenue) OVER(ORDER BY month) - 1)*100,1) AS rev_growth_rate
from mth_rev;
