-- Должна быть ошибка
CALL UPD_JOBSAL('SY_ANAL', 7000, 140);

ALTER TABLE employees DISABLE TRIGGER ALL;
ALTER TABLE jobs DISABLE TRIGGER ALL;

CALL UPD_JOBSAL('SY_ANAL', 7000, 14000);

SELECT * FROM jobs WHERE job_id = 'SY_ANAL';

COMMIT;

ALTER TABLE employees ENABLE TRIGGER ALL;
ALTER TABLE jobs ENABLE TRIGGER ALL;