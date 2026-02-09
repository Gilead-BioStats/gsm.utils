#' Check GitHub Actions version in a package
#'
#' @description
#' Checks the version of GitHub Actions (GHA) workflows installed in a package
#' against the version available in gsm.utils. This helps identify if workflows
#' need to be updated.
#'
#' @param strPackageDir `character` path to package directory. Default is `"."`.
#' @param bVerbose `logical` whether to print detailed information. Default is `TRUE`.
#'
#' @return A list with the following components:
#'   \item{package_version}{Version found in the package workflows (or NA)}
#'   \item{gsm_utils_version}{Current version available in gsm.utils}
#'   \item{is_current}{Logical indicating if package version matches gsm.utils version}
#'   \item{workflows_found}{Character vector of workflow files found}
#'   \item{workflows_missing}{Character vector of workflow files missing from package}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Check current package
#' check_gha_version()
#'
#' # Check another package
#' check_gha_version("path/to/package")
#' }
check_gha_version <- function(strPackageDir = ".", bVerbose = TRUE) {
  # Get gsm.utils version from manifest
  manifest_path <- system.file("gha_templates/gha_version.json", package = "gsm.utils")

  if (!fs::file_exists(manifest_path)) {
    cli::cli_abort("Cannot find GHA version manifest in gsm.utils package.")
  }

  manifest <- jsonlite::fromJSON(manifest_path, simplifyVector = TRUE)
  gsm_utils_version <- manifest$version

  # Check if package .github/workflows directory exists
  workflows_dir <- fs::path(strPackageDir, ".github", "workflows")

  if (!fs::dir_exists(workflows_dir)) {
    if (bVerbose) {
      cli::cli_alert_warning("No .github/workflows directory found in {.path {strPackageDir}}")
    }
    return(list(
      package_version = NA_character_,
      gsm_utils_version = gsm_utils_version,
      is_current = FALSE,
      workflows_found = character(0),
      workflows_missing = manifest$workflows$name
    ))
  }

  # Get list of expected workflow files
  expected_workflows <- manifest$workflows$name
  workflow_files <- fs::dir_ls(workflows_dir, regexp = "\\.ya?ml$")
  workflow_names <- basename(workflow_files)

  # Extract version from first workflow file that has it
  package_version <- NA_character_
  for (wf in workflow_files) {
    if (fs::file_exists(wf)) {
      lines <- readr::read_lines(wf, n_max = 5)
      version_line <- grep("^# gsm.utils GHA version:", lines, value = TRUE)
      if (length(version_line) > 0) {
        package_version <- sub("^# gsm.utils GHA version:\\s*", "", version_line[1])
        break
      }
    }
  }

  # Determine which workflows are present/missing
  workflows_found <- intersect(workflow_names, expected_workflows)
  workflows_missing <- setdiff(expected_workflows, workflow_names)

  is_current <- !is.na(package_version) && package_version == gsm_utils_version

  if (bVerbose) {
    if (is.na(package_version)) {
      cli::cli_alert_warning("No gsm.utils version found in workflow files")
      cli::cli_alert_info("Workflows may not be from gsm.utils or are from an older version")
    } else if (is_current) {
      cli::cli_alert_success("GHA workflows are up to date (v{package_version})")
    } else {
      cli::cli_alert_warning(
        "GHA workflows are outdated (v{package_version}) - current version is v{gsm_utils_version}"
      )
      cli::cli_alert_info("Run {.code gsm.utils::update_gsm_package()} to update")
    }

    if (length(workflows_found) > 0) {
      cli::cli_alert_info("Found {length(workflows_found)} workflow file{?s}: {.file {workflows_found}}")
    }

    if (length(workflows_missing) > 0) {
      cli::cli_alert_warning(
        "Missing {length(workflows_missing)} expected workflow{?s}: {.file {workflows_missing}}"
      )
    }
  }

  invisible(list(
    package_version = package_version,
    gsm_utils_version = gsm_utils_version,
    is_current = is_current,
    workflows_found = workflows_found,
    workflows_missing = workflows_missing
  ))
}
