# Data Dictionary and Methodology

## 1. Dataset overview

The project uses a 30-day cafe rewards experiment dataset. The data is organised into customer records, event records, offer definitions, and offer-channel relationships.

| Table | Rows | Grain | Main key |
|---|---:|---|---|
| `public.customer` | 17,000 | One row per customer | `customer_id` |
| `public.event` | 306,137 | One row per event | No single business key documented in the project |
| `public.offer` | 10 | One row per offer | `offer_id` |
| `public.offer_channels` | 33 | One row per offer-channel pair | (`offer_id`, `channel`) |

## 2. Table and field guide

### `public.customer`

| Field | Meaning | Notes |
|---|---|---|
| `customer_id` | Unique customer identifier | Keep as TEXT/VARCHAR. Do not convert to a number. |
| `became_member_on` | Date the customer joined the rewards programme | Stored as DATE after cleaning. |
| `gender` | Source gender code | M, F, O; missing values remain NULL and are labelled Unknown in analysis. |
| `age` | Customer age | Age 118 was treated as a missing-value code in this project; five age-101 records were retained and flagged. |
| `income` | Estimated annual income | NUMERIC; 2,175 records are missing. |

### `public.event`

| Field | Meaning | Notes |
|---|---|---|
| `customer_id` | Customer associated with the event | Foreign-key relationship to `customer.customer_id`. |
| `event` | Recorded event type | `transaction`, `offer received`, `offer viewed`, or `offer completed`. |
| `raw_value` | Original event value text | Retained for traceability after parsing. |
| `offer_id` | Offer associated with an offer event | Parsed where the event value contains an offer identifier. |
| `amount` | Transaction amount | Used for transaction value and spending analysis. |
| `reward` | Reward value associated with a completed offer | Parsed where applicable. |
| `time_hours` | Hours passed since the experiment started | Elapsed experiment time, not a calendar timestamp. |
| `event_day` | Whole elapsed day derived from time | Calculated as FLOOR(time_hours / 24); day 0 is the first elapsed day. |

### `public.offer`

| Field | Meaning | Notes |
|---|---|---|
| `offer_id` | Unique offer identifier | Keep as TEXT/VARCHAR. |
| `offer_type` | Offer category | BOGO, discount, or informational. |
| `difficulty` | Minimum spend required to complete an offer | Zero for informational offers. |
| `reward` | Reward value in dollars | Zero for informational offers. |
| `duration` | Number of days the offer remains valid after receipt | Ranges from 3 to 10 days in this catalogue. |
| `channels` | Source list of communication channels | Normalised into the supporting `offer_channels` table for SQL analysis. |

### `public.offer_channels`

| Field | Meaning | Notes |
|---|---|---|
| `offer_id` | Offer identifier | Links to `public.offer`. |
| `channel` | Channel included in the offer configuration | Email, mobile, web, or social in this dataset. One offer can have several rows. |

## 3. Data preparation method

1. Imported the original customer, event, offer, and data dictionary files.
2. Kept identifiers as text to protect long IDs.
3. Reviewed missing values, unusual values, duplicate events, and type consistency.
4. Removed only exact duplicate event rows using the full original event record fields.
5. Preserved the original event value text and parsed structured fields when possible.
6. Converted membership dates, income, transaction amounts, and reward values to suitable data types.
7. Normalised the offer channel list into one row per offer-channel relationship.
8. Loaded the cleaned tables into PostgreSQL and checked row counts, data types, and key relationships.

## 4. Important metric definitions

| Metric | Definition used in this project |
|---|---|
| Total transactions | Count of rows where `event = 'transaction'`. |
| Total transaction value | Sum of `amount` for transaction events. |
| Average transaction value | Total transaction value divided by transaction count. |
| Median transaction value | 50th percentile of transaction amounts. |
| High-value transaction | Transaction amount above the exact IQR upper fence of $41.005. |
| Offer receipt events | Count of rows where `event = 'offer received'`. |
| Offer view events | Count of rows where `event = 'offer viewed'`. |
| Offer completion events | Count of rows where `event = 'offer completed'`. |
| View-to-received event ratio | Offer view event count divided by offer receipt event count. This is not a matched customer conversion rate. |
| Completion-to-received event ratio | Offer completion event count divided by offer receipt event count. This is not a matched delivery conversion rate. |
| Unique customers | `COUNT(DISTINCT customer_id)` within the grouping used by the query. Customers can appear in more than one offer or offer-type group. |
| Repeat purchaser | Customer with more than one transaction event during the observed experiment. |
| Repeat offer viewer | Customer with more than one offer-view event across the experiment. |
| Repeat offer completer | Customer with more than one offer-completion event across the experiment. |
| Average spending per customer | Total spending divided by all customers in a group. Where used, customers with no transaction spending are set to zero using `COALESCE`. |

## 5. Analysis method by phase

- **Phase 1:** Row counts, schema checks, type validation, duplicate review, and relationship validation.
- **Phase 2:** Event counts, experiment-day summaries, transaction distributions, percentiles, and IQR outlier screening.
- **Phase 3:** Customer demographic groupings, registration-year summaries, and customer-level purchase aggregation.
- **Phase 4:** Offer-level counts, offer-type comparisons, characteristic comparisons, and channel configuration summaries.
- **Phase 5:** Customer-level engagement classification, repeat event counts, and purchase metrics by offer-completion group.
- **Phase 6:** Descriptive findings translated into testable business recommendations.

## 6. AI assistance and project contribution

The project used AI assistance for cleaning prompts, SQL drafting, analysis planning, query explanations, and documentation. The user imported the data, executed queries in PostgreSQL/DBeaver, supplied outputs, checked results, and worked through the SQL logic. This should be presented as an AI-assisted, hands-on analysis project.
