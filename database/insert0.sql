-- Wstawianie danych do tabeli 'nauczyciel'
INSERT INTO nauczyciel (imie, nazwisko, lata_pracy)
VALUES
('Bernarda', 'Rozmus', 5),
('Bozena', 'Bajda', 20),
('Agnieszka', 'Berezowska', 8),
('Piotr', 'Chmielowiec', 10),
('Magdalena', 'Dygon', 10),
('Tomasz', 'Januszewski', 15),
('Tomasz', 'Manijak', 7),
('Krzysztof', 'Wilczkiewicz', 3),
('Malgorzata', 'Sabat', 10),
('Andrzej', 'Swiatek', 10),
('Renata', 'Sydor', 11),
('Marcin', 'Roman', 13),
('Marcin', 'Posiak', 12),
('Elzbieta', 'Slowik', 9),
('Anna', 'Solecka', 7),
('Szymon', 'Szczepankiewicz', 13),
('Stanislaw', 'Wojnar', 12),
('Magdalena', 'Walicka', 2),
('Mariusz', 'Kraus', 5);


-- Wstawianie danych do tabeli 'sala'
INSERT INTO sala (liczba_miejsc, sala_name)
VALUES
(22, 1),
(28, 2),
(25, 3),
(20, 4),
(27, 5),
(24, 6),
(30, 7),
(23, 8),
(60, 'AULA'),
(300, 'GIM');


-- Wstawianie danych do tabeli klasa
INSERT INTO klasa ( klasa_num, klasa_letter, sala_id, wychowawca_id)
VALUES
(2, 'A', 2, 6),
(3, 'A', 5, 19);


INSERT INTO uczen (PESEL, imie, nazwisko, klasa_id, data_urodzenia)
VALUES
('12345678901', 'Jan', 'Kowalski', 1, '2005-05-15'),
('23456789012', 'Anna', 'Nowak', 1, '2005-09-20'),
('34567890123', 'Piotr', 'Wisniewski', 1, '2005-03-12'),
('45678901234', 'Ewa', 'Jankowska', 1, '2005-07-10'),
('56789012345', 'Tomasz', 'Zielinski', 1, '2005-11-05'),
('67890123456', 'Magdalena', 'Wojciechowska', 1, '2005-06-25'),
('78901234567', 'Pawel', 'Szymanski', 1, '2005-01-30'),
('89012345678', 'Katarzyna', 'Nowakowska', 1, '2005-10-17'),
('90123456789', 'Adam', 'Kaczmarek', 1, '2005-08-02'),
('01234567890', 'Agnieszka', 'Lewandowska', 1, '2005-02-19'),
('12345678912', 'Jakub', 'Mazurek', 1, '2005-12-03'),
('23456789023', 'Karolina', 'Kwiatkowska', 1, '2005-04-13'),
('34567890134', 'Michal', 'Sikora', 1, '2005-01-22'),
('45678901245', 'Dorota', 'Wojcik', 1, '2005-03-30'),
('56789012356', 'Lukasz', 'Zawisza', 1, '2005-06-04');


INSERT INTO uczen (PESEL, imie, nazwisko, klasa_id, data_urodzenia)
VALUES
('21345678901', 'Janek', 'Kowalski', 2, '2004-05-15'),
('32456789012', 'Aneta', 'Brzoza', 2, '2004-09-20'),
('43567890123', 'Piotr', 'Nowicki', 2, '2004-03-12'),
('54678901234', 'Ewa', 'Kaczmarek', 2, '2004-07-10'),
('65789012345', 'Tomek', 'Sikorski', 2, '2004-11-05'),
('76890123456', 'Magda', 'Kwiatkowski', 2, '2004-06-25'),
('87901234567', 'Pawel', 'Wojciechowski', 2, '2004-01-30'),
('98012345678', 'Katarzyna', 'Lis', 2, '2004-10-17'),
('09123456789', 'Adam', 'Chmielewski', 2, '2004-08-02'),
('10234567890', 'Agnieszka', 'Zawisza', 2, '2004-02-19'),
('21345678912', 'Jakub', 'Majewski', 2, '2004-12-03'),
('32456789023', 'Karolina', 'Wojcik', 2, '2004-04-13'),
('43567890134', 'Michal', 'Pawlak', 2, '2004-01-22'),
('54678901245', 'Dorota', 'Witkowska', 2, '2004-03-30'),
('65789012356', 'Lukasz', 'Malinowski', 2, '2004-06-04');



-- Wstawianie danych do tabeli przedmiot
INSERT INTO przedmiot (przedmiot_name)
VALUES
('fizyka'),
('j. niemiecki'),
('historia'),
('WOS'),
('j. polski'),
('HIT'),
('informatyka'),
('religia'),
('biologia'),
('geografia'),
('j. angielski'),
('wych. fiz.'),
('plastyka'),
('chemia'),
('matematyka'),
('godz. wych.');



-- Wstawianie danych do tabeli nauczyciel_przedmiot
INSERT INTO nauczyciel_przedmiot (nauczyciel_id, przedmiot_id)
VALUES
(1, 1), 
(2, 1),
(3, 2),
(4, 3),
(4, 4),
(5, 5),
(6, 3),
(6, 6),
(6, 4),
(6, 16),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(11, 16),
(12, 12),
(13, 12),
(14, 5),
(15, 13),
(16, 14),
(17, 11),
(17, 2),
(18, 15),
(19, 15),
(19, 16);


--KLASA ID =1

INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)
VALUES
(21, 1, 1, 'Pon', 3),  
(25, 1, 2, 'Pon', 4),  
(13, 1, 3, 'Pon',5),   
(4, 1, 4, 'Pon',6),   
(12, 1, 5, 'Pon',7),   
(1, 1, 6, 'Pon',8),   
(3, 1, 7, 'Pon',1),   
(22, 1, 8, 'Pon', 2); 

-- Wt:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(25, 1, 1, 'Wt', 3), 
(22, 1, 2, 'Wt', 4), 
(21, 1, 3, 'Wt', 5), 
(6, 1, 4, 'Wt',9),   
(6, 1, 5, 'Wt',9),   
(13, 1, 6, 'Wt',8),   
(10, 1, 7, 'Wt',2);  

-- Sr:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(25, 1, 2, 'Sr', 3),      
(4, 1, 3, 'Sr',4),        
(12, 1, 4, 'Sr',5),        
(6, 1, 5, 'Sr',6),        
(21, 1, 6, 'Sr', 7),      
(22, 1, 7, 'Sr', 8);      

-- Czw:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(14, 1, 1, 'Czw', 3), 
(22, 1, 2, 'Czw', 4), 
(13, 1, 3, 'Czw',5),  
(25, 1, 4, 'Czw', 6), 
(21, 1, 5, 'Czw', 7), 
(6, 1, 6, 'Czw',8),  
(17, 1, 7, 'Czw', 10),
(17, 1, 8, 'Czw', 10);

-- Piątek:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(20, 1, 1, 'Pt', 3), 
(9, 1, 2, 'Pt',4),   
(17, 1, 3, 'Pt', 10),
(6, 1, 4, 'Pt',6),   
(13, 1, 5, 'Pt',7),   
(25, 1, 6, 'Pt', 1), 
(25, 1, 7, 'Pt', 1); 


--KLASA ID=2

-- Pon:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(2, 2, 1, 'Pon',4),  
(14, 2, 2, 'Pon', 5),
(25, 2, 3, 'Pon', 6),
(22, 2, 4, 'Pon', 7),
(3, 2, 5, 'Pon',8),  
(12, 2, 6, 'Pon',1),  
(19, 2, 7, 'Pon', 3), 
(19, 2, 8, 'Pon', 3); 

-- Wt:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(21, 2, 1, 'Wt', 4),  
(13, 2, 2, 'Wt',5),    
(25, 2, 3, 'Wt', 6),  
(26, 2, 4, 'Wt', 5),  
(19, 2, 5, 'Wt', 8),   
(2, 2, 6, 'Wt',1),    
(11, 2, 7, 'Wt',8);    

-- Sr:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(25, 2, 1, 'Sr', 3),  
(11, 2, 2, 'Sr',4),    
(14, 2, 3, 'Sr', 5),  
(25, 2, 4, 'Sr', 6),  
(8, 2, 5, 'Sr',7),    
(20, 2, 6, 'Sr', 8);  

-- Czw:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(21, 2, 2, 'Czw', 1), 
(19, 2, 3, 'Czw', 2),  
(2, 2, 4, 'Czw',4),   
(17, 2, 5, 'Czw', 10),
(17, 2, 6, 'Czw', 10),
(25, 2, 7, 'Czw', 5), 
(25, 2, 8, 'Czw', 5); 


-- Piątek:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)VALUES
(12, 2, 1, 'Pt',4),    
(19, 2, 2, 'Pt', 5),   
(4, 2, 3, 'Pt',6),    
(17, 2, 4, 'Pt', 10), 
(25, 2, 5, 'Pt', 8),  
(11, 2, 6, 'Pt',2),    
(11, 2, 7, 'Pt',2);    



INSERT INTO ocena (uczen_id, ncz_prz_id, ocena_date, ocena_value, komentarz)
VALUES
    (1, 1, '2024-01-15', 4, 'Aktywność'),
    (2, 14, '2024-01-15', 5, 'Odpowiedź ustna'),
    (3, 13, '2024-01-14', 3, 'Kartkówka'),
    (4, 25, '2024-01-14', 2, 'Zadanie domowe'),
    (5, 17, '2024-01-13', 5, 'Projekt'),
    (6, 21, '2024-01-13', 4, 'Praca w grupie'),
    (7, 4, '2024-01-12', 3, 'Praca na lekcji'),
    (8, 20, '2024-01-12', 1, 'Brak zadania'),
    (9, 1, '2024-01-11', 4, 'Kartkówka'),
    (10, 4, '2024-01-11', 5, 'Prezentacja'),
    (11, 3, '2024-01-10', 3, 'Aktywność'),
    (12, 10, '2024-01-10', 4, 'Praca w grupie'),
    (13, 22, '2024-01-09', 2, 'Odpowiedź ustna'),
    (14, 12, '2024-01-09', 5, 'Projekt'),
    (15, 14, '2024-01-08', 4, 'Kartkówka');

-- Oceny ze sprawdzianu 
INSERT INTO ocena (uczen_id, ncz_prz_id, ocena_date, ocena_value, komentarz, ocena_weight)
VALUES
    (1, 9, '2024-01-05', 4, 'Sprawdzian', 3),
    (2, 9, '2024-01-05', 3, 'Sprawdzian', 3),
    (3, 9, '2024-01-05', 5, 'Sprawdzian', 3),
    (4, 9, '2024-01-05', 2, 'Sprawdzian', 3),
    (5, 9, '2024-01-05', 4, 'Sprawdzian', 3),
    (6, 9, '2024-01-05', 3, 'Sprawdzian', 3),
    (7, 9, '2024-01-05', 2, 'Sprawdzian', 3),
    (8, 9, '2024-01-05', 5, 'Sprawdzian', 3),
    (9, 9, '2024-01-05', 4, 'Sprawdzian', 3),
    (10, 9, '2024-01-05', 3, 'Sprawdzian', 3),
    (11, 9, '2024-01-05', 5, 'Sprawdzian', 3),
    (12, 9, '2024-01-05', 2, 'Sprawdzian', 3),
    (13, 9, '2024-01-05', 4, 'Sprawdzian', 3),
    (14, 9, '2024-01-05', 3, 'Sprawdzian', 3),
    (15, 9, '2024-01-05', 2, 'Sprawdzian', 3);



-- Oceny dla uczniów 16-30 
INSERT INTO ocena (uczen_id, ncz_prz_id, ocena_date, ocena_value, komentarz)
VALUES
    (16, 2, '2024-01-15', 4, 'Aktywność'),
    (17, 3, '2024-01-15', 5, 'Odpowiedź ustna'),
    (18, 4, '2024-01-14', 3, 'Kartkówka'),
    (19, 19, '2024-01-14', 2, 'Zadanie domowe'),
    (20, 8, '2024-01-13', 5, 'Projekt'),
    (21, 11, '2024-01-13', 4, 'Praca w grupie'),
    (22, 12, '2024-01-12', 3, 'Praca na lekcji'),
    (23, 13, '2024-01-12', 1, 'Brak zadania'),
    (24, 14, '2024-01-11', 4, 'Kartkówka'),
    (25, 22, '2024-01-11', 5, 'Prezentacja'),
    (26, 17, '2024-01-10', 3, 'Aktywność'),
    (27, 20, '2024-01-10', 4, 'Praca w grupie'),
    (28, 21, '2024-01-09', 2, 'Odpowiedź ustna'),
    (29, 25, '2024-01-09', 5, 'Projekt'),
    (30, 26, '2024-01-08', 4, 'Kartkówka');

-- Oceny ze sprawdzianu 
INSERT INTO ocena (uczen_id, ncz_prz_id, ocena_date, ocena_value, komentarz, ocena_weight)
VALUES
    (16, 8, '2024-01-05', 4, 'Sprawdzian', 3),
    (17, 8, '2024-01-05', 3, 'Sprawdzian', 3),
    (18, 8, '2024-01-05', 5, 'Sprawdzian', 3),
    (19, 8, '2024-01-05', 2, 'Sprawdzian', 3),
    (20, 8, '2024-01-05', 4, 'Sprawdzian', 3),
    (21, 8, '2024-01-05', 3, 'Sprawdzian', 3),
    (22, 8, '2024-01-05', 2, 'Sprawdzian', 3),
    (23, 8, '2024-01-05', 5, 'Sprawdzian', 3),
    (24, 8, '2024-01-05', 4, 'Sprawdzian', 3),
    (25, 8, '2024-01-05', 3, 'Sprawdzian', 3),
    (26, 8, '2024-01-05', 5, 'Sprawdzian', 3),
    (27, 8, '2024-01-05', 2, 'Sprawdzian', 3),
    (28, 8, '2024-01-05', 4, 'Sprawdzian', 3),
    (29, 8, '2024-01-05', 3, 'Sprawdzian', 3),
    (30, 8, '2024-01-05', 2, 'Sprawdzian', 3);





    -- Nieobecności i spóźnienia dla uczniów 1-15 w dniach 13-17 stycznia
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        -- 13 stycznia
        (1, 1, '2025-01-13'),
        (1, 2, '2025-01-13'),
        (1, 3, '2025-01-13'),
        (1, 4, '2025-01-13'),
        (1, 5, '2025-01-13'),
        (1, 6, '2025-01-13'),
        (1, 7, '2025-01-13'),
        (2, 1, '2025-01-13'),
        (2, 2, '2025-01-13'),
        (3, 1, '2025-01-13');

INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        -- 14 stycznia
        (4, 9, '2025-01-14'), 
        (4, 10, '2025-01-14'),
        (4, 11, '2025-01-14'),
        (4, 12, '2025-01-14'),
        (5, 9, '2025-01-14'), 
        (5, 10, '2025-01-14'),
        (6, 9, '2025-01-14');

INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        -- 15 stycznia
        (7, 16, '2025-01-15'),
        (7, 17, '2025-01-15'),
        (7, 18, '2025-01-15'),
        (7, 19, '2025-01-15'),
        (8, 16, '2025-01-15'),
        (8, 17, '2025-01-15'),
        (9, 16, '2025-01-15');

        -- 16 stycznia
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        (10, 22, '2025-01-16'), 
        (10, 23, '2025-01-16'), 
        (10, 24, '2025-01-16'), 
        (10, 25, '2025-01-16'), 
        (11, 22, '2025-01-16'), 
        (11, 23, '2025-01-16'), 
        (12, 22, '2025-01-16'); 

        -- 17 stycznia
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        (13, 30, '2025-01-17'), 
        (13, 31, '2025-01-17'), 
        (13, 32, '2025-01-17'), 
        (13, 33, '2025-01-17'), 
        (14, 30, '2025-01-17'), 
        (14, 31, '2025-01-17'), 
        (15, 30, '2025-01-17'); 

    
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        -- 13 stycznia
        (16, 37, '2025-01-13'), 
        (16, 38, '2025-01-13'), 
        (16, 39, '2025-01-13'), 
        (16, 40, '2025-01-13'), 
        (16, 41, '2025-01-13'), 
        (17, 37, '2025-01-13'), 
        (18, 37, '2025-01-13'); 

        -- 14 stycznia
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        (19, 45, '2025-01-14'), 
        (19, 46, '2025-01-14'), 
        (19, 47, '2025-01-14'), 
        (19, 48, '2025-01-14'), 
        (20, 45, '2025-01-14'), 
        (21, 45, '2025-01-14'); 

        -- 15 stycznia
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        (22, 52, '2025-01-15'), 
        (22, 53, '2025-01-15'), 
        (22, 54, '2025-01-15'), 
        (23, 52, '2025-01-15'), 
        (23, 53, '2025-01-15'), 
        (24, 52, '2025-01-15'); 

        -- 16 styczni
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        (25, 58, '2025-01-16'), 
        (25, 59, '2025-01-16'), 
        (25, 60, '2025-01-16'), 
        (26, 58, '2025-01-16'), 
        (27, 58, '2025-01-16'); 

        -- 17 stycznia
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
    VALUES
        (28, 65, '2025-01-17'), 
        (28, 66, '2025-01-17'), 
        (28, 67, '2025-01-17'), 
        (29, 65, '2025-01-17'), 
        (30, 65, '2025-01-17'); 




