#' Create GitHub Actions Manifest
#' This function generates a JSON manifest file summarizing the GitHub Actions workflows
#'
#' @param workflows_dir `string` path to directory containing GitHub Actions workflow `.yaml` files
#' @param issue_templates_dir `string` path to directory containing GitHub issue template `.md` files
#' @param repository `string` URL of the GitHub repository
#' @param description_path `string` path to `DESCRIPTION` file
#' @param output_path `string` path to output JSON manifest file
#'
#' @export
#'
create_gha_manifest <- function(
    workflows_dir = "inst/gha_templates/workflows",
    issue_templates_dir = "inst/gha_templates/ISSUE_TEMPLATE",
    repository = "https://github.com/Gilead-BioStats/gsm.utils",
    description_path = "DESCRIPTION",
    output_path = "inst/gha_templates/gha_version.json"
) {
  stopifnot(file.exists(description_path))
  stopifnot(dir.exists(workflows_dir))
  stopifnot(dir.exists(issue_templates_dir))
  stopifnot(is.character(repository), length(repository) == 1)

  # Read DESCRIPTION
  desc <- read.dcf(description_path)
  if (!all(c("Package", "Version") %in% colnames(desc))) {
    stop("DESCRIPTION must contain Package and Version fields.")
  }

  package <- desc[1, "Package"]
  version <- desc[1, "Version"]

  # Discover workflows
  workflow_files <- list.files(
    workflows_dir,
    pattern = "\\.ya?ml$",
    full.names = FALSE
  )

  workflows <- lapply(workflow_files, function(f) {
    list(
      name = f,
      description = infer_from_yaml(
        file.path(workflows_dir, f),
        type = "# Description"
      ),
      path = file.path("workflows", f)
    )
  })

  # Discover issue templates
  issue_files <- list.files(
    issue_templates_dir,
    pattern = "\\.md$",
    full.names = FALSE
  )

  issue_templates <- lapply(issue_files, function(f) {
    list(
      name = infer_from_yaml(
        file.path(issue_templates_dir, f),
        type = "name"
      ),
      description = infer_from_yaml(
        file.path(issue_templates_dir, f),
        type = "type"
      )
    )
  })

  # Build manifest
  manifest <- list(
    version = version,
    package = package,
    repository = repository,
    workflows = workflows,
    issue_templates = issue_templates
  )

  # Write JSON
  jsonlite::write_json(
    manifest,
    path = output_path,
    pretty = TRUE,
    auto_unbox = TRUE
  )
}

#' Infer value from YAML/MD file
#' This helper function extracts a value from a YAML or Markdown file based on a specified type.
#'
#' @param path `string` path to the file
#' @param type `string` type of value to extract, as appears in file (e.g., "name", "type", "# Description")
#'
#' @returns `string` extracted value or `NA_character_` if not found
infer_from_yaml <- function(path, type) {
  lines <- readLines(path, warn = FALSE)
  type_line <- grep(paste0("^",type, "\\s*:"), lines, value = TRUE)

  if (length(type_line) == 0) {
    return(NA_character_)
  }

  sub(paste0("^",type, "\\s*:\\s"), "", type_line[1])
}
