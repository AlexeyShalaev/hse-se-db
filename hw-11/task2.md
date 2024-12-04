## Задание 2

1. Удалите старую базу данных, если есть:
    ```shell
    docker compose down
    ```

2. Поднимите базу данных из src/docker-compose.yml:
    ```shell
    docker compose down && docker compose up -d
    ```

3. Обновите статистику:
    ```sql
    ANALYZE t_books;
    ```

4. Создайте полнотекстовый индекс:
    ```sql
    CREATE INDEX t_books_fts_idx ON t_books 
    USING GIN (to_tsvector('english', title));
    ```

5. Найдите книги, содержащие слово 'expert':
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books 
    WHERE to_tsvector('english', title) @@ to_tsquery('english', 'expert');
    ```
    
    *План выполнения:*
     | QUERY PLAN |
     | :--- |
     | Bitmap Heap Scan on t\_books  \(cost=21.03..1336.08 rows=750 width=33\) \(actual time=0.013..0.014 rows=1 loops=1\) |
     |   Recheck Cond: \(to\_tsvector\('english'::regconfig, \(title\)::text\) @@ '''expert'''::tsquery\) |
     |   Heap Blocks: exact=1 |
     |   -&gt;  Bitmap Index Scan on t\_books\_fts\_idx  \(cost=0.00..20.84 rows=750 width=0\) \(actual time=0.009..0.009 rows=1 loops=1\) |
     |         Index Cond: \(to\_tsvector\('english'::regconfig, \(title\)::text\) @@ '''expert'''::tsquery\) |
     | Planning Time: 1.581 ms |
     | Execution Time: 0.032 ms |

    *Объясните результат:* \
    Создание полнотекстового индекса с использованием GIN позволяет PostgreSQL эффективно обрабатывать запросы с условиями на текстовые совпадения. Запрос использует **Bitmap Index Scan** по индексу `t_books_fts_idx`, чтобы найти релевантные строки, содержащие слово `'expert'`. Затем выполняется **Bitmap Heap Scan** для проверки соответствия условий. Благодаря индексации запрос выполняется быстро (0.032 мс), поскольку проверка текста производится непосредственно через индекс, а не через последовательное сканирование всей таблицы.

6. Удалите индекс:
    ```sql
    DROP INDEX t_books_fts_idx;
    ```

7. Создайте таблицу lookup:
    ```sql
    CREATE TABLE t_lookup (
         item_key VARCHAR(10) NOT NULL,
         item_value VARCHAR(100)
    );
    ```

8. Добавьте первичный ключ:
    ```sql
    ALTER TABLE t_lookup 
    ADD CONSTRAINT t_lookup_pk PRIMARY KEY (item_key);
    ```

9. Заполните данными:
    ```sql
    INSERT INTO t_lookup 
    SELECT 
         LPAD(CAST(generate_series(1, 150000) AS TEXT), 10, '0'),
         'Value_' || generate_series(1, 150000);
    ```

10. Создайте кластеризованную таблицу:
     ```sql
     CREATE TABLE t_lookup_clustered (
          item_key VARCHAR(10) PRIMARY KEY,
          item_value VARCHAR(100)
     );
     ```

11. Заполните её теми же данными:
     ```sql
     INSERT INTO t_lookup_clustered 
     SELECT * FROM t_lookup;
     
     CLUSTER t_lookup_clustered USING t_lookup_clustered_pkey;
     ```

12. Обновите статистику:
     ```sql
     ANALYZE t_lookup;
     ANALYZE t_lookup_clustered;
     ```

13. Выполните поиск по ключу в обычной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup WHERE item_key = '0000000455';
     ```
     
     *План выполнения:*
     | QUERY PLAN |
     | :--- |
     | Index Scan using t\_lookup\_pk on t\_lookup  \(cost=0.42..8.44 rows=1 width=23\) \(actual time=0.014..0.014 rows=1 loops=1\) |
     |   Index Cond: \(\(item\_key\)::text = '0000000455'::text\) |
     | Planning Time: 0.089 ms |
     | Execution Time: 0.025 ms |

     *Объясните результат:* \
     Запрос использует **Index Scan**, так как по колонке `item_key` задан первичный ключ, автоматически создающий B-Tree индекс. Индекс позволяет PostgreSQL эффективно находить строку с ключом `'0000000455'` без необходимости полного сканирования таблицы. Быстрое время выполнения (0.025 мс) обусловлено прямым обращением к индексу и минимальным объемом данных для проверки условия.

14. Выполните поиск по ключу в кластеризованной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup_clustered WHERE item_key = '0000000455';
     ```
     
     *План выполнения:*
     | QUERY PLAN |
     | :--- |
     | Index Scan using t\_lookup\_clustered\_pkey on t\_lookup\_clustered  \(cost=0.42..8.44 rows=1 width=23\) \(actual time=0.018..0.018 rows=1 loops=1\) |
     |   Index Cond: \(\(item\_key\)::text = '0000000455'::text\) |
     | Planning Time: 0.147 ms |
     | Execution Time: 0.030 ms |
     
     *Объясните результат:* \
     Кластеризация таблицы упорядочила данные в соответствии с индексом `t_lookup_clustered_pkey`, что минимизирует фрагментацию. Однако, запрос все равно использует **Index Scan**, так как поиск происходит по ключу `item_key`. В данном случае кластеризация не дает значительного выигрыша в производительности, так как индексация уже обеспечивает быстрый доступ. Время выполнения (0.030 мс) немного больше, чем для обычной таблицы, из-за дополнительных накладных расходов на упорядоченные данные.

15. Создайте индекс по значению для обычной таблицы:
     ```sql
     CREATE INDEX t_lookup_value_idx ON t_lookup(item_value);
     ```

16. Создайте индекс по значению для кластеризованной таблицы:
     ```sql
     CREATE INDEX t_lookup_clustered_value_idx 
     ON t_lookup_clustered(item_value);
     ```

17. Выполните поиск по значению в обычной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup WHERE item_value = 'T_BOOKS';
     ```
     
     *План выполнения:*
     | QUERY PLAN |
     | :--- |
     | Index Scan using t\_lookup\_value\_idx on t\_lookup  \(cost=0.42..8.44 rows=1 width=23\) \(actual time=0.035..0.036 rows=0 loops=1\) |
     |   Index Cond: \(\(item\_value\)::text = 'T\_BOOKS'::text\) |
     | Planning Time: 0.289 ms |
     | Execution Time: 0.055 ms |
     
     *Объясните результат:* \
     Запрос использует **Index Scan** по индексу `t_lookup_value_idx`, который создан для ускорения поиска по колонке `item_value`. Индекс позволяет быстро проверить строки на соответствие значению `'T_BOOKS'`, минуя полное сканирование таблицы. Однако в данном случае результирующих строк нет (rows=0), так как указанное значение отсутствует в данных. Время выполнения (0.055 мс) остается небольшим благодаря индексации.

18. Выполните поиск по значению в кластеризованной таблице:
     ```sql
     EXPLAIN ANALYZE
     SELECT * FROM t_lookup_clustered WHERE item_value = 'T_BOOKS';
     ```
     
     *План выполнения:*
     | QUERY PLAN |
     | :--- |
     | Index Scan using t\_lookup\_clustered\_value\_idx on t\_lookup\_clustered  \(cost=0.42..8.44 rows=1 width=23\) \(actual time=0.031..0.032 rows=0 loops=1\) |
     |   Index Cond: \(\(item\_value\)::text = 'T\_BOOKS'::text\) |
     | Planning Time: 0.173 ms |
     | Execution Time: 0.043 ms |

     *Объясните результат:* \
     Запрос использует **Index Scan** по индексу `t_lookup_clustered_value_idx`, специально созданному для поиска по колонке `item_value`. Индекс позволяет PostgreSQL быстро определить отсутствие строки с указанным значением `'T_BOOKS'`, избегая полного сканирования таблицы. Благодаря индексации время выполнения остается минимальным (0.043 мс). Кластеризация таблицы не влияет на этот запрос, так как порядок данных не связан с колонкой `item_value`.
     
19. Сравните производительность поиска по значению в обычной и кластеризованной таблицах:
 
### Сравнение производительности:

1. **Время выполнения**:
   - Обычная таблица: **0.055 мс**.
   - Кластеризованная таблица: **0.043 мс**.
   - Кластеризованная таблица немного быстрее (~20%), что может быть связано с более компактным расположением данных из-за кластеризации, уменьшившим количество операций ввода-вывода.

2. **План выполнения**:
   - В обоих случаях использовался **Index Scan**, поскольку индексы по `item_value` оптимизируют поиск по значению.

3. **Влияние кластеризации**:
   - Кластеризация сама по себе не улучшает производительность для колонок, не связанных с кластеризующим индексом (`item_key`), но может незначительно повлиять на общую производительность за счет улучшенного порядка хранения данных.

### Итог:
Разница в производительности минимальна, так как поиск выполняется через индекс в обоих случаях. Однако кластеризация может быть полезна для запросов, которые учитывают упорядоченность данных по кластеризующему индексу.