asset_label <- function(symbol) {
  if (identical(symbol, "BTC-USD")) return("Bitcoin")
  if (identical(symbol, "^GSPC")) return("S&P 500")
  symbol
}

plot_price_history <- function(price_data) {
  price_data <- clean_price_data(price_data)
  symbols <- unique(price_data$symbol)
  colors <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a")
  indexed_values <- list()

  for (i in seq_along(symbols)) {
    current <- price_data[price_data$symbol == symbols[i], ]
    price <- if ("adjusted" %in% names(current) && any(is.finite(current$adjusted))) {
      current$adjusted
    } else {
      current$close
    }
    indexed_values[[symbols[i]]] <- price / price[which(is.finite(price))[1]] * 100
  }

  plot(NULL,
    xlim = range(price_data$date),
    ylim = range(unlist(indexed_values), finite = TRUE),
    xlab = "Date",
    ylab = "Indexed price, first observation = 100",
    main = "Indexed Price History"
  )
  grid(col = "gray90")

  for (i in seq_along(symbols)) {
    current <- price_data[price_data$symbol == symbols[i], ]
    lines(current$date, indexed_values[[symbols[i]]], col = colors[i], lwd = 2)
  }
  legend("topleft", legend = vapply(symbols, asset_label, character(1)), col = colors[seq_along(symbols)], lwd = 2, bty = "n")
}

plot_return_histogram <- function(returns, symbol, gts_sample = NULL) {
  x <- asset_returns(returns, symbol)
  hist(x,
    breaks = 50,
    probability = TRUE,
    col = "#d8e2dc",
    border = "white",
    main = paste(asset_label(symbol), "Daily Log Return Distribution"),
    xlab = "Daily log return (%)"
  )
  grid(col = "gray90")
  model <- fit_normal_model(x)
  curve(stats::dnorm(x, mean = model$mean, sd = model$sd), add = TRUE, col = "#1f78b4", lwd = 2)
  if (!is.null(gts_sample)) {
    lines(stats::density(gts_sample), col = "#e31a1c", lwd = 2)
  }
  legend("topright", legend = c("Normal fit", "GTS simulation"), col = c("#1f78b4", "#e31a1c"), lwd = 2, bty = "n")
}

plot_qq_comparison <- function(returns, symbol, gts_grid = NULL) {
  x <- sort(asset_returns(returns, symbol))
  probs <- stats::ppoints(length(x))
  normal_model <- fit_normal_model(x)
  normal_q <- normal_quantiles(probs, normal_model)
  params <- get_gts_parameters(symbol)
  gts_q <- gts_quantiles(probs, params, gts_grid)

  range_all <- range(c(x, normal_q, gts_q), finite = TRUE)
  plot(normal_q, x,
    pch = 16,
    cex = 0.45,
    col = "#1f78b480",
    xlab = "Theoretical quantile",
    ylab = "Empirical quantile",
    main = paste(asset_label(symbol), "Q-Q Comparison"),
    xlim = range_all,
    ylim = range_all
  )
  points(gts_q, x, pch = 16, cex = 0.45, col = "#e31a1c80")
  abline(0, 1, lwd = 2, col = "gray40")
  grid(col = "gray90")
  legend("topleft", legend = c("Normal", "GTS grid"), col = c("#1f78b4", "#e31a1c"), pch = 16, bty = "n")
}

plot_tail_comparison <- function(returns, symbol) {
  x <- asset_returns(returns, symbol)
  losses <- sort(-x)
  survival <- pmax(1 - stats::ecdf(losses)(losses), 1 / (length(losses) + 1))
  plot(losses, survival,
    type = "l",
    lwd = 2,
    col = "#6a3d9a",
    log = "y",
    xlab = "Loss = -return (%)",
    ylab = "Empirical survival probability (log scale)",
    main = paste(asset_label(symbol), "Tail Risk")
  )
  grid(col = "gray90")
}

plot_bootstrap_intervals <- function(intervals) {
  y <- intervals$var_estimate
  lower <- intervals$var_low
  upper <- intervals$var_high
  x <- seq_along(y)
  plot(x, y,
    ylim = range(c(lower, upper), finite = TRUE),
    pch = 16,
    xaxt = "n",
    xlab = "Confidence level",
    ylab = "VaR loss (%)",
    main = "Bootstrap VaR Intervals"
  )
  axis(1, at = x, labels = paste0(intervals$probability * 100, "%"))
  arrows(x, lower, x, upper, angle = 90, code = 3, length = 0.08, col = "#1f78b4", lwd = 2)
  grid(col = "gray90")
}

plot_monte_carlo_distribution <- function(simulations) {
  hist(simulations$cumulative_return,
    breaks = 50,
    col = "#fee08b",
    border = "white",
    main = "Monte Carlo Portfolio Return",
    xlab = "Cumulative return over horizon (%)"
  )
  abline(v = stats::quantile(simulations$cumulative_return, c(0.05, 0.5, 0.95)), col = c("#d73027", "gray30", "#1a9850"), lwd = 2)
  grid(col = "gray90")
}
