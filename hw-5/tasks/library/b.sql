SELECT DISTINCT "Book"."Author", "Book"."Title"
FROM "Book"
JOIN "Borrowing" ON "Book"."ISBN" = "Borrowing"."ISBN"
JOIN "Reader" ON "Borrowing"."ReaderNr" = "Reader"."ID"
WHERE "Reader"."FirstName" = 'Иван' AND "Reader"."LastName" = 'Иванов';
