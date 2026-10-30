-- What types of segments exist within the bank's customers?

-- Balance-based Customer Segmentation using NTILE():-

WITH segmented AS (
    SELECT
        "CustomerId",
        "Balance",
        "Exited",

        CASE
            WHEN "Balance" = 0 THEN 0
            ELSE NTILE(4) OVER (
                PARTITION BY ("Balance" = 0)
                ORDER BY "Balance", "CustomerId")
        END AS segment_order

    FROM public.bank_churn
)

SELECT
    segment_order,

    CASE
        WHEN segment_order = 0 THEN 'Zero Balance'
        WHEN segment_order = 1 THEN 'Q1 - Lowest Positive'
        WHEN segment_order = 2 THEN 'Q2 - Lower-Middle'
        WHEN segment_order = 3 THEN 'Q3 - Upper-Middle'
        WHEN segment_order = 4 THEN 'Q4 - Highest'
    END AS balance_segment,

    COUNT(*) AS total_customers,

    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers,

    ROUND(MIN("Balance")::numeric, 2) AS min_balance,
    ROUND(MAX("Balance")::numeric, 2) AS max_balance,
    ROUND(AVG("Balance")::numeric, 2) AS avg_balance,

    ROUND(100.0 * AVG("Exited"), 2) AS churn_rate_pct

FROM segmented
GROUP BY segment_order
ORDER BY segment_order;

-- Porduct and membership based Customer Segmentation:-

WITH customer_segments AS (
    SELECT
        CASE
            WHEN "NumOfProducts" = 1 THEN '1 Product'
            WHEN "NumOfProducts" = 2 THEN '2 Products'
            ELSE '3+ Products'
        END AS product_segment,

        CASE
            WHEN "IsActiveMember" = 1 THEN 'Active'
            ELSE 'Inactive'
        END AS membership_status,

        "Balance",
        "Age",
        "Exited"

    FROM public.bank_churn
)

SELECT
    product_segment,
    membership_status,

    COUNT(*) AS total_customers,

    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),2) AS pct_of_customers,

    ROUND(AVG("Balance")::numeric, 2) AS avg_balance,

    ROUND(AVG("Age")::numeric, 2) AS avg_age,

    ROUND(100.0 * AVG("Exited"),2) AS churn_rate_pct

FROM customer_segments

GROUP BY product_segment, membership_status

ORDER BY product_segment, membership_status;

-- Geographics segmentation of product and membership based segmentation:-

WITH customer_segments AS (
    SELECT
        "Geography" AS country,

        CASE
            WHEN "NumOfProducts" = 1 THEN '1 Product'
            WHEN "NumOfProducts" = 2 THEN '2 Products'
            ELSE '3+ Products'
        END AS product_segment,

        CASE
            WHEN "IsActiveMember" = 1 THEN 'Active'
            ELSE 'Inactive'
        END AS membership_status,

        "Exited"

    FROM public.bank_churn
),

country_breakdown AS (
    SELECT
        product_segment,
        membership_status,
        country,

        COUNT(*) AS total_customers,

        SUM("Exited") AS churned_customers,

        ROUND(100.0 * AVG("Exited"),2) AS churn_rate_pct

    FROM customer_segments
    GROUP BY
        product_segment,
        membership_status,
        country)

SELECT
    product_segment,
    membership_status,
    country,
    total_customers,

    ROUND(
        100.0 * total_customers /
        SUM(total_customers) OVER (
            PARTITION BY product_segment, membership_status
        ),
        2
    ) AS pct_within_segment,

    churned_customers,
    churn_rate_pct

FROM country_breakdown

ORDER BY
    product_segment,
    membership_status,
    country;