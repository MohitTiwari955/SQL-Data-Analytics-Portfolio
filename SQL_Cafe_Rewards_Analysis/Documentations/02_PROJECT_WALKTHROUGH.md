# Project Walkthrough — A Plain-English Guide

This guide explains what the project does, why each phase exists, and how the pieces connect. It is written for someone who wants to understand the analysis, not just run the SQL.

## The project in one sentence

We used customer, transaction, and offer-event data from a 30-day cafe rewards experiment to understand who purchased, how much they spent, and how customers interacted with promotional offers.

## What the tables represent

Think of the database as four connected lists:

- **Customer:** Who the customer is, including available demographic information.
- **Event:** What happened during the experiment. An event may be a transaction, offer receipt, offer view, or offer completion.
- **Offer:** What each promotion required and rewarded.
- **Offer channels:** Which communication channels were included in each offer's channel list.

The customer table has one row per customer. The event table has many rows per customer because one customer can make many transactions and interact with many offers.

## Phase 1 — Prepare and validate the data

**Why this phase matters:** Analysis is only as reliable as the data behind it.

We checked row counts, column types, IDs, missing values, duplicate events, and relationships between tables. We kept customer IDs and offer IDs as text so long identifiers would not lose digits. We removed only exact duplicate event rows, not rows that merely looked similar.

Key result: the cleaned database contains 17,000 customers, 306,137 events, 10 offers, and 33 offer-channel relationships.

## Phase 2 — Understand events and transactions

**Why this phase matters:** Before studying offers, we need to understand the normal purchasing activity in the experiment.

We counted event types, reviewed activity by experiment day, calculated transaction value statistics, and used the interquartile range (IQR) to flag unusually high transaction values.

Key result: 138,953 transactions generated $1,775,451.97 in transaction value. The average transaction was $12.78, while the median was $8.89. The difference suggests that larger purchases pull the average upward.

The IQR upper fence was $41.005. Transactions above this level are unusual under the IQR rule, but they are not automatically mistakes or fraudulent purchases.

## Phase 3 — Understand customer demographics and purchase patterns

**Why this phase matters:** Customers do not all shop in the same way. We compared purchasing activity across age, gender, and income groups.

We also reviewed membership sign-up years and divided customers into no-purchase, one-time-purchase, and repeat-purchase groups.

Key examples:

- Customers under 30 made more transactions per customer than customers aged 60+.
- Customers aged 60+ had a higher average transaction value than customers under 30.
- Higher-income customers spent more per customer, while lower-income customers made more transactions per customer.
- 95.16% of customers made more than one transaction during the 30-day experiment.

The results describe this dataset. They do not prove that demographic characteristics caused the differences. Membership tenure was not calculated because the experiment's verified calendar start date was not available.

## Phase 4 — Understand offer performance

**Why this phase matters:** The business needs to know which offers were noticed and which offers were completed.

We reviewed the offer catalogue, counted how often each offer was received, compared views and completions, and grouped offers by type. We also explored difficulty, reward, duration, and channel combinations.

Key results:

- Offer distribution was broadly even across the 10 offers.
- BOGO had the highest view-to-received event ratio (83.44%).
- Discount had the highest completion-to-received event ratio among redeemable types (57.89%).
- Higher difficulty generally appeared alongside lower completion ratios, but offer characteristics overlap and the catalogue is small.
- Channel counts show which channels were included in an offer, not which channel actually delivered it to an individual customer.

## Phase 5 — Connect offer engagement to customer behaviour

**Why this phase matters:** We want to understand how customers engage with offers and whether engagement is associated with purchasing activity.

First, we classified customers by their highest recorded engagement stage. Then we checked repeat views and repeat completions. Finally, we compared transaction activity and spending across customers with no, one, or multiple offer-completion events.

Key results:

- 12,774 customers completed at least one offer.
- 4,133 viewed offers but had no recorded completion.
- 73 customers completed at least one offer without any recorded view event.
- 9,560 customers generated more than one completion event.
- Customers with repeat completion events had higher observed average spending and transaction frequency.

This relationship is descriptive. Offer completion is tied to the qualifying purchase behaviour, so the analysis cannot prove that offers caused higher spending.

## Phase 6 — Turn findings into actions

**Why this phase matters:** A business analysis should lead to decisions, tests, or better measurement—not just tables.

The project recommends testing BOGO and discount offers for different goals, testing difficulty and reward separately, investigating customers who view but do not complete offers, and improving channel-level tracking.

## How to read the numbers

A few terms appear throughout the project:

- **Event count:** How many recorded activity rows occurred.
- **Unique customers:** How many different customers appear in that event group.
- **Average transactions per customer:** Total transactions divided by the number of customers in the group. In this project, customers with zero transactions remain included where the query was designed to include all customers.
- **Average spending per customer:** Total spending divided by all customers in the group, including customers with zero spending when `COALESCE` is used.
- **Average transaction value:** Total transaction value divided by total transactions.
- **Event ratio:** One event count divided by another event count. It is not automatically a matched customer conversion rate.

## What this project cannot prove

The dataset cannot show the exact delivery channel used for each customer, cannot match every receipt to one specific view or completion, and cannot prove that a promotion caused additional spending. It also does not contain website session data.
