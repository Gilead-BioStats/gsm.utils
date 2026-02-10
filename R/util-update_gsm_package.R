#' Update GSM package with global issue templates and GH actions
#'
#' @param strPackageDir path to package directory
#'
#' @returns NULL
#' @export
update_gsm_package <- function(strPackageDir = ".") {
  if (!fs::dir_exists(strPackageDir)) {
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
  issuePath <- fs::path(strPackageDir, ".github", "ISSUE_TEMPLATE")
  if (!fs::dir_exists(issuePath)) {
    fs::dir_create(issuePath)
  } else if (!overwrite) {
    stop(
      "The .github/ISSUE_TEMPLATE directory already exists. Set overwrite = TRUE to overwrite it."
    )
  }
  # Copy all issue template files to the target directory  
  source_files <- fs::dir_ls(
    system.file("gha_templates/ISSUE_TEMPLATE", package = "gsm.utils")
  )
  fs::file_copy(
    source_files,
    issuePath,
    overwrite = overwrite
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
  if (fs::file_exists(manifest_path)) {
    manifest <- jsonlite::fromJSON(manifest_path, simplifyVector = TRUE)
    version <- manifest$version
    cli::cli_alert_info("Installing gsm.utils GitHub Actions v{version}")
  }

  workflowsPath <- fs::path(strPackageDir, ".github", "workflows")
  if (!fs::dir_exists(workflowsPath)) {
    fs::dir_create(workflowsPath)
  } else if (!overwrite) {
    stop(
      "The .github/workflows directory already exists. Set overwrite = TRUE to overwrite it."
    )
  }

  result <- tryCatch({
    # Copy all workflow files to the target directory
    source_files <- fs::dir_ls(
      system.file("gha_templates/workflows", package = "gsm.utils"),
      regexp = "\\.ya?ml$"
    )
    fs::file_copy(
      source_files,
      workflowsPath,
      overwrite = overwrite
    )
    TRUE
  }, error = function(e) FALSE)

  if (result) {
    workflow_files <- basename(fs::dir_ls(
      system.file("gha_templates/workflows", package = "gsm.utils"),
      regexp = "\\.ya?ml$"
    ))
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
  strDirPath <- fs::path(strPackageDir, ".github")
  if (!fs::dir_exists(strDirPath)) {
    fs::dir_create(strDirPath)
  }

  strFilePath <- fs::path(strDirPath, "CONTRIBUTING.md")
  if (fs::file_exists(strFilePath) && !overwrite) {
    stop(
      "The .github/CONTRIBUTING.md directory already exists. Set overwrite = TRUE to overwrite it."
    )
  }

  fs::file_copy(
    system.file("gha_templates/CONTRIBUTING.md", package = "gsm.utils"),
    strFilePath,
    overwrite = overwrite
  )
}
