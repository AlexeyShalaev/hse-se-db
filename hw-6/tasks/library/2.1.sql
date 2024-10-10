-- Добавление записи о бронировании читателем ‘Василием Петровым’ книги с ISBN '123456' и номером копии 4.
INSERT INTO "Borrowing" ("ReaderNr", "ISBN", "CopyNumber", "ReturnDate")
VALUES (
    (SELECT "ID" FROM "Reader" WHERE "FirstName" = 'Василий' AND "LastName" = 'Петров'),
    '123456',
    4,
    NULL  -- Книга еще не возвращена
);
