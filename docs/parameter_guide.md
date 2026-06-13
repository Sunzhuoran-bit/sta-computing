# Parameter Guide

## Asset

- **Type**: Dropdown selector
- **Options**: Available assets with downloaded data (e.g., Bitcoin, Ethereum, S&P 500, SPY ETF)
- **Function**: Selects the primary asset for analysis in the Distribution, Tail Risk, and other tabs. Switching assets updates all charts and tables to reflect that asset's data. The dropdown is dynamically populated based on which assets have data available, so only downloaded assets appear.

---

## Risk Confidence Level

- **Type**: Slider
- **Range**: 0.90 – 0.99 (step 0.01)
- **Default**: 0.95
- **Function**: Sets the confidence level for Value-at-Risk (VaR) and Conditional VaR (CVaR) calculations. A 95% confidence level means the VaR estimates the worst expected loss over the holding period with 95% probability. Higher confidence levels (e.g., 99%) focus on more extreme tail events but produce wider confidence intervals.

---

## Cross-Asset X Axis / Cross-Asset Y Axis

- **Type**: Dropdown selectors
- **Options**: All available assets
- **Default**: X = first asset, Y = second asset
- **Function**: Select which two assets to compare in the Cross-Asset tab. The scatter plot shows daily log returns of the Y-axis asset against the X-axis asset, with a linear regression line and Pearson correlation coefficient. The rolling correlation plot shows how the correlation between the two assets evolves over time.

---

## Rolling Correlation Window (Days)

- **Type**: Slider
- **Range**: 20 – 120 (step 5)
- **Default**: 60
- **Function**: Defines the window size (in trading days) for calculating the rolling correlation in the Cross-Asset tab. A shorter window (e.g., 20) reacts quickly to recent market changes but is noisier. A longer window (e.g., 120) produces smoother estimates but responds more slowly to regime shifts.

---

## Bootstrap Iterations

- **Type**: Slider
- **Range**: 50 – 1000 (step 50)
- **Default**: 200
- **Function**: Number of resamples used to compute bootstrap confidence intervals for VaR estimates. Each iteration draws a random sample (with replacement) from the empirical returns, recalculates VaR, and stores the result. More iterations produce more stable confidence intervals at the cost of longer computation time. The Tail Risk tab shows both percentile and BCa (bias-corrected and accelerated) bootstrap intervals.

---

## Monte Carlo Simulations

- **Type**: Slider
- **Range**: 500 – 10000 (step 500)
- **Default**: 3000
- **Function**: Number of simulated portfolio return paths to generate. Each simulation draws a sequence of daily returns over the specified horizon and aggregates them into a cumulative portfolio return. Higher values produce smoother distribution estimates but take longer to compute. Applicable to all three Monte Carlo models.

---

## Simulation Horizon in Days

- **Type**: Slider
- **Range**: 1 – 60 (step 1)
- **Default**: 20
- **Function**: Length of the return path (in trading days) for each Monte Carlo simulation. A horizon of 20 days corresponds to approximately one calendar month of trading. Longer horizons increase the total return variance and are useful for medium-term risk assessment.

---

## Bitcoin Portfolio Weight

- **Type**: Slider
- **Range**: 0.00 – 1.00 (step 0.05)
- **Default**: 0.50
- **Function**: Proportion of the portfolio allocated to Bitcoin (BTC-USD); the remainder is allocated to S&P 500 (^GSPC). For example, a weight of 0.70 means 70% Bitcoin and 30% S&P 500. Adjusting this slider shows how varying the asset mix changes the simulated portfolio return distribution.

---

## Monte Carlo Model

- **Type**: Dropdown selector
- **Options**: Empirical bootstrap, Normal, GTS independent
- **Default**: Empirical bootstrap
- **Function**: Chooses the return-generating model for the Monte Carlo simulation:
  - **Empirical bootstrap**: Resamples actual historical returns with replacement. Makes no distributional assumptions but is limited to observed historical patterns.
  - **Normal**: Assumes returns follow a multivariate normal distribution fitted to the historical mean and covariance. Captures linear dependencies but underestimates tail risk for heavy-tailed data.
  - **GTS independent**: Simulates returns from the Generalized Tempered Stable (GTS) distribution using numerical inversion of the characteristic function. Captures heavy tails and skewness, but treats the two assets as independent (no correlation structure).

---

## Permutation Statistic

- **Type**: Dropdown selector
- **Options**: Mean, Median, Variance
- **Default**: Mean
- **Function**: The test statistic used in the permutation test to compare Bitcoin and S&P 500 return distributions:
  - **Mean**: Tests whether the two assets have significantly different average returns.
  - **Median**: Tests for differences in central tendency that are robust to outliers.
  - **Variance**: Tests whether the return volatilities differ significantly between the two assets.

---

## Permutation Count

- **Type**: Slider
- **Range**: 200 – 5000 (step 200)
- **Default**: 1000
- **Function**: Number of random permutations used to construct the null distribution for the permutation test. Under the null hypothesis, asset labels are randomly shuffled across observations, and the test statistic is recomputed for each shuffle. The p-value is the proportion of permuted statistics that exceed the observed difference. More permutations yield more precise p-values at the cost of extra computation.

---

*Document version: 2026-06-13*
