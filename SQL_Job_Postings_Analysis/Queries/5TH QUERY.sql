/*
BUSINESS QUESTION:
Which combinations of skills do employers most frequently
request together in Data Analyst job postings? Exclude
pairs where both skills are the same, avoid counting
pairs twice in opposite orders (such as SQL + Python
and Python + SQL), and count distinct job postings
for each pair.

OBJECTIVE:
Identify the most commonly requested skill combinations
to help aspiring Data Analysts understand which skills
employers frequently expect together.
*/

SELECT sd1.skills as skill_1,sd2.skills AS skill_2,count(distinct jpf.job_id) as job_count
FROM job_postings_fact as jpf
INNER JOIN skills_job_dim as sjd1
ON jpf.job_id = sjd1.job_id
INNER JOIN skills_job_dim as sjd2
ON jpf.job_id = sjd2.job_id AND sjd1.skill_id < sjd2.skill_id
INNER JOIN skills_dim as sd1
ON sjd1.skill_id = sd1.skill_id
INNER JOIN skills_dim as sd2
ON sjd2.skill_id = sd2.skill_id
WHERE jpf.job_title_short ='Data Analyst'
GROUP BY sjd1.skill_id, sd1.skills, sjd2.skill_id, sd2.skills 
ORDER BY job_count DESC
LIMIT 20;  