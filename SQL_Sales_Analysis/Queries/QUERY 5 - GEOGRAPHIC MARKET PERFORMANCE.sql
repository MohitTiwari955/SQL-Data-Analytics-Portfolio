-- BUSINESS QUESTION
-- Which customer countries contribute the most to Contoso's net
-- revenue, and how has revenue changed across those markets over time?

-- OBJECTIVE
-- Compare annual country-level revenue, overall revenue contribution,
-- country rankings, and revenue changes from the previous available year.

WITH country_year AS (
    SELECT
        c.country,
        EXTRACT(YEAR FROM s.orderdate)::INT AS sales_year,
        SUM(s.quantity::NUMERIC * s.netprice::NUMERIC * s.exchangerate::NUMERIC) AS net_revenue
    FROM sales s
    JOIN customer c
        ON s.customerkey = c.customerkey
    GROUP BY
        c.country,
        EXTRACT(YEAR FROM s.orderdate)
),

country_totals AS (
    SELECT
        country,
        SUM(net_revenue) AS total_revenue,
        RANK() OVER (
            ORDER BY SUM(net_revenue) DESC
        ) AS revenue_rank,
        SUM(SUM(net_revenue)) OVER () AS grand_total
    FROM country_year
    GROUP BY country
),

ranked AS (
    SELECT
        cy.*,
        ct.total_revenue,
        ct.revenue_rank,
        ct.grand_total,
        LAG(cy.net_revenue) OVER (
            PARTITION BY cy.country
            ORDER BY cy.sales_year
        ) AS previous_year
    FROM country_year cy
    JOIN country_totals ct
        ON cy.country = ct.country
)

SELECT
    country,
    sales_year,
    ROUND(net_revenue, 2) AS net_revenue,
    ROUND(100 * total_revenue / grand_total, 2)
        AS revenue_contribution_pct,
    revenue_rank,
    ROUND(
        100 * (net_revenue - previous_year)
        / NULLIF(previous_year, 0),
        2
    ) AS yoy_change_pct
FROM ranked
ORDER BY revenue_rank, country, sales_year;