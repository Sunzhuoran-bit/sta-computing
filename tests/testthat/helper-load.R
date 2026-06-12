root <- normalizePath(file.path(getwd()), winslash = "/", mustWork = TRUE)
r_files <- list.files(file.path(root, "src", "R"), pattern = "\\.R$", full.names = TRUE)
invisible(lapply(sort(r_files), source))
