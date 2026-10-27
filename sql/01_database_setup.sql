-- ============================================================================
-- Africa's Fertility Paradox (2000–2024) | 01: Database and table preparation
-- ============================================================================
-- PURPOSE
--   Create the project database and the expected fertility table; normalize
--   selected field names in previously imported World Bank tables.
--
-- PREREQUISITES
--   The tables gdp_per_capita, female_education_raw and urban_population_raw
--   must already have been imported. The scripts provided do not contain their
--   CREATE TABLE definitions or the original data-import commands.
--
-- IMPORTANT
--   ALTER TABLE ... RENAME COLUMN must be run on the original imported schema.
--   It will fail if the specified old column names have already been renamed.
--   Inspect source columns before running. Do not rerun this setup on an
--   already-prepared database without checking its current schema.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS africa_fertility_paradox;
USE africa_fertility_paradox;

-- Confirm which database is active.
SELECT DATABASE();

-- Create the long-format fertility table when it does not yet exist.
-- Its input data must still be imported separately before analysis.
CREATE TABLE IF NOT EXISTS fertility_raw (
    country_name VARCHAR(150),
    country_code VARCHAR(3),
    indicator_name VARCHAR(150),
    indicator_code VARCHAR(30),
    year SMALLINT,
    fertility_rate DOUBLE
);

-- GDP per capita: standardize source field names after import.
-- The first source name below contains a character-encoding artifact from
-- the original CSV import. Verify it against DESCRIBE output before execution.
DESCRIBE gdp_per_capita;
SELECT *
FROM gdp_per_capita
LIMIT 10;

ALTER TABLE gdp_per_capita
    RENAME COLUMN `ï»¿Country Name` TO country_name,
    RENAME COLUMN `Country Code` TO country_code,
    RENAME COLUMN `Indicator Name` TO indicator_name,
    RENAME COLUMN `Indicator Code` TO indicator_code;

DESCRIBE gdp_per_capita;

-- Female secondary education: apply the same naming convention.
DESCRIBE female_education_raw;

ALTER TABLE female_education_raw
    RENAME COLUMN `ï»¿Country Name` TO country_name,
    RENAME COLUMN `Country Code` TO country_code,
    RENAME COLUMN `Indicator Name` TO indicator_name,
    RENAME COLUMN `Indicator Code` TO indicator_code;

-- Urban population share: apply the same naming convention.
DESCRIBE urban_population_raw;

ALTER TABLE urban_population_raw
    RENAME COLUMN `ï»¿Country Name` TO country_name,
    RENAME COLUMN `Country Code` TO country_code,
    RENAME COLUMN `Indicator Name` TO indicator_name,
    RENAME COLUMN `Indicator Code` TO indicator_code;

-- Sample rows: manual confirmation that the import and renames succeeded.
SELECT *
FROM urban_population_raw
LIMIT 10;
