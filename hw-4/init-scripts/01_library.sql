CREATE TABLE "books" (
  "ISBN" varchar PRIMARY KEY,
  "title" varchar NOT NULL,
  "author" varchar NOT NULL,
  "year" int NOT NULL,
  "pages" int NOT NULL,
  "publisher_id" int NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "categories" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar UNIQUE NOT NULL,
  "parent_category_id" int
);

CREATE TABLE "book_categories" (
  "book_ISBN" varchar NOT NULL,
  "category_id" int NOT NULL,
  PRIMARY KEY ("book_ISBN", "category_id")
);

CREATE TABLE "book_copies" (
  "copy_number" SERIAL PRIMARY KEY,
  "ISBN" varchar NOT NULL,
  "shelf_location" varchar NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "publishers" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar NOT NULL,
  "address" varchar NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "readers" (
  "id" SERIAL PRIMARY KEY,
  "first_name" varchar NOT NULL,
  "last_name" varchar NOT NULL,
  "address" varchar NOT NULL,
  "birth_date" date NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "borrows" (
  "id" SERIAL PRIMARY KEY,
  "reader_id" int NOT NULL,
  "copy_number" int NOT NULL,
  "borrow_date" timestamp NOT NULL,
  "return_date" timestamp
);

ALTER TABLE "books" ADD FOREIGN KEY ("publisher_id") REFERENCES "publishers" ("id");

ALTER TABLE "categories" ADD FOREIGN KEY ("parent_category_id") REFERENCES "categories" ("id");

ALTER TABLE "book_categories" ADD FOREIGN KEY ("book_ISBN") REFERENCES "books" ("ISBN");

ALTER TABLE "book_categories" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "book_copies" ADD FOREIGN KEY ("ISBN") REFERENCES "books" ("ISBN");

ALTER TABLE "borrows" ADD FOREIGN KEY ("reader_id") REFERENCES "readers" ("id");

ALTER TABLE "borrows" ADD FOREIGN KEY ("copy_number") REFERENCES "book_copies" ("copy_number");
