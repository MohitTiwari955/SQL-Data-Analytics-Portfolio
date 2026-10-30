--What attributes are more common among churners than non-churners? Can churn be predicted using the variables in the data?

-- Query 1 - Overall Churn Attributes Comparison:-
-------------------------------------------------------------------
SELECT
    "Exited",
    CASE 
        WHEN "Exited" = 1 THEN 'Churners (Exited=1)' 
        ELSE 'Non-Churners (Exited=0)' 
    END AS group_name,
    COUNT(*) AS total_count,
    
    -- Categorical Features: Geography
    (COUNT(*) FILTER (WHERE "Geography" = 'France') * 100.0 / COUNT(*))::numeric(5,2) AS pct_france,
    (COUNT(*) FILTER (WHERE "Geography" = 'Germany') * 100.0 / COUNT(*))::numeric(5,2) AS pct_germany,
    (COUNT(*) FILTER (WHERE "Geography" = 'Spain') * 100.0 / COUNT(*))::numeric(5,2) AS pct_spain,
    
    -- Categorical Features: Gender
    (COUNT(*) FILTER (WHERE "Gender" = 'Male') * 100.0 / COUNT(*))::numeric(5,2) AS pct_male,
    (COUNT(*) FILTER (WHERE "Gender" = 'Female') * 100.0 / COUNT(*))::numeric(5,2) AS pct_female,
    
    -- Categorical Features: Indicators
    (COUNT(*) FILTER (WHERE "HasCrCard" = 1) * 100.0 / COUNT(*))::numeric(5,2) AS pct_has_crcard,
    (COUNT(*) FILTER (WHERE "HasCrCard" = 0) * 100.0 / COUNT(*))::numeric(5,2) AS pct_no_crcard,
    (COUNT(*) FILTER (WHERE "IsActiveMember" = 1) * 100.0 / COUNT(*))::numeric(5,2) AS pct_active,
    (COUNT(*) FILTER (WHERE "IsActiveMember" = 0) * 100.0 / COUNT(*))::numeric(5,2) AS pct_inactive,
    
    -- Categorical Features: Product Distribution
    (COUNT(*) FILTER (WHERE "NumOfProducts" = 1) * 100.0 / COUNT(*))::numeric(5,2) AS pct_1_product,
    (COUNT(*) FILTER (WHERE "NumOfProducts" = 2) * 100.0 / COUNT(*))::numeric(5,2) AS pct_2_products,
    (COUNT(*) FILTER (WHERE "NumOfProducts" >= 3) * 100.0 / COUNT(*))::numeric(5,2) AS pct_3plus_products,
    
    -- Numerical Averages
    AVG("CreditScore")::numeric(10,2) AS avg_credit_score,
    AVG("Age")::numeric(10,2) AS avg_age,
    AVG("Tenure")::numeric(10,2) AS avg_tenure,
    AVG("Balance")::numeric(10,2) AS avg_balance,
    AVG("EstimatedSalary")::numeric(10,2) AS avg_est_salary
FROM bank_churn
GROUP BY "Exited"
ORDER BY "Exited" DESC;

-- QUERY 2 — Churn by Geography
-- France vs Germany vs Spain: Counts and Churn Rates.
-- ------------------------------------------------------------------
SELECT
    "Geography",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Exited" = 1 THEN 1 ELSE 0 END) AS churned_count,
    COUNT(*) - SUM(CASE WHEN "Exited" = 1 THEN 1 ELSE 0 END) AS retained_count,
    ROUND(100.0 * SUM(CASE WHEN "Exited" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_pct
FROM bank_churn
GROUP BY "Geography"
ORDER BY churn_rate_pct DESC;

-- QUERY 3 — Churn by Gender
-- Male vs Female: Counts and Churn Rates.
-- ------------------------------------------------------------------
SELECT
    "Gender",
    COUNT(*) AS total_customers,
    SUM("Exited") AS churned_count,
    COUNT(*) - SUM("Exited") AS retained_count,
    ROUND(100.0 * SUM("Exited") / COUNT(*), 2) AS churn_rate_pct
FROM bank_churn
GROUP BY "Gender"
ORDER BY churn_rate_pct DESC;

 
-- QUERY 4 — Churn by Credit Card Ownership
-- HasCrCard (1 = Yes, 0 = No).
-- ------------------------------------------------------------------
SELECT
    CASE
        WHEN "HasCrCard" = 1 THEN 'Has Credit Card'
        ELSE 'No Credit Card'
    END AS card_status,
    COUNT(*) AS total_customers,
    SUM("Exited") AS churned_count,
    COUNT(*) - SUM("Exited") AS retained_count,
    ROUND(100.0 * SUM("Exited") / COUNT(*),2) AS churn_rate_pct
FROM public.bank_churn
GROUP BY "HasCrCard"
ORDER BY churn_rate_pct DESC;
 
-- QUERY 5 — Churn by Active Membership
-- IsActiveMember (1 = Active, 0 = Inactive). Compare churn rates for active and inactive members.
-- ------------------------------------------------------------------
SELECT
    CASE "IsActiveMember" WHEN 1 THEN 'Active' ELSE 'Inactive' END AS activity_status,
    COUNT(*) AS total_customers,
    SUM("Exited") AS churned_count,
    COUNT(*) - SUM("Exited") AS retained_count,
    ROUND(100.0 * SUM("Exited") / COUNT(*), 2) AS churn_rate_pct
FROM bank_churn
GROUP BY "IsActiveMember"
ORDER BY churn_rate_pct DESC;
 
-- QUERY 6 — Churn by Number of Products
-- Distribution across 1, 2, 3, 4 products.
-- ------------------------------------------------------------------

SELECT
    "NumOfProducts",
    COUNT(*) AS total_customers,
    SUM("Exited") AS churned_count,
    COUNT(*) - SUM("Exited") AS retained_count,
    ROUND(100.0 * SUM("Exited") / COUNT(*),2) AS churn_rate_pct
FROM public.bank_churn
GROUP BY "NumOfProducts"
ORDER BY "NumOfProducts";

-- QUERIES 7–11 COMBINED: Numerical Attributes "Table 1" Summary
-- Compares Churners (Exited=1) vs Non-Churners (Exited=0) side-by-side
-- ------------------------------------------------------------------

SELECT
    'Age' AS attribute,
    ROUND(AVG("Age") FILTER (WHERE "Exited" = 1)::numeric, 2) AS avg_churned,
    ROUND(AVG("Age") FILTER (WHERE "Exited" = 0)::numeric, 2) AS avg_retained,
    MIN("Age") FILTER (WHERE "Exited" = 1) AS min_churned,
    MAX("Age") FILTER (WHERE "Exited" = 1) AS max_churned,
    MIN("Age") FILTER (WHERE "Exited" = 0) AS min_retained,
    MAX("Age") FILTER (WHERE "Exited" = 0) AS max_retained
FROM bank_churn

UNION ALL

SELECT
    'CreditScore',
    ROUND(AVG("CreditScore") FILTER (WHERE "Exited" = 1)::numeric, 2),
    ROUND(AVG("CreditScore") FILTER (WHERE "Exited" = 0)::numeric, 2),
    MIN("CreditScore") FILTER (WHERE "Exited" = 1),
    MAX("CreditScore") FILTER (WHERE "Exited" = 1),
    MIN("CreditScore") FILTER (WHERE "Exited" = 0),
    MAX("CreditScore") FILTER (WHERE "Exited" = 0)
FROM bank_churn

UNION ALL

SELECT
    'Tenure',
    ROUND(AVG("Tenure") FILTER (WHERE "Exited" = 1)::numeric, 2),
    ROUND(AVG("Tenure") FILTER (WHERE "Exited" = 0)::numeric, 2),
    MIN("Tenure") FILTER (WHERE "Exited" = 1),
    MAX("Tenure") FILTER (WHERE "Exited" = 1),
    MIN("Tenure") FILTER (WHERE "Exited" = 0),
    MAX("Tenure") FILTER (WHERE "Exited" = 0)
FROM bank_churn

UNION ALL

SELECT
    'Balance',
    ROUND(AVG("Balance") FILTER (WHERE "Exited" = 1)::numeric, 2),
    ROUND(AVG("Balance") FILTER (WHERE "Exited" = 0)::numeric, 2),
    MIN("Balance") FILTER (WHERE "Exited" = 1),
    MAX("Balance") FILTER (WHERE "Exited" = 1),
    MIN("Balance") FILTER (WHERE "Exited" = 0),
    MAX("Balance") FILTER (WHERE "Exited" = 0)
FROM bank_churn

UNION ALL

SELECT
    'EstimatedSalary',
    ROUND(AVG("EstimatedSalary") FILTER (WHERE "Exited" = 1)::numeric, 2),
    ROUND(AVG("EstimatedSalary") FILTER (WHERE "Exited" = 0)::numeric, 2),
    MIN("EstimatedSalary") FILTER (WHERE "Exited" = 1),
    MAX("EstimatedSalary") FILTER (WHERE "Exited" = 1),
    MIN("EstimatedSalary") FILTER (WHERE "Exited" = 0),
    MAX("EstimatedSalary") FILTER (WHERE "Exited" = 0)
FROM bank_churn;