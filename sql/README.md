# SQL workflow guide

These files preserve the project's original **small, task-focused SQL statements**. Each script represents a stage of analysis, not a single large query. In MySQL Workbench, inspect and run the relevant **individual statements** in order rather than executing setup operations blindly.

| File | Purpose | Key caution |
| --- | --- | --- |
| [`01_database_setup.sql`](01_database_setup.sql) | Establish the database and normalize previously imported source-table columns. | **Not a complete import script.** `ALTER TABLE ... RENAME COLUMN` is not safe to repeat on an already-prepared database. |
| [`02_data_quality.sql`](02_data_quality.sql) | Check coverage, missingness, country membership, and uniqueness of source records. | Raw World Bank source tables include geographic entities outside the African study sample. |
| [`03_exploratory_analysis.sql`](03_exploratory_analysis.sql) | Create `africa_fertility_panel`; examine levels and changes in fertility, 2000–2024. | The project uses unweighted country averages. |
| [`04_socioeconomic_analysis.sql`](04_socioeconomic_analysis.sql) | Select complete-case country samples for the Python correlation analysis. | **Pearson correlations are calculated in Python**, not in this SQL file. The education comparison uses **2011**. |
| [`05_outlier_analysis.sql`](05_outlier_analysis.sql) | Assign 2024 GDP tertile peer groups with `NTILE(3)`, calculate fertility z-scores, and export six outliers. | Classifications use **rounded** z-scores; near-threshold sensitivity was checked on the included 2024 sample; see validation record. |
| [`06_outlier_validation.sql`](06_outlier_validation.sql) | Repeat outlier detection using four GDP groups with `NTILE(4)`. | This is a grouping-sensitivity check, not a claim of stable outliers. |

## Important reproduction limits

- The six scripts **do not include the original World Bank import process** for the source tables, and cannot rebuild the database from a clean installation yet.
- The original database uses the spelling **`afican_countries`**. Keep that table identifier unless you migrate *all* relevant references and verify the change.
- The original imported GDP/education/urbanization tables had a malformed character prefix in the `Country Name` header. `01_database_setup.sql` documents those one-time renames; do not rerun them without inspecting the table schemas.
- `africa_fertility_panel` has been checked by the project owner in the existing database; that does **not** mean the six scripts have passed a fresh start-to-finish run.
- See [targeted validation results](../docs/validation_record.md), [original review notes](../docs/sql-review-notes.md), and [export mapping](../data/README.md).

## Workflow boundary

**SQL:** data preparation, exploratory/descriptive analysis, year-specific extracts, GDP peer-group z-scores and sensitivity check.  
**Python:** Pearson correlations, scatterplots, fertility trends visualization, and outlier chart.  
**Separate QA:** The long Pearson formulas executed in SQL on 2026-10-27 were **cross-checks only**; they have *not* replaced the Python calculations in the original analysis workflow.
