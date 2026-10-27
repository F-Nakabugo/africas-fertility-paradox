-- ============================================================================
-- Africa's Fertility Paradox (2000–2024) | 04: Socioeconomic associations
-- ============================================================================
-- PURPOSE
--   Prepare complete-case samples for comparisons of fertility with GDP per
--   capita, female secondary gross enrollment, and urban population share.
--
-- METHODOLOGY
--   These SELECT statements do not calculate Pearson's r. The correlation
--   coefficients listed below were recorded from the Python analysis of the
--   SQL exports and still require an independent rerun for verification.
--   The primary education comparison uses 2011 due to limited 2024 coverage.
--   Correlation describes association; it does not establish causation.
-- ============================================================================

USE africa_fertility_paradox;

-- 01 | GDP per capita and fertility, 2024
-- Export: gpd_vs_fertility_2024.csv (historical filename in notebook).
SELECT
    country,
    gdp_per_capita,
    fertility_rate
FROM africa_fertility_panel
WHERE year = 2024
    AND gdp_per_capita IS NOT NULL
    AND fertility_rate IS NOT NULL
ORDER BY country ASC;

-- Identify countries excluded because their 2024 GDP is missing.
SELECT
    country,
    gdp_per_capita,
    fertility_rate
FROM africa_fertility_panel
WHERE year = 2024
    AND gdp_per_capita IS NULL
ORDER BY country ASC;

-- Compare two cross-sectional samples; this is not a longitudinal model.
-- Export: gpd_vs_fertility_2000_2024.csv.
SELECT
    country,
    year,
    gdp_per_capita,
    fertility_rate
FROM africa_fertility_panel
WHERE year IN (2000, 2024)
    AND gdp_per_capita IS NOT NULL
    AND fertility_rate IS NOT NULL
ORDER BY year ASC, country ASC;

-- 02 | Female secondary enrollment and fertility
-- Assess availability before selecting a comparison year.
SELECT
    COUNT(*) AS total_records,
    COUNT(female_secondary_enrollment) AS available_observations
FROM africa_fertility_panel
WHERE year = 2024;

SELECT
    year,
    COUNT(*) AS total_records,
    COUNT(female_secondary_enrollment) AS available_observations
FROM africa_fertility_panel
GROUP BY year
ORDER BY available_observations DESC, year ASC;

-- Export: gpd_vs_edu_2011.csv (historical filename in notebook).
SELECT
    country,
    female_secondary_enrollment,
    fertility_rate
FROM africa_fertility_panel
WHERE year = 2011
    AND fertility_rate IS NOT NULL
    AND female_secondary_enrollment IS NOT NULL
ORDER BY country ASC;

-- 03 | Urban population share and fertility
-- Export: gpd_vs_urbanization_2024.csv.
SELECT
    country,
    urban_pop_pct,
    fertility_rate
FROM africa_fertility_panel
WHERE year = 2024
    AND fertility_rate IS NOT NULL
    AND urban_pop_pct IS NOT NULL
ORDER BY country ASC;

-- Export: gpd_vs_urbanization_2000_2024.csv.
SELECT
    country,
    year,
    urban_pop_pct,
    fertility_rate
FROM africa_fertility_panel
WHERE year IN (2000, 2024)
    AND urban_pop_pct IS NOT NULL
    AND fertility_rate IS NOT NULL
ORDER BY year ASC, country ASC;

-- ============================================================================
-- RECORDED RESULTS — source analysis; pending independent reproduction
--   GDP / fertility (2024): r = -0.647, n = 52.
--   GDP / fertility (2000): r = -0.674, n = 52.
--   Female secondary gross enrollment / fertility (2011): r = -0.903, n = 37.
--   Urbanization / fertility (2024): r = -0.345, n = 54.
--   Urbanization / fertility (2000): r = -0.584, n = 54.
-- In 2024, Eritrea and South Sudan lacked GDP values in the recorded panel.
-- Female secondary enrollment covered only 14 of 54 countries in 2024,
-- compared with 37 of 54 in 2011. Interpret comparisons with care.
-- ============================================================================
