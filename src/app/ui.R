ui <- shiny::fluidPage(
  shiny::titlePanel("Cryptocurrency and Stock Market Volatility Analysis"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::selectInput(
        "asset",
        "Asset",
        choices = c("Bitcoin" = "BTC-USD", "Ethereum" = "ETH-USD", "S&P 500" = "^GSPC", "SPY ETF" = "SPY"),
        selected = "BTC-USD"
      ),
      shiny::sliderInput("confidence", "Risk confidence level", min = 0.90, max = 0.99, value = 0.95, step = 0.01),
      shiny::selectInput("crossAssetX", "Cross-asset X axis",
        choices = c("Bitcoin" = "BTC-USD", "Ethereum" = "ETH-USD", "S&P 500" = "^GSPC", "SPY ETF" = "SPY"),
        selected = "BTC-USD"
      ),
      shiny::selectInput("crossAssetY", "Cross-asset Y axis",
        choices = c("Bitcoin" = "BTC-USD", "Ethereum" = "ETH-USD", "S&P 500" = "^GSPC", "SPY ETF" = "SPY"),
        selected = "^GSPC"
      ),
      shiny::sliderInput("rollingWindow", "Rolling correlation window (days)", min = 20, max = 120, value = 60, step = 5),
      shiny::sliderInput("bootstrapB", "Bootstrap iterations", min = 50, max = 1000, value = 200, step = 50),
      shiny::sliderInput("mcSims", "Monte Carlo simulations", min = 500, max = 10000, value = 3000, step = 500),
      shiny::sliderInput("horizon", "Simulation horizon in days", min = 1, max = 60, value = 20, step = 1),
      shiny::sliderInput("btcWeight", "Bitcoin portfolio weight", min = 0, max = 1, value = 0.5, step = 0.05),
      shiny::selectInput(
        "mcModel",
        "Monte Carlo model",
        choices = c("Empirical bootstrap" = "empirical", "Normal" = "normal", "GTS independent" = "gts"),
        selected = "empirical"
      ),
      shiny::selectInput(
        "permStatistic",
        "Permutation statistic",
        choices = c("Mean" = "mean", "Median" = "median", "Variance" = "variance"),
        selected = "mean"
      ),
      shiny::sliderInput("permB", "Permutation count", min = 200, max = 5000, value = 1000, step = 200)
    ),
    shiny::mainPanel(
      shiny::verbatimTextOutput("dataStatus"),
      shiny::tabsetPanel(
        shiny::tabPanel("Dashboard",
          shiny::verbatimTextOutput("dashOverview"),
          shiny::tableOutput("dashTable")
        ),
        shiny::tabPanel("Data", shiny::uiOutput("pricePlotContainer"), shiny::tableOutput("summaryTable")),
        shiny::tabPanel("Distribution", shiny::plotOutput("histPlot", height = 360), shiny::plotOutput("qqPlot", height = 360), shiny::tableOutput("gofTable")),
        shiny::tabPanel("Tail Risk",
          shiny::plotOutput("tailPlot", height = 360),
          shiny::tableOutput("riskTable"),
          shiny::plotOutput("bootstrapPlot", height = 360),
          shiny::plotOutput("bootstrapDistPlot", height = 280),
          shiny::tableOutput("bootstrapBcaTable")
        ),
        shiny::tabPanel("Monte Carlo", shiny::plotOutput("mcPlot", height = 360), shiny::tableOutput("mcTable")),
        shiny::tabPanel("Permutation Test", shiny::tableOutput("permTable")),
        shiny::tabPanel("Cross-Asset",
          shiny::plotOutput("scatterPlot", height = 320),
          shiny::plotOutput("rollingCorrPlot", height = 320)
        ),
        shiny::tabPanel("Project Notes", shiny::tableOutput("gtsTable"))
      )
    )
  )
)
