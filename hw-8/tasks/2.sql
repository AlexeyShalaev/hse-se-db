ALTER TABLE employees DISABLE TRIGGER ALL;
ALTER TABLE jobs DISABLE TRIGGER ALL;
ALTER TABLE job_history DISABLE TRIGGER ALL;

CREATE OR REPLACE PROCEDURE ADD_JOB_HIST(
    p_employee_id INTEGER,
    p_new_job_id VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_min_salary INTEGER;
    v_hire_date DATE;
BEGIN
    SELECT hire_date INTO v_hire_date FROM employees WHERE employee_id = p_employee_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee ID % does not exist', p_employee_id;
    END IF;

    SELECT min_salary INTO v_min_salary FROM jobs WHERE job_id = p_new_job_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Job ID % does not exist', p_new_job_id;
    END IF;

    INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
    VALUES (p_employee_id, v_hire_date, CURRENT_DATE, p_new_job_id, 
            (SELECT department_id FROM employees WHERE employee_id = p_employee_id));

    UPDATE employees
    SET hire_date = CURRENT_DATE,
        job_id = p_new_job_id,
        salary = v_min_salary + 500
    WHERE employee_id = p_employee_id;
END;
$$;

CALL ADD_JOB_HIST(106, 'SY_ANAL');

SELECT * FROM job_history WHERE employee_id = 106;
SELECT * FROM employees WHERE employee_id = 106;

COMMIT;

ALTER TABLE employees ENABLE TRIGGER ALL;
ALTER TABLE jobs ENABLE TRIGGER ALL;
ALTER TABLE job_history ENABLE TRIGGER ALL;
