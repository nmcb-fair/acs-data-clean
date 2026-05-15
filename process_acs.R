#!/usr/bin/env Rscript

source(file.path("R", "acs_cleaning.R"))

usage <- function() {
  cat(
    "ACS data cleaning\n",
    "\n",
    "Run the standard folder workflow:\n",
    "  Rscript process_acs.R\n",
    "\n",
    "Run one raw file with one header template:\n",
    "  Rscript process_acs.R --raw raw/acs-nmcb-2.csv --header header/nmcb-acs-header-2.csv\n",
    "\n",
    "Optional folder settings for the standard workflow:\n",
    "  Rscript process_acs.R --raw-dir raw --header-dir header --export-dir export\n",
    "\n",
    "Options:\n",
    "  --raw          Raw ACS CSV file without headers\n",
    "  --header       Header/template CSV file with one header row\n",
    "  --out          Cleaned output CSV file or output folder; default: export/YYYYMMDD/\n",
    "  --raw-dir      Folder containing raw files; default: raw\n",
    "  --header-dir   Folder containing header templates; default: header\n",
    "  --export-dir   Folder for cleaned outputs; default: export\n",
    "  --token-prefix Only keep rows where O_token starts with this value; default: nmcb; use all to keep every row\n",
    "  --help         Show this help message\n",
    sep = ""
  )
}

parse_args <- function(args) {
  opts <- list()
  i <- 1

  while (i <= length(args)) {
    key <- args[[i]]

    if (key == "--help") {
      opts$help <- TRUE
      i <- i + 1
      next
    }

    if (!startsWith(key, "--")) {
      stop("Unexpected argument: ", key)
    }

    if (i == length(args) || startsWith(args[[i + 1]], "--")) {
      stop("Missing value for option: ", key)
    }

    opts[[substring(key, 3)]] <- args[[i + 1]]
    i <- i + 2
  }

  opts
}

args <- commandArgs(trailingOnly = TRUE)
opts <- parse_args(args)

if (isTRUE(opts$help)) {
  usage()
  quit(status = 0)
}

has_single_file_args <- all(c("raw", "header") %in% names(opts))
has_some_single_file_args <- any(c("raw", "header", "out") %in% names(opts))

if (has_some_single_file_args && !has_single_file_args) {
  stop("For one-file processing, please provide both --raw and --header")
}

token_prefix <- if (!is.null(opts[["token-prefix"]])) opts[["token-prefix"]] else "nmcb"
if (tolower(token_prefix) %in% c("all", "none", "")) {
  token_prefix <- NULL
}

if (has_single_file_args) {
  export_dir <- if (!is.null(opts[["export-dir"]])) opts[["export-dir"]] else "export"
  dated_export_dir <- file.path(export_dir, format(Sys.Date(), "%Y%m%d"))

  if (is.null(opts$out)) {
    output_file <- file.path(dated_export_dir, basename(opts$raw))
  } else if (grepl("\\.csv$", opts$out, ignore.case = TRUE)) {
    output_file <- opts$out
  } else {
    output_file <- file.path(opts$out, format(Sys.Date(), "%Y%m%d"), basename(opts$raw))
  }

  result <- process_acs_file(
    raw_file = opts$raw,
    header_file = opts$header,
    output_file = output_file,
    token_prefix = token_prefix
  )

  output_dir <- dirname(output_file)
  output_stem <- tools::file_path_sans_ext(basename(output_file))
  deleted_log_path <- file.path(output_dir, paste0(output_stem, "_deleted_cells_log.csv"))
  misalignment_log_path <- file.path(output_dir, paste0(output_stem, "_generalized_rule_misalignment_log.csv"))

  fwrite(result$delete_log, deleted_log_path, quote = TRUE, na = "")
  fwrite(result$generalized_misalignment_log, misalignment_log_path, quote = TRUE, na = "")

  cat("Cleaned file written to:", output_file, "\n")
  cat("Deleted-cell log written to:", deleted_log_path, "\n")
  cat("Misalignment log written to:", misalignment_log_path, "\n")
  print(result$summary)
} else {
  raw_dir <- if (!is.null(opts[["raw-dir"]])) opts[["raw-dir"]] else "raw"
  header_dir <- if (!is.null(opts[["header-dir"]])) opts[["header-dir"]] else "header"
  export_dir <- if (!is.null(opts[["export-dir"]])) opts[["export-dir"]] else "export"

  result <- process_acs_batch(
    raw_dir = raw_dir,
    header_dir = header_dir,
    export_dir = export_dir,
    token_prefix = token_prefix
  )

  cat("Cleaned files written to:", result$export_dir, "\n")
  cat("Deleted-cell log written to:", result$deleted_log_path, "\n")
  cat("Misalignment log written to:", result$generalized_misalignment_log_path, "\n")
  print(result$summary)
}
