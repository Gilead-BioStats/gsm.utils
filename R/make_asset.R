#' Create a pkgdown menu asset file
#'
#' Writes a completed template to the appropriate subdirectory under
#' `strMenuDir`. This is the generic engine behind [make_example()] and
#' similar helpers.
#'
#' @param strFilename (`string`) File name with extension, e.g.
#'   `"Example_Country_Report.Rmd"`.
#' @param strMenu (`string`) Menu subdirectory name, e.g. `"examples"` or
#'   `"slides"`.
#' @param strTemplate (`character`) Completed file body to write (a character
#'   vector of lines).
#' @param strMenuDir (`string`) Root directory for menu sources. Default
#'   `"pkgdown/menus"`.
#' @inheritParams .shared-params
#'
#' @returns Path to the created file (invisibly).
#' @export
make_asset <- function(
  strFilename,
  strMenu,
  strTemplate,
  strMenuDir = "pkgdown/menus",
  overwrite = FALSE,
  verbose = TRUE
) {
  rlang::check_required(strFilename)
  rlang::check_required(strMenu)
  rlang::check_required(strTemplate)

  output_dir <- fs::path(strMenuDir, strMenu)
  fs::dir_create(output_dir)

  output_path <- fs::path(output_dir, strFilename)

  if (fs::file_exists(output_path) && !isTRUE(overwrite)) {
    cli::cli_abort("File already exists: {.path {output_path}}")
  }

  writeLines(strTemplate, output_path)
  if (verbose) {
    cli::cli_inform("Created {strMenu} asset at {.path {output_path}}.")
  }
  invisible(output_path)
}
