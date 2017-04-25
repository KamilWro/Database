-- Wypełnij tabelę student danymi o wszystkich osobach, o których wspomina relacja person_studyat_organisation.
-- Atrybuty personid, firstname, lastname, powinny przyjąć wartości odpowiednich atrybutów tablei person.
-- Jako wartość atrybutu university ustaw nazwę organizjacji, na której dana osoba studiowała (atrybut
-- name tabeli organisation). Dla każdej osoby dodaj tyle krotek ile razy dana osoba jest wspomniana 
-- w tabeli person_studyat_organisation.

INSERT INTO student
 (
 SELECT p.id, p.firstname,p.lastname, o.name
 FROM person_studyat_organisation s
  JOIN person p ON ( p.id=s.personid )
  JOIN organisation o ON (s.organisationid=o.id)
 );

