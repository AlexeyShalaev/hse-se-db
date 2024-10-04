-- Подключаемся к базе данных stations
\c stations

-- ==============================
-- Заполнение таблиц данными
-- ==============================

-- 1. Вставка данных в таблицу City
INSERT INTO "City" ("Name", "Region") VALUES
('Москва', 'Центральный федеральный округ'),
('Санкт-Петербург', 'Северо-Западный федеральный округ'),
('Новосибирск', 'Сибирский федеральный округ'),
('Екатеринбург', 'Уральский федеральный округ'),
('Казань', 'Приволжский федеральный округ'),
('Нижний Новгород', 'Приволжский федеральный округ'),
('Челябинск', 'Уральский федеральный округ'),
('Самара', 'Приволжский федеральный округ'),
('Омск', 'Сибирский федеральный округ'),
('Ростов-на-Дону', 'Южный федеральный округ'),
('Уфа', 'Приволжский федеральный округ'),
('Красноярск', 'Сибирский федеральный округ'),
('Пермь', 'Приволжский федеральный округ'),
('Волгоград', 'Южный федеральный округ'),
('Воронеж', 'Центральный федеральный округ'),
('Саратов', 'Приволжский федеральный округ'),
('Краснодар', 'Южный федеральный округ'),
('Тольятти', 'Приволжский федеральный округ'),
('Ижевск', 'Приволжский федеральный округ'),
('Ульяновск', 'Приволжский федеральный округ'),
('Тверь', 'Центральный федеральный округ');

-- 2. Вставка данных в таблицу Station
INSERT INTO "Station" ("Name", "#Tracks", "CityName", "Region") VALUES
('Москва Казанская', 14, 'Москва', 'Центральный федеральный округ'),
('Москва Ленинградская', 10, 'Москва', 'Центральный федеральный округ'),
('Санкт-Петербург Главный', 12, 'Санкт-Петербург', 'Северо-Западный федеральный округ'),
('Новосибирск Главный', 8, 'Новосибирск', 'Сибирский федеральный округ'),
('Екатеринбург Пассажирский', 9, 'Екатеринбург', 'Уральский федеральный округ'),
('Казань Пассажирская', 7, 'Казань', 'Приволжский федеральный округ'),
('Нижний Новгород Московский', 6, 'Нижний Новгород', 'Приволжский федеральный округ'),
('Челябинск Главный', 5, 'Челябинск', 'Уральский федеральный округ'),
('Самара Пассажирская', 7, 'Самара', 'Приволжский федеральный округ'),
('Ростов Главный', 8, 'Ростов-на-Дону', 'Южный федеральный округ'),
('Уфа Пассажирская', 6, 'Уфа', 'Приволжский федеральный округ'),
('Красноярск Пассажирский', 7, 'Красноярск', 'Сибирский федеральный округ'),
('Пермь II', 5, 'Пермь', 'Приволжский федеральный округ'),
('Волгоград I', 4, 'Волгоград', 'Южный федеральный округ'),
('Воронеж I', 5, 'Воронеж', 'Центральный федеральный округ'),
('Саратов I', 5, 'Саратов', 'Приволжский федеральный округ'),
('Краснодар I', 6, 'Краснодар', 'Южный федеральный округ'),
('Тольятти Пассажирская', 4, 'Тольятти', 'Приволжский федеральный округ'),
('Ижевск Пассажирский', 5, 'Ижевск', 'Приволжский федеральный округ'),
('Ульяновск Центральный', 4, 'Ульяновск', 'Приволжский федеральный округ'),
('Тверь Пассажирская', 4, 'Тверь', 'Центральный федеральный округ');

-- 3. Вставка данных в таблицу Train
INSERT INTO "Train" ("TrainNr", "Length", "StartStationName", "EndStationName") VALUES
('001А', 300, 'Москва Казанская', 'Санкт-Петербург Главный'),
('002А', 320, 'Москва Ленинградская', 'Новосибирск Главный'),
('003А', 280, 'Екатеринбург Пассажирский', 'Казань Пассажирская'),
('004А', 310, 'Нижний Новгород Московский', 'Челябинск Главный'),
('005А', 290, 'Самара Пассажирская', 'Ростов Главный'),
('006А', 275, 'Уфа Пассажирская', 'Красноярск Пассажирский'),
('007А', 265, 'Пермь II', 'Волгоград I'),
('008А', 285, 'Воронеж I', 'Саратов I'),
('009А', 295, 'Краснодар I', 'Тольятти Пассажирская'),
('010А', 305, 'Ижевск Пассажирский', 'Ульяновск Центральный'),
('011А', 315, 'Москва Казанская', 'Екатеринбург Пассажирский'),
('012А', 325, 'Санкт-Петербург Главный', 'Челябинск Главный'),
('013А', 335, 'Новосибирск Главный', 'Казань Пассажирская'),
('014А', 345, 'Москва Ленинградская', 'Ростов Главный'),
('015А', 355, 'Самара Пассажирская', 'Уфа Пассажирская'),
('016А', 365, 'Нижний Новгород Московский', 'Красноярск Пассажирский'),
('017А', 375, 'Пермь II', 'Волгоград I'),
('018A', 385, 'Воронеж I', 'Тольятти Пассажирская'),
('019A', 395, 'Краснодар I', 'Ижевск Пассажирский'),
('020A', 405, 'Ульяновск Центральный', 'Новосибирск Главный'),
('101А', 350, 'Москва Ленинградская', 'Санкт-Петербург Главный'),
('102А', 250, 'Москва Казанская', 'Тверь Пассажирская');

-- 4. Вставка данных в таблицу Connection
INSERT INTO "Connection" ("FromStation", "ToStation", "TrainNr", "Departure", "Arrival") VALUES
('Москва Казанская', 'Санкт-Петербург Главный', '001А', '2023-10-03 08:00:00', '2023-10-03 16:00:00'),
('Москва Ленинградская', 'Новосибирск Главный', '002А', '2023-10-02 09:00:00', '2023-10-03 18:00:00'),
('Екатеринбург Пассажирский', 'Казань Пассажирская', '003А', '2023-10-03 10:00:00', '2023-10-03 20:00:00'),
('Нижний Новгород Московский', 'Челябинск Главный', '004А', '2023-10-04 11:00:00', '2023-10-04 22:00:00'),
('Самара Пассажирская', 'Ростов Главный', '005А', '2023-10-05 12:00:00', '2023-10-05 23:00:00'),
('Уфа Пассажирская', 'Красноярск Пассажирский', '006А', '2023-10-06 13:00:00', '2023-10-07 15:00:00'),
('Пермь II', 'Волгоград I', '007А', '2023-10-07 14:00:00', '2023-10-08 20:00:00'),
('Воронеж I', 'Саратов I', '008А', '2023-10-08 15:00:00', '2023-10-08 23:00:00'),
('Краснодар I', 'Тольятти Пассажирская', '009А', '2023-10-09 16:00:00', '2023-10-10 02:00:00'),
('Ижевск Пассажирский', 'Ульяновск Центральный', '010А', '2023-10-10 17:00:00', '2023-10-10 21:00:00'),
('Москва Казанская', 'Екатеринбург Пассажирский', '011А', '2023-10-11 08:00:00', '2023-10-11 20:00:00'),
('Санкт-Петербург Главный', 'Челябинск Главный', '012А', '2023-10-12 09:00:00', '2023-10-13 22:00:00'),
('Новосибирск Главный', 'Казань Пассажирская', '013А', '2023-10-13 10:00:00', '2023-10-14 18:00:00'),
('Москва Ленинградская', 'Ростов Главный', '014А', '2023-10-14 11:00:00', '2023-10-14 23:00:00'),
('Самара Пассажирская', 'Уфа Пассажирская', '015А', '2023-10-15 12:00:00', '2023-10-15 16:00:00'),
('Нижний Новгород Московский', 'Красноярск Пассажирский', '016А', '2023-10-16 13:00:00', '2023-10-17 20:00:00'),
('Пермь II', 'Волгоград I', '017А', '2023-10-17 14:00:00', '2023-10-18 20:00:00'),
('Воронеж I', 'Тольятти Пассажирская', '018A', '2023-10-18 15:00:00', '2023-10-19 01:00:00'),
('Краснодар I', 'Ижевск Пассажирский', '019A', '2023-10-19 16:00:00', '2023-10-20 06:00:00'),
('Ульяновск Центральный', 'Новосибирск Главный', '020A', '2023-10-20 17:00:00', '2023-10-22 09:00:00'),
('Москва Ленинградская', 'Тверь Пассажирская', '101А', '2023-10-01 08:00:00', '2023-10-01 10:00:00'),
('Тверь Пассажирская', 'Санкт-Петербург Главный', '101А', '2023-10-01 11:00:00', '2023-10-01 16:00:00'),
('Москва Ленинградская', 'Санкт-Петербург Главный', '101А', '2023-10-02 08:00:00', '2023-10-02 16:00:00'),
('Москва Казанская', 'Тверь Пассажирская', '102А', '2023-10-02 09:00:00', '2023-10-02 11:00:00');
