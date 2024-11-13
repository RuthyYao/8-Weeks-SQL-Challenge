# Case Study #3 - Foodie-Fi
## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?
```TSQL
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;
```
| total_customers |
|-----------------|
| 1000            |

---
### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
```TSQL
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
```

| start_month   | plan_name | customer_count|
|---------------|-----------|---------------|
| 2020-01       |trial      |	88          |
| 2020-02       |trial      |	68          |
| 2020-03	    |trial      |	94          |
| 2020-04	    |trial      |	81          |
| 2020-05	    |trial      |	88          |
| 2020-06	    |trial      |	79          |
| 2020-07	    |trial      |	89          |
| 2020-08	    |trial      |	88          |
| 2020-09	    |trial      |	87          |
| 2020-10	    |trial      |	79          |
| 2020-11	    |trial      |	75          |
| 2020-12	    |trial      |	84          |

---
### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?
```TSQL
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
```
| plan_id | plan_name    | subs_count  |
|--------|---------------|-------------|
| 1      | basic monthly | 8           |
| 2      | pro monthly   | 60          |     
| 3      | pro annual    | 63          |
| 4      | churn         | 71          |

---
### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```TSQL
-- Label each row with 1 or 0 based on the plan name (churn) and sum all the values with 1 divided by total
SELECT
	SUM(CASE WHEN plans.plan_name = 'churn' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN plans.plan_name = 'churn' THEN 1 ELSE 0 END) *100 / COUNT(DISTINCT customer_id),1) AS churn_percentage
FROM subscriptions
LEFT JOIN plans
	ON subscriptions.plan_id = plans.plan_id;
```
| churn_count | churn_percentage   |
|-------------|--------------------|
| 307         | 30.7               |

---
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```TSQL
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
```
| churn_after_trial | churn_percentage |
|-------------------|------------------|
| 92                | 9                |

---
### 6. What is the number and percentage of customer plans after their initial free trial?
```TSQL
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
```
| post_trial_plan | count | percentage  |
|-----------------|-------|-------------|
| basic monthly   | 546        | 54.6   |
| pro annual      | 37         | 3.7    |
| pro monthly     | 325        | 32.5   |
| churn           | 92         | 9.2    |

---
### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```TSQL
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
```
| plan_id | plan_name     | customer_count | percentage  |
|---------|---------------|-----------|------------------|
| 0       | trial         | 19        | 1.9              |
| 1       | basic monthly | 224       | 22.4             |
| 2       | pro monthly   | 326       | 32.6             |
| 3       | pro annual    | 195       | 19.5             |
| 4       | churn         | 235       | 23.6             |

---
### 8. How many customers have upgraded to an annual plan in 2020?
```TSQL
SELECT 
  plans.plan_name,
  COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions
JOIN plans ON subscriptions.plan_id = plans.plan_id
WHERE plans.plan_name = 'pro annual'
  AND YEAR(subscriptions.start_date) = 2020;
```
| plan_name  | customer_count  |
|------------|-----------------|
| pro annual |195              |

---
### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```TSQL
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
```
| avg_days_to_annual  |
|---------------------|
| 105                 |

On average, it takes 105 days for a customer to an annual plan from the day they join Foodie-Fi.

---
### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)?
Solution structure: 
* Utilize 2 CTEs in the previous question: ```JoinDate``` and ```AnnualPlan``` to calculate the number of days between ```join_date (trial_date)``` and ```annual_date```, then put that to new CTE named ```DayDiff```
* Create a recursive CTE named ```days_bucket``` to generate 30-days periods (i.e. 0-30 days, 31-60 days etc)
* Left join from ```days_bucket``` with ```DayDiff``` 
    
```TSQL
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
```
| lower_lmt    | upper_lmt  | customer_count  |
|--------------|------------|-----------------|
| 0            | 30         | 49              |
| 31           | 60         | 24              |
| 61           | 90         | 34              |
| 91           | 120        | 35              |
| 121          | 150        | 42              |
| 151          | 180        | 36              |
| 181          | 210        | 26              |
| 211          | 240        | 4               |
| 241          | 270        | 5               |
| 271          | 300        | 1               |
| 301          | 330        | 1               |
| 331          | 360        | 1               |

---
### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```TSQL
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
```
| downgrade_count |
|-----------------|

There were no customers downgrading from a pro monthly to a basic monthly plan in 2020.

---
My solution for **[C. Challenge Payment Question](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/C.%20Challenge%20Payment%20Question.md)**.
