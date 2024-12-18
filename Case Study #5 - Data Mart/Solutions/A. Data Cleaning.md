# Case Study #5 - Data Mart
## A. Data Cleaning

Solution Structure:

* Create a `formatted_date` column that convert the `week_date`column which is in string format to DATE format, stored in a date_cte;
* Use the WEEK(), MONTH(),YEAR() syntax to extract the week_number, month_number and year_number from the `formatted_date`;
* Use CASE() statement and string extraction syntax LEFT() and RIGHT() to create new columns `age_band` and `demographic`;
	* Within the CASE() statement, fill in the null value with "unknown";
* Create a calculated column `avg_transaction` using `sales` divided by `transaction` rounding to 2 decimals. 

``` SQL
CREATE TABLE clean_weekly_sales
  WITH date_cte AS(
     SELECT 
        *,
        STR_TO_DATE(week_date, '%d/%m/%Y') AS formatted_date
     FROM weekly_sales) 
      
SELECT 
	formatted_date AS week_date,
	WEEK(formatted_date) AS week_number,
	MONTH(formatted_date) AS month_number,
	YEAR(formatted_date) AS calendar_year,
	segment,
	CASE
		WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
		WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
		WHEN RIGHT(segment, 1) in ('3', '4') THEN 'Retirees'
		ELSE 'unknown'
		END AS age_band,
	CASE
		WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
		WHEN LEFT(segment, 1) = 'F' THEN 'Families'
		ELSE 'unknown'
		END AS demographic,
	region,
	platform,
	customer_type,
	sales,
	transactions,
	ROUND(sales/transactions, 2) AS avg_transaction
FROM date_cte
;

SELECT * FROM clean_weekly_sales LIMIT 10
```
Running the above query will generate below table.

| **week_date** | **week_number** | **month_number** | **calendar_year** | **segment** | **age_band** | **demographic** | **region** | **platform** | **customer_type** | **sales** | **transactions** | **avg_transaction** |
|---------------|-----------------|------------------|-------------------|-------------|--------------|-----------------|------------|--------------|-------------------|-----------|------------------|---------------------|
| 2020-08-31    | 35              | 8                | 2020              | C3          | Retirees     | Couples         | ASIA       | Retail       | New               | 3656163   | 120631           | 30.31               |
| 2020-08-31    | 35              | 8                | 2020              | F1          | Young Adults | Families        | ASIA       | Retail       | New               | 996575    | 31574            | 31.56               |
| 2020-08-31    | 35              | 8                | 2020              | null        | unknown      | unknown         | USA        | Retail       | Guest             | 16509610  | 529151           | 31.20               |
| 2020-08-31    | 35              | 8                | 2020              | C1          | Young Adults | Couples         | EUROPE     | Retail       | New               | 141942    | 4517             | 31.42               |
| 2020-08-31    | 35              | 8                | 2020              | C2          | Middle Aged  | Couples         | AFRICA     | Retail       | New               | 1758388   | 58046            | 30.29               |
| 2020-08-31    | 35              | 8                | 2020              | F2          | Middle Aged  | Families        | CANADA     | Shopify      | Existing          | 243878    | 1336             | 182.54              |
| 2020-08-31    | 35              | 8                | 2020              | F3          | Retirees     | Families        | AFRICA     | Shopify      | Existing          | 519502    | 2514             | 206.64              |
| 2020-08-31    | 35              | 8                | 2020              | F1          | Young Adults | Families        | ASIA       | Shopify      | Existing          | 371417    | 2158             | 172.11              |
| 2020-08-31    | 35              | 8                | 2020              | F2          | Middle Aged  | Families        | AFRICA     | Shopify      | New               | 49557     | 318              | 155.84              |
| 2020-08-31    | 35              | 8                | 2020              | C3          | Retirees     | Couples         | AFRICA     | Retail       | New               | 3888162   | 111032           | 35.02               |

---
My solution for **[B. Data Exploration](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solutions/B.%20Data%20Exploration.md)**.
