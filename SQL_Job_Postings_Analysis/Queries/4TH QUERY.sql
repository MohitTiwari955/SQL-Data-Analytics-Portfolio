/*
BUSINESS QUESTION:
You are learning SQL for Data Analyst roles and want to
discover which other skills employers commonly expect
alongside SQL. For every skill other than SQL, calculate
the number of distinct Data Analyst job postings that
require both SQL and that skill.

OBJECTIVE:
Identify complementary skills frequently requested
alongside SQL to help plan a Data Analyst learning path.
*/

WITH sql_postings as(
    SELECT jpf.job_id
    FROM job_postings_fact as jpf
    INNER JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id
    WHERE jpf.job_title_short = 'Data Analyst' AND sd.skills = 'sql'
)

SELECT sd.skills,count(DISTINCT sql_postings.job_id) AS jobs_alongside_sql
FROM sql_postings
INNER JOIN skills_job_dim AS sjd
ON sql_postings.job_id = sjd.job_id
INNER JOIN skills_dim as sd
ON sjd.skill_id = sd.skill_id
WHERE sd.skills <> 'sql'
GROUP BY sd.skills
ORDER BY jobs_alongside_sql DESC;