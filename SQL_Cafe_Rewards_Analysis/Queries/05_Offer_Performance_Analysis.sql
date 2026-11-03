/* =====================================================================
   CAFE REWARDS OFFERS | 05 - OFFER PERFORMANCE ANALYSIS (PHASE 4)
   Database: PostgreSQL
   Tables: public.offer, public.offer_channels, public.event

   Purpose:
   - Inspect the offer catalogue and distribution patterns.
   - Measure offer viewing and completion activity.
   - Compare BOGO, discount, and informational offer performance.
   - Explore difficulty, reward, and duration alongside completion.
   - Review the communication channels assigned to each offer.

   IMPORTANT:
   - The SQL statements below are preserved exactly as supplied in the
     uploaded Phase 4/5 script. No original query has been removed,
     rewritten, or replaced. Only headings and explanatory comments
     have been added around the statements.
   - The supplementary SELECT * FROM EVENT statement from the source
     script is retained under Section 4.2 as an exploratory inspection.
   - View-to-received and completion-to-received ratios are event-count
     ratios. They are not verified customer-level or delivery-level
     conversion rates.
   - Unique-customer counts are distinct within each offer or offer-type
     group. The same customer can appear in multiple groups.
   - Offer-channel records describe channels configured for an offer.
     They do not identify the channel that actually delivered an offer
     to an individual customer.
   - Phase 4.6 comparisons are exploratory: the catalogue contains only
     eight redeemable offers, so the results do not establish causation.

   CONTRIBUTION / ASSISTANCE NOTE:
   - SQL analysis planning and query development were carried out
     collaboratively with ChatGPT assistance.
   - The user executed the queries in PostgreSQL/DBeaver, reviewed the
     outputs, and worked through the analytical logic.
   ===================================================================== */

/* ---------------------------------------------------------------------
   4.1 OFFER CATALOGUE OVERVIEW
   Business question:
   What offers were available in the experiment, and how did they differ?

   Fields reviewed:
   - Offer type (BOGO, discount, informational).
   - Difficulty / required spending threshold.
   - Reward value.
   - Offer duration in days.

   Observed catalogue:
   - 10 offers in total: 4 BOGO, 4 discount, and 2 informational.
   - Durations range from 3 to 10 days.
   - Informational offers have zero difficulty and zero reward.
   --------------------------------------------------------------------- */
SELECT
    offer_id,
    offer_type,
    difficulty,
    reward,
    duration
FROM public.offer
ORDER BY
    offer_type,
    duration,
    difficulty,
    reward;



/* ---------------------------------------------------------------------
   4.2 OFFER DISTRIBUTION BY INDIVIDUAL OFFER
   Business question:
   Which offers were distributed most frequently, and how many distinct
   customers received each offer?

   Metrics:
   - offers_received: number of offer-received event records.
   - unique_customers_reached: distinct customers for each offer.
   - received_percentage: each offer's share of all receipt events.

   Observed output:
   - 76,277 offer-received events across the 10 offers.
   - Individual offers received between 7,571 and 7,677 receipt events.
   - Receipt shares ranged from 9.93% to 10.06%, indicating broadly
     even distribution across individual offers.

   Note:
   Total receipt events and unique customers reached are different
   measures because a customer can receive the same offer more than once.
   --------------------------------------------------------------------- */
SELECT
    o.offer_id,
    o.offer_type,

    COUNT(e.offer_id) AS offers_received,

    COUNT(DISTINCT e.customer_id)
        AS unique_customers_reached,

    ROUND(
        COUNT(e.offer_id) * 100.0 /
        SUM(COUNT(e.offer_id)) OVER (), 2
    ) AS received_percentage

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event = 'offer received'

GROUP BY
    o.offer_id,
    o.offer_type

ORDER BY
    offers_received DESC,
    o.offer_id;



/* ---------------------------------------------------------------------
   SUPPLEMENTARY EVENT-TABLE INSPECTION (RETAINED FROM SOURCE SCRIPT)
   Purpose:
   Display the event table during the offer-distribution exploration.

   Note:
   This is a raw inspection query, not a summary metric. It is retained
   exactly as it appeared in the uploaded script.
   --------------------------------------------------------------------- */
SELECT * FROM EVENT;



/* ---------------------------------------------------------------------
   4.3 OFFER VIEW PERFORMANCE
   Business question:
   Which offers attracted the most recorded viewing activity?

   Metrics:
   - offers_received and offers_viewed: event counts per offer.
   - unique_customers_received and unique_customers_viewed: distinct
     customer counts per offer.
   - unique_customer_view_rate: unique viewers divided by unique
     recipients (a descriptive ratio only).
   - view_to_received_event_ratio: view events divided by receipt events.

   Observed output:
   - 57,725 offer-view events overall, compared with 76,277 receipts.
   - Event-level view-to-received ratio across all offers: 75.68%.
   - The highest observed unique-customer ratio was 97.13%; the lowest
     was 37.65%.

   Important interpretation:
   The unique-customer ratio in this query does not explicitly match
   customers who both received and viewed the same offer. Treat it as a
   descriptive ratio, not a confirmed recipient-to-viewer conversion rate.
   --------------------------------------------------------------------- */
SELECT
    o.offer_id,
    o.offer_type,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS offers_received,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer viewed'
    ) AS offers_viewed,
    
    COUNT(DISTINCT e.customer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS unique_customers_received,

    COUNT(DISTINCT e.customer_id) FILTER (
        WHERE e.event = 'offer viewed'
    ) AS unique_customers_viewed,
    
    ROUND(
        COUNT(DISTINCT e.customer_id) FILTER (
            WHERE e.event = 'offer viewed'
        ) * 100.0 /
        NULLIF(
            COUNT(DISTINCT e.customer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS unique_customer_view_rate,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer viewed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS view_to_received_event_ratio

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event IN ('offer received', 'offer viewed')

GROUP BY
    o.offer_id,
    o.offer_type

ORDER BY
    offers_viewed DESC,
    o.offer_id;



/* ---------------------------------------------------------------------
   4.4 OFFER COMPLETION PERFORMANCE
   Business question:
   Which offers generated the most completion events relative to receipts?

   Metrics:
   - offers_received and offers_completed: event counts per offer.
   - unique_customers_received and unique_customers_completed: distinct
     customer counts per offer.
   - completion_to_received_event_ratio: completion events divided by
     receipt events.

   Observed output:
   - 33,182 offer-completed events overall.
   - Overall completion-to-received event ratio: 43.50%.
   - Highest individual offer ratio: 69.30% (discount offer).
   - Informational offers recorded zero completion events, as they are
     not designed for completion in the same way as redeemable offers.

   Important interpretation:
   The event ratio is not an exact offer-delivery conversion rate.
   Unique completers and unique recipients are separate counts here and
   are not explicitly matched customer by customer.
   --------------------------------------------------------------------- */
SELECT
    o.offer_id,
    o.offer_type,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS offers_received,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS offers_completed,

    COUNT(DISTINCT e.customer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS unique_customers_received,

    COUNT(DISTINCT e.customer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS unique_customers_completed,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS completion_to_received_event_ratio

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event IN (
        'offer received',
        'offer completed'
    )

GROUP BY
    o.offer_id,
    o.offer_type

ORDER BY
    offers_completed DESC;



/* ---------------------------------------------------------------------
   4.5 OFFER TYPE PERFORMANCE
   Business question:
   How do BOGO, discount, and informational offers compare at category level?

   Metrics:
   - Number of offers in each type.
   - Receipt, view, and completion event counts.
   - Unique customers represented in each event type.
   - View-to-received and completion-to-received event ratios.

   Observed output:
   - BOGO: 30,499 receipts; 25,449 views; 15,501 completions;
     view event ratio 83.44%; completion event ratio 50.82%.
   - Discount: 30,543 receipts; 21,445 views; 17,681 completions;
     view event ratio 70.21%; completion event ratio 57.89%.
   - Informational: 15,235 receipts; 10,831 views; 0 completions.

   Interpretation:
   BOGO had the higher event-level viewing ratio, while discount had the
   higher event-level completion ratio. Informational offers should not
   be treated as failed redeemable offers.

   Note:
   Unique customers are deduplicated within each offer type. A customer
   can appear in more than one category, so category counts are not
   additive to a total distinct-customer count across the experiment.
   --------------------------------------------------------------------- */
SELECT
    o.offer_type,

    COUNT(DISTINCT o.offer_id) AS total_offers,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS offers_received,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer viewed'
    ) AS offers_viewed,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS offers_completed,

    COUNT(DISTINCT e.customer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS unique_customers_reached,

    COUNT(DISTINCT e.customer_id) FILTER (
        WHERE e.event = 'offer viewed'
    ) AS unique_customers_viewed,

    COUNT(DISTINCT e.customer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS unique_customers_completed,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer viewed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS view_to_received_event_ratio,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS completion_to_received_event_ratio

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event IN (
        'offer received',
        'offer viewed',
        'offer completed'
    )

GROUP BY o.offer_type

ORDER BY
    CASE o.offer_type
        WHEN 'bogo' THEN 1
        WHEN 'discount' THEN 2
        WHEN 'informational' THEN 3
    END;



/* ---------------------------------------------------------------------
   4.6.1 DIFFICULTY VS COMPLETION PERFORMANCE
   Business question:
   How do completion event ratios compare across difficulty levels?

   Scope:
   BOGO and discount offers only. Informational offers are excluded because
   they have no completion requirement comparable to redeemable offers.

   Observed output:
   - BOGO difficulty 5: 56.17%; difficulty 10: 45.48%.
   - Discount difficulty 7: 66.86%; difficulty 10: 60.60%;
     difficulty 20: 43.56%.

   Interpretation:
   Higher difficulty is associated with lower completion event ratios
   in these observed offer groups. This is exploratory and does not prove
   that difficulty alone caused the differences.
   --------------------------------------------------------------------- */
SELECT
    o.offer_type,
    o.difficulty,

    COUNT(DISTINCT o.offer_id) AS total_offers,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS offers_received,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS offers_completed,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS completion_to_received_event_ratio

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event IN ('offer received', 'offer completed')

WHERE o.offer_type IN ('bogo', 'discount')

GROUP BY
    o.offer_type,
    o.difficulty

ORDER BY
    o.offer_type,
    o.difficulty;



/* ---------------------------------------------------------------------
   4.6.2 REWARD VS COMPLETION PERFORMANCE
   Business question:
   How do completion event ratios compare across reward levels?

   Scope:
   BOGO and discount offers only.

   Observed output:
   - BOGO reward 5: 56.17%; reward 10: 45.48%.
   - Discount reward 2: 60.60%; reward 3: 66.86%; reward 5: 43.56%.

   Interpretation:
   Higher rewards do not consistently correspond with higher completion
   ratios. Reward is associated with other offer characteristics in this
   small catalogue, so its independent effect cannot be isolated here.
   --------------------------------------------------------------------- */
SELECT
    o.offer_type,
    o.reward,

    COUNT(DISTINCT o.offer_id) AS total_offers,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS offers_received,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS offers_completed,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS completion_rate

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event IN ('offer received', 'offer completed')

WHERE o.offer_type IN ('bogo', 'discount')

GROUP BY
    o.offer_type,
    o.reward

ORDER BY
    o.offer_type,
    o.reward;



/* ---------------------------------------------------------------------
   4.6.3 DURATION VS OFFER PERFORMANCE
   Business question:
   How do viewing and completion event ratios compare across durations?

   Scope:
   All offer types are included. Informational offers can be viewed even
   though they are not designed to be completed.

   Observed output:
   - BOGO: 5-day offers had 96.03% view ratio and 49.87% completion ratio;
     7-day offers had 70.99% view ratio and 51.76% completion ratio.
   - Discount: 7-day offers had 74.98% view ratio and 59.41% completion
     ratio; 10-day offers had 65.44% view ratio and 56.37% completion ratio.
   - Informational: 3-day offer view ratio 87.78%; 4-day offer 54.40%.

   Interpretation:
   Duration patterns differ by offer type. These are descriptive
   comparisons, not evidence that duration causes engagement or completion.
   --------------------------------------------------------------------- */
SELECT
    o.offer_type,
    o.duration,

    COUNT(DISTINCT o.offer_id) AS total_offers,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS offers_received,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer viewed'
    ) AS offers_viewed,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS offers_completed,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer viewed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS view_event_ratio,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS completion_event_ratio

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event IN (
        'offer received',
        'offer viewed',
        'offer completed'
    )

GROUP BY
    o.offer_type,
    o.duration

ORDER BY
    o.offer_type,
    o.duration;



/* ---------------------------------------------------------------------
   4.6.4 COMBINED OFFER CHARACTERISTICS
   Business question:
   Which observed combinations of offer type, difficulty, reward, and
   duration correspond with stronger completion event ratios?

   Observed output:
   - Highest ratio: discount, difficulty 10, reward 2, duration 10 days
     (69.30%).
   - Next: discount, difficulty 7, reward 3, duration 7 days (66.86%).
   - Lowest ratio: BOGO, difficulty 10, reward 10, duration 5 days
     (43.47%).

   Important limitation:
   Each row represents one individual offer (total_offers = 1).
   There are only eight redeemable offers. Rankings are descriptive and
   cannot establish statistically reliable or causal effects of the
   combined characteristics.
   --------------------------------------------------------------------- */
SELECT
    o.offer_type,
    o.difficulty,
    o.reward,
    o.duration,

    COUNT(DISTINCT o.offer_id) AS total_offers,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer received'
    ) AS offers_received,

    COUNT(e.offer_id) FILTER (
        WHERE e.event = 'offer completed'
    ) AS offers_completed,

    ROUND(
        COUNT(e.offer_id) FILTER (
            WHERE e.event = 'offer completed'
        ) * 100.0 /
        NULLIF(
            COUNT(e.offer_id) FILTER (
                WHERE e.event = 'offer received'
            ), 0
        ), 2
    ) AS completion_event_ratio

FROM public.offer o

LEFT JOIN public.event e
    ON o.offer_id = e.offer_id
    AND e.event IN (
        'offer received',
        'offer completed'
    )

WHERE o.offer_type IN ('bogo', 'discount')

GROUP BY
    o.offer_type,
    o.difficulty,
    o.reward,
    o.duration

ORDER BY
    completion_event_ratio DESC;



/* ---------------------------------------------------------------------
   4.7.1 CHANNEL DISTRIBUTION
   Business question:
   Which communication channels are included across the 10 offers?

   Observed output:
   - Email: 10 offers (100%).
   - Mobile: 9 offers (90%).
   - Web: 8 offers (80%).
   - Social: 6 offers (60%).

   Note:
   Channels are not mutually exclusive. An offer can use multiple
   channels, so channel percentages do not add to 100%.
   --------------------------------------------------------------------- */
SELECT
    channel,
    COUNT(DISTINCT offer_id) AS total_offers
FROM public.offer_channels
GROUP BY channel
ORDER BY total_offers DESC;



/* ---------------------------------------------------------------------
   4.7.2 CHANNEL COMBINATIONS BY OFFER
   Business question:
   Which channel combinations are configured for each offer?

   Observed output:
   - 4 offers use all four channels.
   - 5 offers use three channels.
   - 1 offer uses two channels.
   - Most common combinations: email/mobile/social/web (4 offers),
     email/mobile/web (3), email/mobile/social (2), and email/web (1).

   Important interpretation:
   The offer_channels table describes the channels configured for an
   offer. It does not identify which channel delivered a particular offer
   to a particular customer. Therefore, this analysis does not support
   individual-channel conversion attribution.
   --------------------------------------------------------------------- */
SELECT
    o.offer_id,
    o.offer_type,

    COUNT(oc.channel) AS total_channels,

    STRING_AGG(
        oc.channel,
        ', ' ORDER BY oc.channel
    ) AS available_channels

FROM public.offer o

LEFT JOIN public.offer_channels oc
    ON o.offer_id = oc.offer_id

GROUP BY
    o.offer_id,
    o.offer_type

ORDER BY
    o.offer_type,
    o.offer_id;
