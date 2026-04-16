#' Render Rmd and qmd files in a menu subdirectory
#'
#' @inheritParams build_assets_params
#' @returns Character vector of relative paths to rendered HTML files for
#'   successfully rendered Rmd and qmd files.
#' @keywords internal
render_assets <- function(menu_subdir, assets_dir, verbose) {
  subdir <- fs::path_file(menu_subdir)
  output_subdir <- fs::path(assets_dir, subdir)

  rendered_rmds <- render_rmd_assets(menu_subdir, output_subdir, verbose)
  rendered_qmds <- render_qmd_assets(menu_subdir, output_subdir, verbose)

  rendered_mds <- c(character(), rendered_rmds, rendered_qmds)
  # Get rid of "" paths used as placeholders for failed renders, then return the
  # relative path.
  fs::path_rel(rendered_mds[nzchar(rendered_mds)], assets_dir)
}
