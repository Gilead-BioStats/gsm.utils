#' Initialize gsm Extension package
#'
#' @param lDescriptionFields (`list`) Description fields, passed to
#'   [usethis::create_package()]. Default is `list()`.
#' @param bIncludeWorkflowDir (`boolean`) Whether or not to include the
#'   `inst/workflow` directory in the root of the package. Default is `TRUE`.
#' @param strOrg (`string`) GitHub organization under which the repo should be
#'   created. Set to `NULL` to create the package in your personal GitHub
#'   account.
#' @inheritParams .shared-params
#'
#' @export
init_gsm_package <- function(
  strPackageDir,
  lDescriptionFields = list(),
  bIncludeWorkflowDir = TRUE,
  strOrg = "Gilead-BioStats"
) {
  rlang::check_installed("usethis", reason = "to create the package.")
  rlang::check_installed("withr", reason = "to work in the package directory.")
  rlang::check_installed("testthat", reason = "to set up testthat.")

  fs::dir_create(strPackageDir)
  usethis::create_package(
    strPackageDir,
    open = FALSE,
    fields = lDescriptionFields
  )
  withr::with_dir(strPackageDir, {
    usethis::use_git()
    usethis::use_github(organisation = strOrg)
    usethis::use_pkgdown_github_pages()
    # This will also get rid of the baseline pkgdown.yaml added by
    # use_pkgdown_github_pages()
    update_gsm_package()
    usethis::use_testthat()
    if (bIncludeWorkflowDir) {
      fs::dir_create("inst/workflow/1_mappings")
      fs::dir_create("inst/workflow/2_metrics")
      fs::dir_create("inst/workflow/3_reporting")
      fs::dir_create("inst/workflow/4_modules")
    }
  })
}
