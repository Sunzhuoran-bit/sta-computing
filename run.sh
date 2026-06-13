#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

R_USER_LIB="$HOME/R/library"
export R_LIBS_USER="$R_USER_LIB"
export STA_SHINY_LAUNCH_BROWSER=false

confirm() {
  read -r -p "$1 [y/N] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ---- R ----
R_DEPS=(libssl-dev libcurl4-openssl-dev libxml2-dev
         libfontconfig1-dev libharfbuzz-dev libfribidi-dev
         libfreetype-dev libicu-dev libtiff5-dev
         libjpeg-dev libpng-dev libuv1-dev)

if ! command -v Rscript &>/dev/null; then
  echo "R is not installed."
  if confirm "Install R and compilation dependencies via apt?"; then
    sudo apt update
    sudo apt install -y r-base r-base-dev "${R_DEPS[@]}"
  else
    echo "Aborted." >&2
    exit 1
  fi
else
  missing_deps=()
  for pkg in "${R_DEPS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null 2>&1; then
      missing_deps+=("$pkg")
    fi
  done
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "Missing system dependencies for R package compilation: ${missing_deps[*]}"
    if confirm "Install them via apt?"; then
      sudo apt update
      sudo apt install -y "${missing_deps[@]}"
    fi
  fi
fi

# ---- R packages & launch ----
set +e
Rscript -e '
  root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

  required <- c("jsonlite", "shiny", "markdown", "testthat")
  missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    cat("Missing R packages:", paste(missing, collapse = " "), "\n")
    q(save = "no", status = 99)
  }

  source(file.path(root, "src", "scripts", "run_app.R"), local = TRUE)
'
status=$?
set -e

if [ "$status" -eq 99 ]; then
  if confirm "Install missing R packages now?"; then
    Rscript -e '
      dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE, showWarnings = FALSE)
      .libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))
      install.packages(c("jsonlite", "shiny", "testthat", "markdown"), lib = Sys.getenv("R_LIBS_USER"), repos = "https://cloud.r-project.org")
    '
    echo ""
    STA_SHINY_LAUNCH_BROWSER=false Rscript src/scripts/run_app.R
  else
    echo "Aborted." >&2
    exit 1
  fi
elif [ "$status" -ne 0 ]; then
  exit "$status"
fi
