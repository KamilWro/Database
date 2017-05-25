-- Napisz funkcję SQL pierwszy_zapis(int,int), która dla zadanych jako argumenty kodu użytkownika 
-- oraz numeru semestru, poda czas najwcześniejszego zapisu na zajęcia tego użytkownika w tym semestrze.

CREATE FUNCTION pierwszy_zapis(int,int)
  RETURNS wybor.data%TYPE 
AS $X$
  SELECT min(data)
  FROM wybor
    JOIN grupa USING(kod_grupy)
    JOIN przedmiot_semestr USING(kod_przed_sem)
  WHERE wybor.kod_uz=$1 AND semestr_id=$2;
$X$ LANGUAGE SQL IMMUTABLE;

-- Wykorzystaj funkcję pierwszy_zapis, by podać nazwiska
-- wszystkich osób o nazwisku na ‘A’, które zapisały się 
-- na jakieś zajęcia w ‘’Semestrze zimowym 2010/2011’’ wraz 
-- z czasem ich pierwszego zapisu w tym semestrze. Posortuj
-- wynik rosnąco według czasu i usuń z niego powtórzenia, 
-- jeśli to potrzebne.
SELECT u.nazwisko,pierwszy_zapis(u.kod_uz,s.semestr_id)
FROM student u 
  JOIN wybor w USING (kod_uz)
  JOIN grupa g USING (kod_grupy)
  JOIN przedmiot_semestr ps USING (kod_przed_sem)
  JOIN semestr s USING (semestr_id)  
WHERE s.rok='2010/2011' 
  AND s.semestr='zimowy'
  AND u.nazwisko LIKE 'A%'
ORDER BY 2;
