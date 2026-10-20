/*
BUSINESS QUESTION:
What are the most optimal skills to learn?
Identify skills in high demand associated with high
average salaries for remote Data Analyst roles.

OBJECTIVE:
Identify promising skills to learn by comparing job
demand and average yearly salaries among remote
Data Analyst job postings.
*/

WITH skills_demand as (
    SELECT skills_dim.skill_id, skills_dim.skills,Count(skills_job_dim.job_id) as demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
    GROUP BY skills_dim.skill_id, skills_dim.skills
    order by skills_dim.skill_id  
),
average_salary as (
    SELECT skills_dim.skill_id, skills_dim.skills,ROUND(AVG(salary_year_avg),0) as avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
    GROUP BY skills_dim.skill_id, skills_dim.skills
    order by skills_dim.skill_id  
)

SELECT skills_demand.skill_id, skills_demand.skills,demand_count,avg_salary 
FROM skills_demand
INNER JOIN average_salary
ON skills_demand.skill_id = average_salary.skill_id
ORDER BY avg_salary DESC , demand_count DESC;