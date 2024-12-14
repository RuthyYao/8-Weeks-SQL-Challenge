---------------------------
---- Data Exploration -----
---------------------------

-- 1. What day of the week is used for each week_date value?

SELECT
	DISTINCT DAYNAME(week_date) AS Day_of_week
FROM clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?

WITH RECURSIVE week_num_cte AS(
	SELECT 1 AS wk
	UNION ALL 
		SELECT wk +1 FROM week_num_cte
			WHERE wk+1 <=52)
SELECT
	DISTINCT week_num_cte.wk,
    clean_weekly_sales.week_number
FROM week_num_cte
LEFT JOIN clean_weekly_sales
	ON week_num_cte.wk = clean_weekly_sales.week_number
WHERE clean_weekly_sales.week_number IS NULL;

-- Week 1 to 11 and 36-52 are missing from the dataset.


-- 3. How many total transactions were there for each year in the dataset?

SELECT
	calendar_year,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

-- 4. What is the total sales for each region for each month?
SELECT 
	region,
    calendar_year,
    month_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, calendar_year,month_number
ORDER BY region, calendar_year,month_number;

-- 5. What is the total count of transactions for each platform?
SELECT
	platform,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?

WITH cte AS(
SELECT
	calendar_year,
    month_number,
	SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) AS retail_sales,
    SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) AS shopify_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number
)
SELECT
	calendar_year,
    month_number,
    ROUND(100 * retail_sales / (retail_sales + shopify_sales), 2) AS retail_sales_pct,
    ROUND(100 * shopify_sales / (retail_sales + shopify_sales), 2) AS shopify_sales_pct
FROM cte;

-- 7. What is the percentage of sales by demographic for each year in the dataset?
WITH year_sales AS(
SELECT
	calendar_year,
    demographic,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year,demographic
ORDER BY calendar_year,demographic
)
SELECT
	calendar_year,
    ROUND(100*SUM(CASE WHEN demographic = "Couples" THEN total_sales ELSE 0 END) / SUM(total_sales),2) AS couples_sales_percent,
	ROUND(100*SUM(CASE WHEN demographic = "Families" THEN total_sales ELSE 0 END) /SUM(total_sales),2) AS families_sales_percent,
    ROUND(100*SUM(CASE WHEN demographic = "unknown" THEN total_sales ELSE 0 END) / SUM(total_sales),2) AS unknown_sales_percent
FROM year_sales
GROUP BY calendar_year;


-- 8. Which age_band and demographic values contribute the most to Retail sales?
SELECT
	age_band,
    demographic,
    ROUND(100*SUM(sales)/ (SELECT SUM(sales) FROM clean_weekly_sales WHERE platform = 'Retail'),2) AS sales_percent
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band,demographic
ORDER BY sales_percent DESC;

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT
	calendar_year,
    platform,
    ROUND(AVG(avg_transaction),2) AS avg_tran_by_row,
    ROUND(SUM(sales) / SUM(transactions),2) AS avg_tran_by_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;

-- The difference between avg_transaction_row and avg_transaction_group is as follows:
-- avg_transaction_row calculates the average transaction size by dividing the sales of each row by the number of transactions in that row.
-- On the other hand, avg_transaction_group calculates the average transaction size by dividing the total sales for the entire dataset by the total number of transactions.
-- For finding the average transaction size for each year by platform accurately, it is recommended to use avg_transaction_group.

