SELECT DISTINCT "Reader"."LastName", "Reader"."FirstName"
FROM "Reader"
JOIN "Borrowing" ON "Reader"."ID" = "Borrowing"."ReaderNr"
WHERE "Borrowing"."ReturnDate" IS NOT NULL;
