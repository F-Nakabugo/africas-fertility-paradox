-- ============================================================================
-- Africa's Fertility Paradox (2000–2024) | 02: Data-quality checks
-- ============================================================================
-- PURPOSE
--   Audit geographic and year coverage, missingness, possible invalid
--   values, duplicate keys, and match quality before building the panel.
--
-- INTERPRETATION NOTES
--   Raw World Bank tables include non-African entities. Country-limited
--   checks explicitly join to afican_countries (original table spelling).
--   Historical result summaries are recorded observations, not freshly
--   validated outputs. A SELECT client may display only 1,000 rows while a
--   subsequent COUNT confirms 1,350 joined country-year records.
-- ============================================================================

USE africa_fertility_paradox;

-- -------------------------------------------------------------------------
-- EXAMINING THE FERTILITY TABLE
-- -------------------------------------------------------------------------
-- Check 01: Geographic and temporal coverage
DESCRIBE fertility_raw;
SELECT *
FROM fertility_raw
LIMIT 10;

SELECT
    COUNT(*) AS total_observations,
    COUNT(DISTINCT country_name) AS total_countries,
    MIN(year) AS first_year,
    MAX(year) AS recent_year
FROM fertility_raw;

-- Check 02: Annual data completeness
SELECT
    country_name,
    COUNT(*) AS observation_count
FROM fertility_raw
GROUP BY country_name
HAVING COUNT(*) <> 25;

-- Check 03: Count distinct year coverage
SELECT
    country_name,
    COUNT(DISTINCT year) AS unique_years
FROM fertility_raw
GROUP BY country_name
HAVING COUNT(DISTINCT year) <> 25;

-- Check 04: Checking for missing fertility rate values
SELECT
    country_name,
    country_code,
    year,
    fertility_rate
FROM fertility_raw
WHERE fertility_rate IS NULL;

-- Check 05: Checking validity of the fertility rates (should not have negatives)
SELECT *
FROM fertility_raw
WHERE fertility_rate < 0;

-- Check 06: Checking the fertility rate range
SELECT
    MIN(fertility_rate) AS min_rate,
    MAX(fertility_rate) AS max_rate,
    AVG(fertility_rate) AS avg_rate
FROM fertility_raw;

-- Check 07: Identifying extreme values
SELECT
    country_name AS country,
    country_code AS code,
    year,
    fertility_rate
FROM fertility_raw
ORDER BY fertility_rate DESC
LIMIT 10;

-- 10 Most fertile countries (2000)
SELECT
    country_name AS country,
    country_code AS code,
    year,
    fertility_rate
FROM fertility_raw
WHERE year = 2000
ORDER BY fertility_rate DESC
LIMIT 10;

-- 10 Most fertile countries (2024)
SELECT
    country_name AS country,
    country_code AS code,
    year,
    fertility_rate
FROM fertility_raw
WHERE year = 2024
ORDER BY fertility_rate DESC
LIMIT 10;

-- -------------------------------------------------------------------------
-- EXAMINING THE GDP TABLE
-- -------------------------------------------------------------------------
-- Check 01: Geographic and temporal coverage
SELECT
    COUNT(*) AS total_observations,
    COUNT(DISTINCT country_name) AS total_countries,
    MIN(year) AS first_year,
    MAX(year) AS recent_year
FROM gdp_per_capita;

-- Check 02: Annual data completeness
SELECT
    country_name AS country,
    country_code AS code,
    COUNT(*) AS observation_count
FROM gdp_per_capita
GROUP BY
    country_name,
    country_code
HAVING COUNT(*) <> 25
ORDER BY COUNT(*) DESC;

-- GDP DATA QUALITY FINDINGS
-- Total observations: 6,359
-- Geographic entities: 261
-- Study period: 2000–2024
-- 21 entities have fewer than 25 annual observations.
-- African countries identified with incomplete coverage:
-- Djibouti: 12 observations
-- Eritrea: 12 observations
-- South Sudan: 8 observations
-- Missing values have not been imputed or replaced.

-- -------------------------------------------------------------------------
-- EDUCATION TABLE DATA QUALITY ASSESSMENT
-- -------------------------------------------------------------------------
SELECT *
FROM female_education_raw
LIMIT 10;

-- Check 01: Geographic and temporal coverage
SELECT
    COUNT(*) AS total_observations,
    COUNT(DISTINCT country_code) AS total_countries,
    MIN(year) AS first_year,
    MAX(year) AS recent_year
FROM female_education_raw;

-- Check 02: Annual data completeness
SELECT
    country_name AS country,
    country_code AS code,
    COUNT(*) AS observation_count
FROM female_education_raw
GROUP BY
    country_name,
    country_code
HAVING COUNT(*) <> 25
ORDER BY COUNT(*) DESC;

-- Education coverage diagnostic:
-- Count entities with incomplete annual coverage

SELECT
    COUNT(*) AS entities_with_incomplete_coverage
FROM (
    SELECT
        country_code,
        COUNT(*) AS observation_count
    FROM female_education_raw
    GROUP BY country_code
    HAVING COUNT(*) < 25
) AS incomplete_entities;

-- FEMALE EDUCATION DATA QUALITY FINDINGS
-- Indicator: SE.SEC.ENRR.FE
-- Study period: 2000–2024
-- Total geographic entities: 248
-- Total observations: 4,642
-- Entities with complete annual coverage: 53
-- Entities with incomplete annual coverage: 195
-- Minimum observations per entity: 1
-- Maximum observations per entity: 25
-- Overall observation coverage: approximately 74.9%
-- Missing observations have not been imputed.

-- -------------------------------------------------------------------------
-- DATA QUALITY ASSESSMENT FOR THE URBANIZATION TABLE
-- -------------------------------------------------------------------------
-- A quick look at the data
SELECT *
FROM urban_population_raw
LIMIT 10;

-- Looking at the structure of the table
DESCRIBE urban_population_raw;

-- Check 01: Geographic and temporal coverage
SELECT
    COUNT(*) AS total_observations,
    COUNT(DISTINCT country_name) AS total_countries,
    MIN(year) AS first_year,
    MAX(year) AS recent_year
FROM urban_population_raw;

-- Check 02: Annual data completeness
SELECT
    country_name AS country,
    country_code AS code,
    COUNT(*) AS observation_count
FROM urban_population_raw
GROUP BY
    country_name,
    country_code
HAVING COUNT(*) <> 25
ORDER BY COUNT(*) DESC;

-- Check 03: Missing urban pop data
SELECT
    country_name AS country,
    country_code AS code,
    year,
    urban_pop_pct
FROM urban_population_raw
WHERE urban_pop_pct IS NULL;

-- Check 04: Checking validity of the urban pop data
SELECT
    country_name AS country,
    country_code AS code,
    year,
    urban_pop_pct
FROM urban_population_raw
WHERE urban_pop_pct < 0
    OR urban_pop_pct > 100;

-- Check 05: Checking for duplicates in the urban pop data
SELECT
    country_name AS country,
    country_code AS code,
    year,
    COUNT(*)
FROM urban_population_raw
GROUP BY
    country_name,
    country_code,
    year
HAVING COUNT(*) > 1;

-- RECORDED URBANIZATION CHECK RESULTS (not independently rerun)
-- Total observations: 6,625.
-- Study period matched the intended start/end years.
-- 265 geographic entities represented (not all sovereign countries).
-- Each entity in this source extract had 25 annual rows.
-- all listed entities have urban population values for 2000–2024
-- Urban population shares were within the 0–100% range.
-- No duplicate entity-year combinations were reported.

-- -------------------------------------------------------------------------
-- DATA QUALITY ASSESSMENT FOR COUNTRY METADATA
-- -------------------------------------------------------------------------
SELECT *
FROM countries_raw
LIMIT 20;
DESCRIBE countries_raw;

-- Check 01: Geographic coverage
SELECT
    COUNT(*) AS total_observations,
    COUNT(DISTINCT country_code) AS total_country_codes,
    COUNT(DISTINCT country_name) AS total_countries,
    COUNT(DISTINCT region) AS regions,
    COUNT(DISTINCT income_group) AS total_income_groups
FROM countries_raw;

-- Check 02: Missing entities (NULL values)
SELECT
    SUM(country_code IS NULL) AS missing_country_codes,
    SUM(country_name IS NULL) AS missing_countries,
    SUM(region IS NULL) AS missing_regions,
    SUM(income_group IS NULL) AS missing_income_groups
FROM countries_raw;

-- Check 03: Blank regional and income classifications
SELECT
    country_code,
    country_name,
    region,
    income_group
FROM countries_raw
WHERE TRIM(region) = ''
   OR TRIM(income_group) = '';

-- Filtering out African countries
-- Method 01: using the Word "Africa"
SELECT
    country_name AS country,
    country_code AS code,
    region
FROM countries_raw
WHERE region LIKE '%Africa%'
ORDER BY country_name ASC;

-- RECORDED COUNTRY-METADATA FINDINGS (unverified in this review)
-- Total observations: 265
-- Distinct geographic entity codes: 265.
-- Distinct geographic entity names: 265.
-- Distinct region categories: 8.
-- Distinct income group categories: 5.
-- No SQL NULLs found, but some region and income-group values are blank.
-- Geographic entities with blank region or income group: 21.

-- -------------------------------------------------------------------------
-- EXAMINE THE AFRICAN COUNTRIES TABLE
-- -------------------------------------------------------------------------
-- Check 01: Counting the number of unique entities
SELECT
    COUNT(*) AS total_observations,
    COUNT(DISTINCT region_name) AS total_regions, -- we expect 1
    COUNT(DISTINCT country_name) AS total_countries, -- we expect 54
    COUNT(DISTINCT country_code) AS total_codes
FROM afican_countries;

-- Check 02: Verify that selected African country codes appear in World Bank metadata
SELECT
    a.country_name AS country,
    a.country_code AS code,
    a.region_name AS region,
    c.country_code AS wb_country_code
FROM afican_countries a
LEFT JOIN countries_raw c
ON a.country_code = c.country_code
WHERE c.country_code IS NULL;

-- Check 03: Inspect matches between the selected country list and metadata
SELECT
    a.country_name AS country,
    a.country_code AS code,
    a.region_name AS region,
    c.country_code AS wb_country_code
FROM afican_countries a
LEFT JOIN countries_raw c
ON a.country_code = c.country_code;

-- RECORDED COUNTRY-METADATA JOIN FINDINGS
-- All selected African country codes matched World Bank metadata.
-- The country selection table was retained as imported.

-- -------------------------------------------------------------------------
-- ASSESSING THE INDICATORS AGAINST THE AFRICAN COUNTRIES
-- DATASET
-- -------------------------------------------------------------------------
-- STEP 01: ASSESSING THE FERTILITY DATASET AGAINST AFRICA
-- -------------------------------------------------------------------------
SELECT
    a.country_name AS country,
    a.country_code AS code,
    fr.indicator_name,
    fr.indicator_code,
    fr.year,
    fr.fertility_rate
FROM afican_countries a
LEFT JOIN fertility_raw fr
ON a.country_code = fr.country_code
;                                        -- preview may be limited to 1,000 rows; use the COUNT query below

-- Counting results after joining fertility rate with African countries
SELECT
    COUNT(*) AS total_rows,
    COUNT(fr.fertility_rate) AS available_fertility_values,
    COUNT(DISTINCT fr.country_code) AS countries_with_data
FROM afican_countries a
LEFT JOIN fertility_raw fr
    ON a.country_code = fr.country_code;

-- -------------------------------------------------------------------------
-- STEP 02: ASSESSING THE GDP DATASET AGAINST AFRICA
-- -------------------------------------------------------------------------
SELECT
    a.country_name AS country,
    a.country_code AS code,
    gdp.indicator_name,
    gdp.indicator_code,
    gdp.year,
    gdp.gdp_per_capita
FROM afican_countries a
LEFT JOIN gdp_per_capita gdp
ON a.country_code = gdp.country_code;

-- Counting results after joining gdp_per_capita with African countries
SELECT
    COUNT(*) AS total_rows,
    COUNT(gdp.gdp_per_capita) AS available_gdp_values,
    COUNT(DISTINCT gdp.country_code) AS countries_with_data
FROM afican_countries a
LEFT JOIN gdp_per_capita gdp
    ON a.country_code = gdp.country_code;

-- Examine countries and years without gdp values
SELECT
    a.country_name AS country,
    a.country_code AS code,
    COUNT(gdp.year) AS available_year_rows
FROM afican_countries a
LEFT JOIN gdp_per_capita gdp
    ON a.country_code = gdp.country_code
GROUP BY
    a.country_name,
    a.country_code
HAVING COUNT(gdp.year) < 25;

-- Identify the years available for the 3 countries
SELECT
    a.country_name,
    MIN(gdp.year) AS first_year,
    MAX(gdp.year) AS last_year,
    COUNT(gdp.year) AS available_years
FROM afican_countries a
LEFT JOIN gdp_per_capita gdp
    ON a.country_code = gdp.country_code
WHERE a.country_code IN ('DJI', 'ERI', 'SSD')
GROUP BY a.country_name
ORDER BY a.country_name;

-- -------------------------------------------------------------------------
-- STEP 03: ASSESSING THE EDUCATION DATASET AGAINST AFRICA
-- -------------------------------------------------------------------------
SELECT
    a.country_name AS country,
    a.country_code AS code,
    fe.indicator_name,
    fe.indicator_code,
    fe.year,
    fe.female_secondary_enrollment
FROM afican_countries a
LEFT JOIN female_education_raw fe
ON a.country_code = fe.country_code;

-- How many countries have data for female education
-- How many records of female education do we have
SELECT
    COUNT(*) AS total_rows,
    COUNT(fe.female_secondary_enrollment) AS available_education_values,
    COUNT(DISTINCT fe.country_code) AS countries_with_data
FROM afican_countries a
LEFT JOIN female_education_raw fe
    ON a.country_code = fe.country_code;

-- Get country with completely no record on female education
SELECT
    a.country_name,
    a.country_code,
    COUNT(fe.female_secondary_enrollment) AS total_rows
FROM afican_countries a
LEFT JOIN female_education_raw fe
    ON a.country_code = fe.country_code
GROUP BY
    a.country_name,
    a.country_code
HAVING
    COUNT(fe.female_secondary_enrollment) < 1;

-- Examine education coverage by country - understand how many records per country
SELECT
    a.country_name,
    a.country_code,
    COUNT(fe.female_secondary_enrollment) AS available_observations
FROM afican_countries a
LEFT JOIN female_education_raw fe
    ON a.country_code = fe.country_code
GROUP BY
    a.country_name,
    a.country_code
ORDER BY
    COUNT(fe.female_secondary_enrollment) DESC;

-- Categorize coverage per country groups
WITH education_coverage AS (
    SELECT
    a.country_name,
    a.country_code,
    COUNT(fe.female_secondary_enrollment) AS available_years
FROM afican_countries a
LEFT JOIN female_education_raw fe
    ON a.country_code = fe.country_code
GROUP BY
    a.country_name,
    a.country_code
)

SELECT
    CASE
        WHEN available_years BETWEEN 20 AND 25 THEN 'High Coverage'
        WHEN available_years BETWEEN 15 AND 19 THEN 'Moderate Coverage'
        WHEN available_years BETWEEN 10 AND 14 THEN 'Low Coverage'
        ELSE 'Very low coverage'
    END AS coverage_category,
    COUNT(*) AS number_of_countries

FROM education_coverage
GROUP BY coverage_category
ORDER BY
    MIN(available_years) DESC;

-- Assessing temporal coverage for education data
SELECT
    fe.year,
    COUNT(DISTINCT fe.country_code) AS countries_with_data
FROM female_education_raw fe
INNER JOIN afican_countries a
    ON fe.country_code = a.country_code
WHERE fe.female_secondary_enrollment IS NOT NULL
GROUP BY fe.year
ORDER BY fe.year ASC;

-- Verify country-year uniqueness
SELECT
    fe.country_code,
    fe.year,
    COUNT(*) AS duplicate_count
FROM female_education_raw fe
INNER JOIN afican_countries a
    ON fe.country_code = a.country_code
GROUP BY
    fe.country_code,
    fe.year
HAVING COUNT(*) > 1;

-- -------------------------------------------------------------------------
-- STEP 04: ASSESSING THE URBANIZATION DATASET AGAINST AFRICA
-- -------------------------------------------------------------------------
-- Joining urbanization dataset with African countries
SELECT
    a.country_name AS country,
    a.country_code AS code,
    up.indicator_name,
    up.indicator_code,
    up.year,
    up.urban_pop_pct
FROM afican_countries a
LEFT JOIN urban_population_raw up
ON a.country_code = up.country_code;

-- How many countries have data for urbanization
-- How many records of urbanization do we have
SELECT
    COUNT(*) AS total_rows,
    COUNT(up.urban_pop_pct) AS available_urban_values,
    COUNT(DISTINCT up.country_code) AS countries_with_data
FROM afican_countries a
LEFT JOIN urban_population_raw up
    ON a.country_code = up.country_code;

-- -------------------------------------------------------------------------
-- STEP 05: COMPLETE-CASE AVAILABILITY OF ALL FOUR INDICATORS
-- -------------------------------------------------------------------------
SELECT
    a.country_name AS country,
    a.country_code AS code,
    fr.year,
    fr.fertility_rate,
    gd.gdp_per_capita,
    ub.urban_pop_pct,
    fe.female_secondary_enrollment

FROM afican_countries a
LEFT JOIN fertility_raw fr
ON a.country_code = fr.country_code
LEFT JOIN gdp_per_capita gd
    ON a.country_code = gd.country_code
    AND fr.year = gd.year
LEFT JOIN urban_population_raw ub
    ON a.country_code = ub.country_code
    AND fr.year = ub.year
LEFT JOIN female_education_raw fe
    ON a.country_code = fe.country_code
    AND fr.year = fe.year;

-- -------------------------------------------------------------------------
-- STEP 06: COMPLETE-CASE AVAILABILITY ASSESSMENT
-- -------------------------------------------------------------------------
WITH integrated_data AS (
    SELECT
        a.country_name AS country,
        a.country_code AS code,
        fr.year,
        fr.fertility_rate,
        gd.gdp_per_capita,
        ub.urban_pop_pct,
        fe.female_secondary_enrollment

    FROM afican_countries a

    LEFT JOIN fertility_raw fr
        ON a.country_code = fr.country_code

    LEFT JOIN gdp_per_capita gd
        ON a.country_code = gd.country_code
        AND fr.year = gd.year

    LEFT JOIN urban_population_raw ub
        ON a.country_code = ub.country_code
        AND fr.year = ub.year

    LEFT JOIN female_education_raw fe
        ON a.country_code = fe.country_code
        AND fr.year = fe.year
)

SELECT
    COUNT(*) AS total_observations,

    COUNT(
        CASE
            WHEN fertility_rate IS NOT NULL
             AND gdp_per_capita IS NOT NULL
             AND urban_pop_pct IS NOT NULL
             AND female_secondary_enrollment IS NOT NULL
            THEN 1
        END
    ) AS complete_cases

FROM integrated_data;

-- Checking for duplicates after the complete join of all 4 indicators
WITH integrated_data AS (
    SELECT
        a.country_name AS country,
        a.country_code AS code,
        fr.year,
        fr.fertility_rate,
        gd.gdp_per_capita,
        ub.urban_pop_pct,
        fe.female_secondary_enrollment

    FROM afican_countries a

    LEFT JOIN fertility_raw fr
        ON a.country_code = fr.country_code

    LEFT JOIN gdp_per_capita gd
        ON a.country_code = gd.country_code
        AND fr.year = gd.year

    LEFT JOIN urban_population_raw ub
        ON a.country_code = ub.country_code
        AND fr.year = ub.year

    LEFT JOIN female_education_raw fe
        ON a.country_code = fe.country_code
        AND fr.year = fe.year
)
SELECT
    code,
    year,
    COUNT(*) AS observation_count
FROM integrated_data
GROUP BY
    code,
    year
HAVING COUNT(*) > 1;

-- -------------------------------------------------------------------------
-- RECORDED COVERAGE FINDINGS (original review; not rerun here)
-- -------------------------------------------------------------------------
-- Fertility: 54 African countries x 25 years = 1,350 country-year rows.
-- GDP: 1,307 reported available values (43 fewer than the full panel).
--      Data cover 12 years for Djibouti, 12 for Eritrea, and 8 for
--      South Sudan in the original imported GDP table.
-- Female secondary education: 717 reported nonmissing country-year values
--      (~53% of the 1,350 possible); no values for Djibouti. Just 14
--      countries had >=20 years of education coverage, and 14 had data
--      in 2024.
-- These summaries reflect the historical SQL review, not a new execution.
