# Analytical validation record — 27 October 2026

The project owner ran **targeted, read-only verification queries** in the existing MySQL database and supplied the results. This is not evidence that the six SQL scripts can recreate the database from fresh raw imports. In a separate check, all seven included original CSV exports were analyzed using Python to reproduce the notebook's calculations and charts.

## MySQL checks reported from the existing database

| Test | Outcome |
| --- | --- |
| Database objects present | Seven expected objects, including `africa_fertility_panel` |
| Panel size and coverage | 1,350 observations; 54 countries; 25 years, 2000–2024; no missing fertility values |
| Country–year uniqueness | Duplicate query returned zero rows |
| Mean fertility | 5.191 (2000) → 3.795 (2024); −26.9% |
| GDP/fertility Pearson r (2024) | −0.647 (n=52) |
| Urbanization/fertility Pearson r (2024) | −0.345 (n=54) |
| Education/fertility Pearson r (2011) | −0.903 (n=37) |
| Three GDP peer groups, `NTILE(3)` | Angola +2.35; Kenya −1.95; Lesotho −1.93; Mauritania +1.61; Ghana −1.52; Côte d'Ivoire +1.51 |
| Four GDP peer groups, `NTILE(4)` | Chad +2.25; Equatorial Guinea +2.07; Morocco −2.06; Lesotho −1.88; Angola +1.64; Mali +1.61; Djibouti −1.53 |

Only Angola and Lesotho are shared across the two outlier definitions. The SQL Pearson formulas used for independent validation were **not** incorporated into the original `04_socioeconomic_analysis.sql`: Python remains the project's Pearson calculation tool.

## Python CSV-to-chart tests

- All **seven** supplied CSV exports are included in `data/analysis_outputs/`, in the original filenames.
- Python/pandas reproduced the recorded GDP correlations: **2000 −0.674 (n=52)**; **2024 −0.647 (n=52)**.
- Python/pandas reproduced urbanization correlations: **2000 −0.584 (n=54)**; **2024 −0.345 (n=54)**.
- Python/pandas reproduced the education correlation: **2011 −0.903 (n=37)**.
- The 25-row annual mean CSV reproduced the **−26.9%** decline.
- The six-row outlier CSV reproduced the chart's six listed countries and their **rounded** z-scores.
- Using the included 52-country GDP/fertility 2024 CSV, independent ranking and z-score calculations matched the two peer-group outlier lists; cutoff using rounded vs. unrounded z-scores gave the same selected countries for both groupings. This does not prove alternative future data or groupings would behave the same.

## Remaining provenance and execution limits

1. The World Bank source downloads, complete indicator metadata and original import scripts are not available. **Do not claim the MySQL pipeline has been rebuilt from scratch.**
2. `01_database_setup.sql` includes one-time column rename commands. Do not rerun it against already normalized tables without checking their schema.
3. The existing table is spelled `afican_countries` in the original MySQL instance; it is left unchanged to preserve query references.
4. The source export's rendering of Côte d'Ivoire differs across CSVs. No underlying database characters were modified.
5. Cross-sectional correlations are not causal; missing source values affect sample sizes. **2011 education** should not be mislabeled as a 2024 analysis.
