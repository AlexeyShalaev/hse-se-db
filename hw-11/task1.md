# Задание 1: BRIN индексы и bitmap-сканирование

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

4. Создайте BRIN индекс по колонке category:
   ```sql
   CREATE INDEX t_books_brin_cat_idx ON t_books USING brin(category);
   ```

5. Найдите книги с NULL значением category:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books WHERE category IS NULL;
   ```
   
   *План выполнения:*
   | QUERY PLAN |
   | :--- |
   | Index Scan using t\_books\_cat\_null\_idx on t\_books  \(cost=0.12..7.97 rows=1 width=33\) \(actual time=0.013..0.014 rows=1 loops=1\) |
   | Planning Time: 2.168 ms |
   | Execution Time: 0.033 ms |

   
   *Объясните результат:* \
   BRIN индекс позволяет эффективно находить строки с `NULL`, ограничивая поиск только релевантными блоками данных. В результате запрос выполняется быстро, используя `Index Scan` с низкими затратами на обработку. Это демонстрирует эффективность BRIN индекса для слабо селективных и упорядоченных данных.

6. Создайте BRIN индекс по автору:
   ```sql
   CREATE INDEX t_books_brin_author_idx ON t_books USING brin(author);
   ```

7. Выполните поиск по категории и автору:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM t_books 
   WHERE category = 'INDEX' AND author = 'SYSTEM';
   ```
   
   *План выполнения:*
   | QUERY PLAN |
   | :--- |
   | Bitmap Heap Scan on t\_books  \(cost=17.94..251.76 rows=1 width=33\) \(actual time=0.980..0.981 rows=0 loops=1\) |
   |   Recheck Cond: \(\(\(author\)::text = 'SYSTEM'::text\) AND \(\(category\)::text = 'INDEX'::text\)\) |
   |   -&gt;  BitmapAnd  \(cost=17.94..17.94 rows=73 width=0\) \(actual time=0.974..0.975 rows=0 loops=1\) |
   |         -&gt;  Bitmap Index Scan on t\_books\_author\_title\_index  \(cost=0.00..5.54 rows=149 width=0\) \(actual time=0.973..0.973 rows=0 loops=1\) |
   |               Index Cond: \(\(author\)::text = 'SYSTEM'::text\) |
   |         -&gt;  Bitmap Index Scan on t\_books\_brin\_cat\_idx  \(cost=0.00..12.16 rows=73530 width=0\) \(never executed\) |
   |               Index Cond: \(\(category\)::text = 'INDEX'::text\) |
   | Planning Time: 0.143 ms |
   | Execution Time: 0.997 ms |
   
   *Объясните результат (обратите внимание на bitmap scan):* \
   Запрос использует **Bitmap Heap Scan**, который объединяет результаты двух **Bitmap Index Scan** операций: по `author` и `category`. BRIN индексы быстро находят релевантные блоки данных для каждого условия, а затем объединяются с помощью `BitmapAnd`. Это снижает количество сканируемых строк, но в данном случае строки, соответствующие обоим условиям, отсутствуют, поэтому итоговый результат пустой.

8. Получите список уникальных категорий:
   ```sql
   EXPLAIN ANALYZE
   SELECT DISTINCT category 
   FROM t_books 
   ORDER BY category;
   ```
   
   *План выполнения:*
   | QUERY PLAN |
   | :--- |
   | Sort  \(cost=3100.18..3100.19 rows=6 width=7\) \(actual time=28.708..28.709 rows=7 loops=1\) |
   |   Sort Key: category |
   |   Sort Method: quicksort  Memory: 25kB |
   |   -&gt;  HashAggregate  \(cost=3100.04..3100.10 rows=6 width=7\) \(actual time=28.694..28.696 rows=7 loops=1\) |
   |         Group Key: category |
   |         Batches: 1  Memory Usage: 24kB |
   |         -&gt;  Seq Scan on t\_books  \(cost=0.00..2725.03 rows=150003 width=7\) \(actual time=0.007..7.065 rows=150003 loops=1\) |
   | Planning Time: 0.098 ms |
   | Execution Time: 28.736 ms |
   
   *Объясните результат:* \
   Запрос выполняет последовательное сканирование (**Seq Scan**) таблицы `t_books`, чтобы собрать все строки и определить уникальные значения категории через **HashAggregate**. Затем результат сортируется с использованием **quicksort** для упорядочивания категорий. Несмотря на относительно большой объем данных (150003 строк), операция эффективна, так как агрегация и сортировка используют небольшую память (~25 kB).

9. Подсчитайте книги, где автор начинается на 'S':
   ```sql
   EXPLAIN ANALYZE
   SELECT COUNT(*) 
   FROM t_books 
   WHERE author LIKE 'S%';
   ```
   
   *План выполнения:*
   | QUERY PLAN |
   | :--- |
   | Aggregate  \(cost=3100.08..3100.09 rows=1 width=8\) \(actual time=11.603..11.605 rows=1 loops=1\) |
   |   -&gt;  Seq Scan on t\_books  \(cost=0.00..3100.04 rows=15 width=0\) \(actual time=11.600..11.601 rows=0 loops=1\) |
   |         Filter: \(\(author\)::text \~\~ 'S%'::text\) |
   |         Rows Removed by Filter: 150003 |
   | Planning Time: 0.116 ms |
   | Execution Time: 11.622 ms |

   *Объясните результат:* \
   Запрос использует **Seq Scan** для последовательного чтения всей таблицы `t_books` (150003 строк) из-за отсутствия индекса, подходящего для фильтрации по условию `LIKE 'S%'`. Фильтр проверяет каждую строку на соответствие шаблону, удаляя нерелевантные строки. Поскольку строки с авторами, начинающимися на `S`, отсутствуют, итоговое значение равно нулю, а время выполнения составило ~11.6 мс.

10. Создайте индекс для регистронезависимого поиска:
    ```sql
    CREATE INDEX t_books_lower_title_idx ON t_books(LOWER(title));
    ```

11. Подсчитайте книги, начинающиеся на 'O':
    ```sql
    EXPLAIN ANALYZE
    SELECT COUNT(*) 
    FROM t_books 
    WHERE LOWER(title) LIKE 'o%';
    ```
   
   *План выполнения:*
   | QUERY PLAN |
   | :--- |
   | Aggregate  \(cost=3476.92..3476.93 rows=1 width=8\) \(actual time=43.390..43.392 rows=1 loops=1\) |
   |   -&gt;  Seq Scan on t\_books  \(cost=0.00..3475.05 rows=750 width=0\) \(actual time=43.382..43.385 rows=1 loops=1\) |
   |         Filter: \(lower\(\(title\)::text\) \~\~ 'o%'::text\) |
   |         Rows Removed by Filter: 150002 |
   | Planning Time: 0.299 ms |
   | Execution Time: 43.416 ms |

   *Объясните результат:* \
   Хотя был создан индекс `t_books_lower_title_idx`, запрос все еще использует **Seq Scan** вместо индекса. Это происходит потому, что функция `LOWER(title)` используется внутри фильтра `LIKE`, и PostgreSQL не может эффективно применить индекс для этого условия. В результате все 150003 строки последовательно сканируются, проверяются на соответствие шаблону `LIKE 'o%'`, что приводит к длительному времени выполнения (~43.4 мс). Индекс мог бы быть использован, если бы условие точно соответствовало формату индексации.

12. Удалите созданные индексы:
    ```sql
    DROP INDEX t_books_brin_cat_idx;
    DROP INDEX t_books_brin_author_idx;
    DROP INDEX t_books_lower_title_idx;
    ```

13. Создайте составной BRIN индекс:
    ```sql
    CREATE INDEX t_books_brin_cat_auth_idx ON t_books 
    USING brin(category, author);
    ```

14. Повторите запрос из шага 7:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM t_books 
    WHERE category = 'INDEX' AND author = 'SYSTEM';
    ```
   
   *План выполнения:*
   | QUERY PLAN |
   | :--- |
   | Bitmap Heap Scan on t\_books  \(cost=5.54..428.26 rows=1 width=33\) \(actual time=0.012..0.012 rows=0 loops=1\) |
   |   Recheck Cond: \(\(author\)::text = 'SYSTEM'::text\) |
   |   Filter: \(\(category\)::text = 'INDEX'::text\) |
   |   -&gt;  Bitmap Index Scan on t\_books\_author\_title\_index  \(cost=0.00..5.54 rows=149 width=0\) \(actual time=0.009..0.009 rows=0 loops=1\) |
   |         Index Cond: \(\(author\)::text = 'SYSTEM'::text\) |
   | Planning Time: 0.142 ms |
   | Execution Time: 0.021 ms |
   
   *Объясните результат:* \
   Составной BRIN индекс `t_books_brin_cat_auth_idx` позволяет PostgreSQL эффективно сузить диапазон блоков для поиска по двум колонкам. Однако, в данном запросе используется **Bitmap Index Scan**, но только по колонке `author`, так как фильтр по `category` применяется на этапе **Filter**. Это связано с тем, что BRIN индексы работают с блоками, и точные соответствия зависят от порядка фильтров в запросе. В данном случае строк, удовлетворяющих обоим условиям, не найдено, что подтверждается быстрым временем выполнения (~0.021 мс).