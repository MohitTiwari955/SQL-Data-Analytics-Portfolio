-- BUSINESS QUESTION
-- How many customers from each acquisition cohort remain active
-- or have churned?

-- OBJECTIVE
-- Classify customers by their activity status using their purchase
-- history and compare active and churned customer counts across cohorts.

WITH customer_last_purchase AS (
	SELECT
		customerkey,
		name ,
		orderdate,
		ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
		first_purchase_date,
		cohort_year
	FROM
		cohort_analysis
),
churned_customers AS(
SELECT
	customerkey,
	name,
	first_purchase_date ,
	orderdate AS last_purchase_date,
	CASE
		WHEN orderdate < (
			SELECT
				max(orderdate)
			FROM
				sales
		) - INTERVAL '6 months' THEN 'churned'
		ELSE 'active'
	END AS customer_status,
	cohort_year
FROM
	customer_last_purchase
WHERE
	rn = 1
	AND first_purchase_date < (
		SELECT
			max(orderdate)
		FROM
			sales
	) - INTERVAL '6 months'
)
SELECT
	cohort_year,
	customer_status,
	count(customerkey) AS total_customers,
	sum(count(customerkey)) OVER(PARTITION BY cohort_year) AS cohort_customers,
	100 *round(count(customerkey) / sum(count(customerkey)) OVER(PARTITION BY cohort_year), 2) AS status_percentage
FROM
	churned_customers
GROUP BY
	cohort_year,
	customer_status;
