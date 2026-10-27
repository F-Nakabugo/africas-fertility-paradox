# Data and provenance

The folder `analysis_outputs/` contains **all seven original CSV exports** supplied by the project owner. They were exported from MySQL queries and are sufficient to rerun the Python notebook and regenerate all seven charts. They are **not** the original raw World Bank files.

| File (original filename retained) | Rows | Used for |
| --- | ---: | --- |
| `annual_mean_fertility_2000_2024.csv` | 25 | Annual unweighted mean fertility trend |
| `gpd_vs_fertility_2024.csv` | 52 | GDP per capita and fertility in 2024 |
| `gpd_vs_fertility_2000_2024.csv` | 104 | GDP/fertility comparison (2000, 2024) |
| `gpd_vs_edu_2011.csv` | 37 | Female secondary gross enrollment and fertility (2011) |
| `gpd_vs_urbanization_2024.csv` | 54 | Urban population share and fertility (2024) |
| `gpd_vs_urbanization_2000_2024.csv` | 108 | Urbanization/fertility comparison (2000, 2024) |
| `africa_fertility_outliers_2024.csv` | 6 | Six GDP-peer outliers (2024) |

**Naming:** The historical prefix `gpd_` is an original filename and intentionally retained to avoid breaking references.

**Source family:** World Bank indicators, 2000–2024. The exact World Bank download URLs, collection dates, GDP price/currency basis, and the original raw-file import steps were **not supplied**. These remain an explicit limit on rebuilding the full MySQL database from scratch. The source's female secondary gross enrollment code appears as `SE.SEC.ENRR.FE` in the original SQL notes; other indicator codes require verification.

**Text encoding:** The GDP exports include the original mojibake spelling `CÃ´te dâ€™Ivoire`, while the outlier CSV correctly displays `Côte d'Ivoire`. CSV bytes have been **preserved**; the underlying MySQL import/display encoding has not been repaired here.

**No imputation** was performed in the original analysis. Sample sizes differ according to indicator availability.
