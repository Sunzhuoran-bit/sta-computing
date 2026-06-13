gts_cdf_function <- function(grid) {
  function(q) {
    stats::approx(grid$x, grid$cdf, xout = q, rule = 2, ties = "ordered")$y
  }
}

gof_test_normal <- function(returns) {
  x <- if (is.data.frame(returns)) returns$log_return else returns
  x <- x[is.finite(x)]
  model <- fit_normal_model(x)
  ks <- stats::ks.test(x, "pnorm", mean = model$mean, sd = model$sd)
  data.frame(
    distribution = "Normal",
    ks_statistic = round(as.numeric(ks$statistic), 6),
    ks_p_value = round(ks$p.value, 6),
    ad_statistic = NA_real_,
    ad_p_value = NA_real_,
    stringsAsFactors = FALSE
  )
}

gof_test_gts <- function(returns, grid) {
  x <- if (is.data.frame(returns)) returns$log_return else returns
  x <- x[is.finite(x)]
  if (is.null(grid) || is.null(grid$cdf)) {
    return(data.frame(
      distribution = "GTS",
      ks_statistic = NA_real_,
      ks_p_value = NA_real_,
      ad_statistic = NA_real_,
      ad_p_value = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  cdf_fun <- gts_cdf_function(grid)
  ks <- suppressWarnings(stats::ks.test(x, cdf_fun))
  ad_retry <- tryCatch(
    gof_ad_test(x, cdf_fun),
    error = function(e) list(ad_statistic = NA_real_, ad_p_value = NA_real_)
  )
  data.frame(
    distribution = "GTS",
    ks_statistic = round(as.numeric(ks$statistic), 6),
    ks_p_value = round(ks$p.value, 6),
    ad_statistic = round(ad_retry$ad_statistic, 6),
    ad_p_value = round(ad_retry$ad_p_value, 6),
    stringsAsFactors = FALSE
  )
}

gof_ad_test <- function(x, cdf_fun) {
  x <- sort(x[is.finite(x)])
  n <- length(x)
  if (n < 2) stop("Need at least 2 observations")
  u <- cdf_fun(x)
  u <- pmax(pmin(u, 1 - 1e-15), 1e-15)
  i <- seq_len(n)
  ad <- -n - sum((2 * i - 1) * log(u) + (2 * n + 1 - 2 * i) * log(1 - u)) / n
  ad_corrected <- ad * (1 + 0.75 / n + 2.25 / n^2)
  p <- 0
  if (ad_corrected >= 0.6) p <- exp(1.2937 - 5.709 * ad_corrected + 0.0186 * ad_corrected^2)
  if (ad_corrected > 0.34 && ad_corrected < 0.6) p <- exp(0.9177 - 4.279 * ad_corrected - 1.38 * ad_corrected^2)
  if (ad_corrected <= 0.34) p <- 1 - exp(-8.318 + 42.796 * ad_corrected - 59.938 * ad_corrected^2)
  list(ad_statistic = ad_corrected, ad_p_value = max(p, 0))
}
