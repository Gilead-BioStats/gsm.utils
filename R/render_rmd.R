#' Custom Rmarkdown render function
#'
#' Rmarkdown render function that defaults to rendering intermediate Rmd files
#' in a temporary directory, and falls back to a writable output directory when
#' needed.
#'
#' @param strInputPath `string` or `fs_path` Path to the template `Rmd` file.
#' @param strOutputFile `string` Filename for the output.
#' @param strOutputDir `string` or `fs_path` Path to the directory where the
#'   output will be saved.
#' @param lParams `list` Parameters to pass to the template `Rmd` file.
#' @param quiet Logical. Passed to [rmarkdown::render()].
#'
#' @return Rendered Rmarkdown file path (invisibly).
#' @export
render_rmd <- function(
  strInputPath,
  strOutputFile = basename(strInputPath),
  strOutputDir = getwd(),
  lParams = NULL,
  quiet = FALSE
) {
  rlang::check_installed("rmarkdown", reason = "to render Rmd files.")

  fs::dir_create(strOutputDir)
  if (file.access(strOutputDir, mode = 2) == -1) {
    tpath <- tempdir()
    cli::cli_inform(
      "You do not have permission to write to {.path {strOutputDir}}. "
    )
    cli::cli_inform("Report will be saved to {.path {tpath}}.")
    strOutputDir <- tpath
  }

  output_path <- fs::path(strOutputDir, strOutputFile)
  rendered <- rmarkdown::render(
    input = strInputPath,
    output_file = output_path,
    intermediates_dir = tempdir(),
    params = lParams,
    envir = new.env(parent = globalenv()),
    quiet = quiet
  )

  invisible(rendered)
}
