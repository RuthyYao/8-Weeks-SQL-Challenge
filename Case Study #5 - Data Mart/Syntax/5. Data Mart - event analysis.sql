----------------------------------
---- Before & After Analysis -----
----------------------------------

-- Event: changing the packaging to sustainable packaging 
-- Event Date: 2020-06-15


-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
SELECT 
	DATE_ADD('2020-06-15', INTERVAL -4 WEEK)
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';

SELECT
	'Before_Sales',
    SUM(sales) AS sales
FROM clean_weekly_sales
WHERE week_date BETWEEN DATE_ADD('2020-06-15', INTERVAL -4 WEEK) AND '2020-06-15'

UNION ALL

SELECT
	'After_Sales',
    SUM(sales) AS sales
FROM clean_weekly_sales
WHERE week_date BETWEEN  '2020-06-15' AND DATE_ADD('2020-06-15', INTERVAL +4 WEEK);

SELECT 
	DATE_ADD('2020-06-15', INTERVAL +4 WEEK)
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';

WITH bef_sale AS(
SELECT
    'Sales',
    SUM(sales) AS before_sales
FROM clean_weekly_sales
WHERE week_date BETWEEN DATE_ADD('2020-06-15', INTERVAL -4 WEEK) AND DATE_ADD('2020-06-15', INTERVAL -1 WEEK)
),
af_sale AS(
SELECT
    'Sales',
    SUM(sales) AS after_sales
FROM clean_weekly_sales
WHERE week_date BETWEEN  '2020-06-15' AND DATE_ADD('2020-06-15', INTERVAL +3 WEEK)
)
SELECT 
	b.before_sales,
    a.after_sales,
    a.after_sales-b.before_sales AS sales_change,
    ROUND(100*(a.after_sales-b.before_sales)/b.before_sales,2) AS pct_change
FROM bef_sale AS b
JOIN af_sale AS a
	ON b.sales = a.sales;

-- 2. What about the entire 12 weeks before and after?
WITH bef_sale AS(
SELECT
    'Sales',
    SUM(sales) AS before_sales
FROM clean_weekly_sales
WHERE week_date BETWEEN DATE_ADD('2020-06-15', INTERVAL -12 WEEK) AND DATE_ADD('2020-06-15', INTERVAL -1 WEEK)
),
af_sale AS(
SELECT
    'Sales',
    SUM(sales) AS after_sales
FROM clean_weekly_sales
WHERE week_date BETWEEN  '2020-06-15' AND DATE_ADD('2020-06-15', INTERVAL +11 WEEK)
)
SELECT 
	b.before_sales,
    a.after_sales,
    a.after_sales-b.before_sales AS sales_change,
    ROUND(100*(a.after_sales-b.before_sales)/b.before_sales,2) AS pct_change
FROM bef_sale AS b
JOIN af_sale AS a
	ON b.sales = a.sales;
    
-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

-- Part 1: How did the sales change for 4 weeks before and after the event in 2020 compare with the same period in 2019 and 2018?
-- Find the week_number of '2020-06-15'
SET @weeknum = (
	SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);
-- Find total sales of 4 weeks before and after @weeknum
WITH SalesChange AS(
	SELECT
		calendar_year,
        SUM(
			CASE WHEN week_number BETWEEN @weeknum -4 AND @weeknum -1 THEN sales END
            ) AS before_sales,
		SUM(
			CASE WHEN week_number BETWEEN @weeknum AND @weeknum +3 THEN sales END
            ) AS after_sales
FROM clean_weekly_sales
GROUP BY calendar_year
)
SELECT
	*,
    after_sales-before_sales AS sales_change,
    ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY calendar_year;
	
-- Part 2: How did the sales change for 12 weeks before and after the event in 2020 compare with the same period in 2019 and 2018?
SET @weeknum = (
	SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);
-- Find total sales of 4 weeks before and after @weeknum
WITH SalesChange AS(
	SELECT
		calendar_year,
        SUM(
			CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
		SUM(
			CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
            ) AS after_sales
FROM clean_weekly_sales
GROUP BY calendar_year
)
SELECT
	*,
    after_sales - before_sales AS sales_change,
    ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY calendar_year;