WITH RECURSIVE routes AS (
    -- Базовый случай: все соединения, отправляющиеся из Москвы
    SELECT
        c."FromStation",
        c."ToStation",
        c."Departure",
        c."Arrival",
        ARRAY[c."TrainNr"] AS "TrainNrs",
        ARRAY[c."FromStation", c."ToStation"] AS "StationsVisited",
        c."Departure" AS "FirstDeparture",
        c."Arrival" AS "LastArrival",
        1 AS "NumSegments"
    FROM "Connection" c
    JOIN "Station" s ON c."FromStation" = s."Name"
    JOIN "City" city ON s."CityName" = city."Name" AND s."Region" = city."Region"
    WHERE city."Name" = 'Москва'
      AND DATE(c."Departure") = DATE(c."Arrival")  -- Отправление и прибытие в один день

    UNION ALL

    -- Рекурсивный случай: расширяем маршруты
    SELECT
        r."FromStation",
        c."ToStation",
        r."Departure",
        c."Arrival",
        r."TrainNrs" || c."TrainNr",
        r."StationsVisited" || c."ToStation",
        r."FirstDeparture",
        c."Arrival" AS "LastArrival",
        r."NumSegments" + 1
    FROM routes r
    JOIN "Connection" c ON r."ToStation" = c."FromStation"
    WHERE c."Departure" >= r."Arrival"
      AND NOT c."ToStation" = ANY(r."StationsVisited")  -- Избегаем циклов
      AND DATE(r."FirstDeparture") = DATE(c."Arrival")  -- Поездка в один день
      AND r."NumSegments" < 10  -- Ограничение глубины рекурсии
)

SELECT DISTINCT
    r."TrainNrs",
    r."StationsVisited",
    r."FirstDeparture",
    r."LastArrival",
    r."NumSegments"
FROM routes r
JOIN "Station" s ON r."ToStation" = s."Name"
JOIN "City" city ON s."CityName" = city."Name" AND s."Region" = city."Region"
WHERE city."Name" = 'Санкт-Петербург'
  AND DATE(r."FirstDeparture") = DATE(r."LastArrival")  -- Поездка в один день
  AND r."NumSegments" > 1  -- Исключаем прямые маршруты
ORDER BY r."FirstDeparture";
