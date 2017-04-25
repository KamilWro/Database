-- Dodaj do tablei post_hascreator_person więz klucza obcego wymuszający aby wartość personid
-- odnosiła się do wartości id tabeli person.

ALTER TABLE post_hascreator_person 
 ADD CONSTRAINT fk_post_person 
 FOREIGN KEY (personid) 
 REFERENCES person (id) 
 DEFERRABLE;

