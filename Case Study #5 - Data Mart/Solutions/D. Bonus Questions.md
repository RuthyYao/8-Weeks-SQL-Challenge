# Case Study #5 - Data Mart
## D. Bonus Questions

* [Solutions](#solutions)
* [Insights](#insights)

### Solutions

* First define the variable week_number of 2020-06-15 

``` SQL
SET @weeknum = (
	SELECT DISTINCT week_number
    FROM clean_weekly_sales
    WHERE week_date = '2020-06-15'
);
```

* Next, apply the declared variable for the following analysis.

#### 1. Sales changes by region

```SQL
WITH SalesChange AS(
	SELECT
        region,
        SUM(CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
        SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
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

| region        | before_sales | after_sales | sales_change | pct_change |
|---------------|--------------|-------------|--------------|------------|
| ASIA          | 1637244466   | 1583807621  | -53436845    | -3.26      |
| OCEANIA       | 2354116790   | 2282795690  | -71321100    | -3.03      |
| SOUTH AMERICA | 213036207    | 208452033   | -4584174     | -2.15      |
| CANADA        | 426438454    | 418264441   | -8174013     | -1.92      |
| USA           | 677013558    | 666198715   | -10814843    | -1.60      |
| AFRICA        | 1709537105   | 1700390294  | -9146811     | -0.54      |
| EUROPE        | 108886567    | 114038959   | 5152392      | 4.73       |

-- Asia is the most impacted region with sales decline by -3.26%. 

#### 2. Sales changes by platform

```SQL
WITH SalesChange AS(
	SELECT
        platform,
        SUM(CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
        SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
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
```

| platform | before_sales | after_sales | sales_change | pct_change |
|----------|--------------|-------------|--------------|------------|
| Retail   | 6906861113   | 6738777279  | -168083834   | -2.43      |
| Shopify  | 219412034    | 235170474   | 15758440     | 7.18       |

-- Retail declined by 2.43% while Shopify increased by 7.18%. 

#### 3. Sales changes by age_band

``` SQL
WITH SalesChange AS(
	SELECT
        age_band,
        SUM(CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
	SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
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
```

| age_band     | before_sales | after_sales | sales_change | pct_change |
|--------------|--------------|-------------|--------------|------------|
| unknown      | 2764354464   | 2671961443  | -92393021    | -3.34      |
| Middle Aged  | 1164847640   | 1141853348  | -22994292    | -1.97      |
| Retirees     | 2395264515   | 2365714994  | -29549521    | -1.23      |
| Young Adults | 801806528    | 794417968   | -7388560     | -0.92      |

-- changing the packages has larger impact on Middle_aged and Retirees than the Young Adults.

#### 4. Sales changes by demographic

``` SQL
WITH SalesChange AS(
	SELECT
        demographic,
        SUM(CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
        SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
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
```

| demographic | before_sales | after_sales | sales_change | pct_change |
|-------------|--------------|-------------|--------------|------------|
| unknown     | 2764354464   | 2671961443  | -92393021    | -3.34      |
| Families    | 2328329040   | 2286009025  | -42320015    | -1.82      |
| Couples     | 2033589643   | 2015977285  | -17612358    | -0.87      |

-- sales impacted on families more than the couples.

#### 5. Sales changes by customer_type

``` SQL
WITH SalesChange AS(
	SELECT
        customer_type,
        SUM(CASE WHEN week_number BETWEEN @weeknum -12 AND @weeknum -1 THEN sales END
            ) AS before_sales,
         SUM(CASE WHEN week_number BETWEEN @weeknum AND @weeknum +11 THEN sales END
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
```

| customer_type | before_sales | after_sales | sales_change | pct_change |
|---------------|--------------|-------------|--------------|------------|
| Guest         | 2573436301   | 2496233635  | -77202666    | -3.00      |
| Existing      | 3690116427   | 3606243454  | -83872973    | -2.27      |
| New           | 862720419    | 871470664   | 8750245      | 1.01       |


* The sales for Guests and Existing customers decreased, but increased for New customers.
* Further analysis should be taken to understand why New customers were interested in sustainable packages.

### Insights

* Region wise, Europe sees sales increase whereas all other regions are negative impacted with Asia and Oceania suffering the most significant decline in sales. This could be due to wider public awareness of enviromental impact from plastics in Eruope than Asia and Oceania. Recommended that the management team allows for longer transition period - offering both plastic and sustainable packages at the same in the most negatively impacted regions such as Asia and Oceania for at least 3 months.

* Sales on New Customers are increasing whereas Guests see the most decline in sales followed by existing customers. This reflects the difficulty in changing customers' shopping bag habitual. However, the management team could implement some effective measures to help customer adapt to the new norm, such as offering a transition period in which both plastic and sustainable shopping bags are offered, or providing some incentives for using sustainable packages. These will help minimize the sales impact from the change.

* The data also shows that Middle age and family are the most impacted customer groups. It is advisable that Data Mart release some educational programs and or customer engagement activities targeting kids and families to uplift the their environmental awareness and responsibilities.

*  While Shopify sales increased from the package change, the weight of the shopify channel is still relatively low comapred with the retail (97%). It is advisable that the management team focus more on managing the negtative impact on Retail sales, while seizing this package change opportunity to boost more online/shopify sales. FOr instance,  Data Mark could offer unique online pricing for some products or categories to attract more customers to shopify channel.
