clean_price_data <- function(price_data) {
  required <- c("date", "symbol", "open", "high", "low", "close", "volume")
  missing <- setdiff(required, names(price_data))
  if (length(missing) > 0) {
    stop("Price data is missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  price_data$date <- as.Date(price_data$date)
  numeric_columns <- intersect(c("open", "high", "low", "close", "adjusted", "volume"), names(price_data))
  for (column in numeric_columns) {
    price_data[[column]] <- as.numeric(price_data[[column]])
  }

  price_data <- price_data[!is.na(price_data$date), ]
  price_data <- price_data[is.finite(price_data$close) & price_data$close > 0, ]
  price_data <- price_data[order(price_data$symbol, price_data$date), ]
  price_data <- price_data[!duplicated(price_data[c("symbol", "date")]), ]
  row.names(price_data) <- NULL
  price_data
}
