# Case Study # 6 - Data Mart
<p align="center">
<img src="https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/images/5.png" align="center" width="400" height="400" >

## Table of Contents
* [Bussiness Task](#bussiness-task)
* [Entity Relationship Diagram](#entity-relationship-diagram)
* [Case Study Questions](#case-study-questions)
* [My Solution](#my-solution)

---
## Bussiness Task
Data Mart is an online supermarket that specializes in fresh produce. In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

The management wants to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business questions they'd like to answer are the following:

* What was the quantifiable impact of the changes introduced in June 2020?
* Which platform, region, segment and customer types were the most impacted by this change?
* What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

---
## Entity Relationship Diagram

There is only one data table for this task. 

<p align="center">
<img src="https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/images/case-study-5-erd.png" align="center" width="300" height="300" >

---
## Case Study Questions
### A. Data Cleaning

In a single query, perform the following steps that created a new table in the Data Mart schema named `clean_weekly_sale`.

* Convert the `week_date` to a DATE format

* Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

* Add a `month_number` with the calendar month for each `week_date` value as the 3rd column

* Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values

* Add a new column called `age_band` after the original `segment` column using the following mapping on the number inside the `segment` value
  

| segment | age_band     |
|---------|--------------|
| 1       | Young Adults |
| 2       | Middle Aged  |
| 3 or 4  | Retirees     |

* Add a new `demographic` column using the following mapping for the first letter in the `segment` values:

| segment | demographic |
|---------|-------------|
| C       | Couples     |
| F       | Families    |

* Fill all null string values with an "unknown" string value in the original `segment` column as well as the new `age_band` and `demographic` columns
  
* Generate a new `avg_transaction` column as the `sales value` divided by `transactions` rounded to 2 decimal places for each record

View my solutions [Here](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solutions/A.%20Data%20Cleaning.md).

---
### B. Data Exploration

1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

View my solutions [Here](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solutions/B.%20Data%20Exploration.md).

---
### C. Event Analysis

Taking the week_date value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect. I'll inspect the impact from the packages change by comparing the sales  "before" and "after" the event. 

Using this analysis approach - answer the following questions:

* What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
* What about the entire 12 weeks before and after?
* How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

View my solutions [Here](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solutions/C.%20Event%20Analysis.md).

---
## My Solution
* View the complete syntax [HERE](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%235%20-%20Data%20Mart/Syntax).
* View the result and explanation [HERE](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%235%20-%20Data%20Mart/Solutions).
