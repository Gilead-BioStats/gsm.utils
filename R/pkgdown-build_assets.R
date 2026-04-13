#' Asset params
#'
#' @param assets_dir Character. Path to the directory where rendered `.html`
#'   files should be saved. Default is `"pkgdown/assets"`.
#' @param menu Character. Menu folder name.
#' @param menu_subdir Character. Path to the subdirectory containing `.*md`
#'   files to render and add to pkgdown.
#' @param output_file Character. Path to output HTML file to create.
#' @param params List. Optional list of parameters to pass to
#'   [quarto::quarto_render()].
#' @param pkgdown_contents List. The contents of `_pkgdown.yml`, as loaded by
#'   [yaml::read_yaml()].
#' @param pkgdown_yml Character. Path to the `_pkgdown.yml` file to update with
#'   new menu items, or from which to remove unused menu items.
#' @param qmd_file Character. Path to qmd file to render.
#' @param rendered_assets Character. Path to successfully rendered HTML files to
#'   add to pkgdown menu.
#' @param root_dir Character. Path to the root directory of the package, used to
#'   construct absolute paths. Default is `"."`.
#' @param source_dir Character. Path to the directory containing subdirectories
#'   with `.*md` files to render. Default is `"pkgdown/menus"`.
#' @param verbose Logical. Whether to print messages about rendered assets and
#'   menu updates.
#'
#' @name build_assets_params
#' @keywords internal
NULL

#' Build additional pkgdown assets
#'
#' Scan a directory for subdirectories, render any `.*md` files in those
#' subdirectories to `.html`, and add them to the pkgdown index.
#'
#' @inheritParams build_assets_params
#' @returns `NULL` (invisibily). Called for the side effect of setting up
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
    return(invisible(character()))
  }
  menu_subdirs <- fs::dir_ls(source_dir, type = "directory")

  for (menu_subdir in menu_subdirs) {
    add_menu(menu_subdir, assets_dir, pkgdown_yml, verbose)
  }
}

#' Add a menu to pkgdown from a subdirectory of assets
#'
#' @inheritParams build_assets_params
#' @returns `NULL` (invisibly). Called for the side effect of updating
#'   `pkgdown_yml` with new menu items based on rendered assets.
#' @keywords internal
add_menu <- function(menu_subdir, assets_dir, pkgdown_yml, verbose) {
  rendered_assets <- render_assets(menu_subdir, assets_dir, verbose)
  add_pkgdown_nav(pkgdown_yml, menu_subdir, rendered_assets, verbose)
}
