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

shiny::runApp(root, host = "127.0.0.1", port = 3838, launch.browser = TRUE)
