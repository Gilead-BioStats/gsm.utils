# Update this when we move the source repo for actions (and, eventually, issue
# templates, probably)
.base_url <- paste(
  "https://raw.githubusercontent.com",
  "Gilead-BioStats",
  "gsm.utils",
  "actions-v1",
  sep = "/"
)

#' Add Gilead GitHub Actions to package
#'
#' Add the official Gilead GitHub Actions from
#' <https://github.com/Gilead-BioStats/gsm.utils@actions-v1> to a package, and
#' update existing Gilead GitHub Actions to the latest versions if necessary.
#'
#' @param strPackageDir String. Path to package directory
#' @param overwrite Logical. Overwrite existing files?
#' @param verbose Logical. Inform about changes?
#' @returns A character vector of added and updated action names, invisibly.
#' @export
add_gsm_actions <- function(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
) {
  manifest <- .read_gilead_action_manifest()
  if (NROW(manifest)) {
    workflows_path <- fs::path(strPackageDir, ".github", "workflows")
    .ensure_dir_exists(workflows_path)
    results <- purrr::pmap(
      manifest,
      function(name, description, version) {
        add_gilead_action(
          name,
          version,
          workflows_path = workflows_path,
          overwrite = overwrite,
          verbose = verbose
        )
      }
    ) |>
      purrr::compact() |>
      as.character()
    if (!length(results) && verbose) {
      cli::cli_inform("All workflows already up-to-date.")
    }
    return(invisible(results))
  }
  if (verbose) {
    cli::cli_inform("No canonical workflows found.")
  }
  invisible(character())
}

#' @export
#' @rdname add_gsm_actions
add_gilead_actions <- add_gsm_actions

.read_gilead_action_manifest <- function() {
  .read_github_manifest()$workflows
}

# For easier mocking during tests.
.ensure_dir_exists <- function(path) {
  fs::dir_create(path) # nocov
}

.read_github_manifest <- function() {
  manifest_path <- paste(.base_url, "gha_version.json", sep = "/")
  manifest <- jsonlite::fromJSON(manifest_path, simplifyVector = TRUE)
}

#' Add a Gilead GitHub Action to package
#'
#' Add an official Gilead GitHub Action from
#' <https://github.com/Gilead-BioStats/gsm.utils@actions-v1> to a package, or
#' update an existing Gilead GitHub Actions to the latest version if necessary.
#'
#' @param name String. The action to install.
#' @param version String. The expected version of the action.
#' @param workflows_path String. Path to the package workflows.
#' @inheritParams add_gsm_actions
#' @inheritParams rlang::args_dots_empty
#'
#' @returns The name of the workflow if it was updated, otherwise an empty
#'   character vector.
#' @export
add_gilead_action <- function(
  name,
  version,
  ...,
  workflows_path = "./.github/workflows",
  overwrite = TRUE,
  verbose = TRUE
) {
  workflow_path <- fs::path(workflows_path, name)
  if (!.workflow_up_to_date(name, version, workflow_path)) {
    if (!overwrite && fs::file_exists(workflow_path)) {
      cli::cli_abort(c(
        x = "Workflow file {.file {workflow_path}} already exists.",
        i = "Set {.code overwrite = TRUE} to overwrite the existing workflow."
      ))
    }
    if (verbose) {
      cli::cli_inform(
        "Creating or updating workflow file {.file {workflow_path}}."
      )
    }
    return(.update_workflow(name, workflow_path))
  }
  return(character())
}

.workflow_up_to_date <- function(name, version, workflow_path) {
  if (!fs::file_exists(workflow_path)) {
    return(FALSE)
  }
  existing_contents <- readLines(workflow_path)
  existing_version <- stringr::str_subset(existing_contents, "^# version:") |>
    stringr::str_remove("^# version:\\s*") |>
    stringr::str_trim() |>
    as.numeric_version()
  existing_name <- stringr::str_subset(existing_contents, "^# name:") |>
    stringr::str_remove("^# name:\\s*") |>
    stringr::str_trim()
  length(existing_version) &&
    length(existing_name) &&
    existing_version >= as.numeric_version(version) &&
    isTRUE(name == existing_name)
}

.update_workflow <- function(name, workflow_path) {
  workflow_contents <- .read_workflow_template(name)
  # Use unlink instead of fs here because unlink doens't care if the file
  # exists.
  unlink(workflow_path)
  writeLines(workflow_contents, workflow_path)
  return(name)
}

.read_workflow_template <- function(name) {
  workflow_url <- paste(.base_url, "workflow_templates", name, sep = "/")
  readLines(workflow_url)
}

#' Remove deprecated Gilead GitHub Actions from package
#'
#' Remove old workflows that we no longer recommend nor support:
#' "R-CMD-check-dev.yaml", "pkgdown-cleanup.yaml", "pkgdown-with-examples.yaml",
#' "r-releaser.yaml", and "r_releaser.yaml".
#'
#' @param strPackageDir String. Path to package directory
#' @param overwrite Logical. Is it ok to delete existing files?
#' @param verbose Logical. Inform about changes?
#' @returns A character vector of deleted action names, invisibly.
#' @export
remove_deprecated_workflows <- function(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
) {
  workflows_path <- fs::path(strPackageDir, ".github", "workflows")
  extra_workflows <- c(
    "R-CMD-check-dev.yaml",
    "pkgdown-cleanup.yaml",
    "pkgdown-with-examples.yaml",
    "r-releaser.yaml",
    "r_releaser.yaml"
  )
  results <- purrr::map(extra_workflows, \(name) {
    .remove_deprecated_workflow(name, workflows_path, overwrite = overwrite)
  }) |>
    purrr::compact() |>
    as.character()
  if (!length(results) && verbose) {
    cli::cli_inform("No deprecated workflows found.")
  }
  return(invisible(results))
}

.remove_deprecated_workflow <- function(
  name,
  workflows_path,
  overwrite = TRUE,
  verbose = TRUE
) {
  workflow_path <- fs::path(workflows_path, name)
  if (fs::file_exists(workflow_path)) {
    if (!overwrite) {
      cli::cli_abort(c(
        x = "Deprecated workflow file {.file {workflow_path}} found.",
        i = "Set {.code overwrite = TRUE} to remove the deprecated workflow."
      ))
    }
    if (verbose) {
      cli::cli_inform(
        "Removing deprecated workflow {.file {workflows_path}}."
      )
    }
    fs::file_delete(workflow_path)
    return(name)
  }
  return(character())
}
