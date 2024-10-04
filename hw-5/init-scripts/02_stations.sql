-- Подключаемся к базе данных stations
\c stations

-- ==============================
-- Создание таблиц
-- ==============================

-- Создаем таблицу City
CREATE TABLE "City" (
  "Name" varchar NOT NULL,
  "Region" varchar NOT NULL,
  PRIMARY KEY ("Name", "Region")
);

-- Создаем таблицу Station
CREATE TABLE "Station" (
  "Name" varchar PRIMARY KEY,
  "#Tracks" int NOT NULL,
  "CityName" varchar NOT NULL,
  "Region" varchar NOT NULL,
  FOREIGN KEY ("CityName", "Region") REFERENCES "City" ("Name", "Region")
);

-- Создаем таблицу Train
CREATE TABLE "Train" (
  "TrainNr" varchar PRIMARY KEY,
  "Length" int NOT NULL,
  "StartStationName" varchar NOT NULL,
  "EndStationName" varchar NOT NULL,
  FOREIGN KEY ("StartStationName") REFERENCES "Station" ("Name"),
  FOREIGN KEY ("EndStationName") REFERENCES "Station" ("Name")
);

-- Создаем таблицу Connection
CREATE TABLE "Connection" (
  "FromStation" varchar NOT NULL,
  "ToStation" varchar NOT NULL,
  "TrainNr" varchar NOT NULL,
  "Departure" timestamp NOT NULL,
  "Arrival" timestamp NOT NULL,
  PRIMARY KEY ("FromStation", "ToStation", "TrainNr", "Departure"),
  FOREIGN KEY ("FromStation") REFERENCES "Station" ("Name"),
  FOREIGN KEY ("ToStation") REFERENCES "Station" ("Name"),
  FOREIGN KEY ("TrainNr") REFERENCES "Train" ("TrainNr")
);
