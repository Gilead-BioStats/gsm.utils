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
#' @param rmd_dir Character. Path to directory containing example `\.Rmd` files
#'   used to derive titles and order. Default is `"inst/examples"`.
#'
#' @returns `NULL` invisibly.
#' @export
add_pkgdown_examples <- function(
  examples_dir = "pkgdown/assets/examples",
  pkgdown_yml = "_pkgdown.yml",
  rmd_dir = "inst/examples"
) {
  rlang::check_installed("yaml", reason = "to manipulate _pkgdown.yml files.")

  html_files <- list_non_index_html(examples_dir)
  metadata <- list_example_metadata(rmd_dir)

  if (length(html_files)) {
    update_pkgdown_examples(pkgdown_yml, html_files, metadata)
  } else {
    remove_pkgdown_examples(pkgdown_yml, examples_dir)
  }
  invisible(NULL)
}

#' List HTML files excluding index.html
#'
#' @param examples_dir Character. Path to directory containing example HTML files.
#' @returns Character vector of HTML file names.
#' @keywords internal
list_non_index_html <- function(examples_dir) {
  html_files <- basename(fs::dir_ls(examples_dir, regexp = "\\.html$"))
  html_files[html_files != "index.html"]
}

#' Update pkgdown YAML with example menu entries
#'
#' @param pkgdown_yml Character. Path to `_pkgdown.yml`.
#' @param html_files Character vector of example HTML files.
#' @param metadata Data frame of example metadata.
#' @returns `NULL` invisibly.
#' @keywords internal
update_pkgdown_examples <- function(pkgdown_yml, html_files, metadata) {
  if (!is.null(pkgdown_yml) && file.exists(pkgdown_yml)) {
    pkgdown_yaml <- yaml::read_yaml(pkgdown_yml)
    pkgdown_yaml <- ensure_pkgdown_examples_section(pkgdown_yaml)
    pkgdown_yaml <- add_pkgdown_examples_to_yaml(
      pkgdown_yaml,
      html_files,
      metadata
    )
    write_yaml(pkgdown_yaml, pkgdown_yml)
    cli::cli_inform(
      "Updated {.file {pkgdown_yml}} with {.val {length(html_files)}} example{?s}."
    )
  }
}

#' Ensure pkgdown examples menu exists
#'
#' @param pkgdown_yaml List representation of `_pkgdown.yml`.
#' @returns Updated pkgdown YAML list.
#' @keywords internal
ensure_pkgdown_examples_section <- function(pkgdown_yaml) {
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

#' Add example menu items to pkgdown YAML
#'
#' @param pkgdown_yaml List representation of `_pkgdown.yml`.
#' @param html_files Character vector of example HTML files.
#' @param metadata Data frame of example metadata.
#' @returns Updated pkgdown YAML list.
#' @keywords internal
add_pkgdown_examples_to_yaml <- function(pkgdown_yaml, html_files, metadata) {
  menu_items <- build_examples_menu(html_files, metadata)
  pkgdown_yaml$navbar$components$examples$menu <- lapply(
    menu_items,
    function(item) {
      list(
        text = item$title,
        href = fs::path("examples", item$html)
      )
    }
  )
  return(pkgdown_yaml)
}

#' Remove examples menu from pkgdown YAML
#'
#' @param pkgdown_yml Character. Path to `_pkgdown.yml`.
#' @param examples_dir Character. Path to examples directory.
#' @returns `NULL` invisibly.
#' @keywords internal
remove_pkgdown_examples <- function(pkgdown_yml, examples_dir) {
  cli::cli_inform("No HTML files found in {.path {examples_dir}}.")
  if (!is.null(pkgdown_yml) && fs::file_exists(pkgdown_yml)) {
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

#' List example metadata from Rmd files
#'
#' @param rmd_dir Character. Path to directory containing example Rmd files.
#' @returns Data frame with `html`, `title`, and `index` columns.
#' @keywords internal
list_example_metadata <- function(rmd_dir) {
  if (is.null(rmd_dir) || !fs::dir_exists(rmd_dir)) {
    return(data.frame(html = character(), title = character(), index = numeric()))
  }

  rlang::check_installed(
    "rmarkdown",
    reason = "to read example metadata from Rmd files."
  )

  rmd_files <- fs::dir_ls(rmd_dir, regexp = "\\.Rmd$")
  if (!length(rmd_files)) {
    return(data.frame(html = character(), title = character(), index = numeric()))
  }

  metadata <- lapply(rmd_files, function(rmd_file) {
    front_matter <- tryCatch(
      rmarkdown::yaml_front_matter(rmd_file),
      error = function(e) list()
    )
    title_val <- front_matter$title
    if (length(title_val) == 0) {
      title_val <- NULL
    }
    title <- rlang::`%||%`(
      title_val,
      tools::toTitleCase(gsub("_", " ", tools::file_path_sans_ext(basename(rmd_file))))
    )
    index_val <- front_matter$index
    if (length(index_val) == 0) {
      index_val <- NA_real_
    }
    index <- suppressWarnings(as.numeric(index_val))
    if (length(index) == 0 || is.na(index)) {
      index <- Inf
    }
    data.frame(
      html = paste0(tools::file_path_sans_ext(basename(rmd_file)), ".html"),
      title = as.character(title),
      index = index,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, metadata)
}

#' Build ordered example menu
#'
#' @param html_files Character vector of example HTML files.
#' @param metadata Data frame with `html`, `title`, and `index` columns.
#' @returns List of menu entries with `html` and `title`.
#' @keywords internal
build_examples_menu <- function(html_files, metadata) {
  html_files <- html_files[html_files != "index.html"]
  if (!length(html_files)) {
    return(list())
  }

  meta <- data.frame(
    html = html_files,
    title = tools::toTitleCase(gsub(
      "_",
      " ",
      tools::file_path_sans_ext(html_files)
    )),
    index = Inf,
    stringsAsFactors = FALSE
  )

  if (nrow(metadata)) {
    meta <- merge(meta, metadata, by = "html", all.x = TRUE, suffixes = c(".default", ".rmd"))
    has_title <- !is.na(meta$title.rmd) & nzchar(meta$title.rmd)
    meta$title <- meta$title.default
    meta$title[has_title] <- meta$title.rmd[has_title]

    has_index <- is.finite(meta$index.rmd)
    meta$index[has_index] <- meta$index.rmd[has_index]
    meta <- meta[, c("html", "title", "index")]
  }

  meta <- meta[order(meta$index, meta$title), , drop = FALSE]
  lapply(seq_len(nrow(meta)), function(i) {
    list(html = meta$html[i], title = meta$title[i])
  })
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
