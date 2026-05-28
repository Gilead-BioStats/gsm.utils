# Update this when the manifest moves to a new branch or repo.
.manifest_url <- paste(
  "https://raw.githubusercontent.com",
  "Gilead-BioStats",
  "gsm.utils",
  "actions-v1",
  "gha_version.json",
  sep = "/"
)

# Build a raw content URL for one workflow file. path_extra is omitted when
# NULL, NA, or empty (e.g. workflows that live at the repo root).
.workflow_url <- function(name, repo, ref, path_extra = NULL) {
  parts <- c(
    "https://raw.githubusercontent.com",
    repo,
    ref,
    if (!is.null(path_extra) && !is.na(path_extra) && nzchar(path_extra)) {
      path_extra
    },
    name
  )
  paste(parts, collapse = "/")
}

#' Add Gilead GitHub Actions to package
#'
#' Add the official Gilead GitHub Actions to a package, and update existing
#' Gilead GitHub Actions to the latest versions if necessary.
#'
#' @inheritParams .shared-params
#' @returns A character vector of added and updated action names, invisibly.
#' @export
add_actions <- function(
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
      function(name, version, repo, ref, path_extra = NULL, ...) {
        add_action(
          name,
          version,
          repo = repo,
          ref = ref,
          path_extra = path_extra,
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

.read_gilead_action_manifest <- function() {
  .read_github_manifest()$workflows
}

# For easier mocking during tests.
.ensure_dir_exists <- function(path) {
  fs::dir_create(path) # nocov
}

.read_github_manifest <- function() {
  jsonlite::fromJSON(.manifest_url, simplifyVector = TRUE)
}

#' Add a Gilead GitHub Action to package
#'
#' Add an official Gilead GitHub Action to a package, or update an existing
#' Gilead GitHub Action to the latest version if necessary. The source location
#' is determined by the manifest fields `repo`, `ref`, and `path_extra`.
#'
#' @param name (`string`) The action to install.
#' @param version (`string`) The expected version of the action.
#' @param repo (`string`) GitHub repository in `owner/repo` form.
#' @param ref (`string`) Git ref (branch, tag, or SHA) in `repo`.
#' @param path_extra (`string` or `NULL`) Optional subdirectory within the ref
#'   where the workflow file lives.
#' @param workflows_path (`string`) Path to the package workflows.
#' @inheritParams .shared-params
#' @inheritParams rlang::args_dots_empty
#'
#' @returns The name of the workflow if it was updated, otherwise an empty
#'   character vector.
#' @export
add_action <- function(
  name,
  version,
  repo,
  ref,
  ...,
  path_extra = NULL,
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
    return(.update_workflow(
      name,
      workflow_path,
      repo = repo,
      ref = ref,
      path_extra = path_extra
    ))
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

.update_workflow <- function(
  name,
  workflow_path,
  repo,
  ref,
  path_extra = NULL
) {
  workflow_contents <- .read_workflow_template(
    name,
    repo = repo,
    ref = ref,
    path_extra = path_extra
  )
  # Use unlink instead of fs here because unlink doesn't care if the file
  # exists.
  unlink(workflow_path)
  writeLines(workflow_contents, workflow_path)
  return(name)
}

.read_workflow_template <- function(name, repo, ref, path_extra = NULL) {
  workflow_url <- .workflow_url(
    name,
    repo = repo,
    ref = ref,
    path_extra = path_extra
  )
  readLines(workflow_url)
}

#' Remove deprecated Gilead GitHub Actions from package
#'
#' Remove old workflows that we no longer recommend nor support:
#' "R-CMD-check-dev.yaml", "pkgdown-cleanup.yaml", "pkgdown-with-examples.yaml",
#' "r-releaser.yaml", and "r_releaser.yaml".
#'
#' @inheritParams .shared-params
#' @returns A character vector of deleted action names, invisibly.
#' @export
remove_deprecated_actions <- function(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
) {
  workflows_path <- fs::path(strPackageDir, ".github", "workflows")
  extra_workflows <- c(
    "R-CMD-check-dev.yaml",
    "pkgdown.yaml",
    "pkgdown.yml",
    "pkgdown-cleanup.yaml",
    "pkgdown-with-examples.yaml",
    "r-releaser.yaml",
    "r_releaser.yaml"
  )
  results <- purrr::map(extra_workflows, \(name) {
    .remove_action(name, workflows_path, overwrite = overwrite)
  }) |>
    purrr::compact() |>
    as.character()
  if (!length(results) && verbose) {
    cli::cli_inform("No deprecated workflows found.")
  }
  return(invisible(results))
}

.remove_action <- function(
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
        i = "Set {.code overwrite = TRUE} to remove the workflow."
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
