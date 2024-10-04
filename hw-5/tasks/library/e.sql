SELECT DISTINCT other_readers."LastName", other_readers."FirstName"
FROM "Borrowing" AS other_borrowings
JOIN "Reader" AS other_readers ON other_borrowings."ReaderNr" = other_readers."ID"
WHERE other_borrowings."ISBN" IN (
    SELECT DISTINCT "Borrowing"."ISBN"
    FROM "Borrowing"
    JOIN "Reader" ON "Borrowing"."ReaderNr" = "Reader"."ID"
    WHERE "Reader"."FirstName" = 'Иван' AND "Reader"."LastName" = 'Иванов'
)
AND NOT (other_readers."FirstName" = 'Иван' AND other_readers."LastName" = 'Иванов');
