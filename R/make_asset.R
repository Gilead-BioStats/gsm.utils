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

#' Build an index line for YAML front matter
#'
#' @inheritParams .shared-params
#' @returns A single string or `NULL`.
#' @keywords internal
.make_index_line <- function(intIndex) {
  if (length(intIndex) && !is.na(intIndex)) {
    paste0("index: ", intIndex)
  }
}

#' Build a title line for YAML front matter
#'
#' @inheritParams .shared-params
#' @returns A single string, e.g. `'title: "My Title"'`.
#' @keywords internal
.make_title_line <- function(strTitle) {
  paste0("title: \"", strTitle, "\"")
}

#' Build a generic asset template
#'
#' @param lHeaders (`list`) Additional YAML header fields as a named list.
#'   Requires the \pkg{yaml} package when non-empty.
#' @param chrBody (`character`) Lines of content after the front matter.
#' @inheritParams .shared-params
#' @returns Character vector of template lines.
#' @keywords internal
.build_asset_template <- function(
  strTitle,
  intIndex,
  lHeaders = list(),
  chrBody = character()
) {
  extra_lines <- character()
  if (length(lHeaders)) {
    rlang::check_installed("yaml")
    extra_yaml <- yaml::as.yaml(
      lHeaders,
      handlers = list(
        logical = function(x) {
          result <- ifelse(x, "true", "false")
          class(result) <- "verbatim"
          result
        }
      )
    )
    # Split into lines and drop trailing empty line from as.yaml.
    extra_lines <- strsplit(extra_yaml, "\n")[[1]]
    extra_lines <- extra_lines[nzchar(extra_lines)]
  }

  c(
    "---",
    .make_title_line(strTitle),
    .make_index_line(intIndex),
    extra_lines,
    "---",
    chrBody
  )
}
