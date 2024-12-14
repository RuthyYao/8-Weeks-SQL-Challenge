# Case Study #5 - Data Mart
## C. Event Analysis

According to the case study, the event date is `2020-06-15`.

### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

Solution Structure:
* Find the week_number of '2020-06-15';
* Sum the sales of "before" and "after"

``` SQL
SET @weeknum = (
    SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);
WITH cte AS (
SELECT
	SUM(CASE WHEN week_number BETWEEN @weeknum -4 AND @weeknum -1 THEN sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +3 THEN sales END) AS after_sales
FROM clean_weekly_sales
WHERE calendar_year = 2020
)
SELECT
    *,
    after_sales - before_sales AS sales_change,
    ROUND(100 * (after_sales - before_sales) / before_sales, 2) AS pct_change
FROM cte;
```

| before_sales | after_sales | sales_change | pct_change |
|--------------|-------------|--------------|------------|
| 2345878357   | 2318994169  | -26884188    | -1.15      |

### 2. What about the entire 12 weeks before and after?

``` SQL
SET @weeknum = (
    SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);
WITH cte AS (
SELECT
	SUM(CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END) AS after_sales
FROM clean_weekly_sales
WHERE calendar_year = 2020
)
SELECT
	*,
    after_sales - before_sales AS sales_change,
    ROUND(100 * (after_sales - before_sales) / before_sales, 2) AS pct_change
FROM cte;
```

| before_sales | after_sales | sales_change | pct_change |
|--------------|-------------|--------------|------------|
| 7126273147   | 6973947753  | -152325394   | -2.14      |

### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

##### Part 1: How did the sales change for 4 weeks before and after the event in 2020 compare with the same period in 2019 and 2018?

``` SQL
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
  after_sales - before_sales AS sales_change,
  ROUND(100*(after_sales-before_sales)/before_sales,2) AS pct_change
FROM SalesChange
ORDER BY calendar_year;
```

| calendar_year | before_sales | after_sales | sales_change | pct_change |
|---------------|--------------|-------------|--------------|------------|
| 2018          | 2125140809   | 2129242914  | 4102105      | 0.19       |
| 2019          | 2249989796   | 2252326390  | 2336594      | 0.10       |
| 2020          | 2345878357   | 2318994169  | -26884188    | -1.15      |
	
##### Part 2: How did the sales change for 12 weeks before and after the event in 2020 compare with the same period in 2019 and 2018?

``` SQL
SET @weeknum = (
    SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);
-- Find total sales of 4 weeks before and after @weeknum
WITH SalesChange AS(
	SELECT
		calendar_year,
        SUM(CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
        SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
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
```

| calendar_year | before_sales | after_sales | sales_change | pct_change |
|---------------|--------------|-------------|--------------|------------|
| 2018          | 6396562317   | 6500818510  | 104256193    | 1.63       |
| 2019          | 6883386397   | 6862646103  | -20740294    | -0.30      |
| 2020          | 7126273147   | 6973947753  | -152325394   | -2.14      |

---
