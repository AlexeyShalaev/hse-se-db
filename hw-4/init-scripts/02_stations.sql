CREATE TABLE "train_stations" (
  "name" varchar PRIMARY KEY,
  "num_tracks" int NOT NULL,
  "city_name" varchar NOT NULL
);

CREATE TABLE "cities" (
  "name" varchar PRIMARY KEY,
  "region" varchar NOT NULL
);

CREATE TABLE "trains" (
  "train_number" varchar PRIMARY KEY,
  "length" int NOT NULL
);

CREATE TABLE "journeys" (
  "id" SERIAL PRIMARY KEY,
  "train_number" varchar NOT NULL,
  "departure_station_name" varchar NOT NULL,
  "arrival_station_name" varchar NOT NULL,
  "departure_time" timestamp NOT NULL,
  "arrival_time" timestamp NOT NULL
);

ALTER TABLE "train_stations" ADD FOREIGN KEY ("city_name") REFERENCES "cities" ("name");

ALTER TABLE "journeys" ADD FOREIGN KEY ("train_number") REFERENCES "trains" ("train_number");

ALTER TABLE "journeys" ADD FOREIGN KEY ("departure_station_name") REFERENCES "train_stations" ("name");

ALTER TABLE "journeys" ADD FOREIGN KEY ("arrival_station_name") REFERENCES "train_stations" ("name");
