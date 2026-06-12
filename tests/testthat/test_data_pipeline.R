testthat::test_that("price cleaning and return calculation work on toy data", {
  prices <- data.frame(
    date = as.Date("2026-01-01") + 0:3,
    symbol = "BTC-USD",
    open = c(100, 101, 103, 104),
    high = c(101, 103, 104, 106),
    low = c(99, 100, 102, 103),
    close = c(100, 102, 101, 105),
    adjusted = c(100, 102, 101, 105),
    volume = c(10, 11, 12, 13)
  )

  cleaned <- clean_price_data(prices)
  returns <- compute_returns(cleaned)

  testthat::expect_equal(names(cleaned)[1:7], c("date", "symbol", "open", "high", "low", "close", "adjusted"))
  testthat::expect_equal(nrow(returns), 3)
  testthat::expect_false(any(duplicated(returns[c("date", "symbol")])))
  testthat::expect_equal(round(returns$log_return[1], 6), round(log(102 / 100) * 100, 6))
})
