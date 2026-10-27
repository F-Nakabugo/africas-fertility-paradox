-- ============================================================================
-- Africa's Fertility Paradox (2000–2024) | 06: Peer-group sensitivity test
-- ============================================================================
-- PURPOSE
--   Repeat the 2024 fertility z-score analysis using NTILE(4) instead of
--   NTILE(3) to assess sensitivity to the definition of economic peers.
--
-- METHOD
--   Four GDP-ranked groups of 13 countries each (recorded sample n = 52).
--   Compare each country's fertility with its peer group's mean and
--   population SD. Flag |rounded z| >= 1.5 to match the original analysis.
--   Results describe classification sensitivity, not independent validation
--   of any country's outlier status.
-- ============================================================================

USE africa_fertility_paradox;

-- 01 | Inspect peer-group sizes, mean fertility and standard deviation.
WITH gdp_categories AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        NTILE(4) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
)
SELECT
    gdp_group,
    COUNT(*) AS countries_in_group,
    ROUND(AVG(fertility_rate), 2) AS avg_fertility,
    ROUND(STDDEV_POP(fertility_rate), 2) AS fertility_stddev
FROM gdp_categories
GROUP BY gdp_group
ORDER BY gdp_group;

-- 02 | Identify outliers under the four-group specification.
WITH gdp_categories AS (
    SELECT
        country,
        gdp_per_capita,
        fertility_rate,
        NTILE(4) OVER (ORDER BY gdp_per_capita ASC) AS gdp_group
    FROM africa_fertility_panel
    WHERE year = 2024
        AND gdp_per_capita IS NOT NULL
        AND fertility_rate IS NOT NULL
),
fertility_zscores AS (
    SELECT
        country,
        gdp_group,
        fertility_rate,
        ROUND(
            (fertility_rate - AVG(fertility_rate) OVER (PARTITION BY gdp_group))
            / NULLIF(STDDEV_POP(fertility_rate) OVER (PARTITION BY gdp_group), 0),
            2
        ) AS fertility_zscore
    FROM gdp_categories
)
SELECT
    country,
    gdp_group,
    fertility_rate,
    fertility_zscore
FROM fertility_zscores
WHERE ABS(fertility_zscore) >= 1.5
ORDER BY ABS(fertility_zscore) DESC;

-- ============================================================================
-- RECORDED RESULTS — source analysis; pending independent reproduction
--   Seven NTILE(4) outliers: Chad (+2.25), Equatorial Guinea (+2.07),
--   Morocco (-2.06), Lesotho (-1.88), Angola (+1.64), Mali (+1.61),
--   Djibouti (-1.53). Only Angola and Lesotho overlap the NTILE(3) list.
-- ============================================================================
