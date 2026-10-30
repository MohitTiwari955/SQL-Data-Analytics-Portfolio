# Dataset Source and Preparation Notes

## Dataset identification

**Dataset name:** Bank Customer Churn  
**Publisher / data-playground page:** Maven Analytics  
**Dataset page:** https://mavenanalytics.io/data-playground/bank-customer-churn  
**Source attribution shown by Maven:** Kaggle  
**License label shown by Maven:** Public Domain  
**Dataset description:** Account information for 10,000 customers at a European bank, including credit score, account balance, products, and whether customers have churned.

Maven Analytics lists the recommended business questions on the dataset page, including churner-versus-non-churner comparisons, customer demographics, country-level account behaviour, and customer segmentation. Those questions informed the structure of this project.

> **Attribution note:** Maven's page identifies Kaggle as the source and labels the dataset Public Domain. Before redistributing a raw CSV, check the licence and terms attached to the exact Kaggle copy downloaded. This repository documentation does not include or redistribute the raw dataset.

## Dataset size used in this analysis

The PostgreSQL analysis results reconcile to:

| Item | Value |
|---|---:|
| Customer records analysed | 10,000 |
| Churned customers (`Exited = 1`) | 2,037 |
| Retained customers (`Exited = 0`) | 7,963 |
| Overall churn rate | 20.37% |

The working table used in PostgreSQL was `public.bank_churn`.

## Fields used in the analysis

The analysis used the following customer attributes:

| Field | Description / analytical use |
|---|---|
| `CustomerId` | Customer identifier; used as a tie-breaker when ordering balance values for quartiles. |
| `Geography` | Customer country: France, Germany, or Spain. |
| `Gender` | Customer gender. |
| `Age` | Customer age; grouped into age bands for demographic profiling. |
| `CreditScore` | Customer credit score. |
| `Tenure` | Length of the customer relationship, in years. |
| `Balance` | Customer account balance. |
| `NumOfProducts` | Number of banking products held. |
| `HasCrCard` | Whether the customer has a credit card (0/1). |
| `IsActiveMember` | Whether the customer is marked as an active member (0/1). |
| `EstimatedSalary` | Estimated customer salary. |
| `Exited` | Churn indicator: 1 = churned; 0 = retained. |

The commonly distributed source file may also contain administrative or descriptive fields such as `RowNumber` and `Surname`. Those fields were not used as explanatory variables in the analyses documented here.

## Data preparation notes

- Geography labels were standardised so that country values used consistently in the analysis were `France`, `Germany`, and `Spain`.
- `EstimatedSalary` was treated as numeric. A currency symbol seen in a spreadsheet display was formatting, not a reason to strip characters from the underlying numeric values.
- Surname was not used as an analytical feature.
- Customer-level analysis treated one row as one customer. The 10,000 records and churn totals above were checked against the SQL results.
- `HasCrCard` and `IsActiveMember` were retained as separate fields. Their aggregate totals differ in this analysis (7,055 credit-card holders versus 5,151 active members), so they should not be documented as identical columns.

## Derived fields and segmentation logic

### Age groups (Q2)

- Under 30
- 30–39
- 40–49
- 50–59
- 60+

### Balance segments (Q4)

Zero-balance customers were separated into their own segment because 3,617 customers (36.17%) had a balance of zero. The remaining 6,383 positive-balance customers were divided into four approximately equal-sized groups using `NTILE(4)` ordered by `Balance` and `CustomerId`.

### Product and membership segments (Q4)

Customers were grouped by:

- Product ownership: 1 product, 2 products, or 3+ products.
- Membership status: Active or Inactive.

This produced six combinations. Churn was then profiled within each segment and by country.

## Data limitations

The dataset is a customer-level snapshot with a churn indicator and a limited set of demographic and account attributes. It does not provide transaction-level history, customer complaints, stated exit reasons, customer-service interactions, or competitor information. Therefore, it can support descriptive analysis and exploratory modelling, but it cannot by itself establish the underlying causes of churn.

## References

1. [Maven Analytics – Bank Customer Churn dataset page](https://mavenanalytics.io/data-playground/bank-customer-churn) — dataset description, recommended analysis questions, Kaggle source attribution, and licence label.
2. [Microsoft Learn – Customer churn tutorial](https://learn.microsoft.com/en-us/fabric/data-science/customer-churn) — describes the commonly used 10,000-customer bank churn dataset, its customer attributes, and the `Exited` churn field.
