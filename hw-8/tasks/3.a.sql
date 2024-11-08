CREATE OR REPLACE PROCEDURE UPD_JOBSAL(
    p_job_id VARCHAR(10),
    p_new_min_salary INTEGER,
    p_new_max_salary INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM jobs WHERE job_id = p_job_id) THEN
        RAISE EXCEPTION 'Job ID % does not exist', p_job_id;
    END IF;

    IF p_new_max_salary < p_new_min_salary THEN
        RAISE EXCEPTION 'Maximum salary % is less than minimum salary %', p_new_max_salary, p_new_min_salary;
    END IF;

    BEGIN
        UPDATE jobs
        SET min_salary = p_new_min_salary,
            max_salary = p_new_max_salary
        WHERE job_id = p_job_id;
    EXCEPTION
        WHEN SQLSTATE '55P03' THEN 
            RAISE NOTICE 'The job row with ID % is currently locked or busy', p_job_id;
    END;
END;
$$;
