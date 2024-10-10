-- Подключаемся к базе данных library
\c library

-- ==============================
-- Создание таблиц с каскадным удалением
-- ==============================

-- Создаем таблицу Publisher
CREATE TABLE "Publisher" (
  "PubName" varchar PRIMARY KEY,
  "PubAdress" varchar NOT NULL
);

-- Создаем таблицу Book с каскадным удалением связанных записей
CREATE TABLE "Book" (
  "ISBN" varchar PRIMARY KEY,
  "Title" varchar NOT NULL,
  "Author" varchar NOT NULL,
  "PagesNum" int NOT NULL,
  "PubYear" int NOT NULL,
  "PubName" varchar NOT NULL,
  FOREIGN KEY ("PubName") REFERENCES "Publisher" ("PubName") ON DELETE CASCADE
);

-- Создаем таблицу Category
CREATE TABLE "Category" (
  "CategoryName" varchar PRIMARY KEY,
  "ParentCat" varchar,
  FOREIGN KEY ("ParentCat") REFERENCES "Category" ("CategoryName") ON DELETE CASCADE
);

-- Создаем таблицу BookCat с каскадным удалением связанных записей
CREATE TABLE "BookCat" (
  "ISBN" varchar NOT NULL,
  "CategoryName" varchar NOT NULL,
  PRIMARY KEY ("ISBN", "CategoryName"),
  FOREIGN KEY ("ISBN") REFERENCES "Book" ("ISBN") ON DELETE CASCADE,
  FOREIGN KEY ("CategoryName") REFERENCES "Category" ("CategoryName") ON DELETE CASCADE
);

-- Создаем таблицу Copy с каскадным удалением связанных записей
CREATE TABLE "Copy" (
  "ISBN" varchar NOT NULL,
  "CopyNumber" SERIAL,
  "ShelfPosition" varchar NOT NULL,
  PRIMARY KEY ("ISBN", "CopyNumber"),
  FOREIGN KEY ("ISBN") REFERENCES "Book" ("ISBN") ON DELETE CASCADE
);

-- Создаем таблицу Reader
CREATE TABLE "Reader" (
  "ID" SERIAL PRIMARY KEY,
  "LastName" varchar NOT NULL,
  "FirstName" varchar NOT NULL,
  "Address" varchar NOT NULL,
  "BirthDate" date NOT NULL
);

-- Создаем таблицу Borrowing с каскадным удалением связанных записей
CREATE TABLE "Borrowing" (
  "ReaderNr" int NOT NULL,
  "ISBN" varchar NOT NULL,
  "CopyNumber" int NOT NULL,
  "ReturnDate" date,
  PRIMARY KEY ("ReaderNr", "ISBN", "CopyNumber"),
  FOREIGN KEY ("ReaderNr") REFERENCES "Reader" ("ID") ON DELETE CASCADE,
  FOREIGN KEY ("ISBN", "CopyNumber") REFERENCES "Copy" ("ISBN", "CopyNumber") ON DELETE CASCADE
);
