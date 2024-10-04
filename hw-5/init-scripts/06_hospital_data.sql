-- Подключаемся к базе данных hospital
\c hospital

-- ==============================
-- Заполнение таблиц данными
-- ==============================

-- 1. Заполнение таблицы stations
INSERT INTO "stations" ("station_number", "name")
SELECT
  s AS station_number,
  'Отделение ' || s AS name
FROM generate_series(1, 10) AS s;

-- 2. Заполнение таблицы station_personnel
INSERT INTO "station_personnel" ("personnel_number", "name", "station_number")
SELECT
  s AS personnel_number,
  'Сотрудник ' || s AS name,
  (FLOOR(random() * 10) + 1)::int AS station_number  -- Ссылается на существующую станцию
FROM generate_series(1, 50) AS s;

-- 3. Заполнение таблицы doctors
INSERT INTO "doctors" ("personnel_number", "rank", "area")
SELECT
  sp.personnel_number,
  'Ранг ' || (FLOOR(random() * 5) + 1) AS rank,
  'Специализация ' || (FLOOR(random() * 5) + 1) AS area
FROM "station_personnel" sp
WHERE sp.personnel_number <= 30;  -- Предположим, что первые 30 сотрудников - врачи

-- 4. Заполнение таблицы caregivers
INSERT INTO "caregivers" ("personnel_number", "qualification")
SELECT
  sp.personnel_number,
  'Квалификация ' || (FLOOR(random() * 3) + 1) AS qualification
FROM "station_personnel" sp
WHERE sp.personnel_number > 30;  -- Остальные сотрудники - санитары

-- 5. Заполнение таблицы rooms
INSERT INTO "rooms" ("room_number", "number_of_beds", "station_number")
SELECT
  s AS room_number,
  (FLOOR(random() * 4) + 1)::int AS number_of_beds,  -- Количество коек от 1 до 4
  (FLOOR(random() * 10) + 1)::int AS station_number  -- Ссылается на существующую станцию
FROM generate_series(1, 30) AS s;

-- 6. Заполнение таблицы patients
INSERT INTO "patients" ("patient_number", "name", "disease", "doctor_personnel_number")
SELECT
  s AS patient_number,
  'Пациент ' || s AS name,
  'Диагноз ' || (FLOOR(random() * 10) + 1) AS disease,
  (FLOOR(random() * 30) + 1)::int AS doctor_personnel_number  -- Ссылается на существующего доктора
FROM generate_series(1, 100) AS s;

-- 7. Заполнение таблицы admissions
-- Для каждого пациента создаем запись о госпитализации
INSERT INTO "admissions" ("patient_number", "room_number", "admission_from", "admission_to")
SELECT
  p.patient_number,
  (FLOOR(random() * 30) + 1)::int AS room_number,  -- Ссылается на существующую палату
  NOW() - (random() * interval '2 years') AS admission_from,
  CASE
    WHEN random() < 0.7 THEN NOW() - (random() * interval '1 years')  -- 70% пациентов выписаны
    ELSE NULL  -- 30% все еще находятся в больнице
  END AS admission_to
FROM "patients" p;
