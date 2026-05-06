#' Update GSM package with global issue templates and GH actions
#'
#' @param strPackageDir path to package directory
#' @param overwrite `boolean` argument declaring whether or not to overwrite
#'   existing files. Default is `TRUE`.
#' @param verbose `boolean` argument declaring whether to emit messages about
#'   updates.
#'
#' @returns NULL
#' @export
update_gsm_package <- function(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
) {
  if (!fs::dir_exists(strPackageDir)) {
    cli::cli_abort("The specified package directory does not exist.")
  }
  add_gsm_issue_templates(
    strPackageDir = strPackageDir,
    overwrite = overwrite,
    verbose = verbose
  )
  remove_deprecated_issue_templates(
    strPackageDir = strPackageDir,
    overwrite = overwrite,
    verbose = verbose
  )
  add_actions(
    strPackageDir = strPackageDir,
    overwrite = overwrite,
    verbose = verbose
  )
  remove_deprecated_actions(
    strPackageDir = strPackageDir,
    overwrite = overwrite,
    verbose = verbose
  )
}

#' Add GSM issue templates to package
#'
#' @param strPackageDir path to package directory
#' @param overwrite `boolean` argument declaring whether or not to overwrite
#'   existing files. Default is `TRUE`.
#' @param verbose `boolean` argument declaring whether to emit messages about
#'   updates.
#' @export
add_gsm_issue_templates <- function(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
) {
  issuePath <- fs::path(strPackageDir, ".github", "ISSUE_TEMPLATE")
  if (!overwrite) {
    cli::cli_abort(c(
      x = "The .github/ISSUE_TEMPLATE directory already exists.",
      "Set {.code overwrite = TRUE} to overwrite it."
    ))
  }
  fs::dir_create(issuePath)
  # Copy all issue template files to the target directory
  source_files <- fs::dir_ls(
    fs::path_package("gsm.utils", "gha_templates", "ISSUE_TEMPLATE")
  )
  fs::file_copy(
    source_files,
    issuePath,
    overwrite = overwrite
  )
}

#' Remove deprecated issue templates from package
#'
#' Removes issue templates that we no longer recommend nor support. Currently
#' the only deprecated template is `1-requirement.md` — roadmap requirements
#' now live exclusively in `gsm.roadmap`. New deprecations should be added to
#' the hard-coded list below.
#'
#' @param strPackageDir String. Path to package directory.
#' @param overwrite Logical. Is it ok to delete existing files?
#' @param verbose Logical. Inform about changes?
#' @returns A character vector of deleted template names, invisibly.
#' @export
remove_deprecated_issue_templates <- function(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
) {
  templates_path <- fs::path(strPackageDir, ".github", "ISSUE_TEMPLATE")
  deprecated_templates <- c("1-requirement.md")
  results <- purrr::map(deprecated_templates, \(name) {
    .remove_issue_template(name, templates_path, overwrite = overwrite, verbose = verbose)
  }) |>
    purrr::compact() |>
    as.character()
  if (!length(results) && verbose) {
    cli::cli_inform("No deprecated issue templates found.")
  }
  return(invisible(results))
}

.remove_issue_template <- function(
  name,
  templates_path,
  overwrite = TRUE,
  verbose = TRUE
) {
  template_path <- fs::path(templates_path, name)
  if (fs::file_exists(template_path)) {
    if (!overwrite) {
      cli::cli_abort(c(
        x = "Deprecated issue template {.file {template_path}} found.",
        i = "Set {.code overwrite = TRUE} to remove it."
      ))
    }
    if (verbose) {
      cli::cli_inform("Removing deprecated issue template {.file {template_path}}.")
    }
    fs::file_delete(template_path)
    return(name)
  }
  return(NULL)
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
  fs::dir_create(strDirPath)

  strFilePath <- fs::path(strDirPath, "CONTRIBUTING.md")
  if (fs::file_exists(strFilePath) && !overwrite) {
    cli::cli_abort(c(
      x = "The .github/CONTRIBUTING.md file already exists.",
      i = "Set {.code overwrite = TRUE} to overwrite it."
    ))
  }

  fs::file_copy(
    fs::path_package("gsm.utils", "gha_templates", "CONTRIBUTING.md"),
    strFilePath,
    overwrite = overwrite
  )
}
