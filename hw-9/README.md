# Задание №9

## Шалаев Алексей БПИ 222

### 1

```sql
SELECT 
    (bit_length(name) + char_length(race)) AS calculation
FROM 
    demographics;
```

### 2

```sql
SELECT 
    id,
    bit_length(name) AS name,
    birthday,
    bit_length(race) AS race
FROM 
    demographics;
```

### 3

```sql
SELECT 
    id,
    ascii(name) AS name,
    birthday,
    ascii(race) AS race
FROM 
    demographics;
```

### 4

```sql
SELECT 
    CONCAT_WS(' ', prefix, first, last, suffix) AS title
FROM 
    names;
```

### 5

```sql
SELECT 
    rpad(md5, char_length(sha256), '1') AS md5,
    lpad(sha1, char_length(sha256), '0') AS sha1,
    sha256
FROM 
    encryption;
```
### 6

```sql
SELECT 
    LEFT(project, commits) AS project,
    RIGHT(address, contributors) AS address
FROM 
    repositories;
```
### 7

```sql
SELECT 
    project,
    commits,
    contributors,
    REGEXP_REPLACE(address, '[0-9]', '!', 'g') AS address
FROM 
    repositories;
```

### 8

```sql
SELECT 
    name,
    weight,
    price,
    ROUND(price / (weight / 1000), 2) AS price_per_kg
FROM 
    products
ORDER BY 
    price_per_kg ASC,
    name ASC;
```
