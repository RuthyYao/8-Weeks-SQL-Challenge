# Case Study #3 - Foodie-Fi
## D. Outside The Box Questions
### 1. How would you calculate the rate of growth for Foodie-Fi?
- I choose the year of 2020 to analyze because I already created the ```payments``` table in part C.
- If we want to incorporate the data in 2021 to see the whole picture, we could create a new ```payments``` table and change all the date conditions in part C to '2021-12-31'

```TSQL
WITH mth_rev AS(
SELECT 
	MONTH(payment_date) AS month,
  SUM(amount) AS revenue
FROM payment
GROUP by month
ORDER BY month
)
SELECT
	*,
  ROUND((revenue/LAG(revenue) OVER(ORDER BY month) - 1)*100,1) AS rev_growth_rate
from mth_rev;
```
| month  | revenue  | rev_growth_rate |
|--------|----------|-----------------|
| 1      | 1282.00  | NULL            |
| 2      | 2792.60  | 117.8           |
| 3      | 4342.40  | 50.5            |
| 4      | 5972.70  | 39.3            |
| 5      | 7324.10  | 22.2            |
| 6      | 8765.50  | 19.0            |
| 7      | 10207.50 | 16.9            |
| 8      | 12047.40 | 18.8            |
| 9      | 12913.20 | 7.3             |
| 10     | 14952.50 | 15.1            |
| 11     | 12862.70 | -14.2           |
| 12     | 13429.50 | 4.3             |

### 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
* **Monthly Revenue Growth** - how does the business grow their revenue monty-over-month.
* **Total subscribers** - how many customers the business has in total at a point. This reflects the reach and popularity of Foodie Fi.
* **The customer growth** - how customers increase month-over-month. THis reveals the momentum of the expansion of their customer base.
* **Conversion rate** - how many customers stay in Foodie Fi after the trial. Howe does the rate look like.
* **Churn rate** - how many customers cancel their plan each month?  This signals customer dissatisfaction and can help pinpoint areas for improvements in suer expereince, pricing or content library etc.

### 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
- Customers who downgraded their plan
- Customers who upgraded from basic monthly to pro monthly or pro annual
- Customers who cancelled the subscription

### 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
- What is the primary reason for the cancellation? 
  + Price
  + Content
  + Viewing experience (Technical issues, etc.)
  + Customer support
  + Found an alternative
  + Others (please specify)
- Overall, how satisfied were you with the subscription? (Likert scale: Very Satisfied - Very Unsatisfied)
- Would you consider using our services in the future? (Likert scale: Very Satisfied - Very Unsatisfied)
- Would you recommend our company to a colleague, friend or family member? (Likert scale: Very Satisfied - Very Unsatisfied)

### 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
- From the exit survey, look for the most common reasons why customers cancelled the subscription.
  + Price: increase the number of discounts in some seasons of a year, extend the trial time, or add more benefits to customers.
  + Content: review the content library and and enhance the match between the recoomendation and the customers preference.
  + Service quality: work with the relevant department to fix the issue.
  + Found an alternative: do some competitor analysis to see their competitive advantages over us.
- To validate the effectiveness of those ideas, check:
  + Churn rate
  + Conversion rate
