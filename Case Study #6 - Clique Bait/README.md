# Case Study #6 - Clique Bait
<p align="center">
<img src="https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/images/6.png" align="center" width="400" height="400" >
  
## Table of Contents
* [Bussiness Task](#bussiness-task)
* [Entity Relationship Diagram](#entity-relationship-diagram)
* [Case Study Questions](#case-study-questions)
* [My Solution](#my-solution)

---
## Bussiness Task
Clique Bait, an online seafood shop wants to gain detailed insights into their store and customers. In particular, the management team would like to track their customer journeys and optimize marketing strategies.

---
## Entity Relationship Diagram
<p align="center">
<img src="https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/images/case-study-6-erd.PNG" align="center" width="500" height="250" >

---
## Case Study Questions
### A. Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:

1. How many users are there?
2. How many cookies does each user have on average?
3. What is the unique number of visits by all users per month?
4. What is the number of events for each event type?
5. What is the percentage of visits which have a purchase event?
6. What is the percentage of visits which view the checkout page but do not have a purchase event?
7. What are the top 3 pages by number of views?
8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchases?

View my solutions [Here](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solutions/A.%20Digital%20Analysis.md).

---
### B. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

* How many times was each product viewed?
* How many times was each product added to cart?
* How many times was each product added to a cart but not purchased (abandoned)?
* How many times was each product purchased?
  
Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:

* Which product had the most views, cart adds and purchases?
* Which product was most likely to be abandoned?
* Which product had the highest view to purchase percentage?
* What is the average conversion rate from view to cart add?
* What is the average conversion rate from cart add to purchase?

View my solutions [Here](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solutions/B.%20Product%20Funnel%20Analysis.md).

---
### C. Campaign Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:

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

Some ideas you might want to investigate further include:

* Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
* Does clicking on an impression lead to higher purchase rates?
* What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
* What metrics can you use to quantify the success or failure of each campaign compared to eachother?

View my solutions [Here](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solutions/C.%20%20Campaign%20Analysis.md).

---
### D. Dashboard

On top of the above analysis using SQL, I designed a Power BI dashboard to help communicate all the above insights to Clique Bait's management team. The dahsboard allows the management team to track over time the business performance, identifying the trend and visualize the uplift from campaigns. 

View my solutions [Here](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solutions/D.%20Dashboard.md).

---
## My Solution
* View the complete syntax [HERE](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%236%20-%20Clique%20Bait/Syntax).
* View the result and explanation [HERE](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%236%20-%20Clique%20Bait/Solutions).
