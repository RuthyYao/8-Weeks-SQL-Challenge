# Case Study #3 - Foodie-Fi
## C. Challenge Payment Question

The Foodie-Fi team wants to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

  * monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
  * upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
  * upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
  * once a customer churns they will no longer make payments

Example outputs for this table might look like the following:

| customer_id | plan_id | plan_name     | payment_date | amount | payment_order  |
|-------------|---------|---------------|--------------|--------|----------------|
| 1           | 1       | basic monthly | 2020-08-08   | 9.90   | 1              |
| 1           | 1       | basic monthly | 2020-09-08   | 9.90   | 2              |
| 1           | 1       | basic monthly | 2020-10-08   | 9.90   | 3              |
| 1           | 1       | basic monthly | 2020-11-08   | 9.90   | 4              |
| 1           | 1       | basic monthly | 2020-12-08   | 9.90   | 5              |
| 2           | 3       | pro annual    | 2020-09-27   | 199.00 | 1              |
| 13          | 1       | basic monthly | 2020-12-22   | 9.90   | 1              |
| 15          | 2       | pro monthly   | 2020-03-24   | 19.90  | 1              |
| 15          | 2       | pro monthly   | 2020-04-24   | 19.90  | 2              |
| 16          | 1       | basic monthly | 2020-06-07   | 9.90   | 1              |
| 16          | 1       | basic monthly | 2020-07-07   | 9.90   | 2              |
| 16          | 1       | basic monthly | 2020-08-07   | 9.90   | 3              |
| 16          | 1       | basic monthly | 2020-09-07   | 9.90   | 4              |
| 16          | 1       | basic monthly | 2020-10-07   | 9.90   | 5              |
| 16          | 3       | pro annual    | 2020-10-21   | 189.10 | 6              |
| 18          | 2       | pro monthly   | 2020-07-13   | 19.90  | 1              |
| 18          | 2       | pro monthly   | 2020-08-13   | 19.90  | 2              |
| 18          | 2       | pro monthly   | 2020-09-13   | 19.90  | 3              |
| 18          | 2       | pro monthly   | 2020-10-13   | 19.90  | 4              |

---
Solution structure:
* Using revursive cte to create a table that list out all the monthly payment shedule 2020
* Use CASE statement to calculate the last date of their current plan.
    * If the customer stay in the current plan until the end of 2020, the last date will be 2020-12-31.
    * If the customer change the plan during the year, the last date will be last payment cycle date before he change to the next plan i.e the start_date + the month difference between the new plan start_date and the current plan start_date.
    * Annual plan is not applicable.
* Select all the required columns to create a new table.

```TSQL
CREATE TABLE payment
WITH RECURSIVE payment_schedule AS (
SELECT
	subscriptions.customer_id,
	subscriptions.plan_id,
    plans.plan_name,
    subscriptions.start_date AS payment_date,
	CASE WHEN LEAD(subscriptions.start_date) OVER (PARTITION BY subscriptions.customer_id ORDER BY subscriptions.start_date) IS NULL
		THEN '2020-12-31'  -- if there is no next plan, the last_date would be the end of the year.
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
    amount,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM payment_schedule
WHERE DATE_ADD(payment_date, INTERVAL 1 MONTH) <= last_date  -- stop adding new rows once the payment_date reach the limit - last_date
    AND plan_name != 'Pro Annual'  -- annual plan has only one payment for the year hence it doesn't need to expand.
)
	
SELECT
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    amount
FROM payment_schedule
WHERE amount IS NOT NULL  -- exclude churns
ORDER BY customer_id;
```
Here is what the payment table looks like

```TSQL
SELECT * FROM payment LIMIT 10;
```
| customer_id | plan_id | plan_name     | payment_date | amount | payment_order  |
|-------------|---------|---------------|--------------|--------|----------------|
| 1           | 1       | basic monthly | 2020-08-08   | 9.90   | 1              |
| 1           | 1       | basic monthly | 2020-09-08   | 9.90   | 2              |
| 1           | 1       | basic monthly | 2020-10-08   | 9.90   | 3              |
| 1           | 1       | basic monthly | 2020-11-08   | 9.90   | 4              |
| 1           | 1       | basic monthly | 2020-12-08   | 9.90   | 5              |
| 2           | 3       | pro annual    | 2020-09-27   | 199.00 | 1              |
| 13          | 1       | basic monthly | 2020-12-22   | 9.90   | 1              |
| 15          | 2       | pro monthly   | 2020-03-24   | 19.90  | 1              |
| 15          | 2       | pro monthly   | 2020-04-24   | 19.90  | 2              |
| 16          | 1       | basic monthly | 2020-06-07   | 9.90   | 1              |

---
My solution for **[D. Outside The Box Questions](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/D.%20Outside%20The%20Box%20Questions.md)**.
