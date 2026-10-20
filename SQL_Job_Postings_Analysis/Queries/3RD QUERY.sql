/*
BUSINESS QUESTION:
Which skills are disproportionately associated with remote
Data Analyst opportunities? For every skill, compare the
number of remote jobs, non-remote jobs, and the percentage
of jobs requiring that skill that are remote.

OBJECTIVE:
Identify skills that are more strongly associated with
remote Data Analyst opportunities by comparing remote and
non-remote job counts and the remote percentage for each skill.
*/

WITH skill_job_counts AS (
    SELECT sd.skill_id, sd.skills,
    Count(CASE WHEN jpf.job_work_from_home = TRUE THEN 1 END) AS remote_jobs,
    Count(CASE WHEN jpf.job_work_from_home = FALSE THEN 1 END) AS non_remote_jobs
    FROM skills_job_dim as sjd
    JOIN job_postings_fact AS jpf
    ON sjd.job_id = jpf.job_id
    JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
    GROUP BY sd.skill_id, sd.skills
)

SELECT skills,remote_jobs, non_remote_jobs, 100*remote_jobs/(remote_jobs + non_remote_jobs)
        AS remote_percentage
FROM skill_job_counts
ORDER BY remote_percentage DESC;