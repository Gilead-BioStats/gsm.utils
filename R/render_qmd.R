#' Render qmd files in a menu subdirectory
#'
#' @inheritParams .shared-params
#' @returns Character vector of paths to rendered HTML files for successfully
#'   rendered qmd files, or `""` for failed renders.
#' @keywords internal
render_qmd_assets <- function(menu_subdir, output_dir, verbose) {
  qmd_files <- fs::dir_ls(menu_subdir, glob = "*.qmd")
  if (length(qmd_files)) {
    # We'll put everything into a temp dir for rendering. We'll share a temp
    # dir, so we don't have to (for example) repeatedly copy files.
    safe_temp_dir <- withr::local_tempdir()
    fs::dir_copy(menu_subdir, safe_temp_dir, overwrite = TRUE)

    qmd_tempfiles <- unname(fs::dir_ls(safe_temp_dir, glob = "*.qmd"))
    purrr::map_chr(
      qmd_tempfiles,
      \(qmd_file) {
        output_file <- fs::path(
          output_dir,
          fs::path_ext_set(fs::path_file(qmd_file), "html")
        )
        rendered <- tryCatch(
          {
            render_qmd(qmd_file, output_file, verbose = verbose)
          },
          error = function(e) {
            cli::cli_warn(
              "Failed to render {.file {qmd_file}}: {conditionMessage(e)}",
              class = "gsm.utils-render_failure"
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

#' Render an individual qmd file
#'
#' @inheritParams .shared-params
#' @returns `output_file` (on success) or `""` (on failure), invisibly.
#' @keywords internal
render_qmd <- function(
  qmd_file,
  output_file,
  params = NULL,
  verbose = FALSE
) {
  # Skipping coverage because this really just renders via quarto Test
  # manually.
  #
  # nocov start
  rlang::check_installed("quarto", reason = "to render qmd files.")

  # I already created a safe tempdir before this to render the whole group of
  # QMDs. If we ever want to use just this function, we should restructure that.

  working_dir <- fs::path_dir(qmd_file)
  output_dir <- fs::path_dir(output_file)
  fs::dir_create(output_dir)

  rendered <- tryCatch(
    {
      quarto::quarto_render(
        input = qmd_file,
        output_file = fs::path_file(output_file),
        execute_dir = working_dir,
        # Hard-code `embed-resources` so we don't have to worry about copying
        # over supporting files.
        metadata = c(list(`embed-resources` = TRUE), params),
        quiet = !verbose
      )
      fs::file_copy(
        fs::path(working_dir, fs::path_file(output_file)),
        output_file,
        overwrite = TRUE
      )
      return(output_file)
    },
    error = function(e) ""
  )

  invisible(rendered)
  # nocov end
}
