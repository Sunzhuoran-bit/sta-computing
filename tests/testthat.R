if (!requireNamespace("testthat", quietly = TRUE)) {
  stop("Package 'testthat' is required. Run install.packages('testthat') first.", call. = FALSE)
}

source(file.path("tests", "testthat", "helper-load.R"))
testthat::test_dir("tests/testthat")
