# AGENTS.md — sta-computing

**R Shiny** project for financial volatility analysis (Bitcoin + S&P 500). Course project for 统计计算 (Statistical Computing).

## Setup

- R 4.4.2. On Linux use `Rscript` from PATH. On Windows use full path: `C:\Program Files\R\R-4.4.2\bin\Rscript.exe`.
- Required packages: `jsonlite`, `shiny`, `markdown`, `testthat`
- Working directory **must be the project root** for all scripts.

## Commands (run from project root)

```bash
# Quick launch (Linux — from project root)
./run.sh

# Download data (Yahoo Finance, requires internet)
Rscript src/scripts/download_data.R

# Launch Shiny app (default http://127.0.0.1:3838)
Rscript src/scripts/run_app.R

# Run all tests
Rscript tests/testthat.R
```

## Architecture

- **Not a real R package** despite having `DESCRIPTION`/`NAMESPACE`. All `src/R/` files are `source()`d alphabetically (by `app.R`, scripts, and test helper). No lazy loading, no compiled code.
- **Entrypoint**: `app.R` → checks dependencies → sources `src/R/*.R` sorted → sources `src/app/ui.R` and `src/app/server.R`.
- `load_project_data()` auto-downloads if `data/processed/prices.csv` or `returns.csv` missing.
- `project_root()` walks up from `getwd()` until it finds `DESCRIPTION` + `src/R/` — must be project root.

## Structure

| Path | Purpose |
|---|---|
| `src/R/` | 10 base-R function files (no external deps beyond base + jsonlite) |
| `src/app/` | Shiny `ui.R`, `server.R` |
| `src/scripts/` | `download_data.R`, `run_app.R` |
| `tests/testthat/` | `test_data_pipeline.R`, `test_statistics.R` |
| `config/` | `assets.yml` (symbols, date range), `gts_parameters.yml` (paper params) |

## Conventions

- No linter, formatter, or type checker configured.
- GTS parameters are hard-coded from Nzokem & Maposa (2025) — **do not re-estimate**.
- All CSV data (`data/raw/*.csv`, `data/processed/*.csv`) is gitignored.
- Seed `2026` used across Shiny app for reproducibility.
- Functions use base R + `jsonlite` only; `shiny` only in app layer.
- Health-check dependencies at runtime via `requireNamespace()`.

## Testing

- testthat edition 3.
- No service/API mocking — tests use toy in-memory data only.
- Run: `Rscript tests/testthat.R`

## Quirks

- `run_app.R` reads env vars `STA_SHINY_HOST`, `STA_SHINY_PORT`, `STA_SHINY_LAUNCH_BROWSER`; defaults `127.0.0.1:3838` with browser launch.
- `download_text()` tries PowerShell → curl → base R `readLines(url)` in that order.
- `gts_quantiles()` and `simulate_gts()` require a pre-built `grid` from `build_gts_grid()` — expensive operation cached in Shiny server via env.
- `regularize_covariance()` adds `1e-8` ridge to diagonal.
