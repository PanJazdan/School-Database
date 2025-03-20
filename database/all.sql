

CREATE TABLE nauczyciel(
    nauczyciel_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imie VARCHAR(100) NOT NULL,
    nazwisko VARCHAR(100) NOT NULL,
    lata_pracy INT DEFAULT NULL,
    CONSTRAINT imie_alphabetic CHECK( imie ~ '^[a-zA-Z\''-]+$'),
    CONSTRAINT nazwisko_alphabetic CHECK( nazwisko ~ '^[a-zA-Z\''-]+$')
);

CREATE TABLE sala(
    sala_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    liczba_miejsc INT NOT NULL,
    sala_name VARCHAR (10) NOT NULL UNIQUE
);

CREATE TABLE klasa(
    klasa_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    klasa_num INT NOT NULL,
    klasa_letter CHAR(1) DEFAULT NULL,
    sala_id INT NOT NULL UNIQUE REFERENCES sala(sala_id) ON DELETE CASCADE,
    wychowawca_id INT NOT NULL UNIQUE REFERENCES nauczyciel (nauczyciel_id) ON DELETE CASCADE,
    CONSTRAINT unique_num_letter_combination UNIQUE (klasa_num, klasa_letter)
);

CREATE TABLE uczen (
    uczen_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    PESEL VARCHAR(11) NOT NULL UNIQUE,
    imie VARCHAR(100) NOT NULL,
    nazwisko VARCHAR(100) NOT NULL,
    klasa_id INT NOT NULL REFERENCES klasa (klasa_id) ON DELETE CASCADE,
    data_urodzenia DATE NOT NULL,
   

    CONSTRAINT pesel_length_numeric CHECK(LENGTH(PESEL)=11 AND  PESEL ~'^\d+$'),
    CONSTRAINT imie_alphabetic CHECK( imie ~ '^[a-zA-Z\''-]+$'),
    CONSTRAINT nazwisko_alphabetic CHECK( nazwisko ~ '^[a-zA-Z\''-]+$')
   
);

CREATE TABLE przedmiot(
    przedmiot_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    przedmiot_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE nauczyciel_przedmiot (
    ncz_prz_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, 
    nauczyciel_id INT REFERENCES nauczyciel (nauczyciel_id) ON DELETE CASCADE,
    przedmiot_id INT REFERENCES przedmiot (przedmiot_id) ON DELETE CASCADE,
    UNIQUE (nauczyciel_id, przedmiot_id) 
);



CREATE TABLE plan(
    lekcja_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    klasa_id INT  REFERENCES klasa (klasa_id) ON DELETE CASCADE,
    ncz_prz_id INT  REFERENCES nauczyciel_przedmiot (ncz_prz_id) ON DELETE CASCADE,
    lekcja_num INT DEFAULT NULL,
    dzien CHAR(3) DEFAULT NULL,
    sala_id INT REFERENCES sala (sala_id) ON DELETE CASCADE,

    CONSTRAINT lekcja_range CHECK (lekcja_num BETWEEN 0 AND 8),
    CONSTRAINT valid_day CHECK (dzien IN ('Pon', 'Wt', 'Sr', 'Czw', 'Pt'))
);

CREATE TABLE ocena(
    ocena_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    uczen_id INT NOT NULL REFERENCES uczen(uczen_id) ON DELETE CASCADE,
    ncz_prz_id INT NOT NULL REFERENCES nauczyciel_przedmiot(ncz_prz_id) ON DELETE CASCADE,
    ocena_date DATE NOT NULL,
    ocena_value INT NOT NULL ,
    ocena_weight INT NOT NULL DEFAULT 1,
    komentarz VARCHAR(200) DEFAULT NULL,
    CONSTRAINT ocena__value_range CHECK (ocena_value BETWEEN 1 AND 6),
    CONSTRAINT ocena_weight_range CHECK (ocena_weight BETWEEN 1 AND 5)
);

CREATE TABLE nieobecnosc(
    nieobecnosc_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    uczen_id INT NOT NULL REFERENCES uczen(uczen_id) ON DELETE CASCADE,
    lekcja_id INT NOT NULL REFERENCES plan(lekcja_id) ON DELETE CASCADE,
    nieobecnosc_date DATE NOT NULL
); 







--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@




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

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@



CREATE OR REPLACE FUNCTION trigger_fun_plan_klasy()
RETURNS TRIGGER AS $$
DECLARE
    plan_record RECORD;
BEGIN
   
    IF EXISTS (
        SELECT 1 FROM plan 
        WHERE klasa_id = NEW.klasa_id 
          AND lekcja_num = NEW.lekcja_num 
          AND dzien = NEW.dzien
          AND (TG_OP = 'INSERT' OR lekcja_id != OLD.lekcja_id)
    ) THEN
        
        SELECT pl.dzien, pl.lekcja_num, prz.przedmiot_name, 
               ncz.imie || ' ' || ncz.nazwisko AS nauczyciel
        INTO plan_record
        FROM plan pl
            JOIN nauczyciel_przedmiot np ON pl.ncz_prz_id = np.ncz_prz_id
            JOIN nauczyciel ncz ON np.nauczyciel_id = ncz.nauczyciel_id
            JOIN przedmiot prz ON np.przedmiot_id = prz.przedmiot_id
        WHERE pl.klasa_id = NEW.klasa_id
          AND pl.lekcja_num = NEW.lekcja_num
          AND pl.dzien = NEW.dzien
          AND (TG_OP = 'INSERT' OR pl.lekcja_id != OLD.lekcja_id);

       
        RAISE EXCEPTION 'Ta klasa ma juz wtedy zajecia: Dzien: %, Lekcja: %, Przedmiot: %, Nauczyciel: %',
                        plan_record.dzien, plan_record.lekcja_num, 
                        plan_record.przedmiot_name, plan_record.nauczyciel;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_plan_klasy 
BEFORE INSERT OR UPDATE ON plan
FOR EACH ROW
EXECUTE FUNCTION trigger_fun_plan_klasy();

--###############
--###############
--###############

CREATE OR REPLACE FUNCTION trigger_fun_plan_sali()
RETURNS TRIGGER AS $$
DECLARE
    plan_record RECORD;
BEGIN
  
    IF EXISTS (
        SELECT 1 FROM plan 
        WHERE sala_id = NEW.sala_id 
          AND lekcja_num = NEW.lekcja_num 
          AND dzien = NEW.dzien
          AND (TG_OP = 'INSERT' OR lekcja_id != OLD.lekcja_id) 
    ) THEN
        
        SELECT pl.dzien, pl.lekcja_num, 
               ncz.imie || ' ' || ncz.nazwisko AS nauczyciel,
               kl.klasa_num || kl.klasa_letter AS klasa
        INTO plan_record
        FROM plan pl
            JOIN klasa kl ON pl.klasa_id = kl.klasa_id
            JOIN sala sl ON pl.sala_id = sl.sala_id
            JOIN nauczyciel_przedmiot np ON pl.ncz_prz_id = np.ncz_prz_id
            JOIN nauczyciel ncz ON np.nauczyciel_id = ncz.nauczyciel_id
        WHERE pl.sala_id = NEW.sala_id
          AND pl.lekcja_num = NEW.lekcja_num
          AND pl.dzien = NEW.dzien
          AND (TG_OP = 'INSERT' OR pl.lekcja_id != OLD.lekcja_id);

        
        RAISE EXCEPTION 'Ta sala jest juz wtedy zajeta: Dzien: %, Lekcja: %, Nauczyciel: %, Klasa: %',
                        plan_record.dzien, 
                        plan_record.lekcja_num, 
                        plan_record.nauczyciel, 
                        plan_record.klasa;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_plan_sali 
BEFORE INSERT OR UPDATE ON plan
FOR EACH ROW
EXECUTE FUNCTION trigger_fun_plan_sali();


--###############
--###############
--###############


CREATE OR REPLACE FUNCTION trigger_fun_plan_nauczyciela()
RETURNS TRIGGER AS $$
DECLARE
    plan_record RECORD;
BEGIN
    
    IF EXISTS (
        SELECT 1 FROM plan
        WHERE ncz_prz_id = NEW.ncz_prz_id 
          AND lekcja_num = NEW.lekcja_num 
          AND dzien = NEW.dzien
          AND (TG_OP = 'INSERT' OR lekcja_id != OLD.lekcja_id) 
    ) THEN
        
        SELECT pl.dzien, pl.lekcja_num, 
               sl.sala_name AS sala_name, 
               kl.klasa_num || kl.klasa_letter AS klasa
        INTO plan_record
        FROM plan pl
            JOIN klasa kl ON pl.klasa_id = kl.klasa_id
            JOIN sala sl ON pl.sala_id = sl.sala_id
        WHERE pl.ncz_prz_id = NEW.ncz_prz_id
          AND pl.lekcja_num = NEW.lekcja_num
          AND pl.dzien = NEW.dzien
          AND (TG_OP = 'INSERT' OR pl.lekcja_id != OLD.lekcja_id);

       
        RAISE EXCEPTION 'Ten nauczyciel jest wtedy zajety: Dzien: %, Lekcja: %, Sala: %, Klasa: %',
                        plan_record.dzien,
                        plan_record.lekcja_num,
                        plan_record.sala_name,
                        plan_record.klasa;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_plan_nauczyciela 
BEFORE INSERT OR UPDATE ON plan
FOR EACH ROW
EXECUTE FUNCTION trigger_fun_plan_nauczyciela();

--###############
--###############
--###############

CREATE OR REPLACE FUNCTION enforce_uppercase_klasa_letter()
RETURNS TRIGGER AS $$
BEGIN
   
    NEW.klasa_letter := UPPER(NEW.klasa_letter);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_enforce_uppercase_klasa_letter
BEFORE INSERT OR UPDATE ON klasa
FOR EACH ROW
EXECUTE FUNCTION enforce_uppercase_klasa_letter();

--###############
--###############
--###############

CREATE OR REPLACE FUNCTION trigger_fun_ocena()
RETURNS TRIGGER AS $$
BEGIN
    -- Sprawdzamy, czy dla INSERT istnieje odpowiedni nauczyciel i przedmiot
    IF TG_OP = 'INSERT' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM klasa_przedmiot_info kpi
            WHERE kpi.klasa_id = (SELECT klasa_id FROM uczen WHERE uczen_id = NEW.uczen_id)
              AND kpi.przedmiot_id = (SELECT np.przedmiot_id FROM nauczyciel_przedmiot np WHERE np.ncz_prz_id = NEW.ncz_prz_id)
              AND kpi.ncz_prz_id = NEW.ncz_prz_id
        ) THEN
            RAISE EXCEPTION 'Uczeń nie jest uczony przez tego nauczyciela z tego przedmiotu';
        END IF;
    -- Sprawdzamy, czy dla UPDATE istnieje odpowiedni nauczyciel i przedmiot
    ELSIF TG_OP = 'UPDATE' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM klasa_przedmiot_info kpi
            WHERE kpi.klasa_id = (SELECT klasa_id FROM uczen WHERE uczen_id = NEW.uczen_id)
              AND kpi.przedmiot_id = (SELECT np.przedmiot_id FROM nauczyciel_przedmiot np WHERE np.ncz_prz_id = NEW.ncz_prz_id)
              AND kpi.ncz_prz_id = NEW.ncz_prz_id
        ) THEN
            RAISE EXCEPTION 'Uczeń nie jest uczony przez tego nauczyciela z tego przedmiotu';
        END IF;
    END IF;

    -- Jeżeli wszystko jest poprawne, zapisujemy ocenę
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_ocena
BEFORE INSERT OR UPDATE ON ocena
FOR EACH ROW
EXECUTE FUNCTION trigger_fun_ocena();

--###############
--###############
--###############


CREATE OR REPLACE FUNCTION trigger_fun_sprawdz_nieobecnosc()
RETURNS TRIGGER AS $$
DECLARE
    dzien_lekcji CHAR(3);
BEGIN
    -- Pobieramy dzień lekcji z tabeli plan
    SELECT dzien INTO dzien_lekcji
    FROM plan
    WHERE lekcja_id = NEW.lekcja_id;

    -- Sprawdzamy, czy dzień z planu pasuje do dnia tygodnia wprowadzonej daty
    IF EXTRACT(DOW FROM NEW.nieobecnosc_date) !=
       (CASE dzien_lekcji
           WHEN 'Pon' THEN 1
           WHEN 'Wt' THEN 2
           WHEN 'Sr' THEN 3
           WHEN 'Czw' THEN 4
           WHEN 'Pt' THEN 5
           ELSE NULL
       END) THEN
        RAISE EXCEPTION 'Data nieobecnosc_date nie pasuje do dnia lekcji dla lekcji_id: %, dzien: %, wpisana data: %',
                        NEW.lekcja_id, dzien_lekcji, NEW.nieobecnosc_date;
    END IF;

    -- Jeśli wszystko jest poprawnie, zapisujemy nieobecność
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE TRIGGER trigger_sprawdz_nieobecnosc
BEFORE INSERT OR UPDATE ON nieobecnosc
FOR EACH ROW
EXECUTE FUNCTION trigger_fun_sprawdz_nieobecnosc();


--###############
--###############
--###############



CREATE OR REPLACE FUNCTION trigger_fun_sprawdz_ucznia_lekcje()
RETURNS TRIGGER AS $$
BEGIN
    -- Sprawdzamy, czy uczeń ma zapisaną lekcję w tabeli plan
    IF NOT EXISTS (
        SELECT 1
        FROM plan p
        WHERE p.lekcja_id = NEW.lekcja_id
        AND p.klasa_id = (SELECT u.klasa_id FROM uczen u WHERE u.uczen_id = NEW.uczen_id)
    ) THEN
        RAISE EXCEPTION 'Uczeń o id= % nie ma zapisanej lekcja_id =  % w swojej klasie.', NEW.uczen_id, NEW.lekcja_id;
    END IF;

    -- Jeśli wszystko jest poprawnie, zapisujemy nieobecność
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_sprawdz_ucznia_lekcje
BEFORE INSERT ON nieobecnosc
FOR EACH ROW
EXECUTE FUNCTION trigger_fun_sprawdz_ucznia_lekcje();





--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@



---plan klasy funkcja

CREATE OR REPLACE FUNCTION fun_plan_klasy(INT)
RETURNS TABLE(
    numer_lekcji INT,
    poniedzialek TEXT,
    wtorek TEXT,
    sroda TEXT,
    czwartek TEXT,
    piatek TEXT
) AS $$

BEGIN
    RETURN QUERY
    WITH lekcje AS (
        SELECT generate_series(1, 8) AS lekcja_num
    )
    SELECT 
        l.lekcja_num AS numer_lekcji,
        MAX(CASE WHEN pl.dzien = 'Pon' THEN prz.przedmiot_name || ' ' || sl.sala_name ELSE '---' END) AS poniedzialek,
        MAX(CASE WHEN pl.dzien = 'Wt' THEN prz.przedmiot_name || ' ' || sl.sala_name ELSE '---' END) AS wtorek,
        MAX(CASE WHEN pl.dzien = 'Sr' THEN prz.przedmiot_name || ' ' || sl.sala_name ELSE '---' END) AS sroda,
        MAX(CASE WHEN pl.dzien = 'Czw' THEN prz.przedmiot_name || ' ' || sl.sala_name ELSE '---' END) AS czwartek,
        MAX(CASE WHEN pl.dzien = 'Pt' THEN prz.przedmiot_name || ' ' || sl.sala_name ELSE '---' END) AS piatek
    FROM
        lekcje l
        LEFT JOIN plan pl ON l.lekcja_num = pl.lekcja_num AND (pl.klasa_id = $1 OR pl.klasa_id IS NULL)
        LEFT JOIN przedmiot prz ON pl.przedmiot_id = prz.przedmiot_id
        LEFT JOIN sala sl ON pl.sala_id = sl.sala_id
    GROUP BY
        l.lekcja_num
    ORDER BY
        l.lekcja_num;
END;
$$ LANGUAGE plpgsql;



---plan nauczyciela funkcja

CREATE OR REPLACE FUNCTION fun_plan_nauczyciela(INT)
RETURNS TABLE(
    numer_lekcji INT,
    poniedzialek TEXT,
    wtorek TEXT,
    sroda TEXT,
    czwartek TEXT,
    piatek TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH lekcje AS (
    SELECT generate_series(1, 8) AS lekcja_num 
    )
    SELECT
        l.lekcja_num AS numer_lekcji,
        MAX(CASE WHEN pl.dzien = 'Pon' THEN kl.klasa_num || kl.klasa_letter || ' ' || sl.sala_name ELSE '---' END) AS Poniedzialek,
        MAX(CASE WHEN pl.dzien = 'Wt' THEN kl.klasa_num || kl.klasa_letter || ' ' || sl.sala_name ELSE '---' END) AS Wtorek,
        MAX(CASE WHEN pl.dzien = 'Sr' THEN kl.klasa_num || kl.klasa_letter || ' ' || sl.sala_name ELSE '---' END) AS Sroda,
        MAX(CASE WHEN pl.dzien = 'Czw' THEN kl.klasa_num || kl.klasa_letter || ' ' || sl.sala_name ELSE '---' END) AS Czwartek,
        MAX(CASE WHEN pl.dzien = 'Pt' THEN kl.klasa_num || kl.klasa_letter || ' ' || sl.sala_name ELSE '---' END) AS Piatek
    FROM
        lekcje l
        LEFT JOIN plan pl ON l.lekcja_num = pl.lekcja_num AND (pl.nauczyciel_id = $1 OR pl.nauczyciel_id IS NULL)
        LEFT JOIN klasa kl ON pl.klasa_id = kl.klasa_id
        LEFT JOIN sala sl ON pl.sala_id = sl.sala_id
    GROUP BY
        l.lekcja_num
    ORDER BY
        l.lekcja_num;
END;
$$ LANGUAGE plpgsql;



---plan sali funkcja

CREATE OR REPLACE FUNCTION fun_plan_sali(INT)
RETURNS TABLE(
    numer_lekcji INT,
    poniedzialek TEXT,
    wtorek TEXT,
    sroda TEXT,
    czwartek TEXT,
    piatek TEXT
) AS $$
BEGIN

    
    RETURN QUERY
    WITH lekcje AS (
    SELECT generate_series(1, 8) AS lekcja_num 
    )
    SELECT
        l.lekcja_num AS numer_lekcji,
        MAX(CASE WHEN pl.dzien = 'Pon' THEN kl.klasa_num || kl.klasa_letter || ' ' || ncz.nazwisko ELSE '---' END) AS Poniedzialek,
        MAX(CASE WHEN pl.dzien = 'Wt' THEN kl.klasa_num || kl.klasa_letter || ' ' || ncz.nazwisko ELSE '---' END) AS Wtorek,
        MAX(CASE WHEN pl.dzien = 'Sr' THEN kl.klasa_num || kl.klasa_letter || ' ' || ncz.nazwisko ELSE '---' END) AS Sroda,
        MAX(CASE WHEN pl.dzien = 'Czw' THEN kl.klasa_num || kl.klasa_letter || ' ' || ncz.nazwisko ELSE '---' END) AS Czwartek,
        MAX(CASE WHEN pl.dzien = 'Pt' THEN kl.klasa_num || kl.klasa_letter || ' ' || ncz.nazwisko ELSE '---' END) AS Piatek
    FROM
        lekcje l
        LEFT JOIN plan pl ON l.lekcja_num = pl.lekcja_num AND (pl.sala_id = $1 OR pl.sala_id IS NULL)
        LEFT JOIN klasa kl ON pl.klasa_id = kl.klasa_id
        LEFT JOIN nauczyciel ncz ON pl.nauczyciel_id = ncz.nauczyciel_id
    GROUP BY
        l.lekcja_num
    ORDER BY
        l.lekcja_num;
END;
$$ LANGUAGE plpgsql;


--sklad klasy funkcja

CREATE OR REPLACE FUNCTION fun_sklad_klasy(INT)
RETURNS TABLE(
    nr_dziennka BIGINT,
    nazwisko VARCHAR(100),
    imie VARCHAR(100)
) AS $$
BEGIN 

    RETURN QUERY
        SELECT ROW_NUMBER() OVER (ORDER BY u.nazwisko,u.imie) AS nr_dziennika,
        u.nazwisko,
        u.imie
        FROM uczen u 
        WHERE u.klasa_id = $1
        ORDER BY u.nazwisko;
END;
$$ LANGUAGE plpgsql;


--pokaz informacje o uczniu

CREATE OR REPLACE FUNCTION fun_uczen_info(INT)
RETURNS TABLE(
    nr_dziennika BIGINT,
    nazwisko_imie TEXT,
    klasa TEXT,
    wychowawca TEXT
) AS $$
BEGIN

    IF $1 = 0 THEN
        RETURN QUERY
            SELECT ROW_NUMBER() OVER (PARTITION BY u.klasa_id ORDER BY u.nazwisko,u.imie) AS nr_dziennika, 
            u.nazwisko || ' ' || u.imie,
            kl.klasa_num || kl.klasa_letter,
            ncz.nazwisko || ' ' || ncz.imie
            FROM uczen u 
            JOIN klasa kl ON u.klasa_id = kl.klasa_id
            JOIN nauczyciel ncz ON kl.wychowawca_id = ncz.nauczyciel_id;
     END IF;

    RETURN QUERY
        SELECT ROW_NUMBER() OVER (PARTITION BY u.klasa_id ORDER BY u.nazwisko,u.imie) AS nr_dziennika, 
            u.nazwisko || ' ' || u.imie,
            kl.klasa_num || kl.klasa_letter,
            ncz.nazwisko || ' ' || ncz.imie
            FROM uczen u 
            JOIN klasa kl ON u.klasa_id = kl.klasa_id
            JOIN nauczyciel ncz ON kl.wychowawca_id = ncz.nauczyciel_id
            WHERE u.uczen_id = $1;
END;
$$ LANGUAGE plpgsql;


---dziennik klasy

CREATE OR REPLACE FUNCTION fun_dziennik(INT)
RETURNS TABLE(
    nr_dziennka BIGINT,
    nazwisko VARCHAR(100),
    imie VARCHAR(100),
    oceny TEXT
) AS $$
BEGIN 
    RETURN QUERY
        SELECT
        ROW_NUMBER() OVER (ORDER BY u.nazwisko) AS nr_dziennika,
        u.nazwisko,
        u.imie,
        string_agg(o.ocena_value::TEXT, ', ' ORDER BY o.ocena_date) AS oceny
        FROM
            uczen u
        LEFT JOIN
            ocena o ON u.uczen_id = o.uczen_id
        WHERE
            u.klasa_id = $1
        GROUP BY
            u.nazwisko, u.imie
        ORDER BY
            u.nazwisko;
END; 
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fun_nieobecnosc(INT)
RETURNS TABLE(
    nr BIGINT,
    nazwisko VARCHAR(100),
    imie VARCHAR(100),
    nr_lekcji INT,
    dzien CHAR(3),
    przedmiot VARCHAR(100),
    data DATE
) AS $$
BEGIN 
    RETURN QUERY
        SELECT
        ROW_NUMBER() OVER (ORDER BY u.nazwisko) AS nr,
        u.nazwisko,
        u.imie,
        pl.lekcja_num,
        pl.dzien,
        prz.przedmiot_name,
        n.nieobecnosc_date
        FROM
            uczen u
        LEFT JOIN
            nieobecnosc n ON u.uczen_id = n.uczen_id
        JOIN 
            plan pl ON n.lekcja_id = pl.lekcja_id
        JOIN
            przedmiot prz ON pl.przedmiot_id = prz.przedmiot_id
        WHERE
            u.uczen_id = $1
        GROUP BY
            u.nazwisko,u.imie,pl.lekcja_num,pl.dzien,prz.przedmiot_name,n.nieobecnosc_date
        ORDER BY
            n.nieobecnosc_date;
END; 
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fun_oceny(INT)
RETURNS TABLE(
    nr BIGINT,
    uczen TEXT,
    przedmiot VARCHAR(100),
    nauczyciel_wystawiajacy TEXT,
    ocena INT,
    waga INT,
    data DATE,
    komentarz VARCHAR(200)
) AS $$
BEGIN 
    RETURN QUERY
        SELECT
        ROW_NUMBER() OVER (ORDER BY o.ocena_date) AS nr,
        u.nazwisko || ' ' || u.imie,
        prz.przedmiot_name,
        ncz.nazwisko || ' ' || ncz.imie,
        o.ocena_value,
        o.ocena_weight,
        o.ocena_date,
        o.komentarz
        FROM
            uczen u
        LEFT JOIN
            ocena o ON u.uczen_id = o.uczen_id
        JOIN
            przedmiot prz ON o.przedmiot_id = prz.przedmiot_id
        JOIN 
            plan pl ON prz.przedmiot_id = pl.przedmiot_id
        JOIN 
            nauczyciel ncz ON pl.nauczyciel_id = ncz.nauczyciel_id
        WHERE
            u.uczen_id = $1 AND pl.klasa_id = u.klasa_id
        GROUP BY
            u.nazwisko,u.imie,prz.przedmiot_name,o.ocena_date,ncz.nazwisko,ncz.imie,o.ocena_value,o.ocena_weight,o.komentarz
        ORDER BY
            o.ocena_date;
END; 
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fun_oplaty_uczen(INT)
RETURNS TABLE(
    nazwisko_imie TEXT,
    semestr_1 INT,
    semestr_2 INT,
    "ubezp." INT,
    basen INT,
    wycieczka INT,
    "wyd.kulturowe" INT,
    stolowka INT,
    ferie INT,
    "lek.dodatkowe " INT,
    suma INT
) AS $$
BEGIN

        IF $1=0 THEN
            RETURN QUERY
            SELECT u.nazwisko || ' ' || u.imie AS nazwisko_imie,
                o.semestr_1, o.semestr_2, o.ubezpieczenie, o.basen, 
                o.wycieczka, o.wydarzenia_kulturowe, o.stolowka, 
                o.ferie, o.lekcje_dodatkowe, o.suma
            FROM oplaty o
            JOIN uczen u ON o.uczen_id = u.uczen_id
            ORDER BY u.nazwisko,u.imie;
        ELSE
            RETURN QUERY
            SELECT u.nazwisko || ' ' || u.imie AS nazwisko_imie,
                o.semestr_1, o.semestr_2, o.ubezpieczenie, o.basen, 
                o.wycieczka, o.wydarzenia_kulturowe, o.stolowka, 
                o.ferie, o.lekcje_dodatkowe, o.suma
            FROM oplaty o
            JOIN uczen u ON o.uczen_id = u.uczen_id
            WHERE u.uczen_id = $1;
        END IF;
    
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fun_nauczyciel_info()
RETURNS TABLE (
    nr BIGINT,
    nazwisko VARCHAR(100),
    imie VARCHAR(100),
    "Klasa wychowawcza" TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM nauczyciel_info;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fun_klasa_info()
RETURNS TABLE (
    nr BIGINT,
    klasa TEXT,
    "ilosc uczniow" BIGINT,
    wychowawca TEXT,
    "sala wychowawcza" VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM klasa_info;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION fun_sala_info()
RETURNS TABLE (
    nr BIGINT,
    "nazwa sali" VARCHAR(10),
    pojemnosc INT,
    "sala wychowawcza klasy" TEXT,
    wychowawca TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM sala_info;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fun_przedmiot_info()
RETURNS TABLE (
    nr BIGINT,
    "nazwa" VARCHAR(100),
    nauczyciel TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM przedmiot_info;
END;
$$ LANGUAGE plpgsql;


COMMENT ON FUNCTION fun_plan_klasy(INT) IS 'IDk:   Pokaz plan klasy';
COMMENT ON FUNCTION fun_dziennik(INT) IS 'IDk:   Pokaz dziennik klasy';
COMMENT ON FUNCTION fun_sklad_klasy(INT) IS 'IDk:   Pokaz uczniow klasy';
COMMENT ON FUNCTION fun_uczen_info(INT) IS 'IDu:   Pokaz informacje o uczniu o id(?)';
COMMENT ON FUNCTION fun_nieobecnosc(INT) IS 'IDu:   Pokaz nieobecnosci ucznia o id(?)';
COMMENT ON FUNCTION fun_oceny(INT) IS 'IDu:   Pokaz szczegoly ocen ucznia o id(?)';
COMMENT ON FUNCTION fun_oplaty_uczen(INT) IS 'IDu:   Pokaz oplaty ucznia o id(?)';
COMMENT ON FUNCTION fun_plan_nauczyciela(INT) IS 'IDn:   Pokaz plan nauczyciela';
COMMENT ON FUNCTION fun_plan_sali(INT) IS 'IDs:   Pokaz plan sali';
COMMENT ON FUNCTION fun_klasa_info() IS 'Pokaz klasy w szkole';
COMMENT ON FUNCTION fun_nauczyciel_info() IS 'Pokaz nauczycieli w szkole';
COMMENT ON FUNCTION fun_sala_info() IS 'Pokaz sale lekcyjne';
COMMENT ON FUNCTION fun_przedmiot_info() IS 'Pokaz prowadzne przedmioty';

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@




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







--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@


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
 




