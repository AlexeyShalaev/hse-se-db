# Задание №7

## Шалаев Алексей БПИ 222

### Проводник

- **configs** - конфиги с env
- **service** - Python приложение, для наката миграций, заполнения данных и получения результатов запросов
- **docker-compose.yml** - Docker-compose с PostgreSQL и Сервисом

### Решения

- Миграции [Migrations](./service/migrations/) 
- ORM-запросы [Tasks](./service/src/tasks/) 

### Логи сервиса с ответами

```
db-service  | 2024-10-17 12:05:50.450 | INFO     | __main__:main:12 - Service started.
db-service  | INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
db-service  | INFO  [alembic.runtime.migration] Will assume transactional DDL.
db-service  | 2024-10-17 12:05:50.494 | INFO     | src.core.setup:run_migrations:19 - Database migrated.                                                                                                                   
db-service  | 2024-10-17 12:05:50.515 | DEBUG    | __main__:main:16 - Database filled.                                                                                                                                     
db-service  | ----------------------------------                                                                                                                                                                           
db-service  | 1. Для Олимпийских игр 2004 года сгенерируйте список (год рождения, количество игроков, количество золотых медалей),
db-service  | содержащий годы, в которые родились игроки, количество игроков, родившихся в каждый из этих лет,                                                                                                             
db-service  | которые выиграли по крайней мере одну золотую медаль, и количество золотых медалей, завоеванных игроками, родившимися в этом году.
db-service  | (Decimal('1987'), 1, 1)                                                                                                                                                                                      
db-service  | ----------------------------------
db-service  | 2. Перечислите все индивидуальные (не групповые) соревнования, в которых была ничья в счете, и два или более игрока выиграли золотую медаль.                                                                 
db-service  | ('High Jump                               ', 2)
db-service  | ('100m Sprint                             ', 2)                                                                                                                                                              
db-service  | ----------------------------------
db-service  | 3. Найдите всех игроков, которые выиграли хотя бы одну медаль (GOLD, SILVER и BRONZE) на одной Олимпиаде. (player-name, olympic-id).                                                                         
db-service  | ('Bob Williams                            ', 'wMwhgyB')
db-service  | ('Janet Osborne                           ', 'STTWhnL')                                                                                                                                                      
db-service  | ('Kim Dillon                              ', 'GTQMRhP')
db-service  | ('Kristina Dawson                         ', 'uqUYjne')                                                                                                                                                      
db-service  | ('Julie Moore                             ', 'gLAMewW')                                                                                                                                                      
db-service  | ('Katrina Caldwell                        ', 'QmhgrTj')
db-service  | ('Christopher Williams                    ', 'EbqqSHJ')                                                                                                                                                      
db-service  | ('Katherine Webb                          ', 'QrdJFBk')
db-service  | ('Christopher Carter                      ', 'TVKOjsC')                                                                                                                                                      
db-service  | ('Natasha Moore                           ', 'YjSqmMq')                                                                                                                                                      
db-service  | ----------------------------------
db-service  | 4. В какой стране был наибольший процент игроков (из перечисленных в наборе данных), чьи имена начинались с гласной?                                                                                         
db-service  | ('Guinea                                  ', Decimal('14.61187214611872146100'))                                                                                                                             
db-service  | ----------------------------------
db-service  | 5. Для Олимпийских игр 2000 года найдите 5 стран с минимальным соотношением количества групповых медалей к численности населения.
```