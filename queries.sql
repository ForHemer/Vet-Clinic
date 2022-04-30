/* Queries that provide answers to the questions from all projects */

/* Find all animals whose name ends in "mon" */
SELECT * from animals where name like '%mon';

/* List the name of all animals born between 2016 and 2019 */
SELECT name from animals where date_of_birth between '2016-01-01' and '2019-12-31';

/* List the name of all animals that are neutered and have less than 3 escape attempts */
SELECT name from animals where neutered = true and escape_attempts < 3;

/* List date of birth of all animals named either "Agumon" or "Pikachu" */
SELECT date_of_birth from animals where name in ('Agumon', 'Pikachu');

/* List name and escape attempts of animals that weigh more than 10.5kg */
SELECT name, escape_attempts from animals where weight_kg > 10.5;

/* Find all animals that are neutered */
SELECT * from animals where neutered = true;

/* Find all animals not named Gabumon */
SELECT * from animals where name <> 'Gabumon';

/* Find all animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg) */
SELECT * FROM animals WHERE weight_kg >= 10.4 AND weight_kg <= 17.3;

/* ************************************************************************************ */

/* Inside a transaction update the animals table by setting the species column to unspecified.
Verify that change was made. Then roll back the change and verify that species columns went back 
to the state before transaction. */
BEGIN;
UPDATE animals
SET species = 'unspecified';

SELECT name, species FROM animals;

ROLLBACK;

SELECT name, species FROM animals;

/* Update the animals table by setting the species column to digimon 
for all animals that have a name ending in mon. */
BEGIN;
UPDATE animals
SET species = 'digimon'
WHERE name LIKE '%mon';

/* Update the animals table by setting the species column to pokemon for all animals 
that don't have species already set. */
UPDATE animals
SET species = 'pokemon'
WHERE species IS NULL;

/* Commit the transaction. */
COMMIT;

/* Verify that change was made and persists after commit. */
SELECT species, name FROM animals;

/* Delete all records in the animals table */
BEGIN;
DELETE FROM animals;

/* roll back the transaction. */
ROLLBACK;

/* After the roll back verify if all records in the animals table still exist. */
SELECT * FROM animals;

/* Delete all animals born after Jan 1st, 2022. */
BEGIN;
DELETE FROM animals WHERE date_of_birth > '2022-01-01';

/* Create a savepoint for the transaction. */
SAVEPOINT SAVEPOINT_01;

/* Update all animals' weight to be their weight multiplied by -1 */
UPDATE animals
SET weight_kg = weight_kg * -1;

/* Rollback to the savepoint */
ROLLBACK TO SAVEPOINT_01;

/* Update all animals' weights that are negative to be their weight multiplied by -1 */
UPDATE animals
SET weight_kg = weight_kg * -1
WHERE weight_kg < 0;

/* Commit transaction */
COMMIT;

/* How many animals are there? */
SELECT COUNT(*) as number_of_animals FROM animals;

/* How many animals have never tried to escape? */
SELECT COUNT(*) as number_of_animals_not_tried_to_escape FROM animals
WHERE escape_attempts = 0;

/* What is the average weight of animals? */
SELECT AVG(weight_kg) as average_weight FROM animals;

/* Who escapes the most, neutered or not neutered animals? */
SELECT neutered, SUM(escape_attempts) as escape_attempted FROM animals
GROUP BY neutered;

/* What is the minimum and maximum weight of each type of animal? */
SELECT species, MIN(weight_kg) as min_weight, MAX(weight_kg) as max_weight FROM animals
GROUP BY species;

/* What is the average number of escape attempts per animal type of those born between 1990 and 2000? */
SELECT species, AVG(escape_attempts) as avergage_escape_attempted FROM animals
WHERE EXTRACT(YEAR FROM date_of_birth) BETWEEN 1990 AND 2000
GROUP BY species;

/* *******Queries using Join******* */

/* What animals belong to Melody Pond? */
SELECT animals.name
FROM animals 
INNER JOIN owners 
ON animals.owner_id = owners.id 
WHERE owners.full_name = 'Melody Pond';

/* List of all animals that are pokemon (their type is Pokemon). */
SELECT animals.name
FROM animals 
INNER JOIN species 
ON animals.species_id = species.id 
WHERE species.name = 'Pokemon';

/* List all owners and their animals, remember to include those that don't own any animal. */
SELECT owners.full_name as owner_name, animals.name as animal_name
FROM owners
LEFT JOIN animals ON owners.id = animals.owner_id;

/* How many animals are there per species? */
SELECT species.name, COUNT(animals.id)
FROM species
JOIN animals ON species.id = animals.species_id
GROUP BY species.name;

/* List all Digimon owned by Jennifer Orwell. */
SELECT animals.name as animal_name
FROM owners
JOIN animals ON owners.id = animals.owner_id
JOIN species ON species.id = animals.species_id
WHERE species.name = 'Digimon' AND owners.full_name = 'Jennifer Orwell'; 

/* List all animals owned by Dean Winchester that haven't tried to escape. */
SELECT animals.name as animal_name
FROM owners
JOIN animals ON owners.id = animals.owner_id
WHERE owners.full_name = 'Dean Winchester' AND animals.escape_attempts = 0;

/* Who owns the most animals? */
SELECT filtered name
FROM (
  SELECT owners.full_name as owner_name, COUNT(animals.id) as animals_owned 
  FROM owners
  JOIN animals ON owners.id = animals.owner_id
  GROUP BY owners.full_name
) AS filtered
WHERE filtered.animals_owned = 
  (
    SELECT MAX (filtered.animals_owned)
    FROM (
      SELECT owners.full_name as owner_name, COUNT(animals.id) as animals_owned 
      FROM owners
      JOIN animals ON owners.id = animals.owner_id
      GROUP BY owners.full_name
    ) AS filtered
);