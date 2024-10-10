SELECT "Title", "PagesNum"
FROM "Book"
WHERE "PagesNum" > 2 * (SELECT AVG("PagesNum") FROM "Book");
