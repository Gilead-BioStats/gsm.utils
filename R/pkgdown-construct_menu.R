#' Construct an empty data frame of menu metadata
#'
#' @returns A default blank data.frame with columns `html_file`, `title`, and
#'   `index` for each md file in the menu subdirectory.
#' @keywords internal
empty_menu_metadata_table <- function() {
  data.frame(
    html_file = character(),
    title = character(),
    index = numeric()
  )
}

#' Construct a data frame of menu metadata from md files
#'
#' @inheritParams build_assets_params
#' @returns A data.frame with columns `html_file`, `title`, and `index` for each
#'   md file in the menu subdirectory.
#' @keywords internal
construct_menu_metadata_table <- function(menu_subdir) {
  if (is.null(menu_subdir) || !fs::dir_exists(menu_subdir)) {
    return(empty_menu_metadata_table())
  }

  rlang::check_installed("rmarkdown", reason = "to read md metadata.")

  rmd_files <- fs::dir_ls(menu_subdir, glob = "*.Rmd")
  qmd_files <- fs::dir_ls(menu_subdir, glob = "*.qmd")
  md_files <- unname(c(rmd_files, qmd_files))
  if (!length(md_files)) {
    return(empty_menu_metadata_table())
  }

  purrr::map(md_files, construct_md_metadata_table) |>
    purrr::list_rbind()
}

#' Construct a data frame of menu metadata from a single md file
#'
#' @inheritParams build_assets_params
#' @returns A data.frame with columns `html_file`, `title`, and `index` for one
#'   md file.
#' @keywords internal
construct_md_metadata_table <- function(md_file) {
  front_matter <- tryCatch(
    rmarkdown::yaml_front_matter(md_file),
    error = function(e) list()
  )
  title <- resolve_md_title(md_file, front_matter$title)
  index_val <- front_matter$index
  index <- suppressWarnings(as.numeric(index_val))
  if (!length(index) || is.na(index)) {
    index <- Inf
  }
  data.frame(
    html_file = fs::path_ext_set(fs::path_file(md_file), "html"),
    title = as.character(title),
    index = index,
    stringsAsFactors = FALSE
  )
}

#' Construct a list of menu entries for rendered assets
#'
#' @inheritParams build_assets_params
#' @returns A list of lists with `text` and `href` entries for each rendered
#'   asset, sorted by `index` and `title` metadata from the corresponding md
#'   file.
#' @keywords internal
construct_menu <- function(rendered_assets, metadata, existing_menu = NULL) {
  if (!length(rendered_assets)) {
    return(as.list(existing_menu))
  }
  menu_data <- dplyr::tibble(
    html = rendered_assets,
    html_file = fs::path_file(rendered_assets)
  ) |>
    dplyr::left_join(metadata, by = "html_file") |>
    dplyr::arrange(.data$index, .data$title) |>
    dplyr::select("html", "title")
  rendered_menu <- purrr::pmap(menu_data, \(html, title) {
    list(text = title, href = unclass(html))
  })
  # If there are existing menu items, replace old titles with new for any
  # overlaps, but keep any existing menu items that don't have new rendered
  # assets.
  existing_menu_assets <- purrr::map_chr(existing_menu, \(x) {
    x[["href"]] %||% ""
  })
  leftover_menu_items <- existing_menu[
    !existing_menu_assets %in% menu_data$html
  ]
  return(c(rendered_menu, leftover_menu_items))
}
