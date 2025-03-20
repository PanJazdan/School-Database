
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
        LEFT JOIN nauczyciel_przedmiot np ON pl.ncz_prz_id = np.ncz_prz_id
        JOIN przedmiot prz on np.przedmiot_id = prz.przedmiot_id
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
),
plan_lekcji AS (
    SELECT 
        p.lekcja_num,
        p.dzien,
        k.klasa_num,
        k.klasa_letter,
        s.sala_name
    FROM plan p
    JOIN klasa k ON p.klasa_id = k.klasa_id
    JOIN nauczyciel_przedmiot np ON p.ncz_prz_id = np.ncz_prz_id
    JOIN sala s ON p.sala_id = s.sala_id
    WHERE np.nauczyciel_id = $1 
)
SELECT
    l.lekcja_num AS numer_lekcji,
    MAX(CASE WHEN pl.dzien = 'Pon' THEN pl.klasa_num || pl.klasa_letter || ' '  || pl.sala_name ELSE '---' END) AS Poniedzialek,
    MAX(CASE WHEN pl.dzien = 'Wt' THEN pl.klasa_num || pl.klasa_letter || ' '  || pl.sala_name ELSE '---' END) AS Wtorek,
    MAX(CASE WHEN pl.dzien = 'Sr' THEN pl.klasa_num || pl.klasa_letter || ' '  || pl.sala_name ELSE '---' END) AS Sroda,
    MAX(CASE WHEN pl.dzien = 'Czw' THEN pl.klasa_num || pl.klasa_letter || ' '  || pl.sala_name ELSE '---' END) AS Czwartek,
    MAX(CASE WHEN pl.dzien = 'Pt' THEN pl.klasa_num || pl.klasa_letter || ' '  || pl.sala_name ELSE '---' END) AS Piatek
FROM lekcje l
LEFT JOIN plan_lekcji pl
    ON l.lekcja_num = pl.lekcja_num
GROUP BY l.lekcja_num
ORDER BY l.lekcja_num;

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
        LEFT JOIN nauczyciel_przedmiot np ON pl.ncz_prz_id = np.ncz_prz_id
        LEFT JOIN nauczyciel ncz ON np.nauczyciel_id = ncz.nauczyciel_id
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

CREATE OR REPLACE FUNCTION  fun_dziennik(INT, INT)
RETURNS TABLE (
    nr BIGINT,
    imie_nazwisko TEXT,
    nauczyciel TEXT,
    oceny TEXT,
    srednia FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ROW_NUMBER() OVER (ORDER BY u.nazwisko, u.imie) AS nr,
        u.imie || ' ' || u.nazwisko AS imie_nazwisko,
        (SELECT DISTINCT ncz.imie || ' ' || ncz.nazwisko
         FROM nauczyciel ncz
         JOIN nauczyciel_przedmiot np ON ncz.nauczyciel_id = np.nauczyciel_id
         JOIN plan p ON np.ncz_prz_id = p.ncz_prz_id
         WHERE p.klasa_id = $1 
           AND np.przedmiot_id = $2
         LIMIT 1) AS nauczyciel,
        (SELECT STRING_AGG(o.ocena_value::TEXT, ', ' ORDER BY o.ocena_date) 
         FROM ocena o
         JOIN nauczyciel_przedmiot np ON o.ncz_prz_id = np.ncz_prz_id
         WHERE o.uczen_id = u.uczen_id
           AND np.przedmiot_id = $2
        ) AS oceny,
        licz_srednia(u.uczen_id, $2)
    FROM uczen u
    WHERE u.klasa_id = $1
    ORDER BY u.nazwisko, u.imie;
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
            nauczyciel_przedmiot np ON pl.ncz_prz_id=np.ncz_prz_id
        JOIN
            przedmiot prz ON np.przedmiot_id = prz.przedmiot_id
        WHERE
            u.uczen_id = $1
        GROUP BY
            u.nazwisko,u.imie,pl.lekcja_num,pl.dzien,prz.przedmiot_name,n.nieobecnosc_date
        ORDER BY
            n.nieobecnosc_date;
END; 
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fun_oceny(
    INT,    -- ID ucznia
    INT -- ID przedmiotu
)
RETURNS TABLE (
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
        u.nazwisko || ' ' || u.imie AS uczen,
        p.przedmiot_name AS przedmiot,
        n.imie || ' ' || n.nazwisko AS nauczyciel_wystawiajacy,
        o.ocena_value AS ocena,
        o.ocena_weight AS waga,
        o.ocena_date AS data,
        o.komentarz
    FROM ocena o
    JOIN uczen u ON o.uczen_id = u.uczen_id
    JOIN nauczyciel_przedmiot np ON o.ncz_prz_id = np.ncz_prz_id
    JOIN nauczyciel n ON np.nauczyciel_id = n.nauczyciel_id
    JOIN przedmiot p ON np.przedmiot_id = p.przedmiot_id
    WHERE o.uczen_id = $1
      AND p.przedmiot_id = $2
      AND o.ocena_value IS NOT NULL
    ORDER BY o.ocena_date;
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

CREATE OR REPLACE FUNCTION licz_srednia(INT, INT)
RETURNS FLOAT AS $$
DECLARE
    sum FLOAT :=0;
    val FLOAT :=0;
    waga FLOAT :=0;
    sum_waga FLOAT :=0;
    rec RECORD;
BEGIN
    FOR rec IN (SELECT o.ocena_value AS val, o.ocena_weight AS waga 
                FROM ocena o JOIN nauczyciel_przedmiot np ON o.ncz_prz_id = np.ncz_prz_id
                WHERE o.uczen_id = $1 AND np.przedmiot_id = $2) 
        LOOP
        val:= rec.val;
        waga:= rec.waga;
        sum_waga := waga + sum_waga;
        sum := val*waga + sum;
        END LOOP;
        IF(sum_waga = 0) THEN
            sum := 0;
        ELSE
            sum := sum/sum_waga;
        END IF;
    RETURN sum;
END;
$$ LANGUAGE plpgsql;



COMMENT ON FUNCTION fun_plan_klasy(INT) IS 'IDk:   Pokaz plan klasy';
COMMENT ON FUNCTION fun_dziennik(INT,INT) IS 'IDkIDp:   Pokaz dziennik klasy';
COMMENT ON FUNCTION fun_sklad_klasy(INT) IS 'IDk:   Pokaz uczniow klasy';
COMMENT ON FUNCTION fun_uczen_info(INT) IS 'IDu:   Pokaz informacje o uczniu';
COMMENT ON FUNCTION fun_nieobecnosc(INT) IS 'IDu:   Pokaz nieobecnosci ucznia';
COMMENT ON FUNCTION fun_oceny(INT,INT) IS 'IDuIDp:   Pokaz szczegoly ocen ucznia';
COMMENT ON FUNCTION fun_plan_nauczyciela(INT) IS 'IDn:   Pokaz plan nauczyciela';
COMMENT ON FUNCTION fun_plan_sali(INT) IS 'IDs:   Pokaz plan sali';
COMMENT ON FUNCTION fun_klasa_info() IS 'Pokaz klasy w szkole';
COMMENT ON FUNCTION fun_nauczyciel_info() IS 'Pokaz nauczycieli w szkole';
COMMENT ON FUNCTION fun_sala_info() IS 'Pokaz sale lekcyjne';
COMMENT ON FUNCTION fun_przedmiot_info() IS 'Pokaz prowadzne przedmioty';

