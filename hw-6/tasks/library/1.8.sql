SELECT "Book"."Title", COUNT(*) AS "CopyCount"
FROM "Copy"
JOIN "Book" ON "Copy"."ISBN" = "Book"."ISBN"
GROUP BY "Book"."Title"
HAVING COUNT(*) > 1;
