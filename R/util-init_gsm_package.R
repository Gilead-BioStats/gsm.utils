#' Initialize gsm Extension package
#'
#' @param strPackageDir path to package directory
#' @param lDescriptionFields `list` of description fields, passed to [usethis::create_package()]. Default is `list()`.
#' @param bIncludeWorkflowDir `boolean` argument declaring whether or not to include the `inst/workflow` directory in the root of the package. Default is `TRUE`.
#'
init_gsm_package <- function(strPackageDir,
                             lDescriptionFields = list(),
                             bIncludeWorkflowDir = TRUE) {
    if (!dir.exists(strPackageDir)) {
        dir.create(strPackageDir)
        init_git <- TRUE
    }
    usethis::create_package(strPackageDir,
                            open = F,
                            fields = lDescriptionFields
    )
    withr::with_dir(strPackageDir, {
        usethis::use_pkgdown_github_pages()
        usethis::use_testthat()
        usethis::use_github_action("check-standard")
        dir.create("inst")

        # add gsm-specific GHA and issue template content
        file.copy(system.file("gha_templates", package = "gsm.utils"),
                  ".github",
                  recursive = T
        )
        if (bIncludeWorkflowDir) {
            dir.create("inst/workflow")
            dir.create("inst/workflow/1_mappings")
            dir.create("inst/workflow/2_metrics")
            dir.create("inst/workflow/3_reporting")
            dir.create("inst/workflow/4_modules")
        }
    })
}
