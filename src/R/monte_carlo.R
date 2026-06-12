regularize_covariance <- function(covariance) {
  covariance[!is.finite(covariance)] <- 0
  covariance + diag(1e-8, nrow(covariance))
}

simulate_multivariate_normal <- function(n, mean_vector, covariance) {
  covariance <- regularize_covariance(covariance)
  factor <- chol(covariance)
  z <- matrix(stats::rnorm(n * length(mean_vector)), nrow = n)
  sweep(z %*% factor, 2, mean_vector, "+")
}

simulate_portfolio <- function(
    returns,
    weights = NULL,
    model = c("empirical", "normal", "gts"),
    n_sims = 5000,
    horizon = 20,
    seed = NULL,
    gts_grids = NULL) {
  model <- match.arg(model)
  aligned <- align_returns_by_date(returns)
  symbols <- setdiff(names(aligned), "date")
  matrix_returns <- as.matrix(aligned[, symbols, drop = FALSE])

  if (is.null(weights)) {
    weights <- rep(1 / length(symbols), length(symbols))
    names(weights) <- symbols
  }
  weights <- weights[symbols]
  weights <- weights / sum(weights)

  if (!is.null(seed)) {
    set.seed(seed)
  }

  portfolio_returns <- numeric(n_sims)
  if (model == "empirical") {
    for (i in seq_len(n_sims)) {
      sampled_rows <- sample(seq_len(nrow(matrix_returns)), size = horizon, replace = TRUE)
      path <- matrix_returns[sampled_rows, , drop = FALSE]
      portfolio_returns[i] <- sum(path %*% weights)
    }
  }

  if (model == "normal") {
    mean_vector <- colMeans(matrix_returns)
    covariance <- stats::cov(matrix_returns)
    for (i in seq_len(n_sims)) {
      path <- simulate_multivariate_normal(horizon, mean_vector, covariance)
      portfolio_returns[i] <- sum(path %*% weights)
    }
  }

  if (model == "gts") {
    totals <- matrix(0, nrow = n_sims, ncol = length(symbols))
    colnames(totals) <- symbols
    for (j in seq_along(symbols)) {
      params <- get_gts_parameters(symbols[j])
      grid <- if (!is.null(gts_grids) && !is.null(gts_grids[[symbols[j]]])) {
        gts_grids[[symbols[j]]]
      } else {
        build_gts_grid(params, x_grid = seq(-30, 30, length.out = 801), t_max = 80, n_t = 1024)
      }
      simulated <- matrix(simulate_gts(n_sims * horizon, params, grid), nrow = n_sims)
      totals[, j] <- rowSums(simulated)
    }
    portfolio_returns <- as.numeric(totals %*% weights)
  }

  data.frame(
    simulation_id = seq_len(n_sims),
    model = model,
    horizon_days = horizon,
    cumulative_return = portfolio_returns,
    stringsAsFactors = FALSE
  )
}
