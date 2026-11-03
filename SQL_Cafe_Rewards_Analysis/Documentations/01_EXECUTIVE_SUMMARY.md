# Executive Summary — Cafe Rewards Offers Analysis

## Project purpose

This project analyses a 30-day cafe rewards experiment to understand customer purchasing behaviour and promotional offer performance. The work uses PostgreSQL to examine 17,000 customers, 306,137 cleaned event records, and 10 promotional offers.

The analysis moves from data quality checks to transaction analysis, customer behaviour, offer performance, and customer engagement. The final aim is to turn the results into practical ideas that a rewards or marketing team could test.

## Dataset and approach

The project uses four PostgreSQL tables:

- `customer`: one row per customer and their available demographic information.
- `event`: one row per recorded transaction or offer-related activity.
- `offer`: one row per promotional offer.
- `offer_channels`: one row per offer-channel relationship.

The data was cleaned and checked before analysis. Exact duplicate event rows were removed, identifiers were kept as text, missing demographic values were preserved as unknown, and the event time was treated as elapsed experiment time rather than a calendar date.

## Headline results

### Transaction performance

- **138,953 transactions** were recorded.
- Total transaction value was **$1,775,451.97**.
- Average transaction value was **$12.78** and median transaction value was **$8.89**.
- The IQR upper fence was **$41.005**. There were **1,236 transactions (0.89%)** above this threshold, representing **13.92%** of total transaction value.
- **95.16%** of customers made more than one transaction during the experiment window.

### Customer behaviour

- The largest age group was **60+**, with 5,875 customers (34.56%).
- Customers under 30 averaged **10.31 transactions per customer**, compared with **7.76** for customers aged 60+. However, average transaction value was **$8.15** for the under-30 group and **$16.43** for the 60+ group.
- Higher-income customers averaged **$177.92 spending per customer**, compared with **$67.08** for lower-income customers. Lower-income customers had more transactions per customer (10.04 versus 6.27).
- These are descriptive differences between groups, not proof that age or income caused the behaviour.

### Offer performance

- The 10 offers were distributed at broadly similar levels: each received between **7,571 and 7,677** receipt events.
- BOGO offers had an **83.44% view-to-received event ratio**.
- Discount offers had a **57.89% completion-to-received event ratio**, compared with **50.82%** for BOGO.
- Informational offers had views but no completion events, which is consistent with their design.
- The strongest individual offer completion-to-received event ratio was **69.30%** for a discount offer. The lowest was **43.47%** for a BOGO offer.
- Email was included in all 10 offers; mobile in nine, web in eight, and social in six. These are channel-availability counts, not channel performance measurements.

### Customer engagement and spending

- **12,774 customers (75.14%)** completed at least one offer.
- **4,133 customers (24.31%)** viewed offers but had no recorded completion.
- A separate query confirmed **73 customers** had at least one completion event but no view event anywhere in the experiment.
- **15,807 customers (92.98%)** generated more than one offer-view event.
- **9,560 customers (56.24% of all customers)** generated more than one offer-completion event.
- Customers with repeat offer-completion events averaged **$158.95 spending per customer**, compared with **$18.04** among customers with no offer-completion event. The repeat-completion group contributed **85.59%** of transaction value.

The spending relationship is not causal. Offer completion is itself associated with qualifying purchase activity, and the analysis does not prove that completing offers made customers spend more.

## Main business message

The results suggest that BOGO offers may be useful for attracting attention, while discount offers showed stronger completion activity in this experiment. Repeated offer completion was also strongly associated with higher purchasing activity. These patterns are useful starting points for controlled tests, not final proof of what caused customer behaviour.

## Recommended next actions

1. Test BOGO and discount offers for different goals: attention versus completion.
2. Test offer difficulty and reward levels separately rather than changing several offer features at once.
3. Review customers who viewed offers but did not complete one to understand possible barriers.
4. Use purchasing behaviour to form customer groups, while treating demographic differences as supporting information rather than fixed rules.
5. Improve campaign tracking so each offer delivery records the customer, offer, channel, and timestamp. This would support reliable customer-level conversion analysis.

## Important limits

The project has only 10 offers and a 30-day observation window. Channel data describes which channels were assigned to offers, not the channel that reached each customer. The dataset has no website session records, so website-session trends, session-to-order conversion, and revenue per session are outside the scope of this analysis.
