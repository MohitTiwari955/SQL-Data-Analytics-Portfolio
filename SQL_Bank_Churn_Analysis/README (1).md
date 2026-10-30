# Bank Customer Churn Analysis

A SQL-based exploratory analysis of customer churn, demographics, country-level banking behaviour, and customer segments using a 10,000-record European bank customer dataset.

> **Project status:** Descriptive SQL analysis for Q1–Q4 completed. Statistical validation and dashboard development are planned as follow-up work.

## Project overview

Customer churn is an important retention problem for banks. This project uses customer-level account information to understand how churn differs across customer groups and which patterns may deserve further investigation.

The analysis was performed in **PostgreSQL** on the `public.bank_churn` table. The work focuses on translating business questions into SQL analysis and interpreting the results rather than simply producing query outputs.

## Business questions

1. **How do churned and retained customers differ?** Compare customer characteristics and churn rates across demographic, financial, and account-related attributes.
2. **What do the bank's customer demographics look like?** Describe the customer base by geography, gender, and age group.
3. **Do German, French, and Spanish customers differ in account behaviour?** Compare country-level averages, activity, and churn.
4. **What types of customer segments exist?** Build balance-based and product-usage/activity segments, then profile their characteristics and churn.

## Dataset at a glance

- **Records analysed:** 10,000 customers
- **Churned customers:** 2,037 (20.37%)
- **Retained customers:** 7,963 (79.63%)
- **Countries:** France, Germany, and Spain
- **Target field:** `Exited` (1 = churned; 0 = retained)
- **Source:** [Maven Analytics – Bank Customer Churn](https://mavenanalytics.io/data-playground/bank-customer-churn)

See [Dataset_Source.md](Documentation/Dataset_Source.md) for source attribution, field descriptions, and data-preparation notes.

## Tools and techniques

- **Database:** PostgreSQL
- **SQL client:** DBeaver / PostgreSQL tools
- **Version control and documentation:** Git and GitHub Markdown
- **SQL techniques used:** `GROUP BY`, aggregate functions, `CASE WHEN`, conditional aggregation, CTEs, window functions (`NTILE`, `SUM() OVER`, `AVG() OVER`), `PARTITION BY`, and percentage calculations.

## Analysis highlights

- The overall customer churn rate is **20.37%**.
- Germany has the highest country-level churn rate at **32.44%**, compared with **16.15%** in France and **16.67%** in Spain.
- German customers have a much higher average account balance (**119,730.12**) than customers in France (**62,092.64**) and Spain (**61,818.15**).
- Customers aged **30–39** are the largest age group, accounting for **43.46%** of the customer base.
- Active customers holding **two products** have the lowest churn rate among the six product/activity groups (**5.56%**).
- Germany has the highest churn rate in all six combinations of product ownership and membership activity examined.
- The positive-balance quartile with the highest churn is the **lower-middle balance group** (**27.38%**); churn does not rise consistently with balance.

The detailed tables, interpretations, and caveats are in [Analysis_Findings.md](Documentation/Analysis_Findings.md).

## Repository structure

```text
Bank-Customer-Churn-Analysis/
├── README.md
├── SQL/
│   ├── Q1_Churn_Comparison.sql
│   ├── Q2_Customer_Demographics.sql
│   ├── Q3_Country_Analysis.sql
│   └── Q4_Customer_Segmentation.sql
└── Documentation/
    ├── Analysis_Findings.md
    └── Dataset_Source.md
```

The SQL directory is shown as the intended location for the query files. Add the query scripts separately; they are not included in this documentation package.

## How to read the findings

- **Counts** describe the number of customers in a group.
- **Customer share** describes a group's percentage of the full 10,000-customer dataset unless a table explicitly says “within segment.”
- **Churn rate** is churned customers divided by all customers in the stated group.
- **Within-segment country share** is a country's proportion of a particular product/activity segment; it is not the country's churn rate.

## Important limitations

- The findings are descriptive. They identify patterns and associations, not causal explanations.
- Statistical significance tests and multivariable modelling have not yet been completed.
- The dataset does not include transaction histories, customer complaints, exit reasons, or detailed service interactions, so it cannot establish why customers leave.
- The 3+ product segment is small (266 customers in total), so its very high observed churn rates should be interpreted cautiously.
- The country comparisons are broken down by product ownership and membership activity, but this is not the same as controlling for every possible customer characteristic in a statistical model.
- Currency units are not specified in this documentation; balance and salary values are reported as they appear in the dataset.

## Next steps

1. Statistically validate selected categorical differences (for example, with chi-square tests and confidence intervals).
2. Use logistic regression to examine whether the country-level churn difference persists after accounting for available customer characteristics.
3. Build a Power BI dashboard from the validated analysis.
4. Consider a separate Python clustering exercise to explore data-driven customer groups.

---

*This is an independent learning and portfolio project using a publicly listed practice dataset. It is not an analysis commissioned by or affiliated with a real bank.*
