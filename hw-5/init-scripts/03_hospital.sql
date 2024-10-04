\c hospital

CREATE TABLE "stations" (
  "station_number" int PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE "rooms" (
  "room_number" int PRIMARY KEY,
  "number_of_beds" int NOT NULL,
  "station_number" int NOT NULL
);

CREATE TABLE "patients" (
  "patient_number" int PRIMARY KEY,
  "name" varchar NOT NULL,
  "disease" varchar NOT NULL,
  "doctor_personnel_number" int NOT NULL
);

CREATE TABLE "station_personnel" (
  "personnel_number" int PRIMARY KEY,
  "name" varchar NOT NULL,
  "station_number" int NOT NULL
);

CREATE TABLE "doctors" (
  "personnel_number" int PRIMARY KEY,
  "rank" varchar NOT NULL,
  "area" varchar NOT NULL
);

CREATE TABLE "caregivers" (
  "personnel_number" int PRIMARY KEY,
  "qualification" varchar NOT NULL
);

CREATE TABLE "admissions" (
  "patient_number" int NOT NULL,
  "room_number" int NOT NULL,
  "admission_from" timestamp NOT NULL,
  "admission_to" timestamp,
  PRIMARY KEY ("patient_number", "room_number")
);

ALTER TABLE "rooms" ADD FOREIGN KEY ("station_number") REFERENCES "stations" ("station_number");

ALTER TABLE "patients" ADD FOREIGN KEY ("doctor_personnel_number") REFERENCES "doctors" ("personnel_number");

ALTER TABLE "station_personnel" ADD FOREIGN KEY ("station_number") REFERENCES "stations" ("station_number");

ALTER TABLE "doctors" ADD FOREIGN KEY ("personnel_number") REFERENCES "station_personnel" ("personnel_number");

ALTER TABLE "caregivers" ADD FOREIGN KEY ("personnel_number") REFERENCES "station_personnel" ("personnel_number");

ALTER TABLE "admissions" ADD FOREIGN KEY ("patient_number") REFERENCES "patients" ("patient_number");

ALTER TABLE "admissions" ADD FOREIGN KEY ("room_number") REFERENCES "rooms" ("room_number");
