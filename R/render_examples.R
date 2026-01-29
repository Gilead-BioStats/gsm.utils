#' Render example R Markdown files
#'
#' Render all \code{.Rmd} files in an examples directory to HTML output files.
#' Uses standard rmarkdown rendering without injecting custom headers.
#'
#' @param examples_dir Character. Path to directory containing example
#'   \code{.Rmd} files. Default is \code{"inst/examples"}.
#' @param output_dir Character. Path to output directory for rendered HTML
#'   files. Default is \code{"pkgdown/assets/examples"}.
#' @param recursive Logical. If \code{TRUE}, search for \code{.Rmd} files
#'   recursively. Default is \code{FALSE}.
#' @param quiet Logical. Passed to \code{rmarkdown::render()}.
#'
#' @returns Character vector of rendered output files (invisibly).
#' @export
render_examples <- function(
  examples_dir = "inst/examples",
  output_dir = "pkgdown/assets/examples",
  recursive = FALSE,
  quiet = FALSE
) {
  rlang::check_installed(
    "rmarkdown",
    reason = "to render example Rmd files."
  )

  if (!fs::dir_exists(examples_dir)) {
    cli::cli_inform("Directory {.path {examples_dir}} does not exist.")
    return(invisible(character()))
  }

  rmd_files <- fs::dir_ls(
    examples_dir,
    recurse = recursive,
    type = "file",
    glob = "*.Rmd"
  )

  if (!length(rmd_files)) {
    cli::cli_inform("No .Rmd files found in {.path {examples_dir}}.")
    return(invisible(character()))
  }

  output_dir_abs <- normalize_output_dir(output_dir)
  fs::dir_create(output_dir_abs)

  output_files <- character()
  for (rmd_file in rmd_files) {
    cli::cli_inform("Rendering {.file {rmd_file}}.")
    output_file <- fs::path(
      output_dir_abs,
      paste0(tools::file_path_sans_ext(fs::path_file(rmd_file)), ".html")
    )

    rendered <- tryCatch(
      {
        render_rmd(
          input = rmd_file,
          output_file = output_file,
          quiet = quiet
        )
        output_file
      },
      error = function(e) {
        cli::cli_warn(
          "Failed to render {.file {rmd_file}}: {conditionMessage(e)}"
        )
        NULL
      }
    )

    if (!is.null(rendered) && fs::file_exists(output_file)) {
      output_files <- c(output_files, output_file)
    }
  }

  invisible(output_files)
}

normalize_output_dir <- function(output_dir) {
  fs::path_abs(output_dir, start = getwd())
}


#' Helper to wrap rmarkdown::render for testing.
#'
#' @param ... Arguments passed to [rmarkdown::render()].
#' @returns The value returned by \code{rmarkdown::render()}.
#' @keywords internal
render_rmd <- function(...) {
  # nocov start
  rmarkdown::render(...)
  # nocov end
}

#' Helper to wrap rmarkdown::yaml_front_matter for testing.
#'
#' @param rmd_file Character. Path to the \code{.Rmd} file.
#' @returns A list of metadata from the YAML front matter.
#' @keywords internal
read_example_metadata <- function(rmd_file) {
  # nocov start
  rmarkdown::yaml_front_matter(rmd_file)
  # nocov end
}