#' Shared parameters
#'
#' These parameters are used in multiple functions. They are defined here to
#' make them easier to import and to find.
#'
#' @param assets_dir (`string`) Path to the directory where rendered `.html`
#'   files should be saved. Default is `"pkgdown/assets"`.
#' @param existing_menu List. Existing menu items from the pkgdown YAML
#'   contents, if any, to preserve when adding new menu items for rendered
#'   assets.
#' @param menu (`string`) Menu folder name.
#' @param menu_subdir (`string`) Path to the subdirectory containing `.*md`
#'   files to render and add to pkgdown.
#' @param output_dir (`string`) Directory to write the example to.
#' @param output_file (`string`) Path to output HTML file to create.
#' @param overwrite (`boolean`) Overwrite existing files? Default is `TRUE`.
#' @param params List. Optional list of parameters to pass to
#'   [quarto::quarto_render()].
#' @param pkgdown_contents List. The contents of `_pkgdown.yml`, as loaded by
#'   [yaml::read_yaml()].
#' @param pkgdown_yml (`string`) Path to the `_pkgdown.yml` file to update with
#'   new menu items, or from which to remove unused menu items.
#' @param qmd_file (`string`) Path to qmd file to render.
#' @param rendered_assets (`character`) Paths to successfully rendered HTML
#'   files to add to pkgdown menu.
#' @param root_dir (`string`) Path to the root directory of the package, used to
#'   construct absolute paths. Default is `"."`.
#' @param source_dir (`string`) Path to the directory containing subdirectories
#'   with `.*md` files to render. Default is `"pkgdown/menus"`.
#' @param strPackageDir (`string`) Path to the package directory.
#' @param verbose (`boolean`) Inform about changes? Default is `TRUE`.
#'
#' @name .shared-params
#' @keywords internal
NULL
