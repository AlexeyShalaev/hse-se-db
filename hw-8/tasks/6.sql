CREATE OR REPLACE FUNCTION check_salary_range()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_employee RECORD;
BEGIN
    FOR v_employee IN 
        SELECT employee_id, last_name, salary 
        FROM employees 
        WHERE job_id = NEW.job_id
    LOOP
        IF v_employee.salary < NEW.min_salary OR v_employee.salary > NEW.max_salary THEN
            RAISE EXCEPTION 'Salary of employee ID % (Last name: %, Salary: %) is outside the new range [% - %] for job ID %',
                            v_employee.employee_id, v_employee.last_name, v_employee.salary,
                            NEW.min_salary, NEW.max_salary, NEW.job_id;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_sal_range
BEFORE UPDATE OF min_salary, max_salary ON jobs
FOR EACH ROW
EXECUTE FUNCTION check_salary_range();

SELECT job_id, min_salary, max_salary FROM jobs WHERE job_id = 'SY_ANAL';
SELECT employee_id, last_name, salary FROM employees WHERE job_id = 'SY_ANAL';

UPDATE jobs SET min_salary = 5000, max_salary = 7000 WHERE job_id = 'SY_ANAL';

-- Здесь будет ошибка, так как есть сотрудник с зарплатой 6500 < 7000
-- Salary of employee ID 106 (Last name: Pataballa, Salary: 6500.00) is outside the new range [7000 - 18000] for job ID SY_ANAL
UPDATE jobs SET min_salary = 7000, max_salary = 18000 WHERE job_id = 'SY_ANAL';
