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
      method = "Percentile",
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

bootstrap_risk_intervals_bca <- function(
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
  n <- length(x)

  jack_var <- vapply(seq_len(n), function(i) {
    calculate_var_cvar(x[-i], probs)$var_loss
  }, numeric(length(probs)))

  jack_mean <- rowMeans(jack_var)

  rows <- lapply(seq_along(probs), function(j) {
    prob <- probs[j]
    current <- boot[boot$probability == prob, ]
    boot_var <- current$var_loss
    est <- original$var_loss[j]

    z0 <- stats::qnorm(mean(boot_var < est))
    acc <- if (stats::sd(jack_var[j, ]) > 0) {
      sum((jack_mean[j] - jack_var[j, ])^3) / (6 * sum((jack_mean[j] - jack_var[j, ])^2)^1.5)
    } else {
      0
    }

    alpha1 <- stats::pnorm(z0 + (z0 + stats::qnorm(0.025)) / (1 - acc * (z0 + stats::qnorm(0.025))))
    alpha2 <- stats::pnorm(z0 + (z0 + stats::qnorm(0.975)) / (1 - acc * (z0 + stats::qnorm(0.975))))

    data.frame(
      probability = prob,
      method = "BCa",
      var_estimate = est,
      var_low = as.numeric(stats::quantile(boot_var, alpha1, names = FALSE)),
      var_high = as.numeric(stats::quantile(boot_var, alpha2, names = FALSE)),
      cvar_estimate = original$cvar_loss[j],
      cvar_low = NA_real_,
      cvar_high = NA_real_,
      iterations = b,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

bootstrap_var_distribution <- function(returns, prob = 0.95, b = 200, seed = NULL) {
  x <- if (is.data.frame(returns)) returns$log_return else returns
  x <- x[is.finite(x)]
  if (!is.null(seed)) set.seed(seed)
  vapply(seq_len(b), function(i) {
    sample_x <- sample(x, size = length(x), replace = TRUE)
    calculate_var_cvar(sample_x, prob)$var_loss
  }, numeric(1))
}
