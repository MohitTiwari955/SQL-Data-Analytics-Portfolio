/* =====================================================================
   CAFE REWARDS OFFERS | 06 - CUSTOMER ENGAGEMENT ANALYSIS (PHASE 5)
   Database: PostgreSQL
   Tables: public.customer, public.event

   Purpose:
   - Classify customers by their highest recorded offer-engagement stage.
   - Verify customers who completed an offer without a recorded view.
   - Measure one-time and repeat offer-viewing and completion activity.
   - Compare purchasing behaviour across offer-completion groups.

   IMPORTANT:
   - The SQL statements below are preserved exactly as supplied in the
     uploaded Phase 4/5 script. No original query has been removed,
     rewritten, or replaced. Only headings and explanatory comments
     have been added around the statements.
   - Customer engagement groups are based on activity across the full
     experiment; they are not a strict matched offer-instance funnel.
   - Repeat view/completion counts are event counts across the experiment.
     They do not necessarily represent distinct offers viewed or completed.
   - The purchasing comparison is descriptive. Offer completion is
     associated with qualifying purchase activity, so the results do not
     establish that completing offers caused higher spending.
   - COALESCE converts missing transaction spending to zero so that
     average spending is calculated across all customers in each group,
     including customers with no recorded transactions.

   CONTRIBUTION / ASSISTANCE NOTE:
   - SQL analysis planning and query development were carried out
     collaboratively with ChatGPT assistance.
   - The user executed the queries in PostgreSQL/DBeaver, reviewed the
     outputs, and worked through the analytical logic.
   ===================================================================== */

/* ---------------------------------------------------------------------
   5.1 CUSTOMER OFFER-ENGAGEMENT CLASSIFICATION
   Business question:
   How many customers reached each offer-engagement stage?

   Classification priority:
   - Completed at least one offer.
   - Viewed offers but recorded no completion.
   - Received offers but never viewed an offer.
   - No matching offer activity.

   The CASE expression assigns each customer to one mutually exclusive
   group based on the highest stage they reached.

   Observed output:
   - Completed at least one offer: 12,774 (75.14%).
   - Viewed but no completion: 4,133 (24.31%).
   - Received but never viewed: 87 (0.51%).
   - No offer activity: 6 (0.04%).

   Interpretation:
   This is a customer-level classification across the experiment, not a
   strict event-by-event funnel. A completion can be recorded without a
   corresponding view event.
   --------------------------------------------------------------------- */
WITH customer_activity AS (
    SELECT
        c.customer_id,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'offer received'
        ) AS received_events,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'offer viewed'
        ) AS viewed_events,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completed_events

    FROM public.customer c

    LEFT JOIN public.event e
        ON c.customer_id = e.customer_id
        AND e.event IN (
            'offer received',
            'offer viewed',
            'offer completed'
        )

    GROUP BY c.customer_id
)

SELECT
    CASE
        WHEN completed_events > 0
            THEN 'Completed at least one offer'
        WHEN viewed_events > 0
            THEN 'Viewed but no completion'
        WHEN received_events > 0
            THEN 'Received but never viewed'
        ELSE 'No offer activity'
    END AS engagement_group,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 2
    ) AS customer_percentage

FROM customer_activity

GROUP BY engagement_group

ORDER BY
    CASE
        WHEN MAX(completed_events) > 0 THEN 1
        WHEN MAX(viewed_events) > 0 THEN 2
        WHEN MAX(received_events) > 0 THEN 3
        ELSE 4
    END;



/* ---------------------------------------------------------------------
   5.1.1 VALIDATION: COMPLETED WITHOUT ANY RECORDED VIEW
   Business question:
   How many distinct customers had at least one offer-completed event
   but no offer-viewed event anywhere in the experiment?

   Observed output:
   - 73 customers.

   Validation note:
   This query groups by customer_id across the experiment, not by
   offer_id. It verifies the customer-level count inferred from the
   Phase 5.1 classification and event-level unique-customer totals.
   --------------------------------------------------------------------- */
SELECT
    COUNT(*) AS customers_completed_without_view

FROM (
    SELECT
        customer_id

    FROM public.event

    WHERE event IN (
        'offer viewed',
        'offer completed'
    )

    GROUP BY customer_id

    HAVING
        COUNT(*) FILTER (
            WHERE event = 'offer completed'
        ) > 0

        AND

        COUNT(*) FILTER (
            WHERE event = 'offer viewed'
        ) = 0

) AS customer_check;



/* ---------------------------------------------------------------------
   5.2 REPEAT OFFER-ENGAGEMENT ANALYSIS
   Business question:
   How many customers generated no, one, or multiple view and completion
   events during the experiment?

   Classification:
   - No engagement: zero relevant events.
   - One-time engagement: exactly one relevant event.
   - Repeat engagement: more than one relevant event.

   Observed output:
   Viewing:
   - No views: 166 customers.
   - One view: 1,027 customers.
   - Repeat views: 15,807 customers (92.98% of all customers).

   Completion:
   - No completions: 4,226 customers.
   - One completion: 3,214 customers.
   - Repeat completions: 9,560 customers (56.24% of all customers).

   Important interpretation:
   These are event counts across the full experiment. Multiple view events
   can relate to the same offer or to different offers. Likewise, multiple
   completion events do not necessarily prove completion of multiple
   distinct offers.
   --------------------------------------------------------------------- */
WITH customer_activity AS (
    SELECT
        c.customer_id,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'offer viewed'
        ) AS view_events,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completion_events

    FROM public.customer c

    LEFT JOIN public.event e
        ON c.customer_id = e.customer_id
        AND e.event IN (
            'offer viewed',
            'offer completed'
        )

    GROUP BY c.customer_id
)

SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE view_events = 0
    ) AS customers_no_views,

    COUNT(*) FILTER (
        WHERE view_events = 1
    ) AS customers_one_view,

    COUNT(*) FILTER (
        WHERE view_events > 1
    ) AS customers_repeat_views,

    COUNT(*) FILTER (
        WHERE completion_events = 0
    ) AS customers_no_completions,

    COUNT(*) FILTER (
        WHERE completion_events = 1
    ) AS customers_one_completion,

    COUNT(*) FILTER (
        WHERE completion_events > 1
    ) AS customers_repeat_completions

FROM customer_activity;



/* ---------------------------------------------------------------------
   5.3 OFFER COMPLETION ENGAGEMENT VS PURCHASING BEHAVIOUR
   Business question:
   How does transaction activity and spending differ among customers
   with no, one-time, and repeat offer-completion events?

   Customer groups:
   - No offer completion.
   - One-time completion.
   - Repeat completion.

   Metrics:
   - Total customers and purchasing customers.
   - Total transactions and average transactions per customer.
   - Total spending and average spending per customer.
   - Average transaction value for each group.

   Observed output:
   - No completion: 4,226 customers; 20,775 transactions;
     average spending/customer $18.04; average transaction value $3.67.
   - One-time completion: 3,214 customers; 24,115 transactions;
     average spending/customer $55.89; average transaction value $7.45.
   - Repeat completion: 9,560 customers; 94,063 transactions;
     average spending/customer $158.95; average transaction value $16.15.

   Validation:
   The three groups reconcile to 17,000 customers, 138,953 transactions,
   and total spending of $1,775,451.97.

   Interpretation and limitation:
   Repeat completers show higher observed purchasing frequency, average
   spending, and average transaction value. This is descriptive association,
   not proof that offer completion caused higher spending. Offer completion
   itself is associated with qualifying purchase activity.
   --------------------------------------------------------------------- */
WITH customer_activity AS (
    SELECT
        c.customer_id,

        COUNT(e.customer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) AS completion_events,

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
        AND e.event IN ('offer completed', 'transaction')

    GROUP BY c.customer_id
)

SELECT
    CASE
        WHEN completion_events = 0 THEN 'No offer completion'
        WHEN completion_events = 1 THEN 'One-time completion'
        ELSE 'Repeat completion'
    END AS engagement_group,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE total_transactions > 0
    ) AS purchasing_customers,

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

GROUP BY engagement_group

ORDER BY MIN(completion_events);
