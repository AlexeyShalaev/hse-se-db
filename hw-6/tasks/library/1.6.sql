SELECT "Author", COUNT(*) AS "BookCount"
FROM "Book"
GROUP BY "Author"
ORDER BY "BookCount" DESC
LIMIT 1;
