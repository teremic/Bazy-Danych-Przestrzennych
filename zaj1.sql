-- Punkty 1 i 2 wykonałem klikjąc po PG_Adminie
-- 3
SET search_path TO ksiegowosc;

CREATE TABLE IF NOT EXISTS pracownicy(
	id_pracownika SERIAL PRIMARY KEY,
	imie VARCHAR(50),
	nazwisko VARCHAR(50),
	adres VARCHAR(50),
	telefon INT
);

COMMENT ON TABLE pracownicy IS 'Tabela przechowuje dane o pracownikach zatrudnionych w firmie.';
COMMENT ON COLUMN pracownicy.id_pracownika IS 'Kolumna przechowuje unikalny identyfikator pracownika';
COMMENT ON COLUMN pracownicy.imie IS 'Kolumna przechowuje imie pracownika';
COMMENT ON COLUMN pracownicy.nazwisko IS 'Kolumna przechowuje nazwisko pracownika';
COMMENT ON COLUMN pracownicy.adres IS 'Kolumna przechowuje sluzbowy adres e-mail pracownika z koncowka: @frima.gmail.com pracownika';
COMMENT ON COLUMN pracownicy.telefon IS 'Kolumna przechowuje sluzbowy numer telefonu pracownika';

CREATE TABLE IF NOT EXISTS godziny(
	id_godziny SERIAL PRIMARY KEY,
	data DATE,
	liczba_godzin NUMERIC,
	id_pracownika INT,
	FOREIGN KEY (id_pracownika) REFERENCES pracownicy(id_pracownika)
);

COMMENT ON TABLE godziny IS 'Tabela przechowuje dane o miesiecznej ilości przepracowanych godzin kazdego pracownika firmy.';
COMMENT ON COLUMN godziny.id_godziny IS 'Kolumna przechowuje unikalny identyfikator zarejestrowanych godzin danego pracownika w danym miesiacu';
COMMENT ON COLUMN godziny.liczba_godzin IS 'Kolumna przechowuje liczbe przepracowanych godzin w miesiacu';
COMMENT ON COLUMN godziny.id_pracownika IS 'Kolumna przechowuje unikalny identyfikator pracownika, ktorego dotyczy rekord';

CREATE TABLE IF NOT EXISTS pensja(
	id_pensji SERIAL PRIMARY KEY,
	stanowisko VARCHAR(50),
	kwota NUMERIC
);

COMMENT ON TABLE pensja IS 'Tabela przechowuje dane o wysokosci pensji na danym stanowisku.';
COMMENT ON COLUMN pensja.id_pensji IS 'Kolumna przechowuje unikalny identyfikator pensji na danym stanowisku';
COMMENT ON COLUMN pensja.stanowisko IS 'Kolumna przechowuje nazwe stanowiska';
COMMENT ON COLUMN pensja.kwota IS 'Kolumna przechowuje kwote pensji na stanowisku';

CREATE TABLE IF NOT EXISTS premia(
	id_premii SERIAL PRIMARY KEY,
	rodzaj VARCHAR(50),
	kwota NUMERIC
);

COMMENT ON TABLE premia IS 'Tabela przechowuje dane o wysokosci premii roznych rodzajow.';
COMMENT ON COLUMN premia.id_premii IS 'Kolumna przechowuje unikalny identyfikator rodzaju premii';
COMMENT ON COLUMN premia.rodzaj IS 'Kolumna przechowuje rodzaj premii';
COMMENT ON COLUMN premia.kwota IS 'Kolumna przechowuje kwote premii';

CREATE TABLE IF NOT EXISTS wynagrodzenie(
	id_wynagrodzenia SERIAL PRIMARY KEY,
	data DATE,
	id_pracownika INT,
	id_godziny INT,
	id_pensji INT,
	id_premii INT,
	FOREIGN KEY (id_pracownika) REFERENCES pracownicy(id_pracownika),
	FOREIGN KEY (id_godziny) REFERENCES godziny(id_godziny),
	FOREIGN KEY (id_pensji) REFERENCES pensja(id_pensji),
	FOREIGN KEY (id_premii) REFERENCES premia(id_premii)
);

COMMENT ON TABLE wynagrodzenie IS 'Tabela przechowuje dane o wysokosci miesiecznego wynagrodzenia dla danego pracownika.';
COMMENT ON COLUMN wynagrodzenie.id_wynagrodzenia IS 'Kolumna przechowuje unikalny identyfikator wynagrodzenia';
COMMENT ON COLUMN wynagrodzenie.data IS 'Kolumna przechowuje miesiac, za ktory jest wynagrodzenie';
COMMENT ON COLUMN wynagrodzenie.id_pracownika IS 'Kolumna przechowuje identyfikator pracownika';
COMMENT ON COLUMN wynagrodzenie.id_godziny IS 'Kolumna przechowuje identyfikator rekordu godzin w tebeli godziny';
COMMENT ON COLUMN wynagrodzenie.id_pensji IS 'Kolumna przechowuje identyfikator pensji dla stanowiska pracownika';
COMMENT ON COLUMN wynagrodzenie.id_premii IS 'Kolumna przechowuje identyfikator premii, ktora otrzymal pracownik';

-- 4
-- J na początku imienia
-- Nazwisko zawiera n i kończy się na a
INSERT INTO pracownicy(imie, nazwisko, adres, telefon) VALUES
	('Jan', 'Polana', 'jpolana', 123456789),
	('Jakub', 'Nowak', 'jnowak', 928452789),
	('Łucja', 'Kowalska', 'lkowalska', 723356581),
	('Anna', 'Nowakowska', 'anowakowska', 143476282),
	('Janina', 'Dzwon', 'jdzwon', 463426182),
	('Mariusz', 'Karski', 'mkarski', 143456292),
	('Lucjan', 'Kosan', 'lkosan', 153076282),
	('Antonia', 'Lancka', 'alancka', 142406212),
	('Jadwiga', 'Wilk', 'jwilk', 542476282),
	('Michał', 'Tracz', 'mtracz', 143976381);

-- liczba nadgodzin
-- były nadgodziny a premii nie
INSERT INTO godziny(data, liczba_godzin, id_pracownika) VALUES
	('2024-07-31', 160, 1),
	('2024-07-31', 168, 2),
	('2024-07-31', 160, 3),
	('2024-07-31', 160, 4),
	('2024-07-31', 162, 5),
	('2024-07-31', 170, 6),
	('2024-07-31', 180, 7),
	('2024-07-31', 160, 8),
	('2024-07-31', 165, 9),
	('2024-07-31', 168, 10);

-- płaca > 1000
-- płaca > 2000 i brak premii
-- pensja 1500-3000
-- stanowisko kierownik
-- pensja < 1200
INSERT INTO pensja(stanowisko, kwota) VALUES
	('kierownik', 5000),
	('dyrektor', 10000),
	('sekretarz', 2100),
	('analityk', 2500),
	('portier', 1600),
	('sprzątacz', 1100),
	('informatyk', 2500),
	('stażysta', 500),
	('prezes', 30000),
	('tester', 2000);

INSERT INTO premia(rodzaj, kwota) VALUES
	('25-lecie', 5000),
	('20-lecie', 4500),
	('15-lecie', 4000),
	('10-lecie', 3500),
	('5-lecie', 3000),
	('roczna', 2000),
	('pracownik miesiąca', 1000),
	('świąteczna', 800),
	('uznaniowa', 500),
	('brak', 0);
	
-- płaca > 2000 i brak premii
-- były nadgodziny a premii nie
INSERT INTO wynagrodzenie(data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
	('2024-07-31', 1, 1, 1, 5),
	('2024-07-31', 2, 2, 4, 10),
	('2024-07-31', 3, 3, 4, 5),
	('2024-07-31', 4, 4, 2, 6),
	('2024-07-31', 5, 5, 10, 9),
	('2024-07-31', 6, 6, 6, 10),
	('2024-07-31', 7, 7, 5, 6),
	('2024-07-31', 8, 8, 8, 10),
	('2024-07-31', 9, 9, 1, 5),
	('2024-07-31', 10, 10, 7, 10);

-- 5
-- a)
SELECT id_pracownika, nazwisko
FROM pracownicy;

-- b)
SELECT a.id_pracownika
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
WHERE b.kwota > 1000;

-- c)
SELECT a.id_pracownika
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
WHERE b.kwota > 2000 AND a.id_premii = 10;

-- d)
SELECT *
FROM pracownicy
WHERE imie LIKE 'J%';

-- e)
SELECT *
FROM pracownicy
WHERE nazwisko LIKE '%n%a';

-- f)
SELECT a.imie, a.nazwisko, b.liczba_godzin - 160 AS liczba_nadgodzin
FROM pracownicy AS a
LEFT JOIN godziny AS b ON a.id_pracownika = b.id_pracownika;

-- g)
SELECT c.imie, c.nazwisko
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
LEFT JOIN pracownicy AS c ON a.id_pracownika = c.id_pracownika
WHERE b.kwota BETWEEN 1500 AND 3000;

-- h)
SELECT c.imie, c.nazwisko
FROM wynagrodzenie AS a
LEFT JOIN godziny AS b ON a.id_godziny = b.id_godziny
LEFT JOIN pracownicy AS c ON a.id_pracownika = c.id_pracownika
WHERE liczba_godzin > 160 AND a.id_premii = 10;

-- i)
SELECT c.imie, c.nazwisko, b.kwota
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
LEFT JOIN pracownicy AS c ON a.id_pracownika = c.id_pracownika
ORDER BY b.kwota DESC;

-- j)
SELECT c.imie, c.nazwisko, b.kwota AS pensja, d.kwota AS premia
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
LEFT JOIN pracownicy AS c ON a.id_pracownika = c.id_pracownika
LEFT JOIN premia AS d ON a.id_premii = d.id_premii
ORDER BY b.kwota DESC, d.kwota DESC;

-- k)
SELECT b.stanowisko, COUNT(b.stanowisko)
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
GROUP BY b.stanowisko;

-- l)
SELECT MIN(kwota), MAX(kwota), AVG(kwota)
FROM pensja
WHERE stanowisko = 'kierownik';

-- m)
SELECT SUM(b.kwota)
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji;

-- n)
SELECT SUM(b.kwota)
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
WHERE b.stanowisko = 'kierownik';

-- o)
SELECT b.stanowisko, COUNT(c.kwota)
FROM wynagrodzenie AS a
LEFT JOIN pensja AS b ON a.id_pensji = b.id_pensji
LEFT JOIN premia AS c ON a.id_premii = c.id_premii
WHERE a.id_premii < 10
GROUP BY b.stanowisko;

-- p) Tutaj nie wiem jak pozbyć się danych z pozostałych powiązanych tabel
DELETE FROM pracownicy AS a
USING pensja AS b, wynagrodzenie AS c
WHERE a.id_pracownika = c.id_pracownika AND b.id_pensji = c.id_pensji AND b.kwota < 1200;


