project_root <- function() {
  current <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(current, "DESCRIPTION")) &&
        dir.exists(file.path(current, "src", "R"))) {
      return(current)
    }
    parent <- dirname(current)
    if (identical(parent, current)) {
      return(normalizePath(getwd(), winslash = "/", mustWork = TRUE))
    }
    current <- parent
  }
}

path_from_root <- function(...) {
  file.path(project_root(), ...)
}

ensure_directory <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  invisible(path)
}

symbol_file_name <- function(symbol) {
  cleaned <- gsub("[^A-Za-z0-9]+", "_", symbol)
  cleaned <- gsub("^_|_$", "", cleaned)
  tolower(cleaned)
}

date_to_unix <- function(date_value) {
  as.integer(as.POSIXct(as.Date(date_value), tz = "UTC"))
}

download_text <- function(url) {
  temp_file <- tempfile(fileext = ".json")
  user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

  if (.Platform$OS.type == "windows" && nzchar(Sys.which("powershell"))) {
    ps_script <- tempfile(fileext = ".ps1")
    escape_ps <- function(value) gsub("'", "''", value, fixed = TRUE)
    writeLines(
      c(
        "$ProgressPreference = 'SilentlyContinue'",
        sprintf(
          "Invoke-WebRequest -UseBasicParsing -Uri '%s' -TimeoutSec 60 -OutFile '%s'",
          escape_ps(url),
          escape_ps(temp_file)
        )
      ),
      ps_script,
      useBytes = TRUE
    )
    status <- system2(
      "powershell",
      args = c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ps_script),
      stdout = TRUE,
      stderr = TRUE
    )
    exit_status <- attr(status, "status")
    if (is.null(exit_status) && file.exists(temp_file) && file.info(temp_file)$size > 0) {
      return(paste(readLines(temp_file, warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
    }
  }

  if (nzchar(Sys.which("curl"))) {
    status <- system2(
      "curl",
      args = c("-L", "-A", user_agent, "-o", temp_file, url),
      stdout = TRUE,
      stderr = TRUE
    )
    exit_status <- attr(status, "status")
    if (is.null(exit_status) && file.exists(temp_file) && file.info(temp_file)$size > 0) {
      return(paste(readLines(temp_file, warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
    }
  }

  old_timeout <- getOption("timeout")
  old_agent <- getOption("HTTPUserAgent")
  options(timeout = max(60, old_timeout))
  options(HTTPUserAgent = user_agent)
  on.exit(options(timeout = old_timeout, HTTPUserAgent = old_agent), add = TRUE)
  paste(readLines(url, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

fetch_yahoo_prices <- function(symbol, start_date, end_date) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required for Yahoo Finance downloads.", call. = FALSE)
  }

  period1 <- date_to_unix(start_date)
  period2 <- date_to_unix(as.Date(end_date) + 1)
  encoded_symbol <- utils::URLencode(symbol, reserved = TRUE)
  url <- sprintf(
    paste0(
      "https://query1.finance.yahoo.com/v8/finance/chart/%s",
      "?period1=%s&period2=%s&interval=1d&events=history"
    ),
    encoded_symbol,
    period1,
    period2
  )

  response <- jsonlite::fromJSON(download_text(url), simplifyVector = FALSE)
  if (!is.null(response$chart$error)) {
    stop("Yahoo Finance error for ", symbol, ": ", response$chart$error$description, call. = FALSE)
  }
  result <- response$chart$result[[1]]
  timestamps <- unlist(result$timestamp)
  quote <- result$indicators$quote[[1]]
  adjusted <- result$indicators$adjclose[[1]]$adjclose

  prices <- data.frame(
    date = as.Date(as.POSIXct(timestamps, origin = "1970-01-01", tz = "UTC")),
    symbol = symbol,
    open = as.numeric(unlist(quote$open)),
    high = as.numeric(unlist(quote$high)),
    low = as.numeric(unlist(quote$low)),
    close = as.numeric(unlist(quote$close)),
    adjusted = as.numeric(unlist(adjusted)),
    volume = as.numeric(unlist(quote$volume)),
    stringsAsFactors = FALSE
  )
  prices[order(prices$date), ]
}

download_default_dataset <- function(
    start_date = "2021-06-12",
    end_date = "2026-06-12",
    symbols = c("BTC-USD", "^GSPC")) {
  raw_dir <- path_from_root("data", "raw")
  processed_dir <- path_from_root("data", "processed")
  ensure_directory(raw_dir)
  ensure_directory(processed_dir)

  price_list <- lapply(symbols, function(symbol) {
    prices <- clean_price_data(fetch_yahoo_prices(symbol, start_date, end_date))
    raw_path <- file.path(raw_dir, paste0(symbol_file_name(symbol), "_prices.csv"))
    utils::write.csv(prices, raw_path, row.names = FALSE)
    prices
  })

  prices <- do.call(rbind, price_list)
  prices <- clean_price_data(prices)
  returns <- compute_returns(prices)

  utils::write.csv(prices, file.path(processed_dir, "prices.csv"), row.names = FALSE)
  utils::write.csv(returns, file.path(processed_dir, "returns.csv"), row.names = FALSE)

  list(prices = prices, returns = returns)
}

load_project_data <- function() {
  prices_path <- path_from_root("data", "processed", "prices.csv")
  returns_path <- path_from_root("data", "processed", "returns.csv")

  if (!file.exists(prices_path) || !file.exists(returns_path)) {
    return(download_default_dataset())
  }

  prices <- utils::read.csv(prices_path, stringsAsFactors = FALSE)
  returns <- utils::read.csv(returns_path, stringsAsFactors = FALSE)
  prices$date <- as.Date(prices$date)
  returns$date <- as.Date(returns$date)
  keep_symbols <- c("BTC-USD", "^GSPC")
  prices <- prices[prices$symbol %in% keep_symbols, ]
  returns <- returns[returns$symbol %in% keep_symbols, ]
  list(prices = prices, returns = returns)
}
