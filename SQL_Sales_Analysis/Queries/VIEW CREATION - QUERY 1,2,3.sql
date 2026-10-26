CREATE OR REPLACE VIEW AS 

WITH customer_revenue AS( 
SELECT 
s.customerkey,
s.orderdate,
sum(s.quantity:: double PRECISION * s.netprice * s.exchangerate) AS total_net_revenue,
count(s.orderkey) AS num_orders,
max(c.countryfull)AS countryfull,
max(c.age)AS age,
max(concat(trim(givenname), ' ', trim(surname))) AS name
FROM
sales s
INNER JOIN customer c ON
c.customerkey = s.customerkey
GROUP BY
s.customerkey,
s.orderdate
)
SELECT
	cr.*,
	min(cr.orderdate) OVER (
		PARTITION BY cr.customerkey
	) AS first_purchase_date,
	EXTRACT(YEAR FROM min(cr.orderdate) OVER(PARTITION BY cr.customerkey)) AS cohort_year
FROM
	customer_revenue cr
