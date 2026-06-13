bootstrap_risk_intervals <- function(
    returns,
    probs = c(0.95, 0.99),
    b = 200,
    seed = NULL) {
  x <- if (is.data.frame(returns)) returns$log_return else returns
  x <- x[is.finite(x)]
  if (length(x) < 5) {
    stop("At least five returns are required for bootstrap intervals.", call. = FALSE)
  }
  if (!is.null(seed)) {
    set.seed(seed)
  }

  original <- calculate_var_cvar(x, probs)
  values <- vector("list", b)
  for (i in seq_len(b)) {
    sample_x <- sample(x, size = length(x), replace = TRUE)
    values[[i]] <- transform(calculate_var_cvar(sample_x, probs), iteration = i)
  }
  boot <- do.call(rbind, values)

  rows <- lapply(probs, function(prob) {
    current <- boot[boot$probability == prob, ]
    estimate <- original[original$probability == prob, ]
    data.frame(
      probability = prob,
      var_estimate = estimate$var_loss,
      var_low = as.numeric(stats::quantile(current$var_loss, 0.025, names = FALSE)),
      var_high = as.numeric(stats::quantile(current$var_loss, 0.975, names = FALSE)),
      cvar_estimate = estimate$cvar_loss,
      cvar_low = as.numeric(stats::quantile(current$cvar_loss, 0.025, names = FALSE)),
      cvar_high = as.numeric(stats::quantile(current$cvar_loss, 0.975, names = FALSE)),
      iterations = b,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}
