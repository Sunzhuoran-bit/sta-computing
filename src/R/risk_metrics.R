calculate_var_cvar <- function(returns, probs = c(0.95, 0.99)) {
  x <- if (is.data.frame(returns)) returns$log_return else returns
  x <- x[is.finite(x)]
  if (length(x) == 0) {
    stop("No finite returns available for risk calculation.", call. = FALSE)
  }

  losses <- -x
  rows <- lapply(probs, function(prob) {
    var_loss <- as.numeric(stats::quantile(losses, probs = prob, names = FALSE, type = 7))
    tail_losses <- losses[losses >= var_loss]
    cvar_loss <- if (length(tail_losses) > 0) mean(tail_losses) else max(losses)
    data.frame(
      probability = prob,
      var_loss = var_loss,
      cvar_loss = cvar_loss,
      var_return_threshold = -var_loss,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}
