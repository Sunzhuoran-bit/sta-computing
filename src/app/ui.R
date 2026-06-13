ui <- bslib::page_navbar(
  title = "Cryptocurrency and Stock Market Volatility Analysis",

  theme = bslib::bs_theme(
    bootswatch = "flatly",
    base_font = bslib::font_google("Inter")
  ),

  bslib::nav_item(bslib::input_dark_mode(id = "dark_mode")),

  sidebar = bslib::sidebar(
    width = 300,
    bslib::accordion(
      bslib::accordion_panel(
        "Data Selection",
        shiny::uiOutput("assetSelector")
      ),
      bslib::accordion_panel(
        "Risk Parameters",
        shiny::sliderInput("confidence", "Confidence level", min = 0.90, max = 0.99, value = 0.95, step = 0.01),
        shiny::sliderInput("bootstrapB", "Bootstrap iterations", min = 50, max = 1000, value = 200, step = 50)
      ),
      bslib::accordion_panel(
        "Cross-Asset",
        shiny::uiOutput("crossAssetXSelector"),
        shiny::uiOutput("crossAssetYSelector"),
        shiny::sliderInput("rollingWindow", "Rolling window (days)", min = 20, max = 120, value = 60, step = 5)
      ),
      bslib::accordion_panel(
        "Monte Carlo",
        shiny::selectInput("mcModel", "Model",
          choices = c("Empirical" = "empirical", "Normal" = "normal", "GTS" = "gts"),
          selected = "empirical"),
        shiny::sliderInput("mcSims", "Simulations", min = 500, max = 10000, value = 3000, step = 500),
        shiny::sliderInput("horizon", "Horizon (days)", min = 1, max = 60, value = 20, step = 1),
        shiny::sliderInput("btcWeight", "Bitcoin weight", min = 0, max = 1, value = 0.5, step = 0.05)
      ),
      bslib::accordion_panel(
        "Permutation Test",
        shiny::selectInput("permStatistic", "Statistic",
          choices = c("Mean" = "mean", "Median" = "median", "Variance" = "variance"),
          selected = "mean"),
        shiny::sliderInput("permB", "Permutations", min = 200, max = 5000, value = 1000, step = 200)
      )
    )
  ),

  bslib::nav_panel("Dashboard",
    bslib::card(bslib::card_header("Data Status"), shiny::verbatimTextOutput("dataStatus")),
    bslib::card(bslib::card_header("Overview"), shiny::verbatimTextOutput("dashOverview")),
    bslib::card(bslib::card_header("Key Metrics by Asset"), shiny::tableOutput("dashTable"), full_screen = TRUE),
    bslib::card(shiny::downloadButton("downloadReport", "Download HTML Report"))
  ),

  bslib::nav_panel("Data",
    bslib::card(bslib::card_header("Indexed Price History"), shiny::uiOutput("pricePlotContainer"), full_screen = TRUE),
    bslib::card(bslib::card_header("Summary Statistics"), shiny::tableOutput("summaryTable"), full_screen = TRUE)
  ),

  bslib::nav_panel("Distribution",
    bslib::layout_columns(
      bslib::card(bslib::card_header("Return Distribution"), shiny::plotOutput("histPlot", height = "100%"), full_screen = TRUE),
      bslib::card(bslib::card_header("Q-Q Comparison"), shiny::plotOutput("qqPlot", height = "100%"), full_screen = TRUE)
    ),
    bslib::card(bslib::card_header("Goodness-of-Fit Tests"), shiny::tableOutput("gofTable"))
  ),

  bslib::nav_panel("Tail Risk",
    bslib::card(bslib::card_header("Tail Survival"), shiny::plotOutput("tailPlot", height = "100%"), full_screen = TRUE),
    bslib::layout_columns(
      bslib::card(bslib::card_header("VaR / CVaR"), shiny::tableOutput("riskTable")),
      bslib::card(bslib::card_header("Bootstrap VaR Intervals"), shiny::plotOutput("bootstrapPlot", height = "100%"), full_screen = TRUE)
    ),
    bslib::card(bslib::card_header("Bootstrap Distribution"), shiny::plotOutput("bootstrapDistPlot", height = "100%"), full_screen = TRUE),
    bslib::card(bslib::card_header("Bootstrap CI Comparison"), shiny::tableOutput("bootstrapBcaTable"))
  ),

  bslib::nav_panel("Monte Carlo",
    bslib::card(bslib::card_header("Portfolio Return Distribution"), shiny::plotOutput("mcPlot", height = "100%"), full_screen = TRUE),
    bslib::card(bslib::card_header("Simulation Summary"), shiny::tableOutput("mcTable"))
  ),

  bslib::nav_panel("Permutation Test",
    bslib::card(bslib::card_header("Permutation Test Results"), shiny::tableOutput("permTable"))
  ),

  bslib::nav_panel("Cross-Asset",
    bslib::layout_columns(
      bslib::card(bslib::card_header("Return Scatter"), shiny::plotOutput("scatterPlot", height = "100%"), full_screen = TRUE),
      bslib::card(bslib::card_header("Rolling Correlation"), shiny::plotOutput("rollingCorrPlot", height = "100%"), full_screen = TRUE)
    )
  ),

  bslib::nav_panel("GTS Parameters",
    bslib::card(bslib::card_header("Estimated GTS Parameters"), shiny::tableOutput("gtsTable"), full_screen = TRUE)
  ),

  bslib::nav_panel("Parameter Guide",
    bslib::card(shiny::includeMarkdown(file.path("docs", "parameter_guide.md")))
  )
)
