-- Z tabeli person usuń wszystkie osoby które napisały wiecej komentarzy niż postów
DELETE FROM person p WHERE (
 ( SELECT count(*) 
   FROM post_hascreator_person
   WHERE p.id=personid
 ) < ( 
   SELECT count(*) 
   FROM comment_hascreator_person
   WHERE p.id=personid
 )
);
