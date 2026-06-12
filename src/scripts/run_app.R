args <- commandArgs(trailingOnly = FALSE)
file_arg <- args[grepl("^--file=", args)]
if (length(file_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE)
  root <- normalizePath(file.path(dirname(script_path), "..", ".."), winslash = "/", mustWork = TRUE)
} else {
  root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}
setwd(root)

if (!requireNamespace("shiny", quietly = TRUE)) {
  stop("Package 'shiny' is required. Run install.packages('shiny') first.", call. = FALSE)
}

host <- Sys.getenv("STA_SHINY_HOST", "127.0.0.1")
port <- as.integer(Sys.getenv("STA_SHINY_PORT", "3838"))
launch_browser <- tolower(Sys.getenv("STA_SHINY_LAUNCH_BROWSER", "true")) %in% c("1", "true", "yes")

shiny::runApp(root, host = host, port = port, launch.browser = launch_browser)
