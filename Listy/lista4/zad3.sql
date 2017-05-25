-- Na poprzednich zajęciach tworzyliśmy tabele, które pozwalały zapisywać studentów na praktyki. 
-- Napisz funkcję przydziel_praktyki() (bez argumentów i niezwracającą wartości), która wykona 
-- zadanie 5.6 z poprzedniej listy, czyli wypełni wszystkie wolne miejsca na praktykach studentami, 
-- którzy jeszcze nie zaliczyli praktyki i są na semestrze między 6 a 10.
CREATE OR REPLACE FUNCTION przydziel_praktyki() RETURNS VOID 
AS $X$
DECLARE osoba student;
        ofertap int;
BEGIN
  FOR osoba IN  
    SELECT *
    FROM student
    WHERE kod_uz NOT IN
      (SELECT student FROM praktyki)
      AND semestr BETWEEN 6 AND 10
  LOOP
    SELECT max(kod_oferty) INTO ofertap
    FROM oferta_praktyki
    WHERE liczba_miejsc>0;
   
    IF (ofertap IS NULL) THEN EXIT; END IF;
   
    UPDATE oferta_praktyki  
      SET liczba_miejsc=liczba_miejsc-1
    WHERE kod_oferty=ofertap;
   
    INSERT INTO praktyki(student,oferta)
      VALUES(osoba.kod_uz,ofertap);
  END LOOP;
END
$X$ LANGUAGE plpgsql;
