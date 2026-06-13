required <- c("jsonlite", "shiny", "markdown")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  stop(
    "Missing required R packages: ",
    paste(missing, collapse = ", "),
    ". Run install.packages(c('jsonlite', 'shiny')) first.",
    call. = FALSE
  )
}

root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
r_files <- list.files(file.path(root, "src", "R"), pattern = "\\.R$", full.names = TRUE)
invisible(lapply(sort(r_files), source))

source(file.path(root, "src", "app", "ui.R"), local = TRUE)
source(file.path(root, "src", "app", "server.R"), local = TRUE)

shiny::shinyApp(ui = ui, server = server)
