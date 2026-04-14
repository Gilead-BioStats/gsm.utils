#' Add rendered assets to pkgdown navbar menu
#'
#' @inheritParams build_assets_params
#' @returns `NULL` (invisibly). Updates `_pkgdown.yml` in place.
#' @keywords internal
add_pkgdown_nav <- function(
  pkgdown_yml,
  menu_subdir,
  rendered_assets,
  verbose
) {
  if (!length(pkgdown_yml) || !fs::file_exists(pkgdown_yml)) {
    cli::cli_inform(
      "No {.file {pkgdown_yml}} found. Skipping pkgdown menu update."
    )
    return(invisible(NULL))
  }

  rlang::check_installed("yaml", reason = "to manipulate _pkgdown.yml files.")

  menu <- fs::path_file(menu_subdir)
  pkgdown_contents <- yaml::read_yaml(pkgdown_yml)

  if (length(rendered_assets)) {
    pkgdown_contents <- update_pkgdown_menu(
      pkgdown_contents,
      menu,
      menu_subdir,
      rendered_assets,
      verbose
    )
  } else {
    pkgdown_contents <- remove_pkgdown_menu(pkgdown_contents, menu, verbose)
  }
  write_yaml(pkgdown_contents, pkgdown_yml)
  invisible(NULL)
}

#' Update pkgdown contents with menu
#'
#' @inheritParams build_assets_params
#' @returns An updated list of pkgdown YAML contents with the new menu entries
#'   added.
#' @keywords internal
update_pkgdown_menu <- function(
  pkgdown_contents,
  menu,
  menu_subdir,
  rendered_assets,
  verbose
) {
  pkgdown_contents <- ensure_pkgdown_menu_section(pkgdown_contents, menu) |>
    add_assets_to_pkgdown_menu(
      menu,
      menu_subdir,
      rendered_assets
    )
  if (verbose) {
    n_rendered <- length(rendered_assets)
    cli::cli_inform(
      "Added {.val {n_rendered}} {menu} {qty(n_rendered)} item{?s} to pkgdown layout."
    )
  }
  return(pkgdown_contents)
}

#' Ensure pkgdown menu section exists
#'
#' @inheritParams build_assets_params
#' @returns An updated list of pkgdown YAML contents with the new menu added.
#' @keywords internal
ensure_pkgdown_menu_section <- function(pkgdown_contents, menu) {
  if (is.null(pkgdown_contents[["navbar"]][["components"]][[menu]])) {
    pkgdown_contents[["navbar"]][["components"]][[menu]] <- list(
      text = to_title_case(menu),
      menu = list()
    )
  }

  # Ensure menu is in navbar$structure$left if structure exists
  if (!is.null(pkgdown_contents[["navbar"]][["structure"]][["left"]])) {
    if (!(menu %in% pkgdown_contents[["navbar"]][["structure"]][["left"]])) {
      pkgdown_contents[["navbar"]][["structure"]][["left"]] <- c(
        pkgdown_contents[["navbar"]][["structure"]][["left"]],
        menu
      )
    }
  }

  return(pkgdown_contents)
}

#' Update pkgdown contents with menu entries for rendered assets
#'
#' @inheritParams build_assets_params
#' @returns An updated list of pkgdown YAML contents with the new menu entries
#'   added.
#' @keywords internal
add_assets_to_pkgdown_menu <- function(
  pkgdown_contents,
  menu,
  menu_subdir,
  rendered_assets
) {
  metadata <- construct_menu_metadata_table(menu_subdir)
  menu_items <- construct_menu(rendered_assets, metadata)

  pkgdown_contents[["navbar"]][["components"]][[menu]][["menu"]] <- menu_items
  return(pkgdown_contents)
}

#' Remove menu from pkgdown YAML
#'
#' @inheritParams build_assets_params
#' @returns An updated list of pkgdown YAML contents with the menu removed.
#' @keywords internal
remove_pkgdown_menu <- function(pkgdown_contents, menu, verbose) {
  navbar_list <- pkgdown_contents[["navbar"]]
  menu_exists <- length(navbar_list[["components"]][[menu]]) != 0
  left_exists <- length(navbar_list[["structure"]][["left"]]) != 0 &&
    menu %in% navbar_list[["structure"]][["left"]]
  if (verbose && (menu_exists || left_exists)) {
    cli::cli_inform(
      "No rendered assets found. Removing {menu} menu from pkgdown layout."
    )
  }
  pkgdown_contents[["navbar"]][["components"]][[menu]] <- NULL
  pkgdown_contents[["navbar"]][["structure"]][["left"]] <- setdiff(
    navbar_list[["structure"]][["left"]],
    menu
  )

  return(pkgdown_contents)
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
