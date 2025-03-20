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
    -
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
    
    SELECT dzien INTO dzien_lekcji
    FROM plan
    WHERE lekcja_id = NEW.lekcja_id;

    
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
    
    IF NOT EXISTS (
        SELECT 1
        FROM plan p
        WHERE p.lekcja_id = NEW.lekcja_id
        AND p.klasa_id = (SELECT u.klasa_id FROM uczen u WHERE u.uczen_id = NEW.uczen_id)
    ) THEN
        RAISE EXCEPTION 'Uczeń o id= % nie ma zapisanej lekcja_id =  % w swojej klasie.', NEW.uczen_id, NEW.lekcja_id;
    END IF;

    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_sprawdz_ucznia_lekcje
BEFORE INSERT ON nieobecnosc
FOR EACH ROW
EXECUTE FUNCTION trigger_fun_sprawdz_ucznia_lekcje();



