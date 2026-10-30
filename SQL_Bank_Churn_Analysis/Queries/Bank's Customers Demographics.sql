-- What do the overall demographics of the bank's customers look like?

-- Customer Distribution by Geography

SELECT
    "Geography",
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER (),2) AS pct_of_customers
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY customer_count DESC;

-- Customer Distribution by Gender

SELECT
    "Gender",
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER (),2) AS pct_of_customers
FROM public.bank_churn
GROUP BY "Gender"
ORDER BY customer_count DESC;

-- Customer Distribution by Age Group

WITH customer_age_groups AS (
    SELECT
        CASE
            WHEN "Age" < 30 THEN 'Under 30'
            WHEN "Age" < 40 THEN '30-39'
            WHEN "Age" < 50 THEN '40-49'
            WHEN "Age" < 60 THEN '50-59'
            ELSE '60+'
        END AS age_group,
        CASE
            WHEN "Age" < 30 THEN 1
            WHEN "Age" < 40 THEN 2
            WHEN "Age" < 50 THEN 3
            WHEN "Age" < 60 THEN 4
            ELSE 5
        END AS age_group_order
    FROM public.bank_churn
)
SELECT
    age_group,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS pct_of_customers
FROM customer_age_groups
GROUP BY age_group, age_group_order
ORDER BY age_group_order;