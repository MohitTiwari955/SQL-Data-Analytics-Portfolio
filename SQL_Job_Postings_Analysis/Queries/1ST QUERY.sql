/*
BUSINESS QUESTION:
You want to know when Data Analyst opportunities
are increasing or decreasing. Find the number of
Data Analyst job postings for each month and identify
the busiest and quietest months.

OBJECTIVE:
Summarize monthly job-posting volume to reveal
hiring trends.
*/

-- / Quietest Months
SELECT to_char(job_posted_date,'YYYY-MM') as postings_month,
    count(*) as total_postings
FROM job_postings_fact 
WHERE job_title_short = 'Data Analyst'
GROUP BY to_char(job_posted_date,'YYYY-MM')
ORDER BY postings_month desc;

-- Busiest Months
SELECT to_char(job_posted_date,'YYYY-MM') as postings_month,
    count(*) as total_postings
FROM job_postings_fact 
WHERE job_title_short = 'Data Analyst'
GROUP BY to_char(job_posted_date,'YYYY-MM')
ORDER BY postings_month desc;
