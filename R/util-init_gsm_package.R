#' Initialize gsm Extension package
#'
#' @param strPackageDir path to package directory
#' @param lDescriptionFields `list` of description fields, passed to
#'   [usethis::create_package()]. Default is `list()`.
#' @param bIncludeWorkflowDir `boolean` argument declaring whether or not to
#'   include the `inst/workflow` directory in the root of the package. Default
#'   is `TRUE`.
#'
#' @export
init_gsm_package <- function(
  strPackageDir,
  lDescriptionFields = list(),
  bIncludeWorkflowDir = TRUE
) {
  rlang::check_installed("usethis", reason = "to create the package.")
  rlang::check_installed("withr", reason = "to work in the package directory.")

  if (!fs::dir_exists(strPackageDir)) {
    fs::dir_create(strPackageDir)
    init_git <- TRUE
  }
  usethis::create_package(strPackageDir, open = F, fields = lDescriptionFields)
  withr::with_dir(strPackageDir, {
    usethis::use_pkgdown_github_pages()
    usethis::use_testthat()
    usethis::use_github_action("check-standard")
    fs::dir_create("inst")

    # add gsm-specific GHA and issue template content to .github from `inst/gha_templates`
    gha_templates_source <- system.file("gha_templates", package = "gsm.utils")
    fs::dir_copy(
      gha_templates_source,
      ".github/gha_templates"
    )
    if (bIncludeWorkflowDir) {
      fs::dir_create("inst/workflow")
      fs::dir_create("inst/workflow/1_mappings")
      fs::dir_create("inst/workflow/2_metrics")
      fs::dir_create("inst/workflow/3_reporting")
      fs::dir_create("inst/workflow/4_modules")
    }
  })
}
