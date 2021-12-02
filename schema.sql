/* Database schema to keep the structure of entire database */

/* Part 1 */
/* Create a table named animals with the following columns:
id: integer
name: string
date_of_birth: date
escape_attempts: integer
neutered: boolean
weight_kg: decimal
*/
CREATE TABLE animals(
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  date_of_birth DATE,
  escape_attempts INT,
  neutered BOOLEAN,
  weight_kg DECIMAL
);

/* Part 2 */
/* Add a column species of type string to animals table */
ALTER TABLE animals ADD COLUMN species VARCHAR(100);

/* Part 3 */
/* Create a table named owners with the following columns:
id: integer (set it as autoincremented PRIMARY KEY)
full_name: string
age: integer
*/
CREATE TABLE owners(
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(100),
  age INT
);

/* Create a table named species with the following columns:
id: integer (set it as autoincremented PRIMARY KEY)
name: string
*/
CREATE TABLE species(
  id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);

/* Modify animals table:
Make sure that id is set as autoincremented PRIMARY KEY
Remove column species
Add column species_id which is a foreign key referencing species table
Add column owner_id which is a foreign key referencing the owners table
*/
ALTER TABLE animals DROP COLUMN species;
ALTER TABLE animals ADD species_id INT;
ALTER TABLE animals ADD owner_id INT;
ALTER TABLE animals ADD FOREIGN KEY (species_id) REFERENCES species(id);
ALTER TABLE animals ADD FOREIGN KEY (owner_id) REFERENCES owners(id);

/* Part 4 */
/* Create a table named vets with the following columns:
id: integer (set it as autoincremented PRIMARY KEY)
name: string
age: integer
date_of_graduation: date
*/
CREATE TABLE vets(
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  age INT,
  date_of_graduation DATE
);

/* There is a many-to-many relationship between the tables species and vets: a vet can specialize
in multiple species, and a species can have multiple vets specialized in it. Create a "join table"
called specializations to handle this relationship.
*/
CREATE TABLE specializations(
  species_id INT REFERENCES species(id),
  vet_id INT REFERENCES vets(id)
);

/* There is a many-to-many relationship between the tables animals and vets: an animal can visit
multiple vets and one vet can be visited by multiple animals. Create a "join table" called visits
to handle this relationship, it should also keep track of the date of the visit.
*/
CREATE TABLE visits (
  animal_id INT REFERENCES animals(id),
  vet_id INT REFERENCES vets(id),
  date_of_visit DATE
);
