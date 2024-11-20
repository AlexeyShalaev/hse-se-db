# Задание 1. B-tree индексы в PostgreSQL

1. Запустите БД через docker compose в ./src/docker-compose.yml:

2. Выполните запрос для поиска книги с названием 'Oracle Core' и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE title = 'Oracle Core';
   ```
   
   *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Seq Scan on t_books  (cost=0.00..3099.00 rows=1 width=33) (actual time=8.386..8.387 rows=1 loops=1) |
    |   Filter: ((title)::text = 'Oracle Core'::text) |
    |   Rows Removed by Filter: 149999 |
    | Planning Time: 0.056 ms |
    | Execution Time: 8.403 ms |
   
   *Объясните результат:*
    - Запрос использует Seq Scan, перебирая все строки таблицы, так как индекс на столбце title отсутствует.
    - Было обработано 150,000 строк, из которых только одна соответствовала условию.
    - Последовательное сканирование заняло 8.4 мс, что относительно долго для выборки одной строки в большой таблице.
    - Это происходит из-за большого объема данных и необходимости проверять каждую строку вручную.
    - Создание индекса на title значительно ускорит выполнение запроса.

3. Создайте B-tree индексы:
   ```sql
   CREATE INDEX t_books_title_idx ON t_books(title);
   CREATE INDEX t_books_active_idx ON t_books(is_active);
   ```
   
   *Результат:*
    ```sql
    postgres.public> CREATE INDEX t_books_title_idx ON t_books(title)
    [2024-11-20 12:16:57] completed in 361 ms
    postgres.public> CREATE INDEX t_books_active_idx ON t_books(is_active)
    [2024-11-20 12:16:57] completed in 55 ms
    ```

4. Проверьте информацию о созданных индексах:
   ```sql
   SELECT schemaname, tablename, indexname, indexdef
   FROM pg_catalog.pg_indexes
   WHERE tablename = 't_books';
   ```
   
   *Результат:*
    | schemaname | tablename | indexname | indexdef |
    | :--- | :--- | :--- | :--- |
    | public | t_books | t_books_id_pk | CREATE UNIQUE INDEX t_books_id_pk ON public.t_books USING btree (book_id) |
    | public | t_books | t_books_title_idx | CREATE INDEX t_books_title_idx ON public.t_books USING btree (title) |
    | public | t_books | t_books_active_idx | CREATE INDEX t_books_active_idx ON public.t_books USING btree (is_active) |

   *Объясните результат:*
    - Запрос возвращает список индексов таблицы t_books, включая их схему, название и структуру.
    - Индекс t_books_id_pk — это уникальный индекс на book_id, автоматически созданный для первичного ключа.
    - Индекс t_books_title_idx создан для ускорения поиска по столбцу title.
    - Индекс t_books_active_idx создан для оптимизации запросов, использующих условие на is_active.
    - Все индексы используют структуру B-tree, которая подходит для равенств, диапазонов и сортировок.

5. Обновите статистику таблицы:
   ```sql
   ANALYZE t_books;
   ```
   
   *Результат:*
   ```sql
    postgres.public> ANALYZE t_books
    [2024-11-20 12:19:01] completed in 175 ms
   ```

6. Выполните запрос для поиска книги 'Oracle Core' и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE title = 'Oracle Core';
   ```
   
   *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_title_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.037..0.038 rows=1 loops=1) |
    |   Index Cond: ((title)::text = 'Oracle Core'::text) |
    | Planning Time: 0.220 ms |
    | Execution Time: 0.049 ms |
   
   *Объясните результат:*
    - Запрос использует Index Scan, благодаря созданному индексу t_books_title_idx на столбце title.
    - Индекс позволил PostgreSQL напрямую найти нужное значение, избегая полного перебора строк таблицы.
    - Стоимость выполнения запроса уменьшилась до cost=0.42..8.44, что значительно быстрее, чем последовательное сканирование.
    - Время выполнения запроса существенно сократилось до 0.049 мс, так как индекс ускоряет выборку.
    - Использование индекса подтверждает, что он эффективно оптимизировал поиск записи по title.

7. Выполните запрос для поиска книги по book_id и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE book_id = 18;
   ```
   
   *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_id_pk on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.938..0.940 rows=1 loops=1) |
    |   Index Cond: (book_id = 18) |
    | Planning Time: 0.084 ms |
    | Execution Time: 0.956 ms |

   *Объясните результат:*
    - Запрос использует Index Scan, благодаря уникальному индексу t_books_id_pk на столбце book_id, созданному автоматически для первичного ключа.
    - Индекс позволил PostgreSQL быстро найти строку с book_id = 18, минуя полный перебор таблицы.
    - План выполнения показывает низкую стоимость cost=0.42..8.44, так как индексная структура позволяет сразу обратиться к нужной записи.
    - Время выполнения запроса составило 0.956 мс, что эффективно для таблицы с большим количеством записей.
    - Использование индекса на первичный ключ подтверждает его оптимальность для точного поиска по уникальным значениям.

8. Выполните запрос для поиска активных книг и получите план выполнения:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE is_active = true;
   ```
   
   *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Seq Scan on t_books  (cost=0.00..2724.00 rows=75045 width=33) (actual time=0.008..9.913 rows=75131 loops=1) |
    |   Filter: is_active |
    |   Rows Removed by Filter: 74869 |
    | Planning Time: 0.074 ms |
    | Execution Time: 11.845 ms |

   *Объясните результат:*
    - Запрос использует Seq Scan, несмотря на наличие индекса t_books_active_idx, потому что большое количество строк (75131) соответствует условию is_active = true.
    - PostgreSQL решил, что последовательное сканирование эффективнее, так как при высоком проценте совпадений индексное сканирование может быть медленнее.
    - Rows Removed by Filter: 74869 показывает, что почти половина строк была отфильтрована, но оставшиеся строки все же значительны по объему.
    - Общее время выполнения запроса составило 11.845 мс, что выше, чем при использовании индекса для выборки небольшого количества записей.
    - Индексы эффективнее для выборки редких значений, а для частых лучше подходят другие подходы, например, таблица разделения по активным и неактивным записям.

9. Посчитайте количество строк и уникальных значений:
   ```sql
   SELECT 
       COUNT(*) as total_rows,
       COUNT(DISTINCT title) as unique_titles,
       COUNT(DISTINCT category) as unique_categories,
       COUNT(DISTINCT author) as unique_authors
   FROM t_books;
   ```
   
   *Результат:*
    | total_rows | unique_titles | unique_categories | unique_authors |
    | :--- | :--- | :--- | :--- |
    | 150000 | 150000 | 6 | 1003 |

10. Удалите созданные индексы:
    ```sql
    DROP INDEX t_books_title_idx;
    DROP INDEX t_books_active_idx;
    ```
    
    *Результат:*
    ```sql
    postgres.public> DROP INDEX t_books_title_idx
    [2024-11-20 12:23:33] completed in 9 ms
    postgres.public> DROP INDEX t_books_active_idx
    [2024-11-20 12:23:33] completed in 4 ms
    ```

11. Основываясь на предыдущих результатах, создайте индексы для оптимизации следующих запросов: \
    a. `WHERE title = $1 AND category = $2` \
    b. `WHERE title = $1` \
    c. `WHERE category = $1 AND author = $2` \
    d. `WHERE author = $1 AND book_id = $2`
    
    *Созданные индексы:*
    ```sql
    -- a. Оптимизация WHERE title = $1 AND category = $2
    CREATE INDEX t_books_title_category_idx ON t_books(title, category);

    -- b. Оптимизация WHERE title = $1
    CREATE INDEX t_books_title_idx ON t_books(title);

    -- c. Оптимизация WHERE category = $1 AND author = $2
    CREATE INDEX t_books_category_author_idx ON t_books(category, author);

    -- d. Оптимизация WHERE author = $1 AND book_id = $2
    CREATE INDEX t_books_author_book_id_idx ON t_books(author, book_id);
    ```
    
    *Объясните ваше решение:*
    - **Запрос a (WHERE title = $1 AND category = $2):** \
    Комбинированный индекс на (title, category) позволяет эффективно отфильтровать записи по обоим условиям одновременно, сокращая необходимость дополнительной фильтрации.

    - **Запрос b (WHERE title = $1):** \
    Индекс на title уже был создан ранее. Он оптимизирует запрос, так как позволяет сразу найти записи по значению title.

    - **Запрос c (WHERE category = $1 AND author = $2):** \
    Комбинированный индекс на (category, author) упорядочивает данные, ускоряя фильтрацию по обоим столбцам.

    - **Запрос d (WHERE author = $1 AND book_id = $2):** \
    Индекс на (author, book_id) позволяет PostgreSQL использовать упорядоченные данные для быстрого поиска по первому и второму столбцу в одном запросе.

    Все индексы построены с учетом порядка столбцов, где первый столбец используется в качестве основного фильтра. Комбинированные индексы особенно эффективны для запросов с несколькими условиями.

12. Протестируйте созданные индексы.
    
    *Результаты тестов:*

    a. `WHERE title = $1 AND category = $2`
    
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title = 'Oracle Core' AND category = 'Database';
    ```

    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_category_author_idx on t_books  (cost=0.29..8.23 rows=1 width=33) (actual time=0.021..0.021 rows=0 loops=1) |
    |   Index Cond: ((category)::text = 'Database'::text) |
    |   Filter: ((title)::text = 'Oracle Core'::text) |
    | Planning Time: 0.309 ms |
    | Execution Time: 0.035 ms |

    b. `WHERE title = $1`

    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title = 'Oracle Core';
    ```

    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_title_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.090..0.091 rows=1 loops=1) |
    |   Index Cond: ((title)::text = 'Oracle Core'::text) |
    | Planning Time: 0.079 ms |
    | Execution Time: 0.104 ms |

    c. `WHERE category = $1 AND author = $2`

    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE category = 'Databases' AND author = 'Tom Lane';
    ```

    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_category_author_idx on t_books  (cost=0.29..8.31 rows=1 width=33) (actual time=0.023..0.023 rows=1 loops=1) |
    |   Index Cond: (((category)::text = 'Databases'::text) AND ((author)::text = 'Tom Lane'::text)) |
    | Planning Time: 0.078 ms |
    | Execution Time: 0.037 ms |

    d. `WHERE author = $1 AND book_id = $2`

    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE author = 'Tom Lane' AND book_id = 2025;
    ```

    | QUERY PLAN |
    | :--- |
    | Index Scan using t_books_author_book_id_idx on t_books  (cost=0.42..8.44 rows=1 width=33) (actual time=0.025..0.026 rows=1 loops=1) |
    |   Index Cond: (((author)::text = 'Tom Lane'::text) AND (book_id = 2025)) |
    | Planning Time: 0.083 ms |
    | Execution Time: 0.042 ms |
        
    *Объясните результаты:*
    - Индексы значительно ускорили выполнение запросов, особенно когда порядок полей в индексе совпадает с условиями запроса.
    - Запрос a продемонстрировал, что порядок полей в индексе критичен для оптимальной производительности.
    - Индексы b, c, и d показали наилучшие результаты, так как их структура полностью соответствует запросам.
    - Для дальнейшей оптимизации запроса a стоит создать индекс (title, category).
    
13. Выполните регистронезависимый поиск по началу названия:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title ILIKE 'Relational%';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Seq Scan on t_books  (cost=0.00..3099.00 rows=15 width=33) (actual time=68.579..68.580 rows=0 loops=1) |
    |   Filter: ((title)::text \~\~\* 'Relational%'::text) |
    |   Rows Removed by Filter: 150000 |
    | Planning Time: 0.111 ms |
    | Execution Time: 68.595 ms |

    
    *Объясните результат:*
    - **Тип сканирования:** \
    Используется Seq Scan (последовательное сканирование), так как условие ILIKE 'Relational%' не может быть эффективно обработано с использованием существующих индексов.
    - **Фильтрация:** \
    Для каждой строки выполняется проверка на соответствие шаблону Relational%, что требует полного перебора всех строк таблицы (150,000 строк).
    -  **Время выполнения:** \
    В результате последовательного сканирования и проверки каждой строки общее время выполнения составило 68.595 мс, что значительно больше, чем при использовании индекса.
    - **Причина отсутствия индекса:** \
    PostgreSQL не может использовать обычный B-tree индекс для условий ILIKE, так как они чувствительны к регистронезависимому сравнению.

14. Создайте функциональный индекс:
    ```sql
    CREATE INDEX t_books_up_title_idx ON t_books(UPPER(title));
    ```
    
    *Результат:*
    ```sql
    postgres.public> CREATE INDEX t_books_up_title_idx ON t_books(UPPER(title))
    [2024-11-20 12:47:18] completed in 343 ms
    ```

15. Выполните запрос из шага 13 с использованием UPPER:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE UPPER(title) LIKE 'RELATIONAL%';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Seq Scan on t_books  (cost=0.00..3474.00 rows=750 width=33) (actual time=39.883..39.884 rows=0 loops=1) |
    |   Filter: (upper((title)::text) \~\~ 'RELATIONAL%'::text) |
    |   Rows Removed by Filter: 150000 |
    | Planning Time: 0.289 ms |
    | Execution Time: 39.899 ms |

    *Объясните результат:*
    Время уменьшилось в ~1.7 раза.

16. Выполните поиск подстроки:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title ILIKE '%Core%';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Seq Scan on t_books  (cost=0.00..3099.00 rows=15 width=33) (actual time=63.776..63.778 rows=1 loops=1) |
    |   Filter: ((title)::text \~\~\* '%Core%'::text) |
    |   Rows Removed by Filter: 149999 |
    | Planning Time: 0.109 ms |
    | Execution Time: 63.796 ms |

    *Объясните результат:*
    [Ваше объяснение]

17. Попробуйте удалить все индексы:
    ```sql
    DO $$ 
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN (SELECT indexname FROM pg_indexes 
                  WHERE tablename = 't_books' 
                  AND indexname != 't_books_id_pk')
        LOOP
            EXECUTE 'DROP INDEX ' || r.indexname;
        END LOOP;
    END $$;
    ```
    
    *Результат:*
    Остался один индекс: `t_books_id_pk`.
    
    *Объясните результат:*
    Удалили все индексы, кроме PK.

18. Создайте индекс для оптимизации суффиксного поиска:
    ```sql
    -- Вариант 1: с reverse()
    CREATE INDEX t_books_rev_title_idx ON t_books(reverse(title));

    -- Вариант 2: с триграммами
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
    CREATE INDEX t_books_trgm_idx ON t_books USING gin (title gin_trgm_ops);
    ```

    *Результаты тестов:*
   
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE reverse(title) LIKE reverse('%Core');
    ```

    | QUERY PLAN |
    | :--- |
    | Seq Scan on t_books  (cost=0.00..3474.00 rows=750 width=33) (actual time=21.002..21.003 rows=1 loops=1) |
    |   Filter: (reverse((title)::text) \~\~ 'eroC%'::text) |
    |   Rows Removed by Filter: 149999 |
    | Planning Time: 0.191 ms |
    | Execution Time: 21.013 ms |    


    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title ILIKE '%Core%';
    ```

    | QUERY PLAN |
    | :--- |
    | Bitmap Heap Scan on t_books  (cost=21.57..76.77 rows=15 width=33) (actual time=0.015..0.016 rows=1 loops=1) |
    |   Recheck Cond: ((title)::text \~\~\* '%Core%'::text) |
    |   Heap Blocks: exact=1 |
    |   -&gt;  Bitmap Index Scan on t_books_trgm_idx  (cost=0.00..21.56 rows=15 width=0) (actual time=0.009..0.009 rows=1 loops=1) |
    |         Index Cond: ((title)::text \~\~\* '%Core%'::text) |
    | Planning Time: 0.193 ms |
    | Execution Time: 0.032 ms |
    
    *Объясните результаты:*
    - **Индекс reverse():**\
    Подходит для строгого суффиксного поиска (например, reverse(title) LIKE 'Core%'), но неудобен для произвольного поиска, так как требует вызова функции reverse().

    - **Триграммный индекс (pg_trgm):** \
    Универсальное решение для поиска подстрок в любом месте строки. Поддерживает запросы с % в начале, середине или конце шаблона.
    Рекомендуется использовать триграммный индекс (pg_trgm) для произвольного поиска, так как он значительно уменьшает время выполнения запросов.

19. Выполните поиск по точному совпадению:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title = 'Oracle Core';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Bitmap Heap Scan on t_books  (cost=116.57..120.58 rows=1 width=33) (actual time=0.036..0.037 rows=1 loops=1) |
    |   Recheck Cond: ((title)::text = 'Oracle Core'::text) |
    |   Heap Blocks: exact=1 |
    |   -&gt;  Bitmap Index Scan on t_books_trgm_idx  (cost=0.00..116.57 rows=1 width=0) (actual time=0.025..0.025 rows=1 loops=1) |
    |         Index Cond: ((title)::text = 'Oracle Core'::text) |
    | Planning Time: 0.124 ms |
    | Execution Time: 0.053 ms |

    *Объясните результат:*
    - **Тип сканирования:** \
    Используется Bitmap Heap Scan, что означает, что PostgreSQL сначала выполняет поиск в триграммном индексе t_books_trgm_idx, а затем считывает соответствующие блоки из таблицы.

    - **Условие:** \
    Запрос с точным совпадением title = 'Oracle Core' полностью покрывается триграммным индексом. \
    Bitmap Index Scan позволяет PostgreSQL быстро найти позицию строк, соответствующих условию.

    - **Эффективность:** \
    Index Cond указывает, что поиск был оптимизирован за счет использования индекса. \
    Общее время выполнения составило 0.053 мс, включая обработку индекса и извлечение строки.

20. Выполните поиск по началу названия:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books WHERE title ILIKE 'Relational%';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Bitmap Heap Scan on t_books  (cost=95.15..150.36 rows=15 width=33) (actual time=0.028..0.028 rows=0 loops=1) |
    |   Recheck Cond: ((title)::text \~\~\* 'Relational%'::text) |
    |   Rows Removed by Index Recheck: 1 |
    |   Heap Blocks: exact=1 |
    |   -&gt;  Bitmap Index Scan on t_books_trgm_idx  (cost=0.00..95.15 rows=15 width=0) (actual time=0.018..0.018 rows=1 loops=1) |
    |         Index Cond: ((title)::text \~\~\* 'Relational%'::text) |
    | Planning Time: 0.128 ms |
    | Execution Time: 0.044 ms |
    
    *Объясните результат:*
    - **Тип сканирования:** \
    Используется Bitmap Heap Scan, что означает, что PostgreSQL нашел соответствующие строки с помощью триграммного индекса t_books_trgm_idx и затем извлек данные из таблицы.

    - **Условие:** \
    Условие ILIKE 'Relational%' обработано с использованием триграммного индекса, который эффективно поддерживает поиск строк с любым префиксом.

    - **Эффективность:** \
    Bitmap Index Scan на триграммном индексе позволил быстро найти потенциальные совпадения. \
    Recheck Cond выполняет дополнительную проверку на соответствие, так как триграммный индекс допускает ложные срабатывания. \
    Время выполнения составило всего 0.044 мс, что показывает высокую эффективность триграммного индекса для префиксного поиска.
    
    - **Результат:** \
    Несмотря на использование ILIKE, запрос полностью оптимизирован за счет триграммного индекса.

21. Создайте свой пример индекса с обратной сортировкой:
    ```sql
    CREATE INDEX t_books_desc_idx ON t_books(title DESC);
    ```
    
    *Тестовый запрос:*
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books ORDER BY title DESC LIMIT 10;
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Limit  (cost=0.42..1.02 rows=10 width=33) (actual time=0.174..0.178 rows=10 loops=1) |
    |   -&gt;  Index Scan using t_books_desc_idx on t_books  (cost=0.42..9062.40 rows=150000 width=33) (actual time=0.174..0.177 rows=10 loops=1) |
    | Planning Time: 0.267 ms |
    | Execution Time: 0.187 ms |

    *Объясните результат:* \
    Индексы с обратной сортировкой эффективны для запросов с ORDER BY ... DESC, особенно в сочетании с ограничением (LIMIT). Это особенно полезно для обработки больших таблиц, когда нужно быстро получить несколько записей, отсортированных в обратном порядке.