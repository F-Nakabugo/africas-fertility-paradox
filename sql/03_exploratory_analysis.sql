-- ============================================================================
-- Africa's Fertility Paradox (2000–2024) | 03: Fertility panel and trends
-- ============================================================================
-- PURPOSE
--   Build the reusable country-year view and examine fertility levels,
--   changes, variation, and cross-country rankings from 2000 to 2024.
--
-- PANEL DESIGN
--   Retain all 54 African countries and available fertility years by
--   starting from afican_countries and fertility_raw. Other indicators are
--   LEFT JOINed on country AND year; missing values are not imputed.
--   Summary means are UNWEIGHTED across countries, not population-weighted.
--   The table afican_countries intentionally retains its source spelling.
-- ============================================================================

USE africa_fertility_paradox;

-- Create a reusable integrated view of the four indicators.
CREATE OR REPLACE VIEW africa_fertility_panel AS
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

-- Inspect countries with all four indicators available in all 25 years.
SELECT *
FROM africa_fertility_panel
WHERE code IN (
    SELECT code
    FROM africa_fertility_panel
    GROUP BY code
    HAVING
        COUNT(DISTINCT year) = 25
        AND COUNT(fertility_rate) = 25
        AND COUNT(gdp_per_capita) = 25
        AND COUNT(urban_pop_pct) = 25
        AND COUNT(female_secondary_enrollment) = 25
)
ORDER BY country ASC;

-- -------------------------------------------------------------------------
-- 01 | Descriptive statistics for fertility, 2000–2024
-- -------------------------------------------------------------------------
-- EDA 01: Descriptive fertility statistics
-- Minimum, maximum, average, and variation in fertility rates
-- -------------------------------------------------------------------------
-- STATISTIC 01: MINIMUM FERTILITY RATE (2000–2024)
-- -------------------------------------------------------------------------
-- 1. Calculate the overall minimum fertility rate.
SELECT
    MIN(fertility_rate) AS min_fertility_rate
FROM africa_fertility_panel;

-- 2. Identify the country and year with the lowest fertility rate.
SELECT
    country,
    code,
    year
FROM africa_fertility_panel
WHERE fertility_rate = (
    SELECT MIN(fertility_rate)
    FROM africa_fertility_panel
);

-- 3. Calculate and rank the minimum fertility rate for each country.
SELECT
    country,
    code,
    MIN(fertility_rate) AS min_fertility_rate
FROM africa_fertility_panel
GROUP BY
    country,
    code
ORDER BY min_fertility_rate ASC;

-- -------------------------------------------------------------------------
-- STATISTIC 02: MAXIMUM FERTILITY RATE (2000–2024)
-- -------------------------------------------------------------------------
-- 1. Calculate the overall maximum fertility rate.
SELECT
    MAX(fertility_rate) AS max_fertility_rate
FROM africa_fertility_panel;

-- 2. Identify the country and year with the highest fertility rate.
SELECT
    country,
    code,
    year
FROM africa_fertility_panel
WHERE fertility_rate = (
    SELECT MAX(fertility_rate)
    FROM africa_fertility_panel
);

-- -------------------------------------------------------------------------
-- STATISTIC 03: AVERAGE FERTILITY RATE (2000–2024)
-- -------------------------------------------------------------------------
-- 1. Calculate the average fertility rate for 2000
SELECT
    AVG(fertility_rate) AS avg_fertility_rate_2000
FROM africa_fertility_panel
WHERE year = 2000;

-- 2. Calculate the average fertility rate for 2024
SELECT
    AVG(fertility_rate) AS avg_fertility_rate_2024
FROM africa_fertility_panel
WHERE year = 2024;

-- -------------------------------------------------------------------------
-- STATISTIC 04: VARIATION IN FERTILITY RATE (2000–2024)
-- -------------------------------------------------------------------------
-- 1. Calculate the standard deviation of fertility rates in 2000
SELECT
    STDDEV_POP(fertility_rate) AS fertility_std_dev
FROM africa_fertility_panel
WHERE year = 2000;

-- -- 2. Calculate the standard deviation of fertility rates in 2024
SELECT
    STDDEV_POP(fertility_rate) AS fertility_std_dev
FROM africa_fertility_panel
WHERE year = 2024;

-- -------------------------------------------------------------------------
-- 02 | Annual unweighted mean fertility, 2000–2024
-- Compute the average fertility rate for every year (2000-2024)
-- -------------------------------------------------------------------------
SELECT
    year,
    AVG(fertility_rate) AS avg_fertility_rate
FROM africa_fertility_panel
GROUP BY year
ORDER BY year ASC;

-- -------------------------------------------------------------------------
-- 03 | Country-level fertility changes, 2000 vs. 2024
-- -------------------------------------------------------------------------
-- Compare each country's observed fertility rate in
-- 2000 and 2024
SELECT
    country,
    code,
    year,
    fertility_rate
FROM africa_fertility_panel
WHERE year IN (2000, 2024)
ORDER BY country ASC, year ASC;

-- Compute each country's absolute change in fertility rate for
-- country
SELECT
    country,
    code,
    MAX(CASE WHEN year = 2000 THEN fertility_rate END) AS fertility_rate_2000,
    MAX(CASE WHEN year = 2024 THEN fertility_rate END) AS fertility_rate_2024,
    ROUND((
    MAX(CASE WHEN year = 2024 THEN fertility_rate END)-
    MAX(CASE WHEN year = 2000 THEN fertility_rate END)), 2) AS absolute_change
FROM africa_fertility_panel
GROUP BY
    country,
    code
ORDER BY absolute_change  ASC;

--
SELECT
    country,
    code,
    MAX(CASE WHEN year = 2000 THEN fertility_rate END) AS fertility_rate_2000,
    MAX(CASE WHEN year = 2024 THEN fertility_rate END) AS fertility_rate_2024,
    MAX(CASE WHEN year = 2024 THEN fertility_rate END)-
    MAX(CASE WHEN year = 2000 THEN fertility_rate END) AS absolute_change
FROM africa_fertility_panel
GROUP BY
    country,
    code
ORDER BY ABS(absolute_change) ASC
LIMIT 5;

-- -------------------------------------------------------------------------
-- 04 | Relative fertility changes by country
-- -------------------------------------------------------------------------
-- Examining how quickly fertility rates changed across countries
-- Check 01: Countries with the largest %changes
SELECT
    country,
    code,
    MAX(CASE WHEN year = 2000 THEN fertility_rate END) AS fertility_rate_2000,
    MAX(CASE WHEN year = 2024 THEN fertility_rate END) AS fertility_rate_2024,
    ROUND((
    (MAX(CASE WHEN year = 2024 THEN fertility_rate END)-
    MAX(CASE WHEN year = 2000 THEN fertility_rate END))
    /
    MAX(CASE WHEN year = 2000 THEN fertility_rate END)
    ),3) * 100 AS percentage_change

FROM africa_fertility_panel
GROUP BY
    country,
    code
ORDER BY percentage_change  ASC;

-- Check 02: Countries with the smallest %changes
SELECT
    country,
    code,
    MAX(CASE WHEN year = 2000 THEN fertility_rate END) AS fertility_rate_2000,
    MAX(CASE WHEN year = 2024 THEN fertility_rate END) AS fertility_rate_2024,
ROUND(
    (
        MAX(CASE WHEN year = 2024 THEN fertility_rate END) -
        MAX(CASE WHEN year = 2000 THEN fertility_rate END)
    )
    /
    MAX(CASE WHEN year = 2000 THEN fertility_rate END)
    * 100,
    2
) AS percentage_change

FROM africa_fertility_panel
GROUP BY
    country,
    code
ORDER BY percentage_change  DESC
LIMIT 5;

-- -------------------------------------------------------------------------
-- AFRICA'S FERTILITY PARADOX (2000–2024)
-- Descriptive analysis and recorded findings — SUMMARY OF FINDINGS
-- -------------------------------------------------------------------------
--
-- Finding 01: Minimum Fertility Rate
-- Mauritius recorded the lowest fertility rate among the 54 African
-- countries during 2000–2024, at 1.33 births per woman in 2022.
--
-- Finding 02: Maximum Fertility Rate
-- Niger recorded the highest fertility rate among the 54 African
-- countries during 2000–2024, at 7.829 births per woman in 2000.
--
-- Finding 03: Mean Fertility Rate
-- The mean fertility rate across 54 African countries declined from
-- 5.191 births per woman in 2000 to 3.795 in 2024, representing
-- an absolute decrease of 1.396 births per woman (26.9%).
-- This indicates a substantial decline in average fertility levels.
--
-- Finding 04: Variation in Fertility Rates
-- The standard deviation of fertility rates across 54 African countries
-- decreased from approximately 1.47 births per woman in 2000 to
-- 1.12 in 2024, representing a reduction of about 23.8%.
-- This indicates a narrowing of fertility differences between countries,
-- suggesting convergence in fertility levels over the study period.
--
-- Finding 05: Annual Fertility Trends (2000–2024)
-- The unweighted mean fertility rate across the 54 countries
-- declined consistently from approximately 5.19 births per woman in 2000
-- to about 3.80 births per woman (a reduction of 26.9%).
--
-- Finding 06: Country-Level Fertility Changes (2000–2024)
-- Between 2000 and 2024, 52 of the 54 African countries (96.3%) experienced
-- a reduction in their total fertility rates.
-- Only Algeria and the Central African Republic recorded increases of
-- approximately 0.13 and 0.10 births per woman, respectively.
--
-- Finding 07: Countries With the Largest Absolute Fertility Declines
-- South Sudan, Ethiopia, Sierra Leone, Uganda, and Burkina Faso recorded
-- the five largest absolute reductions in total fertility rates between
-- 2000 and 2024.
--
-- Finding 08: Largest Relative Fertility Declines (2000–2024)
-- Cabo Verde recorded the largest percentage reduction in fertility rates among
-- the 54 African countries, declining by approximately 57.38% between 2000 and 2024.
-- South Sudan (44.36%), Djibouti (43.10%), Sierra Leone (41.73%), and
-- Ethiopia (41.25%) followed.
-- The rankings differ from those based on absolute changes, demonstrating
-- that countries' initial fertility levels influence how the magnitude of
-- demographic change is interpreted.
--
-- Finding 09: Countries With the Smallest Relative Fertility
-- Declines or Increases (2000–2024)
-- Algeria and the Central African Republic were the only two countries to
-- record increases in fertility rates between 2000 and 2024, rising by
-- approximately 5.14% and 1.76%, respectively.
-- Among countries experiencing fertility declines, Zimbabwe (−8.36%),
-- South Africa (−8.62%), and Tunisia (−10.22%) recorded the smallest
-- percentage reductions.
--
--
-- -------------------------------------------------------------------------
