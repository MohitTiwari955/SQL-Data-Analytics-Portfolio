# Phase-wise Findings and Results

This document records the main results from the SQL analysis. Amounts are shown in the source dataset's dollar units.

## Phase 1 — Data quality and validation

### Final table counts

| Table | Rows | Table grain |
|---|---:|---|
| `customer` | 17,000 | One row per customer |
| `event` | 306,137 | One row per cleaned event record |
| `offer` | 10 | One row per offer |
| `offer_channels` | 33 | One row per offer-channel pair |

### Main cleaning and validation decisions

- The original event file had 306,534 rows. A total of 397 excess exact-duplicate rows across 396 duplicate groups were removed, leaving 306,137 rows. The removed excess rows were all in `offer completed` records.
- Customer IDs and offer IDs were retained as text to protect long identifiers.
- The event value field was retained as `raw_value` and parsed into structured columns such as `offer_id`, `amount`, and `reward` when applicable.
- `time` was represented as elapsed experiment hours (`time_hours`), not a real calendar timestamp. `event_day` is the elapsed-day number derived from those hours.
- Age `118` was treated as a missing-value code in this project and converted to NULL. Five age-101 records were retained and flagged rather than automatically removed.
- A group of 2,175 customers had missing gender, income, and age placeholder values. Their customer records were retained.
- The latest cleaning validation reported zero unmatched customer references, zero unmatched offer references, and zero unparseable event values.

## Phase 2 — Event and transaction analysis

### Event distribution after cleaning

| Event | Event records | Unique customers | Share of all events | First hour | Last hour |
|---|---:|---:|---:|---:|---:|
| Transaction | 138,953 | 16,578 | 45.39% | 0 | 714 |
| Offer received | 76,277 | 16,994 | 24.92% | 0 | 576 |
| Offer viewed | 57,725 | 16,834 | 18.86% | 0 | 714 |
| Offer completed | 33,182 | 12,774 | 10.84% | 0 | 714 |
| **Total** | **306,137** | — | **100.00%** | — | — |

Unique-customer counts are calculated separately for each event type. A customer can appear in more than one event category.

### Transaction value profile

| Metric | Result |
|---|---:|
| Transactions | 138,953 |
| Customers with transactions | 16,578 |
| Total transaction value | $1,775,451.97 |
| Average transaction value | $12.78 |
| Median transaction value | $8.89 |
| First quartile (Q1) | $2.78 |
| Third quartile (Q3) | $18.07 |
| Minimum | $0.05 |
| Maximum | $1,062.28 |

The average is higher than the median, showing that larger transactions influence the average.

### High-value transactions using the IQR rule

- IQR = Q3 − Q1 = **$15.29**.
- Upper fence = Q3 + 1.5 × IQR = **$41.005** (displayed as $41.01 when rounded).
- Transactions above the exact $41.005 fence: **1,236** (0.89% of transactions).
- Value of those transactions: **$247,145.38**, or **13.92%** of total transaction value.
- Customers with at least one such transaction: **1,151**, or **6.94%** of customers who transacted.

An IQR flag identifies statistically unusual values under this method. It does not establish that a transaction is wrong.

### High-value customer comparison

| Metric | Customers with at least one high-value transaction | Other purchasing customers |
|---|---:|---:|
| Customers | 1,151 | 15,427 |
| All transactions by the group | 11,402 | 127,551 |
| Average transactions/customer | 9.91 | 8.27 |
| Total spending from all their transactions | $397,694.52 | $1,377,757.45 |
| Average spending/customer | $345.52 | $89.31 |
| Average transaction value | $34.88 | $10.80 |

This comparison includes all transactions made by customers in each group, not only the transactions above the IQR threshold.

When only regular transactions at or below $41.005 were compared, the high-value-customer group averaged **8.83** regular transactions and **$130.80** regular spending per customer; other customers averaged **8.27** regular transactions and **$89.31** regular spending per customer.

The top 100 high-value customer spending ranks accounted for approximately **33.53%** of high-value transaction value. The ranking query uses `DENSE_RANK`, so ties can mean the selected set contains more than exactly 100 customers.

### Daily activity highlights

- Transaction count peaked on experiment day 18 at **5,887 transactions**.
- Highest daily transaction value was **$77,719.88** on experiment day 25; day 22 recorded **$77,262.51**.

`event_day` is an elapsed-day index beginning at day 0, not a calendar date.

## Phase 3 — Customer demographics and purchasing behaviour

### Customer profile

**Gender distribution**

| Gender group | Customers | Share |
|---|---:|---:|
| Male | 8,484 | 49.91% |
| Female | 6,129 | 36.05% |
| Unknown | 2,175 | 12.79% |
| Other | 212 | 1.25% |

**Age distribution**

| Age group | Customers | Share |
|---|---:|---:|
| Under 30 | 1,574 | 9.26% |
| 30–39 | 1,526 | 8.98% |
| 40–49 | 2,309 | 13.58% |
| 50–59 | 3,541 | 20.83% |
| 60+ | 5,875 | 34.56% |
| Unknown | 2,175 | 12.79% |

**Income profile**

| Metric | Result |
|---|---:|
| Customers | 17,000 |
| Customers with recorded income | 14,825 |
| Missing income | 2,175 |
| Average income | $65,404.99 |
| Median income | $64,000 |
| Q1 income | $49,000 |
| Q3 income | $80,000 |
| Minimum income | $30,000 |
| Maximum income | $120,000 |

**Income groups**

| Income group | Customers | Share |
|---|---:|---:|
| Lower Income | 3,781 | 22.24% |
| Lower-Middle Income | 3,863 | 22.72% |
| Upper-Middle Income | 3,616 | 21.27% |
| Higher Income | 3,565 | 20.97% |
| Unknown | 2,175 | 12.79% |

The group thresholds were informed by income quartiles. Because multiple customers can have the same income value, the groups are not guaranteed to have exactly equal sizes.

### Membership registrations

| Membership year | Customers joining |
|---|---:|
| 2013 | 286 |
| 2014 | 691 |
| 2015 | 1,830 |
| 2016 | 3,526 |
| 2017 | 6,469 |
| 2018 | 4,198 |

Observed membership dates range from **2013-07-29** to **2018-07-26**. The first and last calendar years are partial years. Exact membership tenure was not calculated because the experiment's verified calendar start date was unavailable.

### Purchasing behaviour by age

| Age group | Avg. transactions/customer | Avg. spending/customer | Avg. transaction value |
|---|---:|---:|---:|
| Under 30 | 10.31 | $84.07 | $8.15 |
| 30–39 | 10.06 | $101.16 | $10.06 |
| 40–49 | 8.32 | $107.16 | $12.87 |
| 50–59 | 7.79 | $127.72 | $16.39 |
| 60+ | 7.76 | $127.41 | $16.43 |
| Unknown | 6.89 | $18.63 | $2.70 |

Younger customers made more transactions on average. Older customers had higher average transaction values and higher average spending per customer.

### Purchasing behaviour by gender

| Gender | Avg. transactions/customer | Avg. spending/customer | Avg. transaction value |
|---|---:|---:|---:|
| Male | 8.58 | $99.59 | $11.61 |
| Female | 8.06 | $140.92 | $17.49 |
| Other | 8.40 | $124.32 | $14.80 |
| Unknown | 6.89 | $18.63 | $2.70 |

Male and female purchasing rates were almost identical (97.77% and 97.78%). Female customers had higher average spending per customer and transaction value, while male customers had slightly higher average transaction frequency.

### Purchasing behaviour by income

| Income group | Avg. transactions/customer | Avg. spending/customer | Avg. transaction value |
|---|---:|---:|---:|
| Lower Income | 10.04 | $67.08 | $6.68 |
| Lower-Middle Income | 8.96 | $98.83 | $11.03 |
| Upper-Middle Income | 8.04 | $128.66 | $16.01 |
| Higher Income | 6.27 | $177.92 | $28.39 |
| Unknown | 6.89 | $18.63 | $2.70 |

Higher-income customers spent more per customer and had higher average transaction values. Lower-income customers had more transactions per customer. These are descriptive group differences.

### Purchase-frequency classification

| Customer type | Customers | Share |
|---|---:|---:|
| No Purchase | 422 | 2.48% |
| One-time Purchaser | 401 | 2.36% |
| Repeat Purchaser | 16,177 | 95.16% |

Repeat purchasers made **138,552 transactions** and generated **$1,770,077.62**, approximately **99.70%** of transaction value. This measures repeat purchasing in the 30-day experiment; it does not establish long-term customer loyalty.

## Phase 4 — Offer performance

### Offer catalogue

There were 10 offers: **4 BOGO**, **4 discount**, and **2 informational**. Offers had durations from 3 to 10 days. Informational offers had zero difficulty and zero reward.

### Distribution

- Total receipt events: **76,277**.
- Each individual offer received between **7,571 and 7,677** receipt events.
- Individual offer shares ranged from **9.93% to 10.06%**.

Distribution was broadly even across the 10 offers.

### Viewing and completion by offer type

| Offer type | Offers | Received events | Viewed events | Completed events | View event ratio | Completion event ratio |
|---|---:|---:|---:|---:|---:|---:|
| BOGO | 4 | 30,499 | 25,449 | 15,501 | 83.44% | 50.82% |
| Discount | 4 | 30,543 | 21,445 | 17,681 | 70.21% | 57.89% |
| Informational | 2 | 15,235 | 10,831 | 0 | 71.09% | 0.00% |

The ratios are event-count ratios: viewed events divided by received events, and completed events divided by received events. They are not matched customer conversion rates.

### Individual offer highlights

- Highest individual completion-to-received event ratio: **69.30%**, a discount offer with difficulty 10, reward 2, and duration 10 days.
- Second-highest: **66.86%**, a discount offer with difficulty 7, reward 3, and duration 7 days.
- Lowest redeemable-offer ratio: **43.47%**, a BOGO offer with difficulty 10, reward 10, and duration 5 days.
- The two informational offers had zero completion events; they are not designed for the same completion process as redeemable offers.

### Difficulty and reward comparisons

**Difficulty**

| Type | Difficulty | Offers | Received events | Completed events | Completion event ratio |
|---|---:|---:|---:|---:|---:|
| BOGO | 5 | 2 | 15,248 | 8,565 | 56.17% |
| BOGO | 10 | 2 | 15,251 | 6,936 | 45.48% |
| Discount | 7 | 1 | 7,646 | 5,112 | 66.86% |
| Discount | 10 | 2 | 15,229 | 9,229 | 60.60% |
| Discount | 20 | 1 | 7,668 | 3,340 | 43.56% |

**Reward**

| Type | Reward | Offers | Completion event ratio |
|---|---:|---:|---:|
| BOGO | 5 | 2 | 56.17% |
| BOGO | 10 | 2 | 45.48% |
| Discount | 2 | 2 | 60.60% |
| Discount | 3 | 1 | 66.86% |
| Discount | 5 | 1 | 43.56% |

Higher reward did not consistently correspond with higher completion. Reward and difficulty often changed together in this offer catalogue.

### Duration comparisons

| Type | Duration | Offers | View event ratio | Completion event ratio |
|---|---:|---:|---:|---:|
| BOGO | 5 days | 2 | 96.03% | 49.87% |
| BOGO | 7 days | 2 | 70.99% | 51.76% |
| Discount | 7 days | 2 | 74.98% | 59.41% |
| Discount | 10 days | 2 | 65.44% | 56.37% |
| Informational | 3 days | 1 | 87.78% | 0.00% |
| Informational | 4 days | 1 | 54.40% | 0.00% |

Duration patterns differed across offer types. They do not establish that changing duration alone would cause the same result.

### Communication channels

| Channel | Offers containing the channel | Share of offers |
|---|---:|---:|
| Email | 10 | 100% |
| Mobile | 9 | 90% |
| Web | 8 | 80% |
| Social | 6 | 60% |

Channel combinations: four offers used all four channels; five offers used three channels; one offer used two channels. Channel data describes the offer's configured channels, not customer-level delivery or attribution.

## Phase 5 — Customer engagement

### Engagement classification

| Engagement group | Customers | Share |
|---|---:|---:|
| Completed at least one offer | 12,774 | 75.14% |
| Viewed but no completion | 4,133 | 24.31% |
| Received but never viewed | 87 | 0.51% |
| No matching offer activity | 6 | 0.04% |
| **Total** | **17,000** | **100%** |

This is a customer-level classification based on the highest recorded engagement stage. It is not a strict event-by-event funnel.

A separate SQL query confirmed **73 customers** with at least one offer-completion event and no offer-view event anywhere in the experiment.

### Repeat offer engagement

| Behaviour | No events | Exactly one event | More than one event |
|---|---:|---:|---:|
| Offer views | 166 customers | 1,027 customers | 15,807 customers |
| Offer completions | 4,226 customers | 3,214 customers | 9,560 customers |

Repeat views were **92.98% of all customers**. Repeat completion events were generated by **56.24% of all customers**; among the 12,774 customers who completed at least one offer, 9,560 (74.84%) generated multiple completion events.

These counts are event-based. Multiple events do not necessarily mean multiple distinct offers.

### Offer completion and purchasing behaviour

| Completion group | Customers | Purchasing customers | Transactions | Avg. transactions/customer | Total spending | Avg. spending/customer | Avg. transaction value |
|---|---:|---:|---:|---:|---:|---:|---:|
| No offer completion | 4,226 | 3,804 | 20,775 | 4.92 | $76,233.33 | $18.04 | $3.67 |
| One-time completion | 3,214 | 3,214 | 24,115 | 7.50 | $179,635.21 | $55.89 | $7.45 |
| Repeat completion | 9,560 | 9,560 | 94,063 | 9.84 | $1,519,583.43 | $158.95 | $16.15 |

The three groups reconcile to 17,000 customers, 138,953 transactions, and $1,775,451.97 in transaction value. Repeat completers contributed **85.59%** of total transaction value.

This is a descriptive relationship, not evidence that offer completion caused higher spending. Offer completion is associated with qualifying purchase activity.
