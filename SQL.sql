INSERT INTO klasa ( klasa_num, klasa_letter, sala_id, wychowawca_id)
VALUES
(3, 'B', 7, 11);

INSERT INTO uczen (PESEL, imie, nazwisko, klasa_id, data_urodzenia)
VALUES
('21345678910', 'Kamil', 'Wroblewski', 3, '2004-05-15'),
('32456789021', 'Beata', 'Jasinska', 3, '2004-09-20'),
('43567890132', 'Marek', 'Zawadzki', 3, '2004-03-12'),
('54678901243', 'Lidia', 'Sobolewska', 3, '2004-07-10'),
('65789012354', 'Wojtek', 'Laskowski', 3, '2004-11-05'),
('76890123465', 'Anna', 'Marek', 3, '2004-06-25'),
('87901234576', 'Grzegorz', 'Bielawski', 3, '2004-01-30'),
('98012345689', 'Monika', 'Krupa', 3, '2004-10-17'),
('09123456790', 'Filip', 'Piekarski', 3, '2004-08-02'),
('10234567801', 'Natalia', 'Nowakowska', 3, '2004-02-19'),
('21345678921', 'Dawid', 'Zielonka', 3, '2004-12-03'),
('32456789032', 'Olga', 'Michalska', 3, '2004-04-13'),
('43567890143', 'Patryk', 'Slusarczyk', 3, '2004-01-22'),
('54678901254', 'Jagoda', 'Kwiatkowska', 3, '2004-03-30'),
('65789012365', 'Michal', 'Bartosz', 3, '2004-06-04');


INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)
VALUES
(14, 3, 1, 'Pon', 9), 
(11, 3, 2, 'Pon', 6),   
(1, 3, 3, 'Pon', 9),   
(24, 3, 4, 'Pon', 3), 
(24, 3, 5, 'Pon', 3), 
(6, 3, 6, 'Pon', 2);   

-- Wt:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)
VALUES
(20, 3, 1, 'Wt',  8),  
(7, 3, 2, 'Wt', 7),    
(6, 3, 3, 'Wt', 2),    
(16, 3, 4, 'Wt',  7),  
(15, 3, 5, 'Wt',  6),  
(15, 3, 6, 'Wt',  6),  
(21, 3, 7, 'Wt',  1);  

-- Sr:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)
VALUES
(1, 3, 1, 'Sr', 2),    
(1, 3, 2, 'Sr', 2),    
(24, 3, 3, 'Sr',  6),  
(14, 3, 4, 'Sr',  9),  
(14, 3, 5, 'Sr',  9),  
(12, 3, 6, 'Sr', 3),   
(18, 3, 7, 'Sr',  10); 

-- Czwartek:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)
VALUES
(6, 3, 1, 'Czw', 5),   
(6, 3, 2, 'Czw', 5),   
(3, 3, 3, 'Czw', 6),   
(18, 3, 4, 'Czw',  9), 
(18, 3, 5, 'Czw',  9), 
(24, 3, 6, 'Czw',  6), 
(13, 3, 7, 'Czw', 2),  
(24, 3, 8, 'Czw',  6); 

-- Piątek:
INSERT INTO plan ( ncz_prz_id, klasa_id, lekcja_num, dzien,  sala_id)
VALUES
(24, 3, 1, 'Pt',  8),  
(6, 3, 2, 'Pt', 7),    
(15, 3, 3, 'Pt',  4),  
(7, 3, 4, 'Pt', 7),    
(1, 3, 5, 'Pt', 3),    
(1, 3, 6, 'Pt', 3),    
(21, 3, 7, 'Pt',  5);  


INSERT INTO ocena (uczen_id, ncz_prz_id, ocena_date, ocena_value, komentarz)
VALUES
    (31, 1, '2025-01-15', 4, 'Aktywność'),
    (32, 3, '2025-01-15', 5, 'Odpowiedź ustna'),
    (33, 7, '2025-01-14', 3, 'Kartkówka'),
    (34, 6, '2025-01-14', 2, 'Zadanie domowe'),
    (35, 6, '2025-01-13', 5, 'Projekt'),
    (36, 11, '2025-01-13', 4, 'Praca w grupie'),
    (37, 12, '2025-01-12', 3, 'Praca na lekcji'),
    (38, 13, '2025-01-12', 2, 'Brak zadania'),
    (39, 14, '2025-01-11', 4, 'Kartkówka'),
    (40, 15, '2025-01-11', 5, 'Prezentacja'),
    (41, 18, '2025-01-10', 3, 'Aktywność'),
    (42, 20, '2025-01-10', 4, 'Praca w grupie'),
    (43, 21, '2025-01-09', 2, 'Odpowiedź ustna'),
    (44, 24, '2025-01-09', 5, 'Projekt'),
    (45, 16, '2025-01-08', 4, 'Kartkówka');

-- Oceny ze sprawdzianu
INSERT INTO ocena (uczen_id, ncz_prz_id, ocena_date, ocena_value, komentarz, ocena_weight)
VALUES
    (31, 7, '2025-01-05', 4, 'Sprawdzian', 3),
    (32, 7, '2025-01-05', 3, 'Sprawdzian', 3),
    (33, 7, '2025-01-05', 5, 'Sprawdzian', 3),
    (34, 7, '2025-01-05', 2, 'Sprawdzian', 3),
    (35, 7, '2025-01-05', 4, 'Sprawdzian', 3),
    (36, 7, '2025-01-05', 3, 'Sprawdzian', 3),
    (37, 7, '2025-01-05', 2, 'Sprawdzian', 3),
    (38, 7, '2025-01-05', 5, 'Sprawdzian', 3),
    (39, 7, '2025-01-05', 4, 'Sprawdzian', 3),
    (40, 7, '2025-01-05', 3, 'Sprawdzian', 3),
    (41, 7, '2025-01-05', 5, 'Sprawdzian', 3),
    (42, 7, '2025-01-05', 2, 'Sprawdzian', 3),
    (43, 7, '2025-01-05', 4, 'Sprawdzian', 3),
    (44, 7, '2025-01-05', 3, 'Sprawdzian', 3),
    (45, 7, '2025-01-05', 2, 'Sprawdzian', 3);


INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
VALUES
    -- 13 stycznia (Poniedziałek)
    (31, 72, '2025-01-13'), 
    (31, 73, '2025-01-13'), 
    (31, 74, '2025-01-13'), 
    (31, 75, '2025-01-13'), 
    (32, 72, '2025-01-13'), 
    (33, 72, '2025-01-13');
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
VALUES
    -- 14 stycznia (Wtorek)
    (34, 78, '2025-01-14'), 
    (34, 79, '2025-01-14'), 
    (34, 80, '2025-01-14'), 
    (34, 81, '2025-01-14'), 
    (35, 78, '2025-01-14'), 
    (36, 78, '2025-01-14'); 
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
VALUES
    -- 15 stycznia (Środa)
    (37, 85, '2025-01-15'), 
    (37, 86, '2025-01-15'), 
    (37, 87, '2025-01-15'), 
    (37, 88, '2025-01-15'), 
    (38, 85, '2025-01-15'), 
    (39, 85, '2025-01-15'); 
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
VALUES
    -- 16 stycznia (Czwartek)
    (40, 92, '2025-01-16'), 
    (40, 93, '2025-01-16'), 
    (40, 94, '2025-01-16'), 
    (40, 95, '2025-01-16'), 
    (41, 92, '2025-01-16'), 
    (42, 92, '2025-01-16'); 
INSERT INTO nieobecnosc (uczen_id, lekcja_id, nieobecnosc_date)
VALUES
    -- 17 stycznia (Piątek)
    (43, 100, '2025-01-17'),
    (43, 101, '2025-01-17'),
    (43, 102, '2025-01-17'),
    (43, 103, '2025-01-17'),
    (44, 100, '2025-01-17'),
    (45, 100, '2025-01-17');
 

