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

## 1. Data Cleaning

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
