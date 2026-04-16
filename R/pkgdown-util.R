#' Convert a string to title case, preserving acronyms
#'
#' @param x A string in "camelCase", "snake_case", "kebab-case", "Title Case",
#'   "Sentence case", or "lowercase" format. Strings of capital letters within
#'   the string (e.g. "API" in "TheAPIClient") will be treated a group.
#' @returns The string in Title Case, with separators removed and acronyms
#'   preserved. For example, "theAPIClient" and "the_API_client" both become
#'   "The API Client".
#' @keywords internal
to_title_case <- function(x) {
  pattern <- extract_pattern(x)
  stringr::str_match(x, pattern)[-1] |>
    paste(collapse = " ") |>
    # tools::toTitleCase() keeps all-uppercase pieces as-is, while
    # stringr::str_to_title() converts them to title case, eg "API" to "Api".
    tools::toTitleCase()
}

#' Turn a string into a regex pattern to match pieces of that string
#'
#' @param x A string in "camelCase", "snake_case", "kebab-case", "Title Case",
#'   "Sentence case", or "lowercase" format. Strings of capital letters within
#'   the string (e.g. "API" in "TheAPIClient") will be treated a group.
#' @returns A regex pattern to match pieces of the input string, ignoring
#'   separators and case.
#' @keywords internal
extract_pattern <- function(x) {
  paste0(
    "(",
    stringr::str_split_1(
      stringr::str_to_snake(x),
      "_"
    ),
    ")",
    collapse = "[-_ ]*"
  ) |>
    stringr::regex(ignore_case = TRUE)
}

#' Determine a title for a file
#'
#' @param path Character. The path to a file.
#' @param title Character. An optional string to use as the title.
#' @returns A title-case string to use as the title of the file, without html,
#'   etc.
#' @keywords internal
resolve_md_title <- function(path, title = NULL) {
  rlang::check_installed("rvest", reason = "to resolve md titles.")
  title <- if (length(title) && nzchar(title)) {
    # Deal with extra HTML in titles (useful in QMD slide decks).
    rvest::read_html(paste0("<html>", title, "</html>")) |>
      rvest::html_text2() |>
      stringr::str_trim()
  }
  # Make sure it *still* has characters
  if (!length(title) || !nzchar(title) || is.na(title)) {
    title <- NULL
  }
  title %||% to_title_case(fs::path_ext_remove(fs::path_file(path)))
}
