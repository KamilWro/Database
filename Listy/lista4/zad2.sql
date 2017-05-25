-- Napisz funkcję plan_zajec_prac(int,int) - pierwszy argument
-- to kod pracownika, a drugi, to kod semestru. Funkcja ma
-- zwracać wszystkie zajęcia danego pracownika w danym
-- semestrze wraz z nazwą przedmiotu, rodzajem zajęć, terminem,
-- salą i liczbą osób zapisanych na zajęcia. Zobacz plan zajęć
-- użytkownika 187 w semestrze 39.

CREATE TYPE plan_zajec_typ AS (
  nazwa text,
  rodzaj_zajec char,
  termin text,
  sala text,
  liczba_osob int);
  
CREATE FUNCTION plan_zajec_prac(int, int)
  RETURNS SETOF plan_zajec_typ
AS $X$
  SELECT
    p.nazwa, g.rodzaj_zajec, g.termin::text,g.sala::text,COUNT(*)::int
  FROM grupa g
    JOIN przedmiot_semestr USING(kod_przed_sem)
    JOIN przedmiot p USING(kod_przed)
    JOIN wybor USING (kod_grupy)
    JOIN semestr s USING (semestr_id)
  WHERE g.kod_uz=$1
    AND s.semestr_id=$2
  GROUP BY p.nazwa, g.rodzaj_zajec, g.termin, g.sala;
$X$ LANGUAGE SQL;

SELECT plan_zajec_prac(187,39);
