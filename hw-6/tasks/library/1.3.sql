SELECT "Author"
FROM "Book"
GROUP BY "Author"
HAVING COUNT(*) > 5;
