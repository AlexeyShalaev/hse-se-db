SELECT DISTINCT c."TrainNr", c."FromStation", c."ToStation", c."Departure", c."Arrival"
FROM "Connection" c
JOIN "Station" fs ON c."FromStation" = fs."Name"
JOIN "City" fc ON fs."CityName" = fc."Name" AND fs."Region" = fc."Region"
JOIN "Station" ts ON c."ToStation" = ts."Name"
JOIN "City" tc ON ts."CityName" = tc."Name" AND ts."Region" = tc."Region"
WHERE fc."Name" = 'Москва'
  AND tc."Name" = 'Тверь'
  AND c."FromStation" <> c."ToStation";
