/* =====================================================================
   CAFE REWARDS OFFERS | 02 - EVENT EXPLORATION & TRANSACTION ANALYSIS
   Database: PostgreSQL
   Purpose: Understand event activity, transaction performance, spending
   distribution, and statistically unusual transaction values.

   Completed analysis in this file is AI-assisted: queries were drafted and
   explained with ChatGPT; the user ran them in DBeaver and shared results.
   ===================================================================== */

/* ---------------------------------------------------------------------
   1. EVENT DISTRIBUTION
   Business question: What activity types are recorded, how often do they
   occur, how many customers participate, and what share of all events do
   they represent?

   Observed output:
   transaction 138953 (45.39%)
   offer received 76277 (24.92%)
   offer viewed 57725 (18.86%)
   offer completed 33182 (10.84%)
   --------------------------------------------------------------------- */
SELECT
    event,
    COUNT(*) AS total_events,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS event_percentage,
    MIN(time_hours) AS first_event_hour,
    MAX(time_hours) AS last_event_hour
FROM public.event
GROUP BY event
ORDER BY total_events DESC;

/* ---------------------------------------------------------------------
   2. DAILY EVENT ACTIVITY
   Business question: How does each event type vary across experiment days?
   event_day is elapsed-hour day number, not a calendar date.
   --------------------------------------------------------------------- */
SELECT
    event_day,
    event,
    COUNT(*) AS total_events,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM public.event
GROUP BY event_day, event
ORDER BY event_day, event;

/* ---------------------------------------------------------------------
   3. DAILY TRANSACTION PERFORMANCE
   Business question: How do daily transaction volume, purchasing customers,
   total transaction value, and average transaction value change over time?
   --------------------------------------------------------------------- */
SELECT
    event_day,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_transaction_value,
    ROUND(MIN(amount), 2) AS min_transaction,
    ROUND(MAX(amount), 2) AS max_transaction
FROM public.event
WHERE event = 'transaction'
GROUP BY event_day
ORDER BY event_day;

/* ---------------------------------------------------------------------
   4. OVERALL TRANSACTION VALUE DISTRIBUTION
   Business question: What are the mean, median and quartiles of transaction
   value? This helps assess skew and spread rather than relying only on mean.

   Observed output: 138,953 transactions; total 1,775,451.97; mean 12.78;
   median 8.89; Q1 2.78; Q3 18.07; min 0.05; max 1,062.28.
   --------------------------------------------------------------------- */
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value,
    ROUND((PERCENTILE_CONT(0.25)
           WITHIN GROUP (ORDER BY amount))::NUMERIC, 2) AS q1,
    ROUND((PERCENTILE_CONT(0.50)
           WITHIN GROUP (ORDER BY amount))::NUMERIC, 2) AS median_transaction_value,
    ROUND((PERCENTILE_CONT(0.75)
           WITHIN GROUP (ORDER BY amount))::NUMERIC, 2) AS q3,
    ROUND(MIN(amount), 2) AS minimum_transaction,
    ROUND(MAX(amount), 2) AS maximum_transaction
FROM public.event
WHERE event = 'transaction';

/* ---------------------------------------------------------------------
   5. IQR OUTLIER / HIGH-VALUE TRANSACTION ANALYSIS
   Rule: upper fence = Q3 + 1.5 * (Q3 - Q1).
   Keep the exact calculated threshold for filtering (41.005); 41.01 is only
   the rounded display value. Being above the fence means statistically
   unusual under this rule, not erroneous or fraudulent.

   Observed output: upper fence 41.01; 1,236 transactions; 0.89% of
   transactions; 247,145.38 transaction value; 13.92% of total value.
   --------------------------------------------------------------------- */
WITH transaction_stats AS (
    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY amount) AS q1,
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY amount) AS q3
    FROM public.event
    WHERE event = 'transaction'
),
threshold AS (
    SELECT
        q1,
        q3,
        q3 - q1 AS iqr,
        q3 + 1.5 * (q3 - q1) AS upper_fence
    FROM transaction_stats
)
SELECT
    ROUND(MAX(t.upper_fence)::NUMERIC, 2) AS upper_fence,
    COUNT(*) FILTER (WHERE e.amount > t.upper_fence) AS high_value_transactions,
    ROUND(
        COUNT(*) FILTER (WHERE e.amount > t.upper_fence) * 100.0 / COUNT(*),
        2
    ) AS percentage_of_transactions,
    ROUND(
        SUM(e.amount) FILTER (WHERE e.amount > t.upper_fence),
        2
    ) AS high_value_transaction_value,
    ROUND(
        SUM(e.amount) FILTER (WHERE e.amount > t.upper_fence) * 100.0
        / SUM(e.amount),
        2
    ) AS percentage_of_total_value
FROM public.event e
CROSS JOIN threshold t
WHERE e.event = 'transaction';

/* ---------------------------------------------------------------------
   6. CUSTOMER COUNT FOR HIGH-VALUE TRANSACTIONS
   Question: How many distinct purchasing customers made at least one
   transaction above the calculated IQR upper fence?
   The exact (unrounded) upper fence from this dataset is 41.005.
   --------------------------------------------------------------------- */
SELECT
    COUNT(DISTINCT customer_id) FILTER (
        WHERE amount > 41.005
    ) AS high_value_customers,
    ROUND(
        COUNT(DISTINCT customer_id) FILTER (WHERE amount > 41.005) * 100.0
        / COUNT(DISTINCT customer_id),
        2
    ) AS percentage_of_customers
FROM public.event
WHERE event = 'transaction';

/* Observed output: 1,151 high-value customers, 6.94% of 16,578 purchasing
   customers. This is customer share, not transaction share. */
