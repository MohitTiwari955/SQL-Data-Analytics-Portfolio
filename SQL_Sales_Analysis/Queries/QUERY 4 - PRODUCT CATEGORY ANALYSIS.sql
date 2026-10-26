-- BUSINESS QUESTION
-- How do Contoso's product categories compare in sales volume,
-- revenue contribution, and average revenue per unit?

-- OBJECTIVE
-- Compare units sold, net revenue, revenue contribution, average
-- revenue per unit, and rankings by revenue and sales volume.

WITH category_metrics AS (
	SELECT
		p.categoryname AS product_category,
		SUM(s.quantity) AS units_sold,
		SUM(s.quantity::NUMERIC * s.netprice::NUMERIC * s.exchangerate::NUMERIC) AS net_revenue
	FROM sales s
	JOIN public.product p ON
		s.productkey = p.productkey
	GROUP BY
		p.categoryname
)
SELECT
	product_category,
	units_sold,
	net_revenue,
	ROUND((net_revenue / SUM(net_revenue) OVER () * 100), 2) AS revenue_contribution_pct,
	ROUND(net_revenue / NULLIF(units_sold, 0), 2) AS avg_revenue_per_unit,
	RANK() OVER (
	ORDER BY
		net_revenue DESC
	) AS revenue_rank,
	RANK() OVER (
	ORDER BY
		units_sold DESC
	) AS volume_rank
FROM
	category_metrics
ORDER BY
	revenue_rank ASC;