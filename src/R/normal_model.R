fit_normal_model <- function(returns) {
  x <- if (is.data.frame(returns)) returns$log_return else returns
  x <- x[is.finite(x)]
  if (length(x) < 2) {
    stop("At least two finite returns are required.", call. = FALSE)
  }
  list(mean = mean(x), sd = stats::sd(x), n = length(x))
}

simulate_normal <- function(n, model, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  stats::rnorm(n, mean = model$mean, sd = model$sd)
}

normal_quantiles <- function(probs, model) {
  stats::qnorm(probs, mean = model$mean, sd = model$sd)
}
