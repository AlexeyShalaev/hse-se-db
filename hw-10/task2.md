# Задание 2: Специальные случаи использования индексов

# Партиционирование и специальные случаи использования индексов

1. Удалите прошлый инстанс PostgreSQL - `docker-compose down` в папке `src` и запустите новый: `docker-compose up -d`.

2. Создайте партиционированную таблицу и заполните её данными:

    ```sql
    -- Создание партиционированной таблицы
    CREATE TABLE t_books_part (
        book_id     INTEGER      NOT NULL,
        title       VARCHAR(100) NOT NULL,
        category    VARCHAR(30),
        author      VARCHAR(100) NOT NULL,
        is_active   BOOLEAN      NOT NULL
    ) PARTITION BY RANGE (book_id);

    -- Создание партиций
    CREATE TABLE t_books_part_1 PARTITION OF t_books_part
        FOR VALUES FROM (MINVALUE) TO (50000);

    CREATE TABLE t_books_part_2 PARTITION OF t_books_part
        FOR VALUES FROM (50000) TO (100000);

    CREATE TABLE t_books_part_3 PARTITION OF t_books_part
        FOR VALUES FROM (100000) TO (MAXVALUE);

    -- Копирование данных из t_books
    INSERT INTO t_books_part 
    SELECT * FROM t_books;
    ```

3. Обновите статистику таблиц:
   ```sql
   ANALYZE t_books;
   ANALYZE t_books_part;
   ```
   
   *Результат:*
    ```sql
    postgres.public> ANALYZE t_books
    [2024-11-20 13:17:30] completed in 180 ms
    postgres.public> ANALYZE t_books_part
    [2024-11-20 13:17:30] completed in 522 ms
    ```

4. Выполните запрос для поиска книги с id = 18:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books_part WHERE book_id = 18;
   ```
   
   *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Seq Scan on t_books_part_1 t_books_part  (cost=0.00..1032.99 rows=1 width=32) (actual time=0.008..2.367 rows=1 loops=1) |
    |   Filter: (book_id = 18) |
    |   Rows Removed by Filter: 49998 |
    | Planning Time: 0.250 ms |
    | Execution Time: 2.380 ms |
   
   *Объясните результат:*
   Из-за партицирования время исполнения запроса увеличилось в 2 раза.

5. Выполните поиск по названию книги:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books_part 
   WHERE title = 'Expert PostgreSQL Architecture';
   ```
   
   *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Append  (cost=0.00..3100.01 rows=3 width=33) (actual time=2.812..8.918 rows=1 loops=1) |
    |   -&gt;  Seq Scan on t_books_part_1  (cost=0.00..1032.99 rows=1 width=32) (actual time=2.811..2.812 rows=1 loops=1) |
    |         Filter: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    |         Rows Removed by Filter: 49998 |
    |   -&gt;  Seq Scan on t_books_part_2  (cost=0.00..1033.00 rows=1 width=33) (actual time=2.716..2.716 rows=0 loops=1) |
    |         Filter: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    |         Rows Removed by Filter: 50000 |
    |   -&gt;  Seq Scan on t_books_part_3  (cost=0.00..1034.01 rows=1 width=34) (actual time=3.384..3.384 rows=0 loops=1) |
    |         Filter: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    |         Rows Removed by Filter: 50001 |
    | Planning Time: 0.170 ms |
    | Execution Time: 8.936 ms |

   *Объясните результат:*
   Поиск по партициям занимает чуть больше времени.

6. Создайте партиционированный индекс:
   ```sql
   CREATE INDEX ON t_books_part(title);
   ```
   
   *Результат:*
   Создан индекс.

7. Повторите запрос из шага 5:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books_part 
   WHERE title = 'Expert PostgreSQL Architecture';
   ```
   
   *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Append  (cost=0.29..24.94 rows=3 width=33) (actual time=0.033..0.081 rows=1 loops=1) |
    |   -&gt;  Index Scan using t_books_part_1_title_idx on t_books_part_1  (cost=0.29..8.31 rows=1 width=32) (actual time=0.032..0.033 rows=1 loops=1) |
    |         Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    |   -&gt;  Index Scan using t_books_part_2_title_idx on t_books_part_2  (cost=0.29..8.31 rows=1 width=33) (actual time=0.030..0.030 rows=0 loops=1) |
    |         Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    |   -&gt;  Index Scan using t_books_part_3_title_idx on t_books_part_3  (cost=0.29..8.31 rows=1 width=34) (actual time=0.016..0.016 rows=0 loops=1) |
    |         Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    | Planning Time: 0.582 ms |
    | Execution Time: 0.106 ms |
   
   *Объясните результат:*
   Время выполнения значительно сократилось.

8. Удалите созданный индекс:
   ```sql
   DROP INDEX t_books_part_title_idx;
   ```
   
   *Результат:*
   Индекс удалился.

9. Создайте индекс для каждой партиции:
   ```sql
   CREATE INDEX ON t_books_part_1(title);
   CREATE INDEX ON t_books_part_2(title);
   CREATE INDEX ON t_books_part_3(title);
   ```
   
   *Результат:*
   Создались индексы.

10. Повторите запрос из шага 5:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books_part 
    WHERE title = 'Expert PostgreSQL Architecture';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Append  (cost=0.29..24.94 rows=3 width=33) (actual time=0.019..0.048 rows=1 loops=1) |
    |   -&gt;  Index Scan using t_books_part_1_title_idx on t_books_part_1  (cost=0.29..8.31 rows=1 width=32) (actual time=0.019..0.019 rows=1 loops=1) |
    |         Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    |   -&gt;  Index Scan using t_books_part_2_title_idx on t_books_part_2  (cost=0.29..8.31 rows=1 width=33) (actual time=0.016..0.016 rows=0 loops=1) |
    |         Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    |   -&gt;  Index Scan using t_books_part_3_title_idx on t_books_part_3  (cost=0.29..8.31 rows=1 width=34) (actual time=0.011..0.011 rows=0 loops=1) |
    |         Index Cond: ((title)::text = 'Expert PostgreSQL Architecture'::text) |
    | Planning Time: 0.308 ms |
    | Execution Time: 0.064 ms |

    *Объясните результат:*
    Поиск стал еще быстрее.

11. Удалите созданные индексы:
    ```sql
    DROP INDEX t_books_part_1_title_idx;
    DROP INDEX t_books_part_2_title_idx;
    DROP INDEX t_books_part_3_title_idx;
    ```
    
    *Результат:*
    Индексы удалились.

12. Создайте обычный индекс по book_id:
    ```sql
    CREATE INDEX t_books_part_idx ON t_books_part(book_id);
    ```
    
    *Результат:*
    Индекс создался.

13. Выполните поиск по book_id:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books_part WHERE book_id = 11011;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_part_1_book_id_idx on t_books_part_1 t_books_part  (cost=0.29..8.31 rows=1 width=32) (actual time=0.011..0.012 rows=1 loops=1) |
    |   Index Cond: (book_id = 11011) |
    | Planning Time: 0.237 ms |
    | Execution Time: 0.024 ms |

    
    *Объясните результат:*
    Поиск ускорился.

14. Создайте индекс по полю is_active:
    ```sql
    CREATE INDEX t_books_active_idx ON t_books(is_active);
    ```
    
    *Результат:*
    Индекс создался.

15. Выполните поиск активных книг с отключенным последовательным сканированием:
    ```sql
    SET enable_seqscan = off;
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE is_active = true;
    SET enable_seqscan = on;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Bitmap Heap Scan on t_books  (cost=844.41..2823.11 rows=75370 width=33) (actual time=1.811..8.115 rows=75152 loops=1) |
    |   Recheck Cond: is_active |
    |   Heap Blocks: exact=1225 |
    |   -&gt;  Bitmap Index Scan on t_books_active_idx  (cost=0.00..825.57 rows=75370 width=0) (actual time=1.696..1.697 rows=75152 loops=1) |
    |         Index Cond: (is_active = true) |
    | Planning Time: 0.173 ms |
    | Execution Time: 10.034 ms |

    *Объясните результат:* \
    Индекс на is_active позволяет значительно ускорить запросы с частыми условиями, избегая полного сканирования таблицы. Использование Bitmap Index Scan эффективно обрабатывает большие объемы данных, минимизируя затраты.

16. Создайте составной индекс:
    ```sql
    CREATE INDEX t_books_author_title_index ON t_books(author, title);
    ```
    
    *Результат:*
    Индекс создался.

17. Найдите максимальное название для каждого автора:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, MAX(title) 
    FROM t_books 
    GROUP BY author;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | HashAggregate  (cost=3475.00..3485.01 rows=1001 width=42) (actual time=49.888..49.990 rows=1003 loops=1) |
    |   Group Key: author |
    |   Batches: 1  Memory Usage: 193kB |
    |   -&gt;  Seq Scan on t_books  (cost=0.00..2725.00 rows=150000 width=21) (actual time=0.005..6.750 rows=150000 loops=1) |
    | Planning Time: 0.217 ms |
    | Execution Time: 50.043 ms |
    
    *Объясните результат:* \
    Запрос эффективно использует HashAggregate, но последовательное сканирование таблицы замедляет выполнение. Составной индекс на (author, title DESC) ускорит поиск максимального значения и группировку.

18. Выберите первых 10 авторов:
    ```sql
    EXPLAIN ANALYZE
    SELECT DISTINCT author 
    FROM t_books 
    ORDER BY author 
    LIMIT 10;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Limit  (cost=0.42..56.61 rows=10 width=10) (actual time=0.108..0.335 rows=10 loops=1) |
    |   -&gt;  Result  (cost=0.42..5625.42 rows=1001 width=10) (actual time=0.107..0.333 rows=10 loops=1) |
    |         -&gt;  Unique  (cost=0.42..5625.42 rows=1001 width=10) (actual time=0.107..0.332 rows=10 loops=1) |
    |               -&gt;  Index Only Scan using t_books_author_title_index on t_books  (cost=0.42..5250.42 rows=150000 width=10) (actual time=0.105..0.258 rows=1345 loops=1) |
    |                     Heap Fetches: 4 |
    | Planning Time: 0.080 ms |
    | Execution Time: 0.349 ms |

    *Объясните результат:* \
    Запрос эффективно использует **Index Only Scan** на индексе `t_books_author_title_index`, извлекая уникальные значения авторов без необходимости полного сканирования таблицы. Лимитирование до 10 строк ускоряет выполнение, обеспечивая время всего **0.349 мс**.

19. Выполните поиск и сортировку:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, title 
    FROM t_books 
    WHERE author LIKE 'T%'
    ORDER BY author, title;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Sort  (cost=3100.29..3100.33 rows=15 width=21) (actual time=11.594..11.595 rows=1 loops=1) |
    |   Sort Key: author, title |
    |   Sort Method: quicksort  Memory: 25kB |
    |   -&gt;  Seq Scan on t_books  (cost=0.00..3100.00 rows=15 width=21) (actual time=11.585..11.586 rows=1 loops=1) |
    |         Filter: ((author)::text \~\~ 'T%'::text) |
    |         Rows Removed by Filter: 149999 |
    | Planning Time: 0.121 ms |
    | Execution Time: 11.610 ms |

    *Объясните результат:* \
    Запрос выполняет **Seq Scan** для фильтрации авторов, соответствующих шаблону `LIKE 'T%'`, что замедляет выполнение. Сортировка выполняется с использованием **quicksort**, но создание индекса на `(author, title)` может существенно ускорить фильтрацию и упорядочивание.

20. Добавьте новую книгу:
    ```sql
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150001, 'Cookbook', 'Mr. Hide', NULL, true);
    COMMIT;
    ```
    
    *Результат:*
    ```sql
    postgres.public> INSERT INTO t_books (book_id, title, author, category, is_active)
                    VALUES (150001, 'Cookbook', 'Mr. Hide', NULL, true)
    [2024-11-20 13:37:28] 1 row affected in 6 ms
    postgres.public> COMMIT
    [2024-11-20 13:37:28] [25P01] there is no transaction in progress
    [2024-11-20 13:37:28] completed in 7 ms
    ```

21. Создайте индекс по категории:
    ```sql
    CREATE INDEX t_books_cat_idx ON t_books(category);
    ```
    
    *Результат:*
    Индекс создался.

22. Найдите книги без категории:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, title 
    FROM t_books 
    WHERE category IS NULL;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_cat_idx on t_books  (cost=0.29..8.13 rows=1 width=21) (actual time=0.023..0.024 rows=1 loops=1) |
    |   Index Cond: (category IS NULL) |
    | Planning Time: 0.262 ms |
    | Execution Time: 0.035 ms |
    
    *Объясните результат:* \
    Запрос эффективно использует **Index Scan** на индексе `t_books_cat_idx`, чтобы быстро найти строки, где `category IS NULL`. Это минимизирует время выполнения до **0.035 мс**, избегая полного сканирования таблицы.

23. Создайте частичные индексы:
    ```sql
    DROP INDEX t_books_cat_idx;
    CREATE INDEX t_books_cat_null_idx ON t_books(category) WHERE category IS NULL;
    ```
    
    *Результат:*
    Индексы созданы.

24. Повторите запрос из шага 22:
    ```sql
    EXPLAIN ANALYZE
    SELECT author, title 
    FROM t_books 
    WHERE category IS NULL;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_cat_null_idx on t_books  (cost=0.12..7.96 rows=1 width=21) (actual time=0.008..0.009 rows=1 loops=1) |
    | Planning Time: 0.198 ms |
    | Execution Time: 0.019 ms |
    
    *Объясните результат:* \
    Запрос использует частичный индекс `t_books_cat_null_idx`, созданный специально для строк с `category IS NULL`. Это уменьшило затраты и время выполнения до **0.019 мс**, сделав запрос более быстрым и эффективным.

25. Создайте частичный уникальный индекс:
    ```sql
    CREATE UNIQUE INDEX t_books_selective_unique_idx 
    ON t_books(title) 
    WHERE category = 'Science';
    
    -- Протестируйте его
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150002, 'Unique Science Book', 'Author 1', 'Science', true);
    
    -- Попробуйте вставить дубликат
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150003, 'Unique Science Book', 'Author 2', 'Science', true);
    
    -- Но можно вставить такое же название для другой категории
    INSERT INTO t_books (book_id, title, author, category, is_active)
    VALUES (150004, 'Unique Science Book', 'Author 3', 'History', true);
    ```
    
    *Результат:*
    ```sql
    postgres.public> CREATE UNIQUE INDEX t_books_selective_unique_idx
                     ON t_books(title)
                     WHERE category = 'Science'
    [2024-11-20 13:40:25] completed in 70 ms
    postgres.public> INSERT INTO t_books (book_id, title, author, category, is_active)
                        VALUES (150002, 'Unique Science Book', 'Author 1', 'Science', true)
    [2024-11-20 13:40:25] 1 row affected in 4 ms
    postgres.public> INSERT INTO t_books (book_id, title, author, category, is_active)
                        VALUES (150003, 'Unique Science Book', 'Author 2', 'Science', true)
    [2024-11-20 13:40:25] [23505] ERROR: duplicate key value violates unique constraint "t_books_selective_unique_idx"
    [2024-11-20 13:40:25] Подробности: Key (title)=(Unique Science Book) already exists.
    postgres.public> INSERT INTO t_books (book_id, title, author, category, is_active)
                     VALUES (150004, 'Unique Science Book', 'Author 3', 'History', true)
    [2024-11-20 13:41:14] 1 row affected in 4 ms
    ```
    
    *Объясните результат:*

    1. **Частичный уникальный индекс:**  
    Индекс `t_books_selective_unique_idx` обеспечивает уникальность значений `title`, но только для строк, где `category = 'Science'`.  

    2. **Первая вставка:**  
    Строка с `title = 'Unique Science Book'` и `category = 'Science'` была успешно добавлена, так как это первая запись, соответствующая условию индекса.  

    3. **Попытка дублирования:**  
    Попытка вставить другую строку с таким же `title` и `category = 'Science'` завершилась ошибкой, так как частичный индекс запретил дублирование.  

    4. **Иная категория:**  
    Вставка строки с тем же `title`, но с другой категорией (`category = 'History'`), была успешной, так как частичный индекс не распространяется на строки, не соответствующие условию `category = 'Science'`.  

    5. **Вывод:**  
    Частичный уникальный индекс позволяет гибко ограничивать уникальность только для определенного подмножества данных, обеспечивая как целостность, так и гибкость.