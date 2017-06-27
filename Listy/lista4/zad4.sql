--Zadanie 4 (wyzwalacze)

-- Napisz wyzwalacze, które będą pilnowały, by student zapisując się na zajęcia pomocnicze został 
-- także zapisany na wykład do przedmiotu. Przy zapisie studenta na zajęcia typu innego niż 'w', 
-- należy zapisać go także do grupy z rodzajem zajęć 'w' do tego samego przedmiotu, w tym samym 
-- semestrze (do wszystkich grup, jeśli jest ich więcej). Zwróć uwagę, by nie zapisać studenta na 
-- wykład, jeśli jest już na niego zapisany. Napisz też wyzwalacz dla sytuacji, gdy powstaje nowa 
-- grupa wykładowa, a być może wcześniej zostały otwarte grupy z innymi rodzajami zajęć do danego 
-- przedmiotu w danym semestrze - zapisz wszystkich na wykład.

-- Opisz inne zdarzenia w bazie danych, dla ktorych należałoby napisać wyzwalacz, by zachować warunek: 
-- "student musi być zapisany na wykład do przedmiotu, jeśli jest zapisany na jakiekolwiek zajęcia 
-- innego typu do tego przedmiotu".

-- 1 zapisujemy na wykład, jeśli student jeszcze się nie zapisał
CREATE OR REPLACE FUNCTION zapisz_tez_na_wyklad() RETURNS TRIGGER AS
$X$
 DECLARE 
  rz char;
  kps int;
  gw int;
 BEGIN
  -- wyszukanie rodzaju zajęć i kodu edycji przedmiotu,
  -- których dotyczy zapis
  SELECT rodzaj_zajec, kod_przed_sem INTO rz, kps
  FROM grupa WHERE kod_grupy = NEW.kod_grupy;
  -- jeśli zapis jest do grupy wykładowej, to nie ma żadnej
  -- akcji wyzwalacza
  IF (rz = 'w') THEN RETURN NEW; END IF;
  -- pętla przechodzi po wszystkich grupach wykładowych
  -- do przedmiotu, którego dotyczy wybór studenta
  FOR gw IN
   (SELECT kod_grupy
    FROM grupa
    WHERE kod_przed_sem = kps AND rodzaj_zajec='w')
  LOOP
   -- jeśli nie ma zapisu studenta do danej grupy wykładowej
   -- to zapisujemy go z takim samym czasem, jak na zajęcia
   -- pomocnicze (wziętym z NEW)
   IF NOT EXISTS(
    SELECT * 
    FROM wybor
    WHERE kod_uz= NEW.kod_uz AND kod_grupy=gw)
   THEN
    INSERT INTO wybor(kod_uz,kod_grupy,data)
    VALUES(NEW.kod_uz, gw, NEW.data);
   END IF;
  END LOOP;
  -- kończymy operacje naprawiające wyzwalacza i zwracamy
  -- niezmienioną krotkę do wstawienia do tabeli wybor
  RETURN NEW;
 END
$X$ LANGUAGE plpgsql;

CREATE TRIGGER on_insert_to_wybor AFTER INSERT ON wybor
FOR EACH ROW EXECUTE PROCEDURE zapisz_tez_na_wyklad();
-- 2 po założeniu grupy wykładowej, zapisujemy do niej wszystkich
--   zapisanych na inne zajęcia do danego przedmiotu

CREATE OR REPLACE FUNCTION zapisz_wszystkich_na_wyklad() RETURNS TRIGGER AS 
$X$
 DECLARE 
  st INT;
 BEGIN
  FOR st IN (
   (SELECT w.kod_uz
    FROM wybor w JOIN grupa g USING(kod_grupy)
    WHERE rodzaj_zajec<>'w' AND kod_przed_sem=new.kod_przed_sem
   )
   EXCEPT
   (SELECT w.kod_uz
    FROM wybor w JOIN grupa g USING(kod_grupy)
    WHERE rodzaj_zajec='w' AND kod_przed_sem=new.kod_przed_sem
   )
  )
  LOOP
         INSERT INTO wybor(kod_uz,kod_grupy,data)
            VALUES(st,new.kod_grupy,current_timestamp);
  END LOOP;
  RETURN NULL;
 END
$X$ LANGUAGE plpgsql;

CREATE TRIGGER on_insert_to_grupa AFTER INSERT ON grupa
FOR EACH ROW WHEN (NEW.rodzaj_zajec='w') EXECUTE PROCEDURE zapisz_wszystkich_na_wyklad();


-- Inne zdarzenia wymagające wyzwalaczy (lub innej reakcji):
-- UPDATE ON wybor - najlepiej zablokować tę operację,
--   w razie konieczności trzeba bedzie wybor usunąć i wpisać nowy;
   (CREATE RULE zablokuj_update_on_wybor AS ON UPDATE TO wybor
   DO INSTEAD NOTHING);
-- DELETE ON wybor - nie wolno wypisać się z wykładu, jeśli
--   pozostaje się zapisanym do innych grup; można taką operację
--   zablokować lub wyzwalaczem przywrócić zapis na wykład;
-- UPDATE ON grupa - zmiana grupy z wykładowej na niewykładową może
--   wymagać przepisania wszystkich do innej grupy wykładowej,
--   jeśli taka istnieje; możemy zablokować taką zamianę:
   CREATE RULE nie_zamieniaj_grupy_na_wykladowa
   AS ON UPDATE TO grupa
   WHERE OLD.rodzaj_zajec<>’w’ AND NEW.rodzaj_zajec=’w’
   DO INSTEAD NOTHING;
-- DELETE ON grupa - usunięcie grupy wykładowej może wymagać
--   podobnej reakcji jak UPDATE ON grupa.
