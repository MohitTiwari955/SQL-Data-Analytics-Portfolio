# Bank Customer Churn Analysis — Findings

This document consolidates the descriptive results from the four business questions analysed in PostgreSQL. It records the observed values and the interpretations supported by those values.

## Dataset overview

| Measure | Customers | Share |
|---|---:|---:|
| Churned (`Exited = 1`) | 2,037 | 20.37% |
| Retained (`Exited = 0`) | 7,963 | 79.63% |
| **Total** | **10,000** | **100.00%** |

---

# Q1. How do churned and retained customers differ?

## 1.1 Numerical attribute comparison

| Metric | Churned | Retained |
|---|---:|---:|
| Average age | 44.84 | 37.41 |
| Average credit score | 645.35 | 651.85 |
| Average tenure (years) | 4.93 | 5.03 |
| Average balance | 91,108.54 | 72,745.30 |
| Average estimated salary | 101,465.68 | 99,738.39 |

**Observations**

- Churned customers were older on average than retained customers (44.84 versus 37.41 years).
- Churned customers had a higher average account balance (91,108.54 versus 72,745.30).
- Average credit scores were relatively close (645.35 versus 651.85).
- Average tenure was almost identical (4.93 versus 5.03 years).
- Average estimated salary differed only modestly (101,465.68 versus 99,738.39).

These are group averages; they do not show the full distribution or prove that any attribute causes churn.

## 1.2 Customer composition within churn status

The percentages below describe the composition of each churn-status group. For example, 55.92% means that 55.92% of churned customers were female; it is not the female churn rate.

| Attribute | Category | Churned | Retained |
|---|---|---:|---:|
| Geography | France | 39.76% | 52.79% |
| Geography | Germany | 39.96% | 21.29% |
| Geography | Spain | 20.27% | 25.92% |
| Gender | Male | 44.08% | 57.25% |
| Gender | Female | 55.92% | 42.75% |
| Credit card | Has card | 69.91% | 70.71% |
| Credit card | No card | 30.09% | 29.29% |
| Membership | Active | 36.08% | 55.46% |
| Membership | Inactive | 63.92% | 44.54% |
| Products | 1 product | 69.17% | 46.15% |
| Products | 2 products | 17.08% | 53.27% |
| Products | 3+ products | 13.75% | 0.58% |

## 1.3 Churn rates across selected categories

| Attribute | Category | Customers | Churned | Churn rate |
|---|---|---:|---:|---:|
| Geography | Germany | 2,509 | 814 | 32.44% |
| Geography | France | 5,014 | 810 | 16.15% |
| Geography | Spain | 2,477 | 413 | 16.67% |
| Gender | Female | 4,543 | 1,139 | 25.07% |
| Gender | Male | 5,457 | 898 | 16.46% |
| Credit card | No card | 2,945 | 613 | 20.81% |
| Credit card | Has card | 7,055 | 1,424 | 20.18% |
| Membership | Inactive | 4,849 | 1,302 | 26.85% |
| Membership | Active | 5,151 | 735 | 14.27% |
| Products | 1 product | 5,084 | 1,409 | 27.71% |
| Products | 2 products | 4,590 | 348 | 7.58% |
| Products | 3 products | 266 | 220 | 82.71% |
| Products | 4 products | 60 | 60 | 100.00% |

**Q1 key findings**

1. Germany had the highest country churn rate (32.44%), around twice the rates in France and Spain.
2. Female customers had a higher churn rate than male customers (25.07% versus 16.46%).
3. Inactive members had a higher churn rate than active members (26.85% versus 14.27%).
4. Customers with one product had a 27.71% churn rate, compared with 7.58% among customers with two products.
5. The three- and four-product groups had very high churn rates, but they were small (266 and 60 customers, respectively).
6. Credit-card ownership showed little difference in churn rate (20.81% without a card versus 20.18% with a card).

**Q1 conclusion:** The strongest descriptive differences are associated with geography, gender, membership activity, age, and product count. Credit-card ownership and tenure show comparatively little difference. These relationships require statistical validation and should not be interpreted as causal.

---

# Q2. What do the overall demographics of the bank's customers look like?

## 2.1 Geography

| Country | Customers | Percentage |
|---|---:|---:|
| France | 5,014 | 50.14% |
| Germany | 2,509 | 25.09% |
| Spain | 2,477 | 24.77% |
| **Total** | **10,000** | **100.00%** |

## 2.2 Gender

| Gender | Customers | Percentage |
|---|---:|---:|
| Male | 5,457 | 54.57% |
| Female | 4,543 | 45.43% |
| **Total** | **10,000** | **100.00%** |

## 2.3 Age distribution

| Age group | Customers | Percentage |
|---|---:|---:|
| Under 30 | 1,641 | 16.41% |
| 30–39 | 4,346 | 43.46% |
| 40–49 | 2,618 | 26.18% |
| 50–59 | 869 | 8.69% |
| 60+ | 526 | 5.26% |
| **Total** | **10,000** | **100.00%** |

**Q2 key findings**

1. France accounts for about half of the customer base (50.14%). Germany and Spain each account for about one-quarter.
2. The customer base is slightly male-dominated (54.57% male and 45.43% female).
3. The 30–39 age group is the largest, representing 43.46% of customers.
4. Customers aged 30–49 account for 69.64% of the customer base.
5. Customers aged 50 and above account for 13.95%.

**Q2 conclusion:** The customer base is concentrated in France, has a slight male majority, and is largely made up of customers aged 30–49. Geography, gender, and age were analysed as separate distributions; these results alone do not establish the most common combined demographic profile.

---

# Q3. Is there a difference between German, French, and Spanish customers in terms of account behaviour?

## 3.1 Country-level comparison

| Metric | Germany | France | Spain |
|---|---:|---:|---:|
| Total customers | 2,509 | 5,014 | 2,477 |
| Average balance | 119,730.12 | 62,092.64 | 61,818.15 |
| Average number of products | 1.52 | 1.53 | 1.54 |
| Average tenure (years) | 5.01 | 5.00 | 5.03 |
| Average credit score | 651.45 | 649.67 | 651.33 |
| Average estimated salary | 101,113.44 | 99,899.18 | 99,440.57 |
| Active membership rate | 49.74% | 51.68% | 52.97% |
| Churn rate | 32.44% | 16.15% | 16.67% |

## 3.2 Key findings

1. **Account balance:** Germany's average balance (119,730.12) is about 93% higher than France's (62,092.64) and Spain's (61,818.15). France and Spain are almost identical.
2. **Product usage:** Average products range only from 1.52 to 1.54, indicating very similar average product counts across countries.
3. **Tenure:** Average tenure ranges from 5.00 to 5.03 years, showing almost no difference.
4. **Credit score:** The highest and lowest country averages differ by only 1.78 points.
5. **Estimated salary:** Germany is highest, but the difference between Germany and Spain is about 1.68% of Spain's average.
6. **Active membership:** Spain is highest at 52.97%, followed by France at 51.68% and Germany at 49.74%. The range is modest (3.23 percentage points).
7. **Churn:** Germany's churn rate is 32.44%, compared with 16.15% in France and 16.67% in Spain.

**Q3 conclusion:** Most average account and customer-profile measures are similar across the three countries. The most pronounced differences are Germany's much higher average balance and much higher churn rate. A higher average balance does not correspond to better retention in this dataset.

---

# Q4. What types of segments exist within the bank's customers?

## 4.1 Balance-based segmentation

There were **3,617 zero-balance customers (36.17%)**. They were separated into their own group. The remaining 6,383 positive-balance customers were divided into four approximately equal groups using `NTILE(4)` ordered by balance and customer ID.

| Segment | Customers | Share of all customers | Minimum balance | Maximum balance | Average balance | Churn rate |
|---|---:|---:|---:|---:|---:|---:|
| Zero Balance | 3,617 | 36.17% | 0.00 | 0.00 | 0.00 | 13.82% |
| Q1 – Lowest Positive | 1,596 | 15.96% | 3,768.69 | 100,170.00 | 81,901.67 | 20.61% |
| Q2 – Lower-Middle | 1,596 | 15.96% | 100,194.00 | 119,840.00 | 110,269.28 | 27.38% |
| Q3 – Upper-Middle | 1,596 | 15.96% | 119,852.00 | 139,528.00 | 129,155.24 | 25.31% |
| Q4 – Highest | 1,595 | 15.95% | 139,530.00 | 250,898.00 | 158,007.71 | 23.01% |

**Findings**

- Zero-balance customers make up more than one-third of the customer base and have the lowest observed churn rate (13.82%).
- The lower-middle positive-balance quartile has the highest churn rate (27.38%).
- Churn declines across the upper two quartiles, so churn does not increase monotonically with balance.
- The highest-balance group still has a higher churn rate than the zero-balance group.

**Interpretation:** Balance and churn have a non-linear descriptive pattern in these segments. Balance alone is not sufficient to explain retention differences.

## 4.2 Product usage and membership segmentation

Customers were grouped by number of products (1, 2, or 3+) and membership status (active or inactive).

| Product segment | Membership | Customers | Share of all customers | Average balance | Average age | Churn rate |
|---|---|---:|---:|---:|---:|---:|
| 1 Product | Active | 2,563 | 25.63% | 98,902.02 | 40.25 | 18.92% |
| 1 Product | Inactive | 2,521 | 25.21% | 98,195.89 | 39.09 | 36.65% |
| 2 Products | Active | 2,446 | 24.46% | 51,852.94 | 39.09 | 5.56% |
| 2 Products | Inactive | 2,144 | 21.44% | 51,909.04 | 36.23 | 9.89% |
| 3+ Products | Active | 142 | 1.42% | 74,057.29 | 43.65 | 80.28% |
| 3+ Products | Inactive | 184 | 1.84% | 82,498.74 | 43.66 | 90.22% |

**Findings**

- Active customers with two products have the lowest churn rate (5.56%) and represent 24.46% of all customers.
- Inactive single-product customers have a churn rate of 36.65%, compared with 18.92% among active single-product customers.
- Inactive membership is associated with a higher churn rate in each product-count group.
- Customers with 3+ products show very high churn (80.28% active; 90.22% inactive), but the combined group contains only 326 customers (3.26% of the dataset).

**Interpretation:** The combination of product count and membership activity distinguishes customer groups with notably different observed churn rates. The very high rates in the 3+ product group should be interpreted carefully because the group is small.

## 4.3 Country distribution and churn within product/activity segments

The following table breaks each of the six product/activity segments into France, Germany, and Spain. `Share within segment` is each country's proportion of that specific product/activity segment. `Churn rate` is calculated within the country and segment combination.

| Product segment | Membership | Country | Customers | Share within segment | Churned | Churn rate |
|---|---|---|---:|---:|---:|---:|
| 1 Product | Active | France | 1,261 | 49.20% | 193 | 15.31% |
| 1 Product | Active | Germany | 629 | 24.54% | 203 | 32.27% |
| 1 Product | Active | Spain | 673 | 26.26% | 89 | 13.22% |
| 1 Product | Inactive | France | 1,253 | 49.70% | 371 | 29.61% |
| 1 Product | Inactive | Germany | 720 | 28.56% | 375 | 52.08% |
| 1 Product | Inactive | Spain | 548 | 21.74% | 178 | 32.48% |
| 2 Products | Active | France | 1,269 | 51.88% | 58 | 4.57% |
| 2 Products | Active | Germany | 568 | 23.22% | 48 | 8.45% |
| 2 Products | Active | Spain | 609 | 24.90% | 30 | 4.93% |
| 2 Products | Inactive | France | 1,098 | 51.21% | 77 | 7.01% |
| 2 Products | Inactive | Germany | 472 | 22.01% | 78 | 16.53% |
| 2 Products | Inactive | Spain | 574 | 26.77% | 57 | 9.93% |
| 3+ Products | Active | France | 61 | 42.96% | 47 | 77.05% |
| 3+ Products | Active | Germany | 51 | 35.92% | 45 | 88.24% |
| 3+ Products | Active | Spain | 30 | 21.13% | 22 | 73.33% |
| 3+ Products | Inactive | France | 72 | 39.13% | 64 | 88.89% |
| 3+ Products | Inactive | Germany | 69 | 37.50% | 65 | 94.20% |
| 3+ Products | Inactive | Spain | 43 | 23.37% | 37 | 86.05% |

**Findings**

- Germany has the highest churn rate in all six product/activity/country comparisons.
- Among active single-product customers, German churn is 32.27%, compared with 15.31% in France and 13.22% in Spain.
- Among inactive single-product customers, German churn is 52.08%, compared with 29.61% in France and 32.48% in Spain.
- Among two-product customers, Germany again has the highest churn in both activity groups.
- The 3+ product groups have high churn across all countries, with Germany highest in both activity groups. These country-level subgroups are small (30–72 customers in several cells), so their rates may be unstable.

**Q4 conclusion:** The balance segmentation identifies a non-linear relationship between balance groups and churn. The product/activity segmentation identifies clear differences in observed churn across customer groups. Germany's higher churn remains visible in all six product/activity combinations, suggesting that differences in product count and active membership alone do not account for the country gap.

---

# Overall business takeaways

1. **Germany is the clearest retention concern.** Its overall churn rate is 32.44%, versus 16.15% in France and 16.67% in Spain.
2. **The German churn difference persists within the six product/activity combinations examined.** This indicates that the difference is not explained simply by the distribution of those two characteristics.
3. **Two-product active customers are the strongest-retention segment in this analysis.** Their overall churn rate is 5.56%.
4. **Inactive single-product customers are a potential retention concern.** Their observed churn rate is 36.65% overall and 52.08% among German customers.
5. **Customers with 3+ products have unusually high observed churn.** This warrants further investigation, but the segment is small.
6. **Balance alone does not explain churn.** The lower-middle positive-balance quartile has the highest churn among the balance groups.
7. **Most country averages are similar.** The largest country-level differences are average balance and churn.

# Limitations and interpretation notes

- All results in this document are descriptive. They do not demonstrate that geography, product count, membership activity, or balance causes churn.
- No statistical significance tests, confidence intervals, or multivariable logistic regression have been completed yet.
- The dataset does not include transaction histories, complaints, customer-service interactions, exit reasons, or competitor information. The actual reasons customers leave cannot be established from these fields alone.
- The 3+ product segment contains 326 customers in total, and its country-by-activity subgroups are smaller still. Interpret the very high churn percentages with caution.
- The balance quartiles were created only among positive-balance customers; zero-balance customers were kept as a separate group. Quartile sizes are therefore approximately 25% of positive-balance customers, not 25% of the full dataset.
- Country shares within a segment and churn rates within a country/segment are different measures. The denominator used for each percentage must be kept clear.
- Separate demographic distributions do not identify the most common combined demographic profile without a cross-tabulation.

# Recommended follow-up analysis

1. Use chi-square tests to assess selected associations between categorical variables and churn.
2. Calculate confidence intervals for key churn rates, especially for small segments.
3. Use logistic regression to examine whether the Germany churn difference remains after accounting for available customer characteristics.
4. Investigate the high churn in the 3+ product group and check whether its small sample size or data structure affects interpretation.
5. Build a Power BI dashboard after the statistical validation stage.
