SELECT "Book"."Title", "Publisher"."PubName"
FROM "Book"
JOIN "Publisher" ON "Book"."PubName" = "Publisher"."PubName";
