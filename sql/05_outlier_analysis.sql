-- ============================================================================
-- Africa's Fertility Paradox (2000–2024) | 05: GDP-peer outliers, 2024
-- ============================================================================
-- RESEARCH QUESTION
--   Which countries have unusually high or low fertility compared with peers
--   having similar GDP per capita in 2024?
--
-- METHOD
--   Use the 52 countries with both 2024 GDP and fertility observations.
--   Rank by GDP per capita and split into NTILE(3) peer groups (18, 17, 17).
--   Within each group compute z = (fertility - group mean) / group SD,
--   where SD is the population standard deviation (STDDEV_POP).
--   Flag a country when |z| >= 1.5. Urbanization is descriptive context;
--   it does not determine peer-group membership.
--
-- NOTE
--   The original workflow rounds z-scores to two decimal places before
--   applying the threshold. This is retained to preserve the project output;
--   the near-threshold classifications should be checked using full precision
--   before final publication. Results change under NTILE(4); see script 06.
-- ============================================================================

USE africa_fertility_paradox;

-- 01 | Inspect 2024 GDP distribution; the available-data count is 52.
SELECT
    COUNT(gdp_per_capita) AS total_countries,
    MIN(gdp_per_capita) AS min_gdp,
    MAX(gdp_per_capita) AS max_gdp,
    AVG(gdp_per_capita) AS avg_gdp
FROM africa_fertility_panel
WHERE year = 2024;

-- 02 | Inspect the two middle GDP observations for an even-sized sample.
WITH ranked_gdp AS (
    SELECT
        country,
        gdp_per_capita,
        ROW_NUMBER() OVER (ORDER BY gdp_per_capita ASC) AS gdp_rank,
        COUNT(*) OVER () AS total_countries
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
)
SELECT *
FROM ranked_gdp
WHERE gdp_rank IN (
    FLOOR((total_countries + 1) / 2),
    FLOOR((total_countries + 2) / 2)
);

-- Calculate median GDP from the two middle observations.
WITH ranked_gdp AS (
    SELECT
        country,
        gdp_per_capita,
        ROW_NUMBER() OVER (ORDER BY gdp_per_capita ASC) AS gdp_rank,
        COUNT(*) OVER () AS total_countries
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
)
SELECT ROUND(AVG(gdp_per_capita), 2) AS median_gdp
FROM ranked_gdp
WHERE gdp_rank IN (
    FLOOR((total_countries + 1) / 2),
    FLOOR((total_countries + 2) / 2)
);

-- 03 | Check GDP tertile sizes using all available 2024 GDP observations.
WITH gdp_categories AS (
    SELECT
        country,
        gdp_per_capita,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
)
SELECT
    gdp_group,
    COUNT(*) AS countries_in_group
FROM gdp_categories
GROUP BY gdp_group
ORDER BY gdp_group;

-- 04 | Check sizes of the complete-case analysis peer groups.
WITH dataset_2024 AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        urban_pop_pct,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
)
SELECT
    gdp_group,
    COUNT(*) AS countries_in_group
FROM dataset_2024
GROUP BY gdp_group
ORDER BY gdp_group;

-- 05 | Calculate the mean fertility rate within each GDP peer group.
WITH dataset_2024 AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        urban_pop_pct,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
)
SELECT
    gdp_group,
    COUNT(*) AS countries_in_group,
    ROUND(AVG(fertility_rate), 2) AS avg_fertility
FROM dataset_2024
GROUP BY gdp_group
ORDER BY gdp_group;

-- 06 | Explore absolute fertility deviations from the group mean.
WITH dataset_2024 AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        urban_pop_pct,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
)
SELECT
    country,
    gdp_group,
    fertility_rate,
    ROUND(AVG(fertility_rate) OVER (PARTITION BY gdp_group), 2) AS peer_avg_fertility,
    ROUND(
        fertility_rate - AVG(fertility_rate) OVER (PARTITION BY gdp_group), 2
    ) AS fertility_deviation
FROM dataset_2024
ORDER BY ABS(fertility_deviation) DESC
LIMIT 10;

-- 07 | Calculate the population standard deviation in each group.
WITH dataset_2024 AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        urban_pop_pct,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
)
SELECT
    gdp_group,
    COUNT(*) AS countries_in_group,
    ROUND(AVG(fertility_rate), 2) AS avg_fertility,
    ROUND(STDDEV_POP(fertility_rate), 2) AS standard_dev
FROM dataset_2024
GROUP BY gdp_group
ORDER BY gdp_group;

-- 08 | Rank countries by standardized fertility deviation.
WITH dataset_2024 AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        urban_pop_pct,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
)
SELECT
    country,
    gdp_group,
    fertility_rate,
    ROUND(
        (fertility_rate - AVG(fertility_rate) OVER (PARTITION BY gdp_group))
        / NULLIF(STDDEV_POP(fertility_rate) OVER (PARTITION BY gdp_group), 0),
        2
    ) AS fertility_zscore
FROM dataset_2024
ORDER BY ABS(fertility_zscore) DESC
LIMIT 10;

-- 09 | Classify deviations at |rounded z| >= 1.5 (original method).
WITH dataset_2024 AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        urban_pop_pct,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
),
country_zscore AS (
    SELECT
        country,
        gdp_group,
        fertility_rate,
        ROUND(
            (fertility_rate - AVG(fertility_rate) OVER (PARTITION BY gdp_group))
            / NULLIF(STDDEV_POP(fertility_rate) OVER (PARTITION BY gdp_group), 0),
            2
        ) AS fertility_zscore
    FROM dataset_2024
)
SELECT
    country,
    gdp_group,
    CASE
        WHEN ABS(fertility_zscore) >= 2 THEN 'Extreme deviation'
        WHEN ABS(fertility_zscore) >= 1.5 THEN 'Notable deviation'
        ELSE 'Within threshold'
    END AS deviation_category
FROM country_zscore
WHERE ABS(fertility_zscore) >= 1.5
ORDER BY ABS(fertility_zscore) DESC;

-- 10 | Export flagged outliers for the Python diverging-bar chart.
-- Expected fields: country, gdp_group, fertility_rate, fertility_zscore,
-- deviation_direction, deviation_category.
-- Export filename: africa_fertility_outliers_2024.csv.
WITH dataset_2024 AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        urban_pop_pct,
        NTILE(3) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
),
country_zscore AS (
    SELECT
        country,
        gdp_group,
        fertility_rate,
        ROUND(
            (fertility_rate - AVG(fertility_rate) OVER (PARTITION BY gdp_group))
            / NULLIF(STDDEV_POP(fertility_rate) OVER (PARTITION BY gdp_group), 0),
            2
        ) AS fertility_zscore
    FROM dataset_2024
)
SELECT
    CASE
        WHEN country LIKE 'C%' AND country LIKE '%Ivoire%'
            THEN 'Côte d''Ivoire'
        ELSE country
    END AS country,
    gdp_group,
    fertility_rate,
    fertility_zscore,
    CASE
        WHEN fertility_zscore > 0 THEN 'Higher than GDP peers'
        WHEN fertility_zscore < 0 THEN 'Lower than GDP peers'
        ELSE 'Equal to GDP peers'
    END AS deviation_direction,
    CASE
        WHEN ABS(fertility_zscore) >= 2 THEN 'Extreme deviation'
        WHEN ABS(fertility_zscore) >= 1.5 THEN 'Notable deviation'
        ELSE 'Within threshold'
    END AS deviation_category
FROM country_zscore
WHERE ABS(fertility_zscore) >= 1.5
ORDER BY ABS(fertility_zscore) DESC;

-- ============================================================================
-- RECORDED RESULTS — source analysis; pending independent reproduction
--   GDP range (2024): $268.70–$16,612.64; mean $2,590.72; median $1,387.90.
--   Six NTILE(3) outliers: Angola (+2.35), Kenya (-1.95), Lesotho (-1.93),
--   Mauritania (+1.61), Ghana (-1.52), Côte d'Ivoire (+1.51).
--   These are comparisons within GDP-ranked groups, not causal effects.
-- ============================================================================
