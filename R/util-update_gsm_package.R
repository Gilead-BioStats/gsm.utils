#' Update GSM package with global issue templates and GH actions
#'
#' Add standard GSM issue templates ([add_gsm_issue_templates()]) and actions
#' ([add_actions()]), and remove deprecated versions of each
#' ([remove_deprecated_issue_templates()] and [remove_deprecated_actions()]).
#'
#' @inheritParams .shared-params
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

# add_gsm_issue_templates ----

#' Add GSM issue templates to package
#'
#' @inheritParams .shared-params
#' @export
add_gsm_issue_templates <- function(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
) {
  issuePath <- .find_issue_path(strPackageDir)
  if (fs::dir_exists(issuePath) && !overwrite) {
    cli::cli_abort(c(
      x = "The .github/ISSUE_TEMPLATE directory already exists.",
      "Set {.code overwrite = TRUE} to overwrite it."
    ))
  }
  fs::dir_create(issuePath)
  # Copy all issue template files to the target directory
  source_files <- fs::dir_ls(
    fs::path_package("gsm.utils", "github_templates", "ISSUE_TEMPLATE")
  )
  fs::file_copy(
    source_files,
    issuePath,
    overwrite = overwrite
  )
}

#' A simple path constructor for mocking
#'
#' @inheritParams add_gsm_issue_templates
#'
#' @returns The path to issue templates.
#' @keywords internal
.find_issue_path <- function(strPackageDir) {
  fs::path(strPackageDir, ".github", "ISSUE_TEMPLATE") # nocov
}

# remove_deprecated_issue_templates ----

#' Remove deprecated issue templates from package
#'
#' Removes issue templates that we no longer recommend nor support. Currently
#' the only deprecated template is `1-requirement.md` — roadmap requirements
#' now live exclusively in `gsm.roadmap`. New deprecations should be added to
#' the hard-coded list below.
#'
#' @inheritParams .shared-params
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
    .remove_issue_template(
      name,
      templates_path,
      overwrite = overwrite,
      verbose = verbose
    )
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
      cli::cli_inform(
        "Removing deprecated issue template {.file {template_path}}."
      )
    }
    fs::file_delete(template_path)
    return(name)
  }
  return(NULL)
}

# add_contributor_guidelines ----

#' Add GSM Contributor Guidelines markdown to package
#'
#' @inheritParams .shared-params
#'
#' @export
add_contributor_guidelines <- function(strPackageDir = ".", overwrite = TRUE) {
  .ensure_github_dir_exists(strPackageDir)
  strFilePath <- .find_contributing(strPackageDir)
  if (fs::file_exists(strFilePath) && !overwrite) {
    cli::cli_abort(c(
      x = "The .github/CONTRIBUTING.md file already exists.",
      i = "Set {.code overwrite = TRUE} to overwrite it."
    ))
  }

  fs::file_copy(
    fs::path_package("gsm.utils", "github_templates", "CONTRIBUTING.md"),
    strFilePath,
    overwrite = overwrite
  )
}

.ensure_github_dir_exists <- function(strPackageDir) {
  strDirPath <- fs::path(strPackageDir, ".github")
  fs::dir_create(strDirPath)
}

.find_contributing <- function(strPackageDir) {
  fs::path(strPackageDir, ".github", "CONTRIBUTING.md") # nocov
}
