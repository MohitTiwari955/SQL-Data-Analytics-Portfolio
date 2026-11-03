/* =====================================================================
   CAFE REWARDS OFFERS | 03 - CUSTOMER DEMOGRAPHICS & BEHAVIOUR
   Database: PostgreSQL
   Tables: public.customer, public.event

   Purpose:
   - Profile the customer base by gender, age, and income.
   - Review membership registration dates and observed date coverage.
   - Compare purchasing behaviour across demographic groups.
   - Classify customers by purchase frequency during the experiment.

   IMPORTANT:
   - The SQL statements below are preserved exactly as supplied.
   - Only section headings and explanatory comments have been added.
   - No original query has been removed, rewritten, or replaced.
   - Exact membership tenure is intentionally excluded because the
     experiment's verified calendar start date is unavailable.
   - The customer and event tables contain the cleaned CSV exports loaded
     into PostgreSQL. The customer-level joins retain customers with no
     transactions through LEFT JOIN where applicable.

   CONTRIBUTION / ASSISTANCE NOTE:
   - Excel cleaning was carried out with the Neutron tool/agent using
     prompts prepared with ChatGPT assistance.
   - SQL query development and analysis planning were mostly AI-assisted.
   - The user imported the data into PostgreSQL/DBeaver, executed queries,
     shared outputs, and worked through the SQL logic collaboratively.
   ===================================================================== */

/* ---------------------------------------------------------------------
   1. CUSTOMER DISTRIBUTION BY GENDER
   Business question:
   What is the gender composition of the customer base?

   Metrics:
   - Customer count by gender category.
   - Percentage of all customers in each category.

   Handling:
   - M, F, and O are labelled Male, Female, and Other.
   - NULL, empty, and whitespace-only values are classified as Unknown.
   - Unexpected category values are retained as Unrecognized.

   Observed output:
   Male 8,484 (49.91%); Female 6,129 (36.05%);
   Unknown 2,175 (12.79%); Other 212 (1.25%).
   --------------------------------------------------------------------- */
SELECT
    CASE
        WHEN gender = 'M' THEN 'Male'
        WHEN gender = 'F' THEN 'Female'
        WHEN gender = 'O' THEN 'Other'
        WHEN NULLIF(TRIM(gender), '') IS NULL
            THEN 'Unknown'
        ELSE 'Unrecognized'
    END AS gender_group,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 2
    ) AS customer_percentage

FROM public.customer

GROUP BY gender_group
ORDER BY total_customers DESC;



/* ---------------------------------------------------------------------
   2. CUSTOMER DISTRIBUTION BY AGE GROUP
   Business question:
   How is the customer base distributed across age groups?

   Age bands:
   Under 30, 30-39, 40-49, 50-59, 60+, and Unknown.
   A separate sort_order value ensures age groups appear chronologically.
   The five retained age-101 records fall in the 60+ group and remain
   flagged for review in the cleaning documentation.

   Observed output:
   Under 30: 1,574; 30-39: 1,526; 40-49: 2,309;
   50-59: 3,541; 60+: 5,875; Unknown: 2,175.
   --------------------------------------------------------------------- */
WITH customer_age_groups AS (
    SELECT
        CASE
            WHEN age IS NULL THEN 'Unknown'
            WHEN age < 30 THEN 'Under 30'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS age_group,

        CASE
            WHEN age IS NULL THEN 6
            WHEN age < 30 THEN 1
            WHEN age BETWEEN 30 AND 39 THEN 2
            WHEN age BETWEEN 40 AND 49 THEN 3
            WHEN age BETWEEN 50 AND 59 THEN 4
            ELSE 5
        END AS sort_order

    FROM public.customer
)

SELECT
    age_group,
    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 2
    ) AS customer_percentage

FROM customer_age_groups
GROUP BY age_group, sort_order
ORDER BY sort_order;


/* ---------------------------------------------------------------------
   3. OVERALL CUSTOMER INCOME PROFILE
   Business question:
   What does the income distribution look like among customers with
   recorded income?

   Metrics:
   - Total customers and customers with known income.
   - Missing income count.
   - Mean, median, Q1, Q3, minimum, and maximum income.

   Observed output:
   17,000 customers; 14,825 with income; 2,175 missing;
   mean 65,404.99; median 64,000; Q1 49,000; Q3 80,000;
   minimum 30,000; maximum 120,000.
   --------------------------------------------------------------------- */
SELECT
    COUNT(*) AS total_customers,

    COUNT(income) AS customers_with_income,

    COUNT(*) FILTER (
        WHERE income IS NULL
    ) AS missing_income,

    ROUND(AVG(income), 2) AS average_income,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY income)::NUMERIC, 2
    ) AS median_income,

    ROUND(
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY income)::NUMERIC, 2
    ) AS q1_income,

    ROUND(
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY income)::NUMERIC, 2
    ) AS q3_income,

    MIN(income) AS minimum_income,
    MAX(income) AS maximum_income

FROM public.customer;


/* ---------------------------------------------------------------------
   4. CUSTOMER DISTRIBUTION BY INCOME GROUP
   Business question:
   How many customers fall into each income segment?

   Boundaries used in the analysis:
   - Lower Income: <= 49,000
   - Lower-Middle Income: 49,001 to 64,000
   - Upper-Middle Income: 64,001 to 80,000
   - Higher Income: > 80,000
   - Unknown: NULL income

   Note: These are quartile-informed thresholds. Tied income values mean
   the groups are not guaranteed to contain exactly equal numbers of
   customers. The original query is preserved as supplied.

   Observed output:
   Lower 3,781; Lower-Middle 3,863; Upper-Middle 3,616;
   Higher 3,565; Unknown 2,175.
   --------------------------------------------------------------------- */
WITH classified_customers AS (
    SELECT
        CASE
            WHEN income IS NULL THEN 'Unknown'
            WHEN income <= 49000 THEN 'Lower Income'
            WHEN income <= 64000 THEN 'Lower-Middle Income'
            WHEN income <= 80000 THEN 'Upper-Middle Income'
            ELSE 'Higher Income'
        END AS income_group

    FROM public.customer
)

SELECT
    income_group,
    COUNT(*) AS total_customers,
      ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 2
    ) AS customer_percentage

FROM classified_customers
GROUP BY income_group;


/* ---------------------------------------------------------------------
   5. MEMBERSHIP REGISTRATIONS BY YEAR
   Business question:
   In which calendar years did customers join the rewards programme?

   Interpretation note:
   The observed date range begins on 2013-07-29 and ends on 2018-07-26.
   Therefore 2013 and 2018 are partial calendar years and should not be
   compared directly with the full years 2014-2017.

   Observed output:
   2013: 286; 2014: 691; 2015: 1,830; 2016: 3,526;
   2017: 6,469; 2018: 4,198.
   --------------------------------------------------------------------- */
SELECT
    EXTRACT(YEAR FROM became_member_on) AS membership_year,
    COUNT(*) AS new_customers
FROM public.customer
GROUP BY membership_year
ORDER BY membership_year;


/* ---------------------------------------------------------------------
   6. OBSERVED MEMBERSHIP DATE COVERAGE
   Purpose:
   Confirm the earliest and latest membership dates represented in the
   customer table and the number of customer records.

   Observed output:
   Earliest: 2013-07-29; latest: 2018-07-26; customers: 17,000.

   Scope decision:
   Exact membership tenure is intentionally not calculated because the
   experiment's verified calendar start date is unavailable. The event
   time column is elapsed experiment time, not a calendar date.
   --------------------------------------------------------------------- */
SELECT
    MIN(became_member_on) AS earliest_membership,
    MAX(became_member_on) AS latest_membership,
    COUNT(*) AS total_customers
FROM public.customer;



/* ---------------------------------------------------------------------
   7. PURCHASING BEHAVIOUR BY AGE GROUP
   Business question:
   Do age groups differ in purchasing participation, frequency, and spend?

   Method:
   - Aggregate transactions and spending to one row per customer.
   - LEFT JOIN retains customers with no transactions.
   - Average customer spending includes non-purchasers as zero.
   - Average transaction value is total spending / total transactions.

   Observed highlights:
   Under 30: 10.31 average transactions/customer;
   60+: 7.76 average transactions/customer.
   Average transaction value: 8.15 (Under 30) versus 16.43 (60+).
   Average spending/customer: 127.72 (50-59) and 127.41 (60+).

   Note: Age 118 was converted to NULL; the five age-101 records were
   retained and fall into the 60+ category.
   --------------------------------------------------------------------- */
WITH customer_activity AS (
    SELECT
        c.customer_id,

        CASE
            WHEN c.age IS NULL THEN 'Unknown'
            WHEN c.age < 30 THEN 'Under 30'
            WHEN c.age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS age_group,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'transaction'
        ) AS total_transactions,

        COALESCE(
            SUM(e.amount) FILTER (
                WHERE e.event = 'transaction'
            ), 0
        ) AS total_spending

    FROM public.customer c
    LEFT JOIN public.event e
        ON c.customer_id = e.customer_id

    GROUP BY c.customer_id, age_group
)

SELECT
    age_group,
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE total_transactions > 0
    ) AS purchasing_customers,

    ROUND(
        COUNT(*) FILTER (
            WHERE total_transactions > 0
        ) * 100.0 / COUNT(*), 2
    ) AS purchasing_rate,

    SUM(total_transactions) AS total_transactions,

    ROUND(AVG(total_transactions), 2)
        AS avg_transactions_per_customer,

    ROUND(SUM(total_spending), 2)
        AS total_spending,

    ROUND(AVG(total_spending), 2)
        AS avg_spending_per_customer,

    ROUND(
        SUM(total_spending) /
        NULLIF(SUM(total_transactions), 0), 2
    ) AS avg_transaction_value

FROM customer_activity
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN 'Under 30' THEN 1
        WHEN '30-39' THEN 2
        WHEN '40-49' THEN 3
        WHEN '50-59' THEN 4
        WHEN '60+' THEN 5
        ELSE 6
    END;


/* ---------------------------------------------------------------------
   8. PURCHASING BEHAVIOUR BY GENDER
   Business question:
   Do gender groups differ in purchasing participation, frequency,
   customer spending, and average transaction value?

   Method:
   - Normalize surrounding whitespace and case for gender codes.
   - Missing gender values are classified as Unknown.
   - LEFT JOIN retains customers with no transactions.

   Observed highlights:
   Male: 8.58 average transactions/customer; 99.59 average spending/customer;
   average transaction value 11.61.
   Female: 8.06 average transactions/customer; 140.92 average spending/customer;
   average transaction value 17.49.
   Male and female purchasing rates were approximately 97.77% and 97.78%.
   --------------------------------------------------------------------- */
WITH customer_activity AS (
    SELECT
        c.customer_id,

        CASE
            WHEN NULLIF(TRIM(c.gender), '') IS NULL
                THEN 'Unknown'
            WHEN UPPER(TRIM(c.gender)) = 'M'
                THEN 'Male'
            WHEN UPPER(TRIM(c.gender)) = 'F'
                THEN 'Female'
            WHEN UPPER(TRIM(c.gender)) = 'O'
                THEN 'Other'
            ELSE 'Unrecognized'
        END AS gender_group,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'transaction'
        ) AS total_transactions,

        COALESCE(
            SUM(e.amount) FILTER (
                WHERE e.event = 'transaction'
            ), 0
        ) AS total_spending

    FROM public.customer c
    LEFT JOIN public.event e
        ON c.customer_id = e.customer_id

    GROUP BY c.customer_id, gender_group
)

SELECT
    gender_group,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE total_transactions > 0
    ) AS purchasing_customers,

    ROUND(
        COUNT(*) FILTER (
            WHERE total_transactions > 0
        ) * 100.0 / COUNT(*), 2
    ) AS purchasing_rate,

    SUM(total_transactions) AS total_transactions,

    ROUND(AVG(total_transactions), 2)
        AS avg_transactions_per_customer,

    ROUND(SUM(total_spending), 2)
        AS total_spending,

    ROUND(AVG(total_spending), 2)
        AS avg_spending_per_customer,

    ROUND(
        SUM(total_spending) /
        NULLIF(SUM(total_transactions), 0), 2
    ) AS avg_transaction_value

FROM customer_activity
GROUP BY gender_group
ORDER BY
    CASE gender_group
        WHEN 'Male' THEN 1
        WHEN 'Female' THEN 2
        WHEN 'Other' THEN 3
        WHEN 'Unknown' THEN 4
        ELSE 5
    END;



/* ---------------------------------------------------------------------
   9. PURCHASING BEHAVIOUR BY INCOME GROUP
   Business question:
   Do income groups differ in purchasing participation, frequency,
   customer spending, and average transaction value?

   Method:
   - Reuse the same income thresholds established in the income profile.
   - LEFT JOIN retains customers with no transactions.
   - Unknown income remains a separate group.

   Observed highlights:
   Lower Income: 10.04 average transactions/customer and 6.68 average
   transaction value.
   Higher Income: 6.27 average transactions/customer and 28.39 average
   transaction value.
   Average spending/customer: 67.08 (Lower) versus 177.92 (Higher).
   --------------------------------------------------------------------- */
WITH customer_activity AS (
    SELECT
        c.customer_id,

        CASE
            WHEN c.income IS NULL THEN 'Unknown'
            WHEN c.income <= 49000 THEN 'Lower Income'
            WHEN c.income <= 64000 THEN 'Lower-Middle Income'
            WHEN c.income <= 80000 THEN 'Upper-Middle Income'
            ELSE 'Higher Income'
        END AS income_group,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'transaction'
        ) AS total_transactions,

        COALESCE(
            SUM(e.amount) FILTER (
                WHERE e.event = 'transaction'
            ), 0
        ) AS total_spending

    FROM public.customer c
    LEFT JOIN public.event e
        ON c.customer_id = e.customer_id

    GROUP BY c.customer_id, income_group
)

SELECT
    income_group,
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE total_transactions > 0
    ) AS purchasing_customers,

    ROUND(
        COUNT(*) FILTER (
            WHERE total_transactions > 0
        ) * 100.0 / COUNT(*), 2
    ) AS purchasing_rate,

    SUM(total_transactions) AS total_transactions,

    ROUND(AVG(total_transactions), 2)
        AS avg_transactions_per_customer,

    ROUND(SUM(total_spending), 2)
        AS total_spending,

    ROUND(AVG(total_spending), 2)
        AS avg_spending_per_customer,

    ROUND(
        SUM(total_spending) /
        NULLIF(SUM(total_transactions), 0), 2
    ) AS avg_transaction_value

FROM customer_activity
GROUP BY income_group
ORDER BY
    CASE income_group
        WHEN 'Lower Income' THEN 1
        WHEN 'Lower-Middle Income' THEN 2
        WHEN 'Upper-Middle Income' THEN 3
        WHEN 'Higher Income' THEN 4
        ELSE 5
    END;




/* ---------------------------------------------------------------------
   10. CUSTOMER CLASSIFICATION BY PURCHASE FREQUENCY
   Business question:
   How many customers made no purchases, exactly one purchase, or repeat
   purchases during the observed experiment period?

   Definitions:
   - No Purchase: 0 transactions.
   - One-time Purchaser: exactly 1 transaction.
   - Repeat Purchaser: more than 1 transaction.

   Observed output:
   No Purchase: 422 (2.48%);
   One-time Purchaser: 401 (2.36%);
   Repeat Purchaser: 16,177 (95.16%).

   Interpretation caution:
   Repeat purchasing during this experiment does not establish long-term
   loyalty or retention.

   PRESERVATION NOTE:
   The final ORDER BY CASE expression below is retained exactly as supplied.
   In PostgreSQL, the reference to total_transactions inside this expression
   may be rejected at this grouped query level because total_transactions
   is neither grouped nor aggregated here. It has not been modified, per the
   instruction to preserve every supplied SQL statement. Verify this clause
   if rerunning the script.
   --------------------------------------------------------------------- */
WITH customer_purchases AS (
    SELECT
        c.customer_id,
        COUNT(e.customer_id) AS total_transactions,
        COALESCE(SUM(e.amount), 0) AS total_spending

    FROM public.customer c
    LEFT JOIN public.event e
        ON c.customer_id = e.customer_id
        AND e.event = 'transaction'

    GROUP BY c.customer_id
)

SELECT
    CASE
        WHEN total_transactions = 0 THEN 'No Purchase'
        WHEN total_transactions = 1 THEN 'One-time Purchaser'
        ELSE 'Repeat Purchaser'
    END AS customer_type,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS customer_percentage,

    SUM(total_transactions) AS total_transactions,

    ROUND(SUM(total_spending), 2) AS total_spending,

    ROUND(AVG(total_spending), 2) AS avg_spending_per_customer

FROM customer_purchases
GROUP BY customer_type
ORDER BY
     CASE
        WHEN total_transactions = 0 THEN 'No Purchase'
        WHEN total_transactions = 1 THEN 'One-time Purchaser'
        ELSE 'Repeat Purchaser'
    END;
