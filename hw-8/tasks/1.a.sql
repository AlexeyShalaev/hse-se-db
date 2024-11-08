CREATE OR REPLACE PROCEDURE NEW_JOB(
    p_job_id VARCHAR(10),
    p_job_title VARCHAR(35),
    p_min_salary INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert a new job with max_salary calculated as twice the min_salary
    INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
    VALUES (p_job_id, p_job_title, p_min_salary, p_min_salary * 2);
END;
$$;
