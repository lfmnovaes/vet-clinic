/* Queries that provide answers to the questions from all projects */
/* Part 1 */

/* Find all animals whose name ends in "mon". */
SELECT * FROM animals WHERE name LIKE '%mon';

/* List the name of all animals born between 2016 and 2019. */
SELECT name FROM animals WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-12-31';

/* List the name of all animals that are neutered and have less than 3 escape attempts. */
SELECT name FROM animals WHERE neutered = TRUE AND escape_attempts < 3;

/* List date of birth of all animals named either "Agumon" or "Pikachu". */
SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');

/* List name and escape attempts of animals that weigh more than 10.5kg */
SELECT name FROM animals WHERE weight_kg > 10.5;

/* Find all animals that are neutered. */
SELECT * FROM animals WHERE neutered = TRUE;

/* Find all animals not named Gabumon. */
SELECT * FROM animals WHERE name != 'Gabumon';

/* Find all animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg) */
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

/* Part 2 */

/* Inside a transaction update the animals table by setting the species column to unspecified. Verify that change was made. Then roll back the change and verify that species columns went back to the state before transaction. */
BEGIN;
UPDATE animals SET species = 'unspecified';
SELECT species FROM animals;
ROLLBACK;
SELECT species FROM animals;

/* Inside a transaction:
- Update the animals table by setting the species column to digimon for all animals that have a name ending in mon.
- Update the animals table by setting the species column to pokemon for all animals that don't have species already set.
- Commit the transaction.
- Verify that change was made and persists after commit.
*/
BEGIN;
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals SET species = 'pokemon' WHERE species IS NULL;
COMMIT;
SELECT * FROM animals;

/* Inside a transaction delete all records in the animals table, then roll back the transaction. */
BEGIN;
DELETE FROM animals;
ROLLBACK;

/* After the roll back verify if all records in the animals table still exist. */
SELECT * FROM animals;

/* Inside a transaction:
- Delete all animals born after Jan 1st, 2022.
- Create a savepoint for the transaction.
- Update all animals' weight to be their weight multiplied by -1.
- Rollback to the savepoint
- Update all animals' weights that are negative to be their weight multiplied by -1.
- Commit transaction
*/
BEGIN;
DELETE FROM animals WHERE date_of_birth > '2022-01-01';
SAVEPOINT delete_based_birth;
UPDATE animals SET weight_kg = (weight_kg * -1);
ROLLBACK TO SAVEPOINT delete_based_birth;
UPDATE animals SET weight_kg = (weight_kg * -1) WHERE weight_kg < 0;
COMMIT;

/* Write queries to answer the following questions: */
-- How many animals are there?
SELECT COUNT(*) FROM animals;
-- How many animals have never tried to escape?
SELECT COUNT(*) FROM animals WHERE escape_attempts = 0;
-- What is the average weight of animals?
SELECT AVG(weight_kg) FROM animals;
-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) FROM animals GROUP BY neutered;
-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY species;
-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) FROM animals WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31' GROUP BY species;

/* Part 3 */
/* Write queries (using JOIN) to answer the following questions: */
-- What animals belong to Melody Pond?
SELECT animals.name FROM animals JOIN owners ON owner_id = owners.id WHERE owners.full_name = 'Melody Pond';
-- List of all animals that are pokemon (their type is Pokemon).
SELECT animals.name FROM animals JOIN species ON species.id = animals.species_id WHERE species.name = 'Pokemon';
-- List all owners and their animals, remember to include those that don't own any animal.
SELECT owners.full_name, animals.name FROM owners LEFT JOIN animals ON animals.owner_id = owners.id;
-- How many animals are there per species?
SELECT species.name, COUNT(*) FROM animals FULL OUTER JOIN species ON species.id = animals.species_id GROUP BY species.id;
-- List all Digimon owned by Jennifer Orwell.
SELECT animals.name, owners.full_name FROM animals JOIN owners ON owners.id = animals.owner_id 
  JOIN species ON species.id = animals.species_id WHERE owners.full_name = 'Jennifer Orwell' AND species.name = 'Digimon';
-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT animals.name, animals.escape_attempts, full_name FROM animals RIGHT JOIN owners ON owners.id = animals.owner_id WHERE escape_attempts = 0 AND full_name = 'Dean Winchester';
-- Who owns the most animals?
SELECT owners.full_name, COUNT(animals.owner_id) FROM animals FULL OUTER JOIN owners ON animals.owner_id = owners.id GROUP BY owners.id ORDER BY count DESC LIMIT 1;

/* Part 4 */
/* Write queries to answer the following: */
-- Who was the last animal seen by William Tatcher?
SELECT animals.name, visits.date_of_visit FROM animals JOIN visits ON animals.id = visits.animal_id
  WHERE visits.vet_id = (SELECT id FROM vets WHERE name = 'William Tatcher') ORDER BY visits.date_of_visit DESC LIMIT 1;
-- How many different animals did Stephanie Mendez see?
SELECT COUNT(DISTINCT animals.name) FROM animals JOIN visits ON animals.id = visits.animal_id
  WHERE visits.vet_id = (SELECT id FROM vets WHERE name = 'Stephanie Mendez');
-- List all vets and their specialties, including vets with no specialties.
SELECT vets.name, specializations.species_id FROM vets LEFT JOIN specializations ON vets.id = specializations.vet_id
  JOIN species ON specializations.species_id = species.id ORDER BY vets.name;
-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT animals.name, visits.date_of_visit FROM animals JOIN visits ON animals.id = visits.animal_id
  WHERE visits.vet_id = (SELECT id FROM vets WHERE name = 'Stephanie Mendez')
  AND visits.date_of_visit BETWEEN '2020-04-01' AND '2020-08-30';
-- What animal has the most visits to vets?
SELECT animals.name, COUNT(*) FROM animals LEFT JOIN visits ON animals.id = visits.animal_id
  GROUP BY animals.name ORDER BY count DESC LIMIT 1;
-- Who was Maisy Smith's first visit?
SELECT animals.name, owners.full_name FROM animals JOIN visits ON animals.id = visits.animal_id
  JOIN owners ON owners.id = animals.owner_id
  WHERE visits.vet_id = (SELECT id FROM vets WHERE name = 'Maisy Smith') ORDER BY visits.date_of_visit ASC LIMIT 1;
-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT animals.*, vets.*, visits.date_of_visit FROM animals JOIN visits ON animals.id = visits.animal_id
  JOIN vets ON visits.vet_id = vets.id ORDER BY visits.date_of_visit DESC LIMIT 1;
-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*) FROM visits JOIN vets ON vets.id = visits.vet_id
  JOIN animals ON animals.id = visits.animal_id
  JOIN specializations ON specializations.vet_id = vets.id
  WHERE specializations.species_id != animals.species_id;
-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT species.name, COUNT(visits.animal_id) FROM visits JOIN vets ON vets.id = visits.vet_id
  JOIN animals ON animals.id = visits.animal_id
  JOIN species ON species.id = animals.species_id
  WHERE vets.name = 'Maisy Smith' GROUP BY species.name ORDER BY count DESC LIMIT 1;
