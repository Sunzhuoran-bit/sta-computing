# Volatility Analysis

An interactive R Shiny application for analyzing financial volatility in heavy-tailed asset returns across four assets: Bitcoin, Ethereum, the S&P 500 index, and the SPY ETF.

## About

This project demonstrates why normality-based risk models fail for heavy-tailed financial data. It combines empirical analysis, bootstrapped risk intervals, Monte Carlo simulation under multiple distributional assumptions, and permutation tests — all within an interactive dashboard. The application covers Bitcoin, Ethereum, the S&P 500 index, and the SPY ETF, with GTS distribution parameters drawn from Nzokem & Maposa (2025). The GTS implementation is a pedagogical numerical approximation using characteristic function inversion and discrete CDF sampling.

## Features

- **Dashboard** — overview of data coverage and key metrics across assets
- **Return Distribution** — histogram, Q-Q plot, and goodness-of-fit tests (normal vs. empirical)
- **Tail Risk** — VaR / CVaR calculation with bootstrap confidence intervals and BCa correction
- **Monte Carlo Simulation** — portfolio return simulation under empirical, normal, and GTS models
- **Permutation Test** — non-parametric comparison of asset return distributions
- **Cross-Asset Analysis** — scatter plot and rolling correlation between assets

## Requirements

- **R** >= 4.4.0
- Required packages: `jsonlite`, `shiny`, `testthat`

```r
install.packages(c("jsonlite", "shiny", "testthat"))
```

## Quick Start

### 1. Download data

```bash
Rscript src/scripts/download_data.R
```

Downloads daily price data from Yahoo Finance for all configured assets (Bitcoin, Ethereum, S&P 500, SPY ETF).

### 2. Launch the app

```bash
Rscript src/scripts/run_app.R
```

Opens the Shiny app at `http://127.0.0.1:3838` by default. Set environment variables `STA_SHINY_HOST`, `STA_SHINY_PORT`, or `STA_SHINY_LAUNCH_BROWSER` to customize.

### 3. Run tests

```bash
Rscript tests/testthat.R
```

### All-in-one (Linux)

```bash
./run.sh
```

## Project Structure

```text
sta-computing/
├── app.R                  # Application entry point
├── config/                # Configuration files
│   ├── assets.yml         # Asset symbols and date range
│   └── gts_parameters.yml # GTS parameter estimates
├── data/                  # Data directory (gitignored)
│   ├── raw/               # Raw downloaded CSV files
│   └── processed/         # Processed price/return CSV files
├── docs/                  # Documentation
├── references/            # Reference papers and project materials
├── src/
│   ├── R/                 # Core R functions (data, statistics, plots)
│   ├── app/               # Shiny UI and server
│   └── scripts/           # Data download and app launch scripts
├── tests/
│   └── testthat/          # Unit tests
└── outputs/               # Generated reports and outputs
```

## Methodology

| Method | Description |
|---|---|
| **Normal model** | Fits sample mean and variance; highlights limitations of Gaussian assumptions on heavy-tailed data |
| **GTS model** | Seven-parameter GTS distribution using numerical characteristic function inversion and inverse CDF sampling. Parameters from Nzokem & Maposa (2025) |
| **Bootstrap** | Resamples empirical returns to construct confidence intervals for VaR and CVaR, with BCa correction |
| **Monte Carlo** | Simulates portfolio returns under empirical, normal, and GTS models across asset weight combinations |
| **Permutation test** | Non-parametric comparison of return distributions between any two selected assets (mean, median, variance) |

## Limitations

- GTS parameters are sourced from published estimates and are not re-estimated within this project.
- The GTS sampler uses numerical PDF/CDF grids via characteristic function inversion, not a full Enhanced FRFT implementation.
- Risk metrics are for educational demonstration and do not constitute financial advice.

## Data Sources

| Asset | Symbol | Source |
|---|---|---|
| Bitcoin | BTC-USD | Yahoo Finance |
| Ethereum | ETH-USD | Yahoo Finance |
| S&P 500 Index | ^GSPC | Yahoo Finance |
| SPY ETF | SPY | Yahoo Finance |

Default range: 2021-06-12 to 2026-06-12.

## References

Nzokem, T. A., & Maposa, D. (2025). *High-Performance Simulation of Generalized Tempered Stable Random Variates: Exact and Numerical Methods for Heavy-Tailed Data*.

## License

MIT
