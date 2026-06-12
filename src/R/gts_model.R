gts_parameter_table <- function() {
  data.frame(
    asset_id = c("bitcoin", "sp500"),
    symbol = c("BTC-USD", "^GSPC"),
    label = c("Bitcoin", "S&P 500 Index"),
    mu = c(-0.1216, -0.2494),
    beta_plus = c(0.3155, 0.3286),
    beta_minus = c(0.4066, 0.0886),
    alpha_plus = c(0.7477, 0.7924),
    alpha_minus = c(0.5446, 0.5422),
    lambda_plus = c(0.2465, 1.2797),
    lambda_minus = c(0.1748, 0.9371),
    source = c("Nzokem and Maposa 2025 Table 1", "Nzokem and Maposa 2025 Table 2"),
    stringsAsFactors = FALSE
  )
}

get_gts_parameters <- function(asset_id) {
  table <- gts_parameter_table()
  key <- tolower(asset_id)
  matched <- table[
    tolower(table$asset_id) == key |
      tolower(table$symbol) == key |
      tolower(table$label) == key,
  ]
  if (nrow(matched) == 0) {
    stop("No default GTS parameters found for asset: ", asset_id, call. = FALSE)
  }
  row <- matched[1, ]
  as.list(row[c(
    "asset_id", "symbol", "label", "mu", "beta_plus", "beta_minus",
    "alpha_plus", "alpha_minus", "lambda_plus", "lambda_minus", "source"
  )])
}

gts_characteristic_function <- function(t, params) {
  mu <- as.numeric(params$mu)
  beta_plus <- as.numeric(params$beta_plus)
  beta_minus <- as.numeric(params$beta_minus)
  alpha_plus <- as.numeric(params$alpha_plus)
  alpha_minus <- as.numeric(params$alpha_minus)
  lambda_plus <- as.numeric(params$lambda_plus)
  lambda_minus <- as.numeric(params$lambda_minus)

  psi <- 1i * mu * t +
    alpha_plus * gamma(-beta_plus) *
      ((lambda_plus - 1i * t)^beta_plus - lambda_plus^beta_plus) +
    alpha_minus * gamma(-beta_minus) *
      ((lambda_minus + 1i * t)^beta_minus - lambda_minus^beta_minus)

  exp(psi)
}

trapz <- function(x, y) {
  sum(diff(x) * (head(y, -1) + tail(y, -1)) / 2)
}

build_gts_grid <- function(
    params,
    x_grid = seq(-30, 30, length.out = 1201),
    t_max = 100,
    n_t = 2048) {
  t <- seq(1e-6, t_max, length.out = n_t)
  phi <- gts_characteristic_function(t, params)

  pdf <- vapply(x_grid, function(x) {
    integrand <- Re(exp(-1i * t * x) * phi)
    trapz(t, integrand) / pi
  }, numeric(1))

  pdf[!is.finite(pdf)] <- 0
  pdf[pdf < 0] <- 0
  dx <- mean(diff(x_grid))
  total <- sum(pdf) * dx
  if (!is.finite(total) || total <= 0) {
    stop("GTS grid normalization failed.", call. = FALSE)
  }

  pdf <- pdf / total
  cdf <- cumsum(pdf) * dx
  cdf <- cdf / max(cdf)
  cdf <- cummax(pmin(pmax(cdf, 0), 1))

  list(
    x = x_grid,
    pdf = pdf,
    cdf = cdf,
    params = params,
    method = "characteristic-function numerical inversion"
  )
}

simulate_gts <- function(n, params, grid = NULL, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  if (is.null(grid)) {
    grid <- build_gts_grid(params)
  }

  keep <- is.finite(grid$cdf) & is.finite(grid$x) & !duplicated(grid$cdf)
  u <- stats::runif(n)
  stats::approx(
    x = grid$cdf[keep],
    y = grid$x[keep],
    xout = u,
    rule = 2,
    ties = "ordered"
  )$y
}

gts_quantiles <- function(probs, params, grid = NULL) {
  if (is.null(grid)) {
    grid <- build_gts_grid(params)
  }
  keep <- is.finite(grid$cdf) & is.finite(grid$x) & !duplicated(grid$cdf)
  stats::approx(
    x = grid$cdf[keep],
    y = grid$x[keep],
    xout = probs,
    rule = 2,
    ties = "ordered"
  )$y
}
