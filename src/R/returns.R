compute_returns <- function(price_data, price_col = "adjusted") {
  price_data <- clean_price_data(price_data)
  if (!price_col %in% names(price_data) || all(is.na(price_data[[price_col]]))) {
    price_col <- "close"
  }

  pieces <- lapply(split(price_data, price_data$symbol), function(asset_data) {
    asset_data <- asset_data[order(asset_data$date), ]
    prices <- asset_data[[price_col]]
    log_return <- c(NA_real_, diff(log(prices)) * 100)
    simple_return <- c(NA_real_, (prices[-1] / prices[-length(prices)] - 1) * 100)

    out <- data.frame(
      date = asset_data$date,
      symbol = asset_data$symbol,
      close = asset_data$close,
      price = prices,
      log_return = log_return,
      simple_return = simple_return,
      stringsAsFactors = FALSE
    )
    out[is.finite(out$log_return), ]
  })

  returns <- do.call(rbind, pieces)
  returns <- returns[order(returns$symbol, returns$date), ]
  row.names(returns) <- NULL
  returns
}

asset_returns <- function(returns, symbol) {
  values <- returns$log_return[returns$symbol == symbol]
  values[is.finite(values)]
}

align_returns_by_date <- function(returns) {
  returns$date <- as.Date(returns$date)
  symbols <- sort(unique(returns$symbol))
  dates <- sort(unique(returns$date))
  matrix_data <- matrix(NA_real_, nrow = length(dates), ncol = length(symbols))
  colnames(matrix_data) <- symbols

  for (j in seq_along(symbols)) {
    current <- returns[returns$symbol == symbols[j], c("date", "log_return")]
    matched <- match(dates, current$date)
    matrix_data[, j] <- current$log_return[matched]
  }

  keep <- stats::complete.cases(matrix_data)
  data.frame(date = dates[keep], matrix_data[keep, , drop = FALSE], check.names = FALSE)
}
