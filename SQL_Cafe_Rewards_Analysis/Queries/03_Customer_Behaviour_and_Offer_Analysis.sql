/* =====================================================================
   CAFE REWARDS OFFERS | 03 - CUSTOMER BEHAVIOUR & OFFER ANALYSIS
   Database: PostgreSQL

   This file contains customer-level follow-up analysis already executed
   during the current project, plus clearly marked next-stage work areas.

   Completed queries below were drafted with AI assistance and run/checked
   by the user in DBeaver. Demographic and offer-conversion analysis has not
   yet been completed; do not treat the TODO sections as finished findings.
   ===================================================================== */

/* ---------------------------------------------------------------------
   1. HIGH-VALUE SPENDING CONCENTRATION BY CUSTOMER
   Goal: Within customers who made at least one transaction above 41.005,
   rank customers by the sum of those qualifying transactions and calculate
   individual and cumulative contributions to all high-value transaction
   value.

   DENSE_RANK gives equal-spending customers equal ranks. The cumulative
   running total uses customer_id as a deterministic tie-breaker, so tied
   customers can receive different row-by-row cumulative percentages.
   WHERE customer_rank <= 100 means the first 100 distinct spending ranks;
   ties may result in more than 100 customers.

   Observed top-100 result: cumulative contribution 33.53% of high-value
   transaction value (247,145.38 total).
   --------------------------------------------------------------------- */
WITH customer_spending AS (
    SELECT
        customer_id,
        COUNT(*) AS high_value_transactions,
        SUM(amount) AS high_value_spending,
        AVG(amount) AS avg_transaction_value
    FROM public.event
    WHERE event = 'transaction'
      AND amount > 41.005
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        high_value_transactions,
        ROUND(high_value_spending, 2) AS high_value_spending,
        ROUND(avg_transaction_value, 2) AS avg_transaction_value,
        DENSE_RANK() OVER (
            ORDER BY high_value_spending DESC
        ) AS customer_rank,
        ROUND(
            high_value_spending * 100.0 / SUM(high_value_spending) OVER (),
            2
        ) AS individual_contribution_pct,
        ROUND(
            SUM(high_value_spending) OVER (
                ORDER BY high_value_spending DESC, customer_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) * 100.0 / SUM(high_value_spending) OVER (),
            2
        ) AS cumulative_contribution_pct
    FROM customer_spending
)
SELECT *
FROM ranked_customers
WHERE customer_rank <= 100
ORDER BY customer_rank, customer_id;

/* ---------------------------------------------------------------------
   2. OVERALL PURCHASING BEHAVIOUR: HIGH-VALUE-TRANSACTION CUSTOMERS VS OTHERS
   A customer is in the first group if BOOL_OR finds at least one transaction
   above 41.005. Every transaction (high and regular) contributes to their
   total transactions and total spending in this comparison.

   Observed output:
   High-value group: 1,151 customers, 11,402 transactions, average 9.91
   transactions/customer, total spending 397,694.52, average spending
   345.52/customer, average transaction 34.88.
   Other group: 15,427 customers, 127,551 transactions, average 8.27
   transactions/customer, total spending 1,377,757.45, average spending
   89.31/customer, average transaction 10.80.
   --------------------------------------------------------------------- */
WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS total_transactions,
        SUM(amount) AS total_spending,
        BOOL_OR(amount > 41.005) AS has_high_value_transaction
    FROM public.event
    WHERE event = 'transaction'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN has_high_value_transaction THEN 'High-value transaction customers'
        ELSE 'Other customers'
    END AS customer_group,
    COUNT(*) AS total_customers,
    SUM(total_transactions) AS total_transactions,
    ROUND(AVG(total_transactions), 2) AS avg_transactions_per_customer,
    ROUND(SUM(total_spending), 2) AS total_spending,
    ROUND(AVG(total_spending), 2) AS avg_spending_per_customer,
    ROUND(SUM(total_spending) / SUM(total_transactions), 2) AS avg_transaction_value
FROM customer_summary
GROUP BY has_high_value_transaction
ORDER BY has_high_value_transaction DESC;

/* ---------------------------------------------------------------------
   3. ORDINARY PURCHASE BEHAVIOUR FOR THE SAME TWO CUSTOMER GROUPS
   To prevent the qualifying large purchases from driving the comparison,
   this query calculates each customer's transactions and spending at or
   below 41.005 only. Customers with no regular transaction are kept and
   assigned zero for these two measures in the final averages.

   Observed output:
   High-value group: 1,151 customers; average 8.83 regular transactions;
   average regular spending 130.80 per customer.
   Other group: 15,427 customers; average 8.27 regular transactions;
   average regular spending 89.31 per customer.
   --------------------------------------------------------------------- */
WITH customer_summary AS (
    SELECT
        customer_id,
        BOOL_OR(amount > 41.005) AS has_high_value_transaction,
        COUNT(*) FILTER (WHERE amount <= 41.005) AS regular_transactions,
        SUM(amount) FILTER (WHERE amount <= 41.005) AS regular_spending
    FROM public.event
    WHERE event = 'transaction'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN has_high_value_transaction THEN 'High-value customers'
        ELSE 'Other customers'
    END AS customer_group,
    COUNT(*) AS total_customers,
    ROUND(AVG(regular_transactions), 2) AS avg_regular_transactions,
    ROUND(AVG(COALESCE(regular_spending, 0)), 2) AS avg_regular_spending
FROM customer_summary
GROUP BY has_high_value_transaction
ORDER BY has_high_value_transaction DESC;

/* =====================================================================
   NEXT ANALYSIS AREAS - NOT YET EXECUTED
   Add queries here only after defining the business question and validating
   the required metrics. Planned areas:

   A. Customer demographics and purchasing behaviour
      - Customer distribution by gender, age band and income band.
      - Membership sign-up patterns and tenure.
      - Compare purchase frequency / spending across demographic groups.
      - Report unknown demographic values separately; do not impute them.

   B. Repeat-purchase behaviour
      - Define a repeat customer clearly (e.g., 2+ transaction events).
      - Compare repeat rate, frequency and total spend.
      - Decide whether transaction events represent purchases at the
        appropriate grain before interpreting purchase frequency.

   C. Offer performance and conversion
      - Offer inventory characteristics by offer_type, difficulty, reward,
        duration and channels.
      - Match offer received/viewed/completed events by customer_id + offer_id.
      - Respect event time and repeated offer exposures; do not divide raw
        daily event counts to claim a conversion rate.
      - Separate offer completion from incremental sales / causal impact.

   D. Customer segmentation and recommendations
      - Consider RFM-style measures after validating the experiment window.
      - Use clustering only if resulting segments are interpretable and useful.
      - Clearly distinguish descriptive associations from causal claims.
   ===================================================================== */
