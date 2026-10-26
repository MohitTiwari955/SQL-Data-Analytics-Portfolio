-- BUSINESS QUESTION
-- How does customer revenue vary across customer acquisition cohorts?

-- OBJECTIVE
-- Group customers by the year of their first purchase and compare
-- revenue performance across different acquisition cohorts.

WITH customer_ltv AS (
	SELECT
		customerkey,
		name,
		sum(total_net_revenue) AS total_ltv
	FROM
		cohort_analysis
	GROUP BY
		customerkey,
		name
),
customer_segments AS (
	SELECT
		percentile_cont(0.25) WITHIN GROUP (
		ORDER BY
			total_ltv
		) AS ltv_25th_percentile,
		percentile_cont(0.75) WITHIN GROUP (
		ORDER BY
			total_ltv
		) AS ltv_75th_percentile
	FROM
		customer_ltv
),
segment_values AS (
	SELECT
		c.*,
		CASE
			WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1 - low value'
			WHEN c.total_ltv <= cs.ltv_75th_percentile THEN '2 - mid value'
			ELSE '3 - high value'
		END AS customer_segment
	FROM
		customer_ltv c,
		customer_segments cs
)
SELECT
	customer_segment,
	sum(total_ltv) AS total_ltv,
	count(customerkey) AS customer_count,
	sum(total_ltv) / count(customerkey) AS avg_segment_ltv
FROM
	segment_values
GROUP BY
	customer_segment
ORDER BY
	customer_segment DESC ;