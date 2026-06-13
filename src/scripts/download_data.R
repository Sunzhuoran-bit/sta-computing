args <- commandArgs(trailingOnly = FALSE)
file_arg <- args[grepl("^--file=", args)]
if (length(file_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = TRUE)
  root <- normalizePath(file.path(dirname(script_path), "..", ".."), winslash = "/", mustWork = TRUE)
} else {
  root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}
setwd(root)

r_files <- list.files(file.path(root, "src", "R"), pattern = "\\.R$", full.names = TRUE)
invisible(lapply(sort(r_files), source))

message("Downloading default financial datasets...")
data <- download_default_dataset()
message("Wrote ", nrow(data$prices), " price rows and ", nrow(data$returns), " return rows.")
