# SQL review: changes and checks

**Status:** Documentation/style review completed on all six scripts. On **27 October 2026**, the project owner reproduced the headline numbers using targeted SQL queries in the existing MySQL database (see [validation record](validation_record.md)). The six repository scripts and original imports have **not** been tested end-to-end. The uploaded originals remain preserved separately.

## What changed

- `01_database_setup.sql`: reorganized the setup narrative, used standard SQL casing, clarified imported-table prerequisites, and warned that renaming columns is not repeatable. **No new import routine was invented.**
- `02_data_quality.sql`: corrected comment spelling, standardized basic SQL casing and whitespace, clarified the sample versus global source-table distinction; changed the GDP per-country completeness condition to count `gdp.year` rather than `COUNT(*)` so a missing row from a LEFT JOIN is not miscounted. Changed `LIKE "%Africa%"` to a single-quoted literal, which is safe across `ANSI_QUOTES` SQL modes. These are **technical corrections** that require execution checks.
- `03_exploratory_analysis.sql`: improved documentation and uniform style; retained the original trend and descriptive calculations. Reworded references to the omitted longitudinal outlier research question.
- `04_socioeconomic_analysis.sql`: standardized sectioning and query layout, identified the 2011 education sample, and documented the Python-derived correlations and export filenames. Calculations and filters were retained.
- `05_outlier_analysis.sql`: standardized query layout, corrected the misleading `2014_dataset` CTE name to `dataset_2024`, and documented the use of population SD, GDP tertiles and the threshold. The original rounding-before-threshold behavior is **retained and flagged for numerical validation**.
- `06_outlier_validation.sql`: standardized query layout, explicitly required nonmissing fertility with nonmissing GDP, and described NTILE(4) as a **sensitivity check** rather than definitive validation.

## Open reproducibility issues (do not mark as verified)

1. **Missing import scripts**: `gdp_per_capita`, `female_education_raw`, `urban_population_raw`, `countries_raw`, and `afican_countries` are referenced but are not all created/imported in these six scripts. `fertility_raw` is created but no input data is loaded here. The intentionally misspelled table name `afican_countries` is kept because it appears in the original database references.
2. **Non-repeatable column renames**: `01_database_setup.sql` expects original column names, including a BOM-mojibake column called ``ï»¿Country Name``. Check each table using `DESCRIBE` before running.
3. **Near-threshold outliers**: The original code rounds z-scores before applying `|z| >= 1.5`. A check against the included 2024 GDP export shows this does not change the selected countries for either NTILE(3) or NTILE(4); other data/groupings may differ.
4. **Raw import workflow remains unavailable**: The project owner ran targeted SQL validation queries. All seven original downstream CSV exports are included and the notebook has been executed on them; the six repository SQL scripts have not been run from original raw source files.
5. **Trend percentage precision**: One original trend query rounds the ratio before multiplying by 100; compare the final percentage and ranking against a calculation that rounds only at the end.
6. **Identifier/metric verification**: Confirm exact World Bank indicator codes and data units; retain the original CSV export names, which are now documented and tested against the notebook. Ensure no claim of causal impact or stable outliers.

## Run order after data imports are recovered

1. Inspect the current schema. Execute script **01** only as appropriate for the present schema (avoid repeating completed `RENAME COLUMN` operations).
2. Run **02** to audit input tables and country selection.
3. Run **03** to create the panel and examine trends.
4. Run **04** to extract the samples used for Python correlations.
5. Run **05**, export the outlier CSV, then run **06** for sensitivity checks.

**When publishing to GitHub, describe the Python analyses as reproducible from included exports, but the complete raw-data-to-SQL pipeline as not yet independently reproducible.**

## Independent near-threshold check using supplied 2024 GDP/fertility CSV

Using the 52-country exported data, a Python recomputation of the **same SQL `NTILE(3)`/`NTILE(4)` group sizes** and population-standard-deviation z-scores found **no difference** between thresholding the rounded (two-decimal) and unrounded z-scores. This checks the known 2024 extract only, not the entire database reconstruction. The SQL statements retain their original rounding behavior.
