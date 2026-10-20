# SQL Job Postings Analysis

A **small SQL learning project** created while studying SQL for Data Analytics with **Luke Barousse's beginner SQL course**. I used PostgreSQL in Visual Studio Code to practise turning job-market questions into queries, exploring the results, and learning how different SQL techniques work.

This is a practice project—not a large, production-grade analytics project or a definitive report on the entire job market. The purpose is to strengthen SQL fundamentals through a familiar dataset and a set of self-practised questions.

## Credit and Dataset Source

The job-postings dataset and learning context come from Luke Barousse's SQL learning resources. Thank you to **Luke Barousse** for making the course and dataset resources available for learners.

- **Luke's SQL for Data Analytics course:** <https://www.lukebarousse.com/sql>
- **Luke's SQL job-analysis GitHub repository and dataset/setup resources:** <https://github.com/lukebarousse/SQL_Project_Data_Job_Analysis>

Please visit the original repository for the source data and setup instructions. This project focuses on my practice queries and results; it does not claim that I created the source dataset. Check the original repository's terms before copying or redistributing any underlying data.

## Project Goals

Through these exercises, I practised how to:

- Translate a business question into a SQL query.
- Filter job postings and group them into useful categories.
- Count records and calculate average salaries.
- Join job-posting records with skill information.
- Use common table expressions (CTEs) to organise a query.
- Use conditional aggregation to compare remote and non-remote jobs.
- Use a self-join to identify skills appearing together in the same posting.
- Count distinct job postings and avoid duplicate skill pairs.
- Inspect query results and export them as CSV files.

## Questions Explored

The questions below are the scope of this learning project. Findings are intentionally left for the actual query outputs; I have not filled in results without checking the exported data.

### 1. Monthly Hiring Trends

**Business question**  
When are Data Analyst opportunities increasing or decreasing? Count Data Analyst job postings for each month and identify the busiest and quietest months.

**Objective**  
Summarise monthly posting volume and compare the counts to understand changes in advertised hiring activity.

**Approach practised**  
Filter for Data Analyst roles, format `job_posted_date` as a year-month value with `TO_CHAR`, count the postings, and group them by month.

**SQL file:** `Queries/1ST QUERY.sql`  
**CSV result:** `Query Results/1ST query result.csv`

**Finding:** To be documented after reviewing the final CSV. For a query to rank busiest or quietest months automatically, sort by `total_postings` in descending or ascending order; sorting by month alone is chronological, not a ranking by count.

### 2. High-Demand, High-Salary Skills for Remote Data Analyst Roles

**Business question**  
What skills may be worth prioritising? Identify skills that are in high demand and associated with high average yearly salaries among remote Data Analyst job postings.

**Objective**  
Compare demand and salary together to identify skills that look promising within the available remote job-posting data.

**Approach practised**  
Filter to remote Data Analyst postings, connect job postings with their associated skills, calculate the posting count and average recorded yearly salary for each skill, and combine or compare the per-skill metrics.

**SQL file:** `Queries/2ND QUERY.sql`  
**CSV result:** `Query Results/2ND query result.csv`

**Finding:** To be documented after reviewing the final CSV. Average salary is calculated from postings with recorded salary values and should be interpreted alongside the number of postings behind the estimate.

### 3. Remote vs. Non-Remote Skill Opportunities

**Business question**  
Which skills are disproportionately associated with remote Data Analyst opportunities? For each skill, compare the number of remote postings, the number of non-remote postings, and the percentage of postings requiring that skill that are remote.

**Objective**  
Compare remote counts with non-remote counts and the remote share, rather than ranking skills by remote-job count alone.

**Approach practised**  
Use conditional aggregation with `CASE` inside `COUNT` to calculate remote and non-remote counts by skill, then calculate the remote percentage from those counts.

**SQL file:** `Queries/3RD QUERY.sql`  
**CSV result:** `Query Results/3RD query result.csv`

**Finding:** To be documented after reviewing the final CSV. Check that the query filters to `job_title_short = 'Data Analyst'`; without that condition, the counts would cover other job titles in the dataset as well. Skills with a high remote percentage should also be evaluated alongside their actual posting counts.

### 4. Skills Commonly Required Alongside SQL

**Business question**  
For Data Analyst job postings that require SQL, which other skills are commonly required in the same posting? For each skill other than SQL, count the distinct postings requiring both SQL and that skill.

**Objective**  
Identify complementary skills frequently requested alongside SQL to inform a Data Analyst learning plan.

**Approach practised**  
First identify job IDs for Data Analyst postings that require SQL. Then use those job IDs to find the other skills listed for the same postings, exclude SQL itself, and count distinct job IDs for each additional skill.

**SQL file:** `Queries/4TH QUERY.sql`  
**CSV result:** `Query Results/4TH query result.csv`

**Finding:** To be documented after checking that the CSV was exported from the final, corrected query.

### 5. Most Common Skill Combinations

**Business question**  
Which combinations of two different skills do employers most frequently request together in Data Analyst job postings? Exclude pairs where both skills are the same, avoid counting a pair twice in opposite orders (for example, SQL + Python and Python + SQL), and count distinct postings for each pair.

**Objective**  
Explore which skills commonly appear together, rather than considering each skill only in isolation.

**Approach practised**  
Join the skill-to-job mapping table to itself so two skills can be matched to the same job ID. Use a consistent ordering of skill IDs to avoid reversed duplicate pairs, group by each pair, count distinct job IDs, and sort pairs by posting count.

**SQL file:** `Queries/5TH QUERY.sql`  
**CSV result:** `Query Results/5TH query result.csv` *(add after exporting the final query output)*

**Finding:** Pending execution/export and review of the final result.

## Tools and SQL Concepts

**Tools**

- PostgreSQL
- Visual Studio Code
- GitHub for sharing the SQL practice files and results

**SQL concepts used**

- `SELECT`, `WHERE`, and `ORDER BY`
- `TO_CHAR` for year-month formatting
- `COUNT`, `COUNT(DISTINCT ...)`, and `AVG`
- `GROUP BY` and `HAVING` where appropriate
- `INNER JOIN` and joining tables through shared IDs
- Common table expressions (`WITH`)
- Conditional aggregation with `CASE` and `COUNT`
- Self-joins for skill-pair analysis
- Filtering out missing salary values and interpreting counts with care

The goal was to practise and understand these concepts as they came up—not to use every SQL feature or build a complex data platform.

## Repository Structure

```text
SQL_Job_Postings_Analysis/
├── README.md
├── Queries/
│   ├── 1ST QUERY.sql
│   ├── 2ND QUERY.sql
│   ├── 3RD QUERY.sql
│   ├── 4TH QUERY.sql
│   └── 5TH QUERY.sql
└── Query Results/
    ├── 1ST query result.csv
    ├── 2ND query result.csv
    ├── 3RD query result.csv
    ├── 4TH query result.csv
    └── 5TH query result.csv  # add after the final query is exported
```

The file names above follow the current local project structure. Keep them consistent with the names you upload to GitHub.

## How to View or Run the Work

- **To review the analysis:** Open the `.sql` files directly on GitHub. The CSV exports provide a preview of the query outputs without requiring a local database.
- **To run the queries:** Obtain the dataset from the original source linked above, follow its setup instructions, load the required tables into PostgreSQL, and execute each SQL file in an editor connected to that database.
- **To compare results:** Open the corresponding CSV file and compare it with the output produced by running the query.

Viewing the SQL and CSV exports does not require PostgreSQL. Re-running the SQL does require a compatible PostgreSQL setup and the source tables.

## Scope and Limitations

- This is a small learning exercise based on a job-postings dataset, not a comprehensive study of the labour market.
- Posting counts describe the records in this dataset; they should not automatically be treated as the total number of available jobs in the real world.
- Salary calculations use reported salary values and may be affected by missing salary information or small sample sizes.
- A skill appearing alongside a high salary is an association in the observed postings; it does not prove that the skill itself causes a higher salary.
- Key findings will be added only after the final query outputs have been checked.

## Acknowledgement

Thanks to **Luke Barousse** for the beginner SQL learning resources and the job-postings dataset used for practice. This repository documents my learning and SQL exercises using that resource.
