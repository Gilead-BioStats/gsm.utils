#' Render Rmd files in a menu subdirectory
#'
#' @inheritParams build_assets_params
#' @returns Character vector of relative paths to rendered HTML files for
#'   successfully rendered Rmd files.
#' @keywords internal
render_rmd_assets <- function(menu_subdir, output_dir, verbose) {
  rmd_files <- fs::dir_ls(menu_subdir, glob = "*.Rmd")
  if (length(rmd_files)) {
    purrr::map_chr(
      rmd_files,
      \(rmd_file) {
        output_file <- fs::path(
          output_dir,
          fs::path_ext_set(fs::path_file(rmd_file), "html")
        )
        rendered <- tryCatch(
          {
            render_rmd(
              strInputPath = rmd_file,
              strOutputFile = fs::path_file(output_file),
              strOutputDir = output_dir,
              quiet = !verbose
            )
          },
          error = function(e) {
            cli::cli_warn(
              "Failed to render {.file {rmd_file}}: {conditionMessage(e)}"
            )
            ""
          }
        )
        if (fs::file_exists(rendered %||% "")) {
          output_file
        } else {
          ""
        }
      }
    )
  }
}

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
  if (!fs::file_access(strOutputDir, mode = "write")) {
    cli::cli_abort(
      "You do not have permission to write to {.path {strOutputDir}}. "
    )
  }

  output_path <- fs::path(strOutputDir, strOutputFile)

  # Create a temporary directory with a safe path (no spaces) to avoid issues
  # with Quarto when paths contain spaces
  safe_temp_dir <- fs::file_temp("gsm_render_temp")
  on.exit(unlink(safe_temp_dir), add = TRUE)
  fs::dir_create(safe_temp_dir)

  rendered <- tryCatch({
    rmarkdown::render(
      input = strInputPath,
      output_file = output_path,
      intermediates_dir = safe_temp_dir,
      params = lParams,
      envir = new.env(parent = globalenv()),
      quiet = quiet
    )
  })

  invisible(rendered)
}
