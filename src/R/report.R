generate_html_report <- function(returns, prices, output_path) {
  symbols <- sort(unique(returns$symbol))
  assets <- vapply(symbols, asset_label, character(1))

  aligned <- align_returns_by_date(returns)
  matrix_ret <- as.matrix(aligned[, symbols, drop = FALSE])
  corr <- stats::cor(matrix_ret, use = "pairwise.complete.obs")

  con <- file(output_path, "wt", encoding = "UTF-8")
  on.exit(close(con))

  write_esc <- function(x) {
    writeLines(gsub("&", "&amp;", gsub("<", "&lt;", gsub(">", "&gt;", x))), con)
  }

  writeLines(c(
    "<!DOCTYPE html><html><head><meta charset='utf-8'>",
    "<title>Volatility Analysis Report</title>",
    "<style>",
    "body{font-family:sans-serif;max-width:960px;margin:40px auto;padding:0 20px;color:#333}",
    "h1{color:#1b9e77;border-bottom:2px solid #1b9e77;padding-bottom:8px}",
    "table{border-collapse:collapse;width:100%;margin:16px 0}",
    "th,td{border:1px solid #ddd;padding:8px;text-align:right}",
    "th{background:#1b9e77;color:#fff;text-align:center}",
    "tr:nth-child(even){background:#f5f5f5}",
    ".section{margin:32px 0}",
    ".section h2{color:#d95f02}",
    "</style></head><body>"
  ), con)

  writeLines("<h1>Volatility Analysis Report</h1>", con)
  writeLines(sprintf("<p>Generated: %s</p>", Sys.Date()), con)
  writeLines(sprintf("<p>Assets analyzed: %s</p>", paste(assets, collapse = ", ")), con)
  writeLines(sprintf("<p>Data range: %s to %s</p>", min(prices$date), max(prices$date)), con)

  writeLines("<div class='section'><h2>Summary Statistics</h2>", con)
  writeLines("<table><tr><th>Asset</th><th>N</th><th>Mean (%)</th><th>SD (%)</th><th>Skewness</th><th>Excess Kurtosis</th><th>VaR 95%</th><th>VaR 99%</th></tr>", con)
  for (sym in symbols) {
    x <- asset_returns(returns, sym)
    risk95 <- calculate_var_cvar(x, 0.95)
    risk99 <- calculate_var_cvar(x, 0.99)
    skew <- mean((x - mean(x))^3) / stats::sd(x)^3
    kurt <- mean((x - mean(x))^4) / stats::sd(x)^4 - 3
    writeLines(sprintf(
      "<tr><td>%s</td><td>%d</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td></tr>",
      asset_label(sym), length(x), mean(x), stats::sd(x), skew, kurt, risk95$var_loss, risk99$var_loss
    ), con)
  }
  writeLines("</table></div>", con)

  writeLines("<div class='section'><h2>Correlation Matrix</h2>", con)
  writeLines("<table><tr><th></th>", con)
  for (sym in symbols) writeLines(sprintf("<th>%s</th>", asset_label(sym)), con)
  writeLines("</tr>", con)
  for (i in seq_along(symbols)) {
    writeLines(sprintf("<tr><td><strong>%s</strong></td>", asset_label(symbols[i])), con)
    for (j in seq_along(symbols)) {
      writeLines(sprintf("<td>%.4f</td>", corr[i, j]), con)
    }
    writeLines("</tr>", con)
  }
  writeLines("</table></div>", con)

  writeLines("<div class='section'><h2>GTS Distribution Parameters</h2>", con)
  params <- gts_parameter_table()
  writeLines("<table><tr><th>Asset</th><th>mu</th><th>beta+</th><th>beta-</th><th>alpha+</th><th>alpha-</th><th>lambda+</th><th>lambda-</th></tr>", con)
  for (i in seq_len(nrow(params))) {
    writeLines(sprintf(
      "<tr><td>%s</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td><td>%.4f</td></tr>",
      params$label[i], params$mu[i], params$beta_plus[i], params$beta_minus[i],
      params$alpha_plus[i], params$alpha_minus[i], params$lambda_plus[i], params$lambda_minus[i]
    ), con)
  }
  writeLines("</table></div>", con)

  writeLines("</body></html>", con)
}

export_report <- function(returns, prices, format = "html") {
  dir <- tempfile()
  dir.create(dir)
  path <- file.path(dir, paste0("report.", format))
  generate_html_report(returns, prices, path)
  path
}
