SELECT DISTINCT "ISBN"
FROM "BookCat"
WHERE "CategoryName" = 'Горы'
  AND "ISBN" NOT IN (
    SELECT "ISBN"
    FROM "BookCat"
    WHERE "CategoryName" = 'Путешествия'
  );