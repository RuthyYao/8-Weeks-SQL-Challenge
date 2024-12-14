# Case Study #5 - Data Mart
## B. Data Exploration

### 1. What day of the week is used for each week_date value?

``` SQL
SELECT
	DISTINCT DAYNAME(week_date) AS Day_of_week
FROM clean_weekly_sales;
```
| Day_of_week |
|-------------|
| Monday      |

The week starts from Monday.

### 2. What range of week numbers are missing from the dataset?

Solution Structure:
* Using recursive cte to list all the week numbers for a year from 1 to 52;
* LEFT Join the above recursive cte with the `clean_weekly_sales` table, using the week_number as the join key;
    * where the `week_number` in the `clean_weekly_sales` table is null means the week number is missing.
      
``` SQL
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
```

| # wk | week_number |
|------|-------------|
| 1    | null        |
| 2    | null        |
| 3    | null        |
| 4    | null        |
| 5    | null        |
| 6    | null        |
| 7    | null        |
| 8    | null        |
| 9    | null        |
| 10   | null        |
| 11   | null        |
| 36   | null        |
| 37   | null        |
| 38   | null        |
| 39   | null        |
| 40   | null        |
| 41   | null        |
| 42   | null        |
| 43   | null        |
| 44   | null        |
| 45   | null        |
| 46   | null        |
| 47   | null        |
| 48   | null        |
| 49   | null        |
| 50   | null        |
| 51   | null        |
| 52   | null        |

Week 1 to week 11 and week 36 - week 52 are missing from the dataset.


### 3. How many total transactions were there for each year in the dataset?

``` SQL
SELECT
    calendar_year,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
```
| calendar_year | total_transactions |
|---------------|--------------------|
| 2018          | 346406460          |
| 2019          | 365639285          |
| 2020          | 375813651          |

The year-over-year transactions are increasing.


### 4. What is the total sales for each region for each month?

``` SQL
SELECT 
  region,
  calendar_year,
  month_number,
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, calendar_year,month_number
ORDER BY region, calendar_year,month_number;
```

Just list the top 10 rows of the results.

| region | calendar_year | month_number | total_sales |
|--------|---------------|--------------|-------------|
| AFRICA | 2018          | 3            | 130542213   |
| AFRICA | 2018          | 4            | 650194751   |
| AFRICA | 2018          | 5            | 522814997   |
| AFRICA | 2018          | 6            | 519127094   |
| AFRICA | 2018          | 7            | 674135866   |
| AFRICA | 2018          | 8            | 539077371   |
| AFRICA | 2018          | 9            | 135084533   |
| AFRICA | 2019          | 3            | 141619349   |
| AFRICA | 2019          | 4            | 700447301   |
| AFRICA | 2019          | 5            | 553828220   |

### 5. What is the total count of transactions for each platform?

``` SQL
SELECT
  platform,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;
```

| platform | total_transactions |
|----------|--------------------|
| Retail   | 1081934227         |
| Shopify  | 5925169            |

### 6. What is the percentage of sales for Retail vs Shopify for each month?

Solution Structure:
* Create a cte that sums the sales by `year` and `month`;
    * Use the CASE() statement to tag the sales to "retail" or "shopify".
* Calculate the percentage of sales as total 

``` SQL
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
```

| calendar_year | month_number | retail_sales_pct | shopify_sales_pct |
|---------------|--------------|------------------|-------------------|
| 2018          | 3            | 97.92            | 2.08              |
| 2018          | 4            | 97.93            | 2.07              |
| 2018          | 5            | 97.73            | 2.27              |
| 2018          | 6            | 97.76            | 2.24              |
| 2018          | 7            | 97.75            | 2.25              |
| 2018          | 8            | 97.71            | 2.29              |
| 2018          | 9            | 97.68            | 2.32              |
| 2019          | 3            | 97.71            | 2.29              |
| 2019          | 4            | 97.80            | 2.20              |
| 2019          | 5            | 97.52            | 2.48              |
| 2019          | 6            | 97.42            | 2.58              |
| 2019          | 7            | 97.35            | 2.65              |
| 2019          | 8            | 97.21            | 2.79              |
| 2019          | 9            | 97.09            | 2.91              |
| 2020          | 3            | 97.30            | 2.70              |
| 2020          | 4            | 96.96            | 3.04              |
| 2020          | 5            | 96.71            | 3.29              |
| 2020          | 6            | 96.80            | 3.20              |
| 2020          | 7            | 96.67            | 3.33              |
| 2020          | 8            | 96.51            | 3.49              |

Retail channel account for 97% of the total sales

### 7. What is the percentage of sales by demographic for each year in the dataset?

Solution Structure:
* Create a year_sales cte that sums the sales by `calendar_year` and by `demographic`.
* Group the sales by `calendar_year` from the above cte:
  * Use CASE() statement to extract the sales for each of demographic;
  * Divid the sales of each demographic by the total sales of the year.
  
``` SQL
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
```

| calendar_year | couples_sales_percent | families_sales_percent | unknown_sales_percent |
|---------------|-----------------------|------------------------|-----------------------|
| 2018          | 26.38                 | 31.99                  | 41.63                 |
| 2019          | 27.28                 | 32.47                  | 40.25                 |
| 2020          | 28.72                 | 32.73                  | 38.55                 |

### 8. Which age_band and demographic values contribute the most to Retail sales?

``` SQL
SELECT
	age_band,
    demographic,
    ROUND(100*SUM(sales)/ (SELECT SUM(sales) FROM clean_weekly_sales WHERE platform = 'Retail'),2) AS sales_percent
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band,demographic
ORDER BY sales_percent DESC;
```

| age_band     | demographic | sales_percent |
|--------------|-------------|---------------|
| unknown      | unknown     | 40.52         |
| Retirees     | Families    | 16.73         |
| Retirees     | Couples     | 16.07         |
| Middle Aged  | Families    | 10.98         |
| Young Adults | Couples     | 6.56          |
| Middle Aged  | Couples     | 4.68          |
| Young Adults | Families    | 4.47          |

### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

``` SQL
SELECT
	calendar_year,
    platform,
    ROUND(AVG(avg_transaction),2) AS avg_tran_by_row,
    ROUND(SUM(sales) / SUM(transactions),2) AS avg_tran_by_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
```

| calendar_year | platform | avg_tran_by_row | avg_tran_by_group |
|---------------|----------|-----------------|-------------------|
| 2018          | Retail   | 42.91           | 36.56             |
| 2018          | Shopify  | 188.28          | 192.48            |
| 2019          | Retail   | 41.97           | 36.83             |
| 2019          | Shopify  | 177.56          | 183.36            |
| 2020          | Retail   | 40.64           | 36.56             |
| 2020          | Shopify  | 174.87          | 179.03            |

* The difference between avg_transaction_row and avg_transaction_group is as follows:
* avg_transaction_row calculates the average transaction size by dividing the sales of each row by the number of transactions in that row.
* On the other hand, avg_transaction_group calculates the average transaction size by dividing the total sales for the entire dataset by the total number of transactions.
* For finding the average transaction size for each year by platform accurately, it is recommended to use avg_transaction_group.

---
My solution for **[C. Event Analysis](https://github.com/RuthyYao/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solutions/C.%20Event%20Analysis.md)**.
