/* Database schema to keep the structure of entire database. */
CREATE DATABASE vet_clinic;

CREATE TABLE animals(
    id INT GENERATED ALWAYS AS IDENTITY,
    name varchar(100) not null,
    date_of_birth date not null,
    escape_attempts integer,
    neutered boolean,
    weight_kg real,
    PRIMARY KEY (id)
);

/* Add colums species into animals table */
ALTER TABLE animals ADD COLUMN species varchar(100);
