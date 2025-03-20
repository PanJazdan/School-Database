
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




