-- Is there a difference between German, French, and Spanish customers in terms of account behavior?

-- 1. Average Balance By Country:-
SELECT
    "Geography" AS country,
    COUNT(*) AS total_customers,
    ROUND(AVG("Balance")::numeric, 2) AS avg_balance
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY avg_balance DESC;

-- 2. Average Number of Products by country;-

SELECT
    "Geography" AS country,
    COUNT(*) AS total_customers,
    ROUND(AVG("NumOfProducts")::numeric, 2) AS avg_num_products
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY avg_num_products DESC;

-- 3. Average Tenure by Country:-

SELECT
    "Geography" AS country,
    COUNT(*) AS total_customers,
    ROUND(AVG("Tenure")::numeric, 2) AS avg_tenure_years
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY avg_tenure_years DESC;

-- 4. Average Credit Score by Country:-

SELECT
    "Geography" AS country,
    COUNT(*) AS total_customers,
    ROUND(AVG("CreditScore")::numeric, 2) AS avg_credit_score
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY avg_credit_score DESC;

-- 5. Average Estimated Salary By Country:-

SELECT
    "Geography" AS country,
    COUNT(*) AS total_customers,
    ROUND(AVG("EstimatedSalary")::numeric, 2) AS avg_estimated_salary
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY avg_estimated_salary DESC;

-- 6. Active Membership Rate By Country:-

SELECT
    "Geography" AS country,
    COUNT(*) AS total_customers,
    SUM("IsActiveMember") AS active_members,
    ROUND(100.0 * SUM("IsActiveMember") / COUNT(*), 2) AS active_membership_rate_pct
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY active_membership_rate_pct DESC;

-- 7. Churn Rate by Country:-

SELECT
    "Geography" AS country,
    COUNT(*) AS total_customers,
    SUM("Exited") AS churned_customers,
    ROUND(100.0 * SUM("Exited") / COUNT(*), 2) AS churn_rate_pct
FROM public.bank_churn
GROUP BY "Geography"
ORDER BY churn_rate_pct ASC;  -- ASC so lowest churn (best) appears first