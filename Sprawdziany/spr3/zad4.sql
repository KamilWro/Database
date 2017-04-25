-- Użyj polecenia UPDATE aby nadać kolumnie posts wartość równą liczbie postów napisanych przez danego
-- użytkownika (wg post_hascreator_person)
UPDATE person s 
 SET posts=
 (SELECT COUNT(*) 
  FROM post_hascreator_person p
  WHERE p.personid=s.id
  GROUP BY p.personid
 );
 
UPDATE person 
 SET posts = 0 
 WHERE posts is NULL;
