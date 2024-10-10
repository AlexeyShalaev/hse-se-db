SELECT "Title", "PagesNum"
FROM "Book"
WHERE "PagesNum" = (SELECT MAX("PagesNum") FROM "Book");
