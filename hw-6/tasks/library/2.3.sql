-- Изменение даты возврата для всех книг категории "Базы данных", начиная с 01.01.2016, чтобы увеличить срок заимствования на 30 дней.
UPDATE "Borrowing"
SET "ReturnDate" = "ReturnDate" + INTERVAL '30 days'
WHERE "ISBN" IN (
    SELECT "ISBN"
    FROM "BookCat"
    WHERE "CategoryName" = 'Базы данных'
)
AND "ReturnDate" >= '2016-01-01';
