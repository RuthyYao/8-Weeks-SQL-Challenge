# Case Study #3 - Foodie Fi
<p align="center">
<img src="https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/images/3.png" align="center" width="400" height="400" >
  
## Table of Contents
* [Bussiness Task](#bussiness-task)
* [Entity Relationship Diagram](#entity-relationship-diagram)
* [Case Study Questions](#case-study-questions)
* [My Solution](#my-solution)

---
## Bussiness Task
Foodie-Fi started the video streaming service that only had food related content a year ago. They sell monthly and annual sbuscription plans, giving their customer unlimited on-demand access to exclusively food related vedios from around the world. The management team wants to review the product performance and would like to rely on data to inform their future investment decisions on new product features, customer acquisition and retention and other business growth strategies.

---
## Entity Relationship Diagram
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/e3.PNG" align="center" width="500" height="250" >

---
## Case Study Questions
### A. Customer Journey

* Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

| customer_id | plan_id | start_date | plan_name     | price   |
|-------------|---------|------------|---------------|---------|
| 1           | 0       | 2020-08-01 | trial         | 0.00    |
| 1           | 1       | 2020-08-08 | basic monthly | 9.90    |
| 2           | 0       | 2020-09-20 | trial         | 0.00    |
| 2           | 3       | 2020-09-27 | pro annual    | 199.00  |
| 11          | 0       | 2020-11-19 | trial         | 0.00    |
| 11          | 4       | 2020-11-26 | churn         | NULL    |
| 13          | 0       | 2020-12-15 | trial         | 0.00    |
| 13          | 1       | 2020-12-22 | basic monthly | 9.90    |
| 13          | 2       | 2021-03-29 | pro monthly   | 19.90   |
| 15          | 0       | 2020-03-17 | trial         | 0.00    |
| 15          | 2       | 2020-03-24 | pro monthly   | 19.90   |
| 15          | 4       | 2020-04-29 | churn         | NULL    |
| 16          | 0       | 2020-05-31 | trial         | 0.00    |
| 16          | 1       | 2020-06-07 | basic monthly | 9.90    |
| 16          | 3       | 2020-10-21 | pro annual    | 199.00  |
| 18          | 0       | 2020-07-06 | trial         | 0.00    |
| 18          | 2       | 2020-07-13 | pro monthly   | 19.90   |
| 19          | 0       | 2020-06-22 | trial         | 0.00    |
| 19          | 2       | 2020-06-29 | pro monthly   | 19.90   |

View my solution [HERE](#Solution/A.%20Customer%20Journey.md).

---
### B. Data Analysis Questions
View my solution [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/B.%20Data%20Analysis%20Questions.md).

1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

---
### C. Challenge Payment Question
View my solution [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/C.%20Challenge%20Payment%20Question.md).

The Foodie-Fi team wants to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
  * monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
  * upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
  * upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
  * once a customer churns they will no longer make payments

---
### D. Outside The Box Questions 
View my solution [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/D.%20Outside%20The%20Box%20Questions.md).

1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

---
## 🚀 My Solution
* View the complete syntax [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%233%20-%20Foodie-Fi/Syntax).
* View the result and explanation [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution).
