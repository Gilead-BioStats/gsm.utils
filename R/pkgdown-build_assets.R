#' Build additional pkgdown assets
#'
#' Scan a directory for subdirectories, render any `.*md` files in those
#' subdirectories to `.html`, and add them to the pkgdown index.
#'
#' @inheritParams .shared-params
#' @returns `NULL` (invisibly). Called for the side effect of setting up
#'   pkgdown assets.
#' @export
build_assets <- function(
  source_dir = "pkgdown/menus",
  assets_dir = "pkgdown/assets",
  pkgdown_yml = "_pkgdown.yml",
  root_dir = ".",
  verbose = FALSE
) {
  source_dir <- fs::path_abs(source_dir, start = root_dir)
  assets_dir <- fs::path_abs(assets_dir, start = root_dir)
  pkgdown_yml <- fs::path_abs(pkgdown_yml, start = root_dir)
  if (!fs::dir_exists(source_dir)) {
    cli::cli_inform("Source directory {.path {source_dir}} does not exist.")
    return(invisible(NULL))
  }
  menu_subdirs <- fs::dir_ls(source_dir, type = "directory")

  for (menu_subdir in menu_subdirs) {
    add_menu(menu_subdir, assets_dir, pkgdown_yml, verbose)
  }
}

#' Add a menu to pkgdown from a subdirectory of assets
#'
#' @inheritParams .shared-params
#' @returns `NULL` (invisibly). Called for the side effect of updating
#'   `pkgdown_yml` with new menu items based on rendered assets.
#' @keywords internal
add_menu <- function(menu_subdir, assets_dir, pkgdown_yml, verbose) {
  rendered_assets <- render_assets(menu_subdir, assets_dir, verbose)
  add_pkgdown_nav(
    pkgdown_yml,
    menu_subdir,
    rendered_assets,
    assets_dir,
    verbose
  )
}
