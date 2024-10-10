SELECT "Reader"."LastName", "Reader"."FirstName"
FROM "Reader"
JOIN "Borrowing" ON "Reader"."ID" = "Borrowing"."ReaderNr"
JOIN "Book" ON "Borrowing"."ISBN" = "Book"."ISBN"
WHERE "Book"."Author" = 'Марк Твен'
GROUP BY "Reader"."ID", "Reader"."LastName", "Reader"."FirstName"
HAVING COUNT(DISTINCT "Book"."ISBN") = (
  SELECT COUNT(DISTINCT "ISBN") FROM "Book" WHERE "Author" = 'Марк Твен'
);
