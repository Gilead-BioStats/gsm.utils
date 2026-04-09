construct_menu <- function(rendered_assets, metadata) {
  if (!length(rendered_assets)) {
    return(list())
  }
  menu_data <- dplyr::tibble(
    html = rendered_assets,
    html_file = fs::path_file(rendered_assets)
  ) |>
    dplyr::inner_join(metadata, by = "html_file") |>
    dplyr::arrange(.data$index, .data$title) |>
    dplyr::select("html", "title")

  purrr::pmap(menu_data, \(html, title) {
    list(text = title, href = unclass(html))
  })
}
