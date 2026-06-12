testthat::test_that("risk metrics are ordered by confidence level", {
  x <- c(-3, -2, -1, 0, 1, 2, 3)
  risk <- calculate_var_cvar(x, probs = c(0.90, 0.99))
  testthat::expect_true(risk$var_loss[2] >= risk$var_loss[1])
  testthat::expect_true(all(risk$cvar_loss >= risk$var_loss))
})

testthat::test_that("bootstrap is reproducible with a fixed seed", {
  x <- seq(-5, 5, length.out = 50)
  a <- bootstrap_risk_intervals(x, probs = 0.95, b = 20, seed = 1)
  b <- bootstrap_risk_intervals(x, probs = 0.95, b = 20, seed = 1)
  testthat::expect_equal(a, b)
})

testthat::test_that("permutation p-values stay in range", {
  result <- permutation_test_returns(1:10, 11:20, statistic = "mean", n_perm = 50, seed = 1)
  testthat::expect_true(result$p_value >= 0)
  testthat::expect_true(result$p_value <= 1)
})

testthat::test_that("GTS grid is normalized and monotone", {
  params <- get_gts_parameters("BTC-USD")
  grid <- build_gts_grid(params, x_grid = seq(-20, 20, length.out = 301), t_max = 30, n_t = 256)
  testthat::expect_true(all(diff(grid$cdf) >= -1e-10))
  testthat::expect_true(abs(max(grid$cdf) - 1) < 1e-8)
})
