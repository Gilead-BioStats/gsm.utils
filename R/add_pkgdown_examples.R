#' Generate Examples menu in pkgdown
#'
#' Scans for HTML files in a directory (default is `pkgdown/assets/examples`)
#' and updates a standard `_pkgdown.yml` with a new sub-menu listing the html
#' files.
#'
#' @param examples_dir Character. Path to directory containing example HTML
#'   files. Default is `"pkgdown/assets/examples"`.
#' @param pkgdown_yml Character. Path to `_pkgdown.yml` file to update with menu.
#'   Default is `"_pkgdown.yml"`.
#'
#' @returns `NULL` invisibly.
#' @export
add_pkgdown_examples <- function(
  examples_dir = "pkgdown/assets/examples",
  pkgdown_yml = "_pkgdown.yml"
) {
  rlang::check_installed("yaml", reason = "to manipulate _pkgdown.yml files.")

  html_files <- list_non_index_html(examples_dir)

  if (length(html_files)) {
    update_pkgdown_examples(pkgdown_yml, html_files)
  } else {
    remove_pkgdown_examples(pkgdown_yml, examples_dir)
  }
  invisible(NULL)
}

list_non_index_html <- function(examples_dir) {
  html_files <- list.files(examples_dir, pattern = "\\.html$")
  html_files[html_files != "index.html"]
}

update_pkgdown_examples <- function(pkgdown_yml, html_files) {
  if (!is.null(pkgdown_yml) && file.exists(pkgdown_yml)) {
    pkgdown_yaml <- yaml::read_yaml(pkgdown_yml)
    pkgdown_yaml <- ensure_pkdgown_examples_section(pkgdown_yaml)
    pkgdown_yaml <- add_pkgdown_examples_to_yaml(pkgdown_yaml, html_files)
    write_yaml(pkgdown_yaml, pkgdown_yml)
    cli::cli_inform(
      "Updated {.file {pkgdown_yml}} with {.val {length(html_files)}} example{?s}."
    )
  }
}

ensure_pkdgown_examples_section <- function(pkgdown_yaml) {
  if (is.null(pkgdown_yaml$navbar$components$examples)) {
    pkgdown_yaml$navbar$components$examples <- list(
      text = "Examples",
      menu = list()
    )
  }

  # Ensure "examples" is in navbar$structure$left if structure exists
  if (!is.null(pkgdown_yaml$navbar$structure$left)) {
    if (!("examples" %in% pkgdown_yaml$navbar$structure$left)) {
      pkgdown_yaml$navbar$structure$left <- c(
        pkgdown_yaml$navbar$structure$left,
        "examples"
      )
    }
  }

  return(pkgdown_yaml)
}

add_pkgdown_examples_to_yaml <- function(pkgdown_yaml, html_files) {
  pkgdown_yaml$navbar$components$examples$menu <- lapply(
    html_files,
    function(html_file) {
      list(
        text = tools::toTitleCase(gsub(
          "_",
          " ",
          tools::file_path_sans_ext(html_file)
        )),
        href = file.path("examples", html_file)
      )
    }
  )
  return(pkgdown_yaml)
}

remove_pkgdown_examples <- function(pkgdown_yml, examples_dir) {
  cli::cli_inform("No HTML files found in {.path {examples_dir}}.")
  
  if (!is.null(pkgdown_yml) && file.exists(pkgdown_yml)) {
    pkgdown_yaml <- yaml::read_yaml(pkgdown_yml)
    pkgdown_yaml$navbar$components$examples <- NULL
    if (!is.null(pkgdown_yaml$navbar$structure$left)) {
      pkgdown_yaml$navbar$structure$left <- setdiff(
        pkgdown_yaml$navbar$structure$left,
        "examples"
      )
    }
    write_yaml(pkgdown_yaml, pkgdown_yml)
    cli::cli_inform("Removed examples menu from {.file {pkgdown_yml}}.")
  }
}

#' Helper to wrap yaml::write_yaml for testing.
#'
#' @param ... Arguments passed to [yaml::write_yaml()].
#' @returns `NULL` (invisibly)
#' @keywords internal
write_yaml <- function(...) {
  # nocov start
  yaml::write_yaml(...)
  # nocov end
}
