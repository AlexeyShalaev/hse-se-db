## Задание 3

1. Создайте таблицу с большим количеством данных:
    ```sql
    CREATE TABLE test_cluster AS 
    SELECT 
        generate_series(1,1000000) as id,
        CASE WHEN random() < 0.5 THEN 'A' ELSE 'B' END as category,
        md5(random()::text) as data;
    ```

2. Создайте индекс:
    ```sql
    CREATE INDEX test_cluster_cat_idx ON test_cluster(category);
    ```

3. Измерьте производительность до кластеризации:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM test_cluster WHERE category = 'A';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Bitmap Heap Scan on test\_cluster  \(cost=59.17..7696.73 rows=5000 width=68\) \(actual time=13.424..94.731 rows=500395 loops=1\) |
    |   Recheck Cond: \(category = 'A'::text\) |
    |   Heap Blocks: exact=8334 |
    |   -&gt;  Bitmap Index Scan on test\_cluster\_cat\_idx  \(cost=0.00..57.92 rows=5000 width=0\) \(actual time=12.302..12.303 rows=500395 loops=1\) |
    |         Index Cond: \(category = 'A'::text\) |
    | Planning Time: 0.190 ms |
    | Execution Time: 107.584 ms |
    
    *Объясните результат:* \
    Запрос использует **Bitmap Index Scan** для нахождения блоков с `category = 'A'` и **Bitmap Heap Scan** для извлечения данных, что эффективно благодаря индексу. Однако из-за случайного распределения строк требуется обработать много блоков (8334), что увеличивает время выполнения до ~107 мс. Кластеризация могла бы уменьшить фрагментацию и улучшить производительность.

4. Выполните кластеризацию:
    ```sql
    CLUSTER test_cluster USING test_cluster_cat_idx;
    ```
    
    *Результат:*
    ```sql
    postgres.public> CLUSTER test_cluster USING test_cluster_cat_idx
    [2024-12-04 15:44:29] completed in 763 ms
    ```

5. Измерьте производительность после кластеризации:
    ```sql
    EXPLAIN ANALYZE
    SELECT * FROM test_cluster WHERE category = 'A';
    ```
    
    *План выполнения:*
    | QUERY PLAN |
    | :--- |
    | Bitmap Heap Scan on test\_cluster  \(cost=5565.48..20139.89 rows=499233 width=39\) \(actual time=14.496..75.043 rows=500395 loops=1\) |
    |   Recheck Cond: \(category = 'A'::text\) |
    |   Heap Blocks: exact=4170 |
    |   -&gt;  Bitmap Index Scan on test\_cluster\_cat\_idx  \(cost=0.00..5440.67 rows=499233 width=0\) \(actual time=13.966..13.967 rows=500395 loops=1\) |
    |         Index Cond: \(category = 'A'::text\) |
    | Planning Time: 0.286 ms |
    | Execution Time: 88.820 ms |
    
    *Объясните результат:* \
    Кластеризация упорядочила строки по индексу `test_cluster_cat_idx`, что уменьшило фрагментацию данных. После кластеризации количество блоков для обработки снизилось с 8334 до 4170, что ускорило чтение данных. В результате общее время выполнения сократилось до ~88 мс.

6. Сравните производительность до и после кластеризации:
    
### Сравнение производительности:

1. **До кластеризации**:
   - Время выполнения: **107.584 мс**.
   - Количество обработанных блоков: **8334**.

2. **После кластеризации**:
   - Время выполнения: **88.820 мс** (ускорение ~17%).
   - Количество обработанных блоков: **4170** (уменьшение почти в 2 раза).

3. **Причина улучшения**:
   - После кластеризации строки с `category = 'A'` стали расположены последовательно, что уменьшило количество операций ввода-вывода для чтения данных.

### Итог:
Кластеризация значительно уменьшает фрагментацию данных, улучшая производительность запросов, особенно при поиске по индексированным колонкам.