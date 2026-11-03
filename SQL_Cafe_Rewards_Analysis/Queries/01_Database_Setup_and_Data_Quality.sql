/* =====================================================================
   CAFE REWARDS OFFERS | 01 - DATABASE SETUP & DATA QUALITY
   Database: PostgreSQL
   Tables: public.customer, public.event, public.offer, public.offer_channels

   Purpose:
   - Verify imported row counts and schema.
   - Profile values before changing data types.
   - Convert text-formatted analytical columns to DATE / NUMERIC.

   IMPORTANT:
   - The Excel cleaning workbook produced the cleaned CSV exports.
   - These SQL statements validate the PostgreSQL imports and finalize types.
   - The ALTER TABLE statements are one-time conversions. The user's current
     working database already has these final types; do not rerun those ALTER
     statements against already-converted columns without checking the schema.
   ===================================================================== */

/* ---------------------------------------------------------------------
   1. ROW-COUNT CHECK
   Expected: customer 17000, event 306137, offer 10, offer_channels 33.
   --------------------------------------------------------------------- */
SELECT 'customer' AS table_name, COUNT(*) AS total_rows
FROM public.customer
UNION ALL
SELECT 'event', COUNT(*) FROM public.event
UNION ALL
SELECT 'offer', COUNT(*) FROM public.offer
UNION ALL
SELECT 'offer_channels', COUNT(*) FROM public.offer_channels;

/* ---------------------------------------------------------------------
   2. SCHEMA CHECK
   Use this to verify the actual database types rather than assuming them.
   --------------------------------------------------------------------- */
SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('customer', 'event', 'offer', 'offer_channels')
ORDER BY table_name, ordinal_position;

/* ---------------------------------------------------------------------
   3. PRE-CONVERSION VALUE VALIDATION
   Run this while the columns are still text/varchar.
   REPLACE(..., ',', '') allows optional thousands separators in income.
   The attached raw customers CSV had ungrouped digits, while the earlier
   PostgreSQL import inspection showed comma-formatted values; this check
   tolerates either representation.
   --------------------------------------------------------------------- */
SELECT
    'customer.income' AS column_name,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(income), '') IS NOT NULL
          AND REPLACE(TRIM(income), ',', '')
              !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_values
FROM public.customer
UNION ALL
SELECT
    'event.amount',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(amount), '') IS NOT NULL
          AND TRIM(amount) !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    )
FROM public.event
UNION ALL
SELECT
    'event.reward',
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(reward), '') IS NOT NULL
          AND TRIM(reward) !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    )
FROM public.event;

/* Date-format inspection before conversion. The cleaned CSV may contain
   ISO dates (YYYY-MM-DD); the original source uses YYYYMMDD. Both are valid
   input shapes for the conversion block below. This check validates shape;
   the actual DATE conversion validates calendar dates. */
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(became_member_on), '') IS NOT NULL
          AND TRIM(became_member_on) !~ '^([0-9]{8}|[0-9]{4}-[0-9]{2}-[0-9]{2})$'
    ) AS invalid_date_shapes
FROM public.customer;

/* Inspect common income values when a validation check reports unexpected
   results. This is a diagnostic query; it does not modify the table. */
SELECT income, COUNT(*) AS frequency
FROM public.customer
WHERE NULLIF(TRIM(income), '') IS NOT NULL
GROUP BY income
ORDER BY frequency DESC
LIMIT 20;

/* ---------------------------------------------------------------------
   4. ONE-TIME TYPE CONVERSIONS
   Use only if these columns are currently text/varchar.
   Check Section 2 first. These statements reflect the conversion steps
   performed during this project.
   --------------------------------------------------------------------- */

-- Income: remove optional thousands separators, convert blanks to NULL.
ALTER TABLE public.customer
ALTER COLUMN income TYPE NUMERIC
USING NULLIF(REPLACE(TRIM(income), ',', ''), '')::NUMERIC;

-- Membership date: accept YYYYMMDD from the source or YYYY-MM-DD from a
-- date-formatted cleaned CSV. Blank values remain NULL.
ALTER TABLE public.customer
ALTER COLUMN became_member_on TYPE DATE
USING CASE
    WHEN NULLIF(TRIM(became_member_on), '') IS NULL THEN NULL
    WHEN TRIM(became_member_on) ~ '^[0-9]{8}$'
        THEN TO_DATE(TRIM(became_member_on), 'YYYYMMDD')
    ELSE TRIM(became_member_on)::DATE
END;

-- Event amount and reward: blanks remain NULL; nonblank values become numeric.
ALTER TABLE public.event
ALTER COLUMN amount TYPE NUMERIC
USING NULLIF(TRIM(amount), '')::NUMERIC;

ALTER TABLE public.event
ALTER COLUMN reward TYPE NUMERIC
USING NULLIF(TRIM(reward), '')::NUMERIC;

/* ---------------------------------------------------------------------
   5. POST-CONVERSION VERIFICATION
   Expected types: customer.became_member_on DATE, customer.income NUMERIC,
   event.amount NUMERIC, event.reward NUMERIC, event.raw_value TEXT.
   --------------------------------------------------------------------- */
SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
      (table_name = 'customer'
       AND column_name IN ('customer_id', 'became_member_on', 'gender', 'age', 'income'))
      OR
      (table_name = 'event'
       AND column_name IN ('customer_id', 'event', 'raw_value', 'time_hours',
                           'offer_id', 'amount', 'reward', 'event_day'))
  )
ORDER BY table_name, ordinal_position;

/* Missing income count: expected 2,175 in the cleaned customer table. */
SELECT COUNT(*) AS missing_income
FROM public.customer
WHERE income IS NULL;

/* ---------------------------------------------------------------------
   6. FINAL IMPORT CHECK
   Expected final row counts: 17,000 / 306,137 / 10 / 33.
   --------------------------------------------------------------------- */
SELECT 'customer' AS table_name, COUNT(*) AS total_rows FROM public.customer
UNION ALL SELECT 'event', COUNT(*) FROM public.event
UNION ALL SELECT 'offer', COUNT(*) FROM public.offer
UNION ALL SELECT 'offer_channels', COUNT(*) FROM public.offer_channels;
