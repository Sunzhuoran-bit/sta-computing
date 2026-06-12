permutation_test_returns <- function(
    x,
    y,
    statistic = c("mean", "median", "variance"),
    n_perm = 2000,
    seed = NULL) {
  statistic <- match.arg(statistic)
  x <- if (is.data.frame(x)) x$log_return else x
  y <- if (is.data.frame(y)) y$log_return else y
  x <- x[is.finite(x)]
  y <- y[is.finite(y)]

  stat_fun <- switch(
    statistic,
    mean = mean,
    median = stats::median,
    variance = stats::var
  )

  observed <- abs(stat_fun(x) - stat_fun(y))
  pooled <- c(x, y)
  n_x <- length(x)
  if (!is.null(seed)) {
    set.seed(seed)
  }

  permuted <- numeric(n_perm)
  for (i in seq_len(n_perm)) {
    shuffled <- sample(pooled)
    permuted[i] <- abs(stat_fun(shuffled[seq_len(n_x)]) - stat_fun(shuffled[-seq_len(n_x)]))
  }

  data.frame(
    statistic = statistic,
    observed_difference = observed,
    p_value = mean(permuted >= observed),
    permutations = n_perm,
    stringsAsFactors = FALSE
  )
}
