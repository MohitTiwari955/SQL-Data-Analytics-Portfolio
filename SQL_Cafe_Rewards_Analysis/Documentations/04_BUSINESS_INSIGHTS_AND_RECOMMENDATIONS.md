# Final Business Insights and Recommendations

## Purpose

This document turns the Phase 1–5 SQL results into practical recommendations for a cafe rewards programme. Each recommendation is linked to a finding from the dataset. Where the data is not strong enough to support a firm conclusion, the recommendation is framed as a test rather than a proven answer.

## 1. Key business insights

### Insight 1 — Purchasing during the experiment was mainly repeat-based

**Evidence:** 16,177 customers (95.16%) made more than one transaction during the 30-day experiment. Repeat purchasers generated about 99.70% of the recorded transaction value.

**What it may mean:** The experiment's customer activity was not mainly made up of one-time purchasers. Repeat purchasing is an important part of the observed revenue.

**Business opportunity:** Protect the repeat-purchase experience. Test reminders, relevant product offers, and simple rewards that encourage customers to return.

**Caution:** A 30-day repeat-purchase result is not the same as long-term loyalty or retention. Longer-term data is needed to confirm whether customers continue purchasing later.

### Insight 2 — Different customer groups show different purchase patterns

**Evidence:** Customers under 30 averaged 10.31 transactions per customer, compared with 7.76 for customers aged 60+. Customers aged 60+ had an average transaction value of $16.43, compared with $8.15 for customers under 30. Higher-income customers averaged $177.92 spending per customer, while lower-income customers averaged $67.08.

**What it may mean:** Some groups purchase more often, while others spend more per transaction or per customer.

**Business opportunity:** Test different offer messages and product bundles for different behaviour patterns. For example, test frequent-visit rewards for customers who purchase often and value-focused bundles for customers with higher average transaction values.

**Caution:** Use observed purchase behaviour as the main basis for customer offers. Demographic information should be supporting context, not a fixed assumption about an individual.

### Insight 3 — BOGO and discount offers appear to serve different roles

**Evidence:** BOGO offers had an 83.44% view-to-received event ratio. Discount offers had a 57.89% completion-to-received event ratio, compared with 50.82% for BOGO.

**What it may mean:** BOGO offers attracted more viewing activity, while discount offers had a higher share of completion events relative to receipt events.

**Business opportunity:** Test BOGO offers when the goal is to attract attention, and test discount offers when the goal is to encourage completion. Measure both outcomes in a controlled test before setting a permanent strategy.

**Caution:** These are event-count ratios, not matched customer conversion rates. The results do not prove that offer type alone caused the differences.

### Insight 4 — Some offer settings had stronger completion results than others

**Evidence:** The highest individual completion-to-received event ratio was 69.30% for a discount offer with difficulty 10, reward 2, and duration 10 days. A discount offer with difficulty 7, reward 3, and duration 7 days reached 66.86%. The lowest redeemable offer ratio was 43.47% for a BOGO offer with difficulty 10, reward 10, and duration 5 days.

**What it may mean:** Offer design matters, but difficulty, reward, duration, and offer type overlap in this small catalogue.

**Business opportunity:** Run controlled tests that change one offer feature at a time. Start by testing lower difficulty levels against higher difficulty levels while keeping offer type, reward, and duration as consistent as possible.

**Caution:** There are only eight redeemable offers, and some combinations represent one offer. These results are exploratory, not proof of the best design for future campaigns.

### Insight 5 — A notable group viewed offers but did not complete one

**Evidence:** 4,133 customers (24.31%) viewed offers but had no recorded completion event. A separate query confirmed 73 customers had a completion event but no recorded view event anywhere in the experiment.

**What it may mean:** Viewing an offer does not always lead to a completion event. The data also does not form a perfectly ordered customer funnel.

**Business opportunity:** Review the offers received by the 4,133 customers and test whether clearer requirements, a more suitable reward, or a different difficulty level improves completion. Track the result in a new campaign.

**Caution:** The current dataset cannot identify why each customer did not complete an offer. Do not assume that every customer who viewed but did not complete an offer was unwilling or unable to purchase.

### Insight 6 — Repeat offer completion is strongly associated with spending

**Evidence:** Customers with multiple offer-completion events averaged $158.95 spending per customer and contributed 85.59% of transaction value. Customers with no offer-completion event averaged $18.04 per customer.

**What it may mean:** Repeat offer completers are a high-activity group in this experiment.

**Business opportunity:** Study this group to understand which offers, products, and purchase patterns appear alongside repeated completion. Test retention-focused rewards with similar customers and compare their future behaviour with a suitable comparison group.

**Caution:** Offer completion is itself linked to qualifying purchase activity. This analysis cannot show that the offers caused the higher spending. Customers who already purchase more may also have more chances to complete offers.

### Insight 7 — Channel data is not detailed enough to rank channel performance

**Evidence:** Email was included in all 10 offers, mobile in nine, web in eight, and social in six. Nine offers used at least three channels.

**What it may mean:** The programme used multiple channels to make offers available.

**Business opportunity:** Improve campaign tracking before deciding which channel performs best. Record the channel used for each customer-level delivery and connect it to later views and completions.

**Caution:** The current `offer_channels` table stores channel options for each offer. It does not prove that every customer received an offer through every listed channel.

## 2. Recommended actions

| Priority | Recommended action | Why it is recommended | How to measure it |
|---|---|---|---|
| High | Track each offer delivery at customer level | Current data cannot reliably pair one delivery with one view or completion | Delivery, view, and completion rates by delivery ID |
| High | Test BOGO and discount offers for different campaign goals | BOGO showed higher viewing activity; discount showed higher completion event ratio | Matched customer conversion and incremental sales in a controlled test |
| High | Test offer difficulty separately | Higher difficulty generally appeared with lower completion ratios | Completion rate while keeping other offer features similar |
| High | Investigate customers who viewed but did not complete | 4,133 customers fall into this category | Completion after a new offer design or follow-up test |
| Medium | Test reward levels based on cost and completion | Higher rewards did not consistently produce higher completion | Reward cost, completion, and incremental revenue per offer |
| Medium | Review customer purchase patterns when designing offers | Age and income groups showed different purchase patterns | Repeat purchase, average order value, and revenue by behavioural segment |
| Medium | Track longer-term customer activity | The current window is only 30 days | 60-, 90-, and 180-day repeat purchase and retention |
| Medium | Add a holdout or comparison group to future tests | Current analysis cannot establish incremental offer impact | Lift in purchase rate, revenue, and margin versus control |

## 3. Recommended measurement improvements

For future campaigns, record these fields for each offer delivery:

- A unique `offer_delivery_id` for each time an offer is sent to a customer.
- `customer_id` and `offer_id`.
- The actual delivery channel used.
- Delivery timestamp and delivery status.
- View/open timestamp and channel, where available.
- Completion timestamp and qualifying transaction/order ID.
- A test or control-group indicator.

This would allow the business to connect the steps for the same offer delivery, calculate more reliable conversion rates, compare channels, and estimate whether an offer generated additional purchases.

## 4. Final business conclusion

The 30-day Cafe Rewards experiment recorded high repeat-purchase activity and meaningful engagement with promotional offers. BOGO offers showed stronger viewing activity, while discount offers showed stronger completion activity relative to receipt events. Customers with repeat offer-completion events also showed much higher observed transaction activity and spending.

The programme should use these results as a guide for further testing, not as proof of cause and effect. The next business improvement is better campaign measurement: connect each offer delivery to the customer, channel, view, completion, and transaction. With that information, the business can make stronger decisions about which offers and channels produce genuine additional value.
