-- Подключаемся к базе данных library
\c library

-- ==============================
-- Создание таблиц
-- ==============================

-- Создаем таблицу Publisher
CREATE TABLE "Publisher" (
  "PubName" varchar PRIMARY KEY,
  "PubAdress" varchar NOT NULL
);

-- Создаем таблицу Book
CREATE TABLE "Book" (
  "ISBN" varchar PRIMARY KEY,
  "Title" varchar NOT NULL,
  "Author" varchar NOT NULL,
  "PagesNum" int NOT NULL,
  "PubYear" int NOT NULL,
  "PubName" varchar NOT NULL,
  FOREIGN KEY ("PubName") REFERENCES "Publisher" ("PubName")
);

-- Создаем таблицу Category
CREATE TABLE "Category" (
  "CategoryName" varchar PRIMARY KEY,
  "ParentCat" varchar,
  FOREIGN KEY ("ParentCat") REFERENCES "Category" ("CategoryName")
);

-- Создаем таблицу BookCat
CREATE TABLE "BookCat" (
  "ISBN" varchar NOT NULL,
  "CategoryName" varchar NOT NULL,
  PRIMARY KEY ("ISBN", "CategoryName"),
  FOREIGN KEY ("ISBN") REFERENCES "Book" ("ISBN"),
  FOREIGN KEY ("CategoryName") REFERENCES "Category" ("CategoryName")
);

-- Создаем таблицу Copy
CREATE TABLE "Copy" (
  "ISBN" varchar NOT NULL,
  "CopyNumber" SERIAL,
  "ShelfPosition" varchar NOT NULL,
  PRIMARY KEY ("ISBN", "CopyNumber"),
  FOREIGN KEY ("ISBN") REFERENCES "Book" ("ISBN")
);

-- Создаем таблицу Reader
CREATE TABLE "Reader" (
  "ID" SERIAL PRIMARY KEY,
  "LastName" varchar NOT NULL,
  "FirstName" varchar NOT NULL,
  "Address" varchar NOT NULL,
  "BirthDate" date NOT NULL
);

-- Создаем таблицу Borrowing
CREATE TABLE "Borrowing" (
  "ReaderNr" int NOT NULL,
  "ISBN" varchar NOT NULL,
  "CopyNumber" int NOT NULL,
  "ReturnDate" date,
  PRIMARY KEY ("ReaderNr", "ISBN", "CopyNumber"),
  FOREIGN KEY ("ReaderNr") REFERENCES "Reader" ("ID"),
  FOREIGN KEY ("ISBN", "CopyNumber") REFERENCES "Copy" ("ISBN", "CopyNumber")
);
