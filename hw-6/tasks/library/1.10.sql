WITH RECURSIVE subcategories AS (
    SELECT "CategoryName"
    FROM "Category"
    WHERE "CategoryName" = 'Спорт'
    UNION
    SELECT c."CategoryName"
    FROM "Category" c
    JOIN subcategories s ON c."ParentCat" = s."CategoryName"
)
SELECT "CategoryName" FROM subcategories;
