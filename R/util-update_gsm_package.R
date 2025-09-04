#' Update GSM package with global issue templates and GH actions
#'
#' @param strPackageDir path to package directory
#'
#' @returns NULL
#' @export
update_gsm_package <- function(strPackageDir = ".") {
    if (!dir.exists(strPackageDir)) {
        stop("The specified package directory does not exist.")
    }
    ##add issue templates
    add_gsm_issue_templates(strPackageDir = strPackageDir)

    ##add github actions
    add_gsm_actions(strPackageDir = strPackageDir)
}

#' Add GSM issue templates to package
#'
#' @param strPackageDir path to package directory
#' @param overwrite `boolean` argument declaring whether or not to overwrite existing files. Default is `TRUE`.
#'
#' @export
add_gsm_issue_templates <- function(strPackageDir = ".",
                                    overwrite = TRUE) {
    if (!dir.exists(paste0(strPackageDir, "/.github/ISSUE_TEMPLATE"))) {
        dir.create(paste0(strPackageDir, "/.github/ISSUE_TEMPLATE"),
                   recursive = TRUE,
                   overwrite = overwrite
        )
    } else if (!overwrite) {
        stop("The .github/ISSUE_TEMPLATE directory already exists. Set overwrite = TRUE to overwrite it.")
    }
}

#' Add GSM GitHub Actions to package
#'
#' @param strPackageDir path to package directory
#' @param overwrite `boolean` argument declaring whether or not to overwrite existing files. Default is `TRUE`.
#'
#' @export
add_gsm_actions <- function(strPackageDir = ".",
                               overwrite = TRUE) {
    if (!dir.exists(paste0(strPackageDir, "/.github/workflows"))) {
        dir.create(paste0(strPackageDir, "/.github/workflows"),
                   recursive = TRUE,
                   overwrite = overwrite
        )
    } else if (!overwrite) {
        stop("The .github/workflows directory already exists. Set overwrite = TRUE to overwrite it.")
    }
}
