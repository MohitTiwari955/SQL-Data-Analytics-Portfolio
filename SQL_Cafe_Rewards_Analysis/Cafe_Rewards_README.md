# Cafe Rewards Analytics

## 📌 Project Overview

This project analyzes customer purchasing behavior and promotional offer performance using the **Maven Cafe Rewards** dataset.

The goal was to answer practical business questions around customer purchasing behavior, transaction value, promotional offer performance, customer engagement, repeat purchasing, and business opportunities.

This is an individual Data Analytics case study using SQL and Excel-based data preparation.

## 🎯 Business Objectives

- Understand overall transaction and revenue performance.
- Identify customer purchasing patterns across demographic groups.
- Evaluate promotional offer performance.
- Understand customer engagement with offers.
- Translate analytical findings into business recommendations.

## 🗂️ Dataset

This project uses the **Cafe Rewards Offers** dataset from **Maven Analytics Data Playground**. Maven describes it as data simulating Cafe Rewards member behavior over a 30-day period, including transactions and responses to promotional offers. citeturn241700search1

**Official dataset source:**  
https://mavenanalytics.io/data-playground/cafe-rewards-offers

**Related challenge:**  
Maven Rewards Challenge — the original challenge asks analysts to identify key customer segments and promotional opportunities from the 30-day Cafe Rewards test. citeturn241700search0

### Customers
Customer ID, membership date, gender, age, and income.

### Events
Transactions, offers received/viewed/completed, transaction amount, reward, and experiment time.

### Offers
Offer ID, offer type, difficulty, reward, duration, and channels.

## 🧹 Data Preparation

Key preparation steps included:

- Converting membership values into proper dates.
- Preserving Customer IDs as text.
- Removing exact duplicate event records.
- Parsing the original event `value` field.
- Standardizing offer-related fields.
- Handling missing demographic values.
- Treating age 118 as missing.
- Retaining and flagging unusual age values rather than automatically deleting them.
- Creating `event_day` from experiment time.
- Normalizing offer channels into a separate **Offer_Channels** table.
- Creating a data-quality report and data dictionary.

## 🔄 Analytical Workflow

### Phase 1 — Data Quality & Cleaning
Validated duplicates, missing values, unusual records, and prepared clean analytical tables.

### Phase 2 — Transaction Analysis
Analyzed transaction volume, revenue, transaction distributions, high-value transactions/customers, and daily activity.

### Phase 3 — Customer Demographics & Behaviour
Analyzed purchasing behavior by age, gender, income, membership registration year, and repeat purchasing.

### Phase 4 — Offer Performance
Compared offers by type, difficulty, reward, duration, configuration, and available channels.

### Phase 5 — Customer Engagement
Classified customer engagement and compared purchasing behavior across engagement groups.

### Phase 6 — Business Insights & Recommendations
Consolidated findings into business implications, recommendations, and analytical limitations.

## 📊 Key Results

| Metric | Result |
|---|---:|
| Total customers | 17,000 |
| Cleaned event records | 306,137 |
| Offers | 10 |
| Transactions | 138,953 |
| Total transaction value | $1,775,451.97 |
| Average transaction value | $12.78 |
| Median transaction value | $8.89 |
| Repeat purchasers | 16,177 (95.16%) |
| Customers completing ≥1 offer | 12,774 (75.14%) |
| Repeat offer completers | 9,560 |
| BOGO view / received ratio | 83.44% |
| Discount completion / received ratio | 57.89% |

## 🔎 Major Findings

### 1. Customer purchasing was highly repeat-oriented
95.16% of customers who made purchases were classified as repeat purchasers within the experiment period.

### 2. Higher-income customers generated higher-value purchases
Higher-income customers purchased less frequently on average but had substantially higher transaction values and spending per customer.

The higher-income group had an average transaction value of **$28.39**, compared with **$6.68** for the lower-income group.

### 3. Older customers showed higher transaction values
Younger customers generally purchased more frequently, while older customers showed higher average transaction values and spending per customer.

These are descriptive patterns and should not be interpreted as causal relationships.

### 4. Discount offers performed strongly
Discount offers had a higher overall completion-to-received event ratio than BOGO offers:

- Discount: **57.89%**
- BOGO: **50.82%**

### 5. Offer difficulty appears related to completion
Higher difficulty levels generally aligned with lower completion ratios. With only 10 offers, this should be treated as exploratory.

### 6. Offer completion and spending were strongly associated
Customers with repeat offer completions generated substantially more spending than customers with no recorded offer completion.

This does **not** establish that completing an offer caused higher spending.

## 💡 Business Recommendations

- Prioritize further testing of strong-performing offer configurations.
- Use customer value differences to inform segmentation and promotional strategies.
- Investigate the characteristics of repeatedly engaged customers.
- Test offer difficulty and reward combinations rather than assuming larger rewards automatically perform better.
- Improve channel-level attribution in future experiments.

## 🧠 Important Analytical Limitations

- Event-level completion ratios are not the same as customer-level conversion rates.
- Customers can receive multiple offers, so category-level distinct customer counts should not simply be added together.
- Offer channels represent available/assigned channels rather than verified individual-level attribution.
- Only 10 offers are available, making offer characteristic comparisons exploratory.
- Association between offer completion and spending does not prove causation.
- Repeat purchasing refers to the experiment period, not long-term retention.
- Exact membership tenure was not calculated because a verified experiment-end calendar reference date was unavailable.
- Engagement classification is hierarchical rather than a strict funnel because some customers have completion records without a recorded view event.

## 🛠️ Tools & Technologies

- **PostgreSQL** — SQL analysis
- **DBeaver** — SQL development
- **Microsoft Excel / Power Query** — data preparation
- **GitHub** — documentation and version control

## 🧮 SQL Techniques Used

`CASE` · `COUNT` · `COUNT(DISTINCT)` · `FILTER` · `COALESCE` · `NULLIF` · `TRIM` · `LEFT JOIN` · conditional joins · aggregate functions · `PERCENTILE_CONT` · IQR/outlier detection · `BOOL_OR` · window functions · running/cumulative calculations · `STRING_AGG` · `DENSE_RANK` · CTEs · two-level aggregation

## 📁 Project Structure

```text
Cafe-Rewards-Analytics/
│
├── README.md
│
├── data/
│   └── Cafe_Rewards_Cleaned.xlsx
│
├── sql/
│   ├── 01_Data_Quality.sql
│   ├── 02_Transaction_Analysis.sql
│   ├── 03_Customer_Analysis.sql
│   ├── 04_Offer_Performance_Analysis.sql
│   └── 05_Customer_Engagement_Analysis.sql
│
└── docs/
    ├── 01_EXECUTIVE_SUMMARY.md
    ├── 02_PROJECT_WALKTHROUGH.md
    ├── 03_PHASE_WISE_FINDINGS.md
    ├── 04_BUSINESS_INSIGHTS_AND_RECOMMENDATIONS.md
    ├── 05_DATA_DICTIONARY_AND_METHODOLOGY.md
    └── 06_LIMITATIONS_AND_METRIC_DEFINITIONS.md
```

## 📚 What I Learned

The biggest lesson from this project was that data analysis is not just about writing SQL.

The analytical process was:

**Business Question → Metric Definition → Data Grain → SQL Analysis → Validation → Interpretation → Business Recommendation**

The project developed practical understanding of customer analytics, transaction analysis, offer performance, engagement analysis, metric definitions, data quality, and business interpretation.

## ⚠️ Disclaimer

This is an exploratory analysis of the provided Cafe Rewards dataset. Findings describe patterns in the available data and should not be interpreted as causal evidence unless supported by an appropriate experimental design.

## 👤 Project Type

**Individual Data Analytics Portfolio Project**

Focus areas:

`SQL` · `Excel` · `Data Cleaning` · `Customer Analytics` · `Sales Analytics` · `Business Analysis`
