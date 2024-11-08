CREATE OR REPLACE FUNCTION GET_JOB_COUNT(p_employee_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_count INTEGER := 0;
    v_current_job VARCHAR(10);
BEGIN
    SELECT job_id INTO v_current_job FROM employees WHERE employee_id = p_employee_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee ID % does not exist', p_employee_id;
    END IF;

    SELECT COUNT(DISTINCT job_id)
    INTO v_job_count
    FROM (
        SELECT job_id FROM job_history WHERE employee_id = p_employee_id
        UNION
        SELECT v_current_job
    ) AS distinct_jobs;

    RETURN v_job_count;
END;
$$;

DO $$
BEGIN
    RAISE NOTICE 'Distinct job count for employee 176: %', GET_JOB_COUNT(176);
END;
$$;
