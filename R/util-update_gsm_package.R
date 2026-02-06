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
  ## add issue templates
  add_gsm_issue_templates(strPackageDir = strPackageDir)

  ## add github actions
  add_gsm_actions(strPackageDir = strPackageDir)
}

#' Add GSM issue templates to package
#'
#' @param strPackageDir path to package directory
#' @param overwrite `boolean` argument declaring whether or not to overwrite
#'   existing files. Default is `TRUE`.
#'
#' @export
add_gsm_issue_templates <- function(strPackageDir = ".", overwrite = TRUE) {
  issuePath <- paste0(strPackageDir, "/.github/ISSUE_TEMPLATE")
  if (!dir.exists(issuePath)) {
    dir.create(issuePath, recursive = TRUE)
  } else if (!overwrite) {
    stop(
      "The .github/ISSUE_TEMPLATE directory already exists. Set overwrite = TRUE to overwrite it."
    )
  }
  file.copy(
    system.file("gha_templates/ISSUE_TEMPLATE", package = "gsm.utils"),
    paste0(strPackageDir, "/.github"),
    recursive = TRUE
  )
}

#' Add GSM GitHub Actions to package
#'
#' @param strPackageDir path to package directory
#' @param overwrite `boolean` argument declaring whether or not to overwrite
#'   existing files. Default is `TRUE`.
#'
#' @export
add_gsm_actions <- function(strPackageDir = ".", overwrite = TRUE) {
  # Get version from manifest
  manifest_path <- system.file("gha_templates/gha_version.json", package = "gsm.utils")
  if (file.exists(manifest_path)) {
    manifest <- jsonlite::fromJSON(manifest_path, simplifyVector = TRUE)
    version <- manifest$version
    cli::cli_alert_info("Installing gsm.utils GitHub Actions v{version}")
  }

  workflowsPath <- paste0(strPackageDir, "/.github/workflows")
  if (!dir.exists(workflowsPath)) {
    dir.create(workflowsPath, recursive = TRUE)
  } else if (!overwrite) {
    stop(
      "The .github/workflows directory already exists. Set overwrite = TRUE to overwrite it."
    )
  }

  result <- file.copy(
    system.file("gha_templates/workflows", package = "gsm.utils"),
    paste0(strPackageDir, "/.github"),
    recursive = TRUE
  )

  if (result) {
    workflow_files <- list.files(
      system.file("gha_templates/workflows", package = "gsm.utils"),
      pattern = "\\.ya?ml$"
    )
    cli::cli_alert_success(
      "Installed {length(workflow_files)} workflow file{?s} to {.path {workflowsPath}}"
    )
  }

  invisible(result)
}

#' Add GSM Contributor Guidelines markdown to package
#'
#' @param strPackageDir path to package directory
#' @param overwrite `boolean` argument declaring whether or not to overwrite
#'   existing files. Default is `TRUE`.
#'
#' @export
add_contributor_guidelines <- function(strPackageDir = ".", overwrite = TRUE) {
  strDirPath <- paste0(strPackageDir, "/.github")
  if (!dir.exists(strDirPath)) {
    dir.create(strDirPath, recursive = TRUE)
  }

  strFilePath <- paste0(strDirPath, "/CONTRIBUTING.md")
  if (file.exists(strFilePath) && !overwrite) {
    stop(
      "The .github/CONTRIBUTING.md directory already exists. Set overwrite = TRUE to overwrite it."
    )
  }

  file.copy(
    system.file("gha_templates/CONTRIBUTING.md", package = "gsm.utils"),
    strFilePath,
    recursive = TRUE
  )
}
