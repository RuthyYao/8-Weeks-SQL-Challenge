---------------------------------
-- CASE STUDY #4 - Data Mart --
---------------------------------

-- Author: Ruthy Yao
-- Date: 27/11/2024
-- Tool used: MYSQL

------------------------
---- Data Cleaning -----
------------------------

-- Convert the `week_date` to a `DATE` format;
-- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

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

SELECT * FROM clean_weekly_sales

