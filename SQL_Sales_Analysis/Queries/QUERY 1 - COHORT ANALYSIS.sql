-- BUSINESS QUESTION
-- How can Contoso customers be grouped into low-, medium-, and
-- high-value segments based on their total net revenue?

-- OBJECTIVE
-- Categorize customers based on the revenue they generate and
-- compare the value of different customer segments.

SELECT
	cohort_year,
	sum(total_net_revenue) AS total_revenue,
	count(DISTINCT customerkey) AS total_customers,
	sum(total_net_revenue) / count(DISTINCT customerkey) AS customer_revenue
FROM
	cohort_analysis
WHERE
	orderdate = first_purchase_date
GROUP BY
	cohort_year