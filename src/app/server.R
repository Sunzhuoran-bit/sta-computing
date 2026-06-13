server <- function(input, output, session) {
  data_bundle <- shiny::reactive({
    load_project_data()
  })

  gts_grid_cache <- new.env(parent = emptyenv())
  get_grid <- function(symbol) {
    cache_key <- symbol_file_name(symbol)
    if (!exists(cache_key, envir = gts_grid_cache, inherits = FALSE)) {
      params <- get_gts_parameters(symbol)
      grid <- build_gts_grid(params, x_grid = seq(-30, 30, length.out = 801), t_max = 80, n_t = 1024)
      assign(cache_key, grid, envir = gts_grid_cache)
    }
    get(cache_key, envir = gts_grid_cache, inherits = FALSE)
  }

  selected_returns <- shiny::reactive({
    data <- data_bundle()$returns
    data[data$symbol == input$asset, ]
  })

  output$dataStatus <- shiny::renderText({
    data <- data_bundle()
    sprintf(
      "Loaded %s price rows and %s return rows. Data range: %s to %s.",
      nrow(data$prices),
      nrow(data$returns),
      min(data$prices$date),
      max(data$prices$date)
    )
  })

  output$dashOverview <- shiny::renderText({
    data <- data_bundle()
    ret <- data$returns
    symbols <- unique(ret$symbol)
    sprintf(
      "Dashboard — Cryptocurrency and Stock Market Volatility Analysis\n%s assets analyzed\nData range: %s to %s\nTotal observations: %s",
      length(symbols),
      min(data$prices$date),
      max(data$prices$date),
      nrow(ret)
    )
  })

  output$dashTable <- shiny::renderTable({
    data <- data_bundle()
    ret <- data$returns
    aligned <- align_returns_by_date(ret)
    symbols <- setdiff(names(aligned), "date")
    matrix_ret <- as.matrix(aligned[, symbols, drop = FALSE])
    corr <- stats::cor(matrix_ret, use = "pairwise.complete.obs")
    rows <- lapply(symbols, function(s) {
      x <- asset_returns(ret, s)
      risk95 <- calculate_var_cvar(x, 0.95)
      risk99 <- calculate_var_cvar(x, 0.99)
      data.frame(
        asset = asset_label(s),
        observations = length(x),
        volatility = round(stats::sd(x), 4),
        var_95 = round(risk95$var_loss, 4),
        cvar_95 = round(risk95$cvar_loss, 4),
        var_99 = round(risk99$var_loss, 4),
        cvar_99 = round(risk99$cvar_loss, 4),
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, rows)
  })

  output$pricePlotContainer <- shiny::renderUI({
    if (requireNamespace("plotly", quietly = TRUE)) {
      plotly::plotlyOutput("pricePlotly", height = 360)
    } else {
      shiny::plotOutput("priceBase", height = 360)
    }
  })

  output$priceBase <- shiny::renderPlot({
    plot_price_history(data_bundle()$prices)
  })

  output$pricePlotly <- plotly::renderPlotly({
    plot_price_history(data_bundle()$prices)
  })

  output$summaryTable <- shiny::renderTable({
    returns <- data_bundle()$returns
    rows <- lapply(split(returns$log_return, returns$symbol), function(x) {
      data.frame(
        observations = length(x),
        mean = round(mean(x), 4),
        sd = round(stats::sd(x), 4),
        skew_proxy = round(mean((x - mean(x))^3) / stats::sd(x)^3, 4),
        excess_kurtosis = round(mean((x - mean(x))^4) / stats::sd(x)^4 - 3, 4)
      )
    })
    out <- do.call(rbind, rows)
    out$asset <- vapply(row.names(out), asset_label, character(1))
    out[, c("asset", "observations", "mean", "sd", "skew_proxy", "excess_kurtosis")]
  })

  output$histPlot <- shiny::renderPlot({
    params <- get_gts_parameters(input$asset)
    grid <- get_grid(input$asset)
    gts_sample <- simulate_gts(3000, params, grid, seed = 2026)
    plot_return_histogram(data_bundle()$returns, input$asset, gts_sample)
  })

  output$qqPlot <- shiny::renderPlot({
    plot_qq_comparison(data_bundle()$returns, input$asset, get_grid(input$asset))
  })

  output$gofTable <- shiny::renderTable({
    returns <- data_bundle()$returns
    grid <- get_grid(input$asset)
    normal <- gof_test_normal(returns[returns$symbol == input$asset, ])
    gts <- gof_test_gts(returns[returns$symbol == input$asset, ], grid)
    rbind(normal, gts)
  })

  output$tailPlot <- shiny::renderPlot({
    plot_tail_comparison(data_bundle()$returns, input$asset)
  })

  output$riskTable <- shiny::renderTable({
    risk <- calculate_var_cvar(selected_returns(), probs = c(input$confidence, 0.99))
    transform(
      risk,
      probability = paste0(round(probability * 100), "%"),
      var_loss = round(var_loss, 4),
      cvar_loss = round(cvar_loss, 4),
      var_return_threshold = round(var_return_threshold, 4)
    )
  })

  bootstrap_data <- shiny::reactive({
    list(
      percentile = bootstrap_risk_intervals(selected_returns(), probs = c(input$confidence, 0.99), b = input$bootstrapB, seed = 2026),
      bca = bootstrap_risk_intervals_bca(selected_returns(), probs = c(input$confidence, 0.99), b = input$bootstrapB, seed = 2026),
      var_dist = bootstrap_var_distribution(selected_returns(), prob = input$confidence, b = input$bootstrapB, seed = 2026)
    )
  })

  output$bootstrapPlot <- shiny::renderPlot({
    plot_bootstrap_intervals(bootstrap_data()$percentile)
  })

  output$bootstrapDistPlot <- shiny::renderPlot({
    est <- calculate_var_cvar(selected_returns(), input$confidence)
    plot_bootstrap_distribution(bootstrap_data()$var_dist, est$var_loss)
  })

  output$bootstrapBcaTable <- shiny::renderTable({
    rbind(bootstrap_data()$percentile, bootstrap_data()$bca)
  })

  simulations <- shiny::reactive({
    simulate_portfolio(
      data_bundle()$returns,
      weights = c("BTC-USD" = input$btcWeight, "^GSPC" = 1 - input$btcWeight),
      model = input$mcModel,
      n_sims = input$mcSims,
      horizon = input$horizon,
      seed = 2026
    )
  })

  output$mcPlot <- shiny::renderPlot({
    plot_monte_carlo_distribution(simulations())
  })

  output$mcTable <- shiny::renderTable({
    sim <- simulations()
    data.frame(
      model = unique(sim$model),
      horizon_days = unique(sim$horizon_days),
      mean_return = round(mean(sim$cumulative_return), 4),
      median_return = round(stats::median(sim$cumulative_return), 4),
      loss_95_var = round(as.numeric(stats::quantile(-sim$cumulative_return, 0.95)), 4),
      stringsAsFactors = FALSE
    )
  })

  output$permTable <- shiny::renderTable({
    data <- data_bundle()$returns
    x <- data[data$symbol == "BTC-USD", ]
    y <- data[data$symbol == "^GSPC", ]
    transform(
      permutation_test_returns(x, y, input$permStatistic, input$permB, seed = 2026),
      observed_difference = round(observed_difference, 5),
      p_value = round(p_value, 5)
    )
  })

  output$scatterPlot <- shiny::renderPlot({
    plot_cross_asset_scatter(data_bundle()$returns, input$crossAssetX, input$crossAssetY)
  })

  output$rollingCorrPlot <- shiny::renderPlot({
    plot_rolling_correlation(data_bundle()$returns, input$crossAssetX, input$crossAssetY, input$rollingWindow)
  })

  output$gtsTable <- shiny::renderTable({
    gts_parameter_table()
  })
}
