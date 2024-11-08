CREATE OR REPLACE FUNCTION GET_YEARS_SERVICE(p_employee_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_years INTEGER := 0;
    v_hire_date DATE;
BEGIN
    SELECT hire_date INTO v_hire_date FROM employees WHERE employee_id = p_employee_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee ID % does not exist', p_employee_id;
    END IF;

    SELECT COALESCE(SUM(EXTRACT(YEAR FROM age(end_date, start_date))), 0)
    INTO v_total_years
    FROM job_history
    WHERE employee_id = p_employee_id;

    IF v_hire_date IS NOT NULL THEN
        v_total_years := v_total_years + EXTRACT(YEAR FROM age(CURRENT_DATE, v_hire_date));
    END IF;

    RETURN v_total_years;
END;
$$;

DO $$
BEGIN
    BEGIN
        RAISE NOTICE 'Years of service for employee 999: %', GET_YEARS_SERVICE(999);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error: %', SQLERRM;
    END;
END;
$$;

DO $$
BEGIN
    RAISE NOTICE 'Years of service for employee 106: %', GET_YEARS_SERVICE(106);
END;
$$;

SELECT * FROM job_history WHERE employee_id = 106;
SELECT * FROM employees WHERE employee_id = 106;
