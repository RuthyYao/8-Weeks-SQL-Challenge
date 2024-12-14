# Case Study #5 - Data Mart
## D. Bonus Questions



Solutioins

-- First define the variable week_number of 2020-06-15 
SET @weeknum = (
	SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);

-- Next, apply the declared variable for the following analysis.

##### 1. Sales changes by region

```SQL
WITH SalesChange AS(
	SELECT
        region,
        SUM(
			CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
		SUM(
			CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
            ) AS after_sales
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY region
)
SELECT
	*,
    after_sales-before_sales AS sales_change,
    ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY pct_change
;
```

-- Asia is the most impacted region with sales decline by -3.26%. 

#### 2. Sales changes by platform

```SQL
SET @weeknum = (
	SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);

-- Next, apply the declared variable for the following analysis.

-- 3. Sales changes by region

WITH SalesChange AS(
	SELECT
        platform,
        SUM(
			CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
		SUM(
			CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
            ) AS after_sales
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY platform
)
SELECT
	*,
    after_sales-before_sales AS sales_change,
    ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY pct_change;

-- Retail declined by 2.43% while Shopify increased by 7.18%. 

-- 3. Sales changes by age_band
WITH SalesChange AS(
	SELECT
        age_band,
        SUM(
			CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
		SUM(
			CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
            ) AS after_sales
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY age_band
)
SELECT
	*,
    after_sales-before_sales AS sales_change,
    ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY pct_change;

-- changing the packages has larger impact on Middle_aged and Retirees than the Young Adults.

-- 4. Sales changes by demographic
WITH SalesChange AS(
	SELECT
        demographic,
        SUM(
			CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
		SUM(
			CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
            ) AS after_sales
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY demographic
)
SELECT
	*,
    after_sales-before_sales AS sales_change,
    ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY pct_change;

-- sales impacted on families more than the couples.

-- 5. Sales changes by customer_type
WITH SalesChange AS(
	SELECT
        customer_type,
        SUM(
			CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
		SUM(
			CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
            ) AS after_sales
FROM clean_weekly_sales
WHERE calendar_year = 2020
GROUP BY customer_type
)
SELECT
	*,
    after_sales-before_sales AS sales_change,
    ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY pct_change;

-- The sales for Guests and Existing customers decreased, but increased for New customers.
-- Further analysis should be taken to understand why New customers were interested in sustainable packages.
