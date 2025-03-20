CREATE OR REPLACE VIEW  nauczyciel_info AS
SELECT ROW_NUMBER() OVER (ORDER BY ncz.nazwisko,ncz.imie) AS nr, 
    ncz.nazwisko, 
    ncz.imie ,
    kl.klasa_num || kl.klasa_letter AS "Klasa wychowawcza"
FROM nauczyciel ncz 
FULL JOIN klasa kl ON ncz.nauczyciel_id = kl.wychowawca_id 
ORDER BY ncz.nazwisko;
 

CREATE OR REPLACE VIEW klasa_info AS
WITH CTE AS (SELECT COUNT(u.uczen_id) AS liczba, kl.klasa_id AS id FROM klasa kl FULL JOIN uczen u ON kl.klasa_id = u.klasa_id GROUP BY kl.klasa_id )
SELECT ROW_NUMBER() OVER (ORDER BY kl.klasa_id) AS nr,
    kl.klasa_num || kl.klasa_letter AS klasa,
    CTE.liczba AS "ilosc uczniow",
    ncz.nazwisko || ' ' || ncz.imie AS wychowawca,
    s.sala_name AS "sala wychowawcza"
FROM klasa kl JOIN CTE ON kl.klasa_id = CTE.id
LEFT JOIN nauczyciel ncz ON kl.wychowawca_id = ncz.nauczyciel_id
LEFT JOIN sala s ON kl.sala_id = s.sala_id
ORDER BY kl.klasa_num,klasa_letter;


CREATE OR REPLACE VIEW sala_info AS
SELECT ROW_NUMBER() OVER (ORDER BY s.sala_id) AS nr,
    s.sala_name AS "nazwa sali",
    s.liczba_miejsc AS pojemnosc,
    kl.klasa_num || kl.klasa_letter AS "sala wychowawcza klasy",
    ncz.nazwisko || ' ' || ncz.imie AS wychowawca
FROM sala s 
LEFT JOIN klasa kl ON s.sala_id = kl.sala_id 
LEFT JOIN nauczyciel ncz ON kl.wychowawca_id = ncz.nauczyciel_id
ORDER BY s.sala_name, kl.klasa_id;


CREATE OR REPLACE VIEW przedmiot_info AS
SELECT ROW_NUMBER() OVER (ORDER BY ncz.nazwisko) AS nr,
    p.przedmiot_name AS "nazwa",
    ncz.nazwisko || ' ' || ncz.imie AS nauczyciel
FROM przedmiot p 
JOIN nauczyciel_przedmiot np ON p.przedmiot_id = np.przedmiot_id
JOIN nauczyciel ncz ON np.nauczyciel_id = ncz.nauczyciel_id
ORDER BY ncz.nazwisko,p.przedmiot_name;


CREATE OR REPLACE VIEW klasa_przedmiot_info AS
SELECT DISTINCT kl.klasa_id, np.przedmiot_id,prz.przedmiot_name,np.nauczyciel_id, ncz.nazwisko || ' ' || ncz.imie AS nauczyciel, np.ncz_prz_id
FROM klasa kl JOIN plan pl ON kl.klasa_id = pl.klasa_id
JOIN nauczyciel_przedmiot np ON pl.ncz_prz_id = np.ncz_prz_id
JOIN nauczyciel ncz ON np.nauczyciel_id = ncz.nauczyciel_id
JOIN przedmiot prz ON np.przedmiot_id = prz.przedmiot_id
ORDER BY kl.klasa_id,np.przedmiot_id;



