#' Check Workflow Template Compliance
#' 
#' @description
#' Checks if a package's GitHub Actions workflows comply with gsm.utils templates.
#' This function verifies file presence, version headers, and critical content.
#'
#' @param strPackageDir `character` path to package directory. Default is `"."`.
#' @param bVerbose `logical` whether to print detailed information. Default is `TRUE`.
#' @param bFailOnErrors `logical` whether to call quit() with error status if issues found. Default is `TRUE`.
#'
#' @return A list with compliance check results:
#'   \item{is_compliant}{Logical indicating overall compliance}
#'   \item{missing_workflows}{Character vector of missing workflow files}
#'   \item{extra_workflows}{Character vector of extra workflow files not in templates}
#'   \item{version_issues}{Character vector of version/header issues}
#'   \item{content_issues}{Character vector of content differences}
#'   \item{gsm_utils_version}{Current gsm.utils version}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Check current package compliance
#' check_workflow_compliance()
#' 
#' # Check another package
#' check_workflow_compliance("path/to/package")
#' }
check_workflow_compliance <- function(strPackageDir = ".", bVerbose = TRUE, bFailOnErrors = TRUE) {
  # Load required packages
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required but not available.")
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Package 'cli' is required but not available.")
  }
  
  # Get gsm.utils manifest
  manifest_path <- system.file("gha_templates/gha_version.json", package = "gsm.utils")
  
  # Fallback for development: check local inst folder
  if (!file.exists(manifest_path) || manifest_path == "") {
    manifest_path <- "inst/gha_templates/gha_version.json"
  }
  
  if (!file.exists(manifest_path)) {
    stop("Cannot find GHA version manifest in gsm.utils package or local inst/ folder.")
  }
  
  manifest <- jsonlite::fromJSON(manifest_path, simplifyVector = TRUE)
  gsm_utils_version <- manifest$version
  
  if (bVerbose) {
    cli::cli_h1("GSM.utils Workflow Template Compliance Check")
    cli::cli_alert_info("GSM.utils template version: {gsm_utils_version}")
  }
  
  # Check if .github/workflows directory exists
  workflows_dir <- file.path(strPackageDir, ".github", "workflows")
  if (!dir.exists(workflows_dir)) {
    if (bVerbose) {
      cli::cli_alert_danger("No .github/workflows directory found!")
      cli::cli_alert_info("This package should have GitHub Actions workflows matching gsm.utils templates.")
    }
    if (bFailOnErrors) quit(status = 1)
    return(list(
      is_compliant = FALSE,
      missing_workflows = manifest$workflows$name,
      extra_workflows = character(0),
      version_issues = character(0),
      content_issues = character(0),
      gsm_utils_version = gsm_utils_version
    ))
  }
  
  # Get workflow file information
  expected_workflows <- manifest$workflows$name
  existing_workflows <- list.files(workflows_dir, pattern = "\\.ya?ml$")
  
  if (bVerbose) {
    cli::cli_alert_info("Expected workflow files: {paste(expected_workflows, collapse = ', ')}")
    cli::cli_alert_info("Found workflow files: {paste(existing_workflows, collapse = ', ')}")
  }
  
  # Check for missing/extra workflows
  missing_workflows <- setdiff(expected_workflows, existing_workflows)
  extra_workflows <- setdiff(existing_workflows, expected_workflows)
  
  # Check version headers and content
  version_issues <- check_workflow_headers(workflows_dir, existing_workflows, expected_workflows, gsm_utils_version)
  content_issues <- check_critical_workflow_content(workflows_dir, existing_workflows)
  
  # Determine if there are critical errors
  has_errors <- length(missing_workflows) > 0 || length(version_issues) > 0
  
  # Report findings
  if (bVerbose) {
    report_compliance_results(missing_workflows, extra_workflows, version_issues, content_issues, has_errors)
  }
  
  # Exit with error if requested and issues found
  if (bFailOnErrors && has_errors) {
    quit(status = 1)
  }
  
  return(list(
    is_compliant = !has_errors,
    missing_workflows = missing_workflows,
    extra_workflows = extra_workflows,
    version_issues = version_issues,
    content_issues = content_issues,
    gsm_utils_version = gsm_utils_version
  ))
}

#' Check Workflow File Headers
#' 
#' @description Internal function to check version and generated-by headers in workflow files.
#' 
#' @param workflows_dir `character` path to workflows directory
#' @param existing_workflows `character` vector of existing workflow file names
#' @param expected_workflows `character` vector of expected workflow file names
#' @param gsm_utils_version `character` expected gsm.utils version
#' 
#' @return `character` vector of header issues
#' @keywords internal
check_workflow_headers <- function(workflows_dir, existing_workflows, expected_workflows, gsm_utils_version) {
  version_issues <- character(0)
  
  for (wf in intersect(existing_workflows, expected_workflows)) {
    workflow_path <- file.path(workflows_dir, wf)
    if (file.exists(workflow_path)) {
      lines <- readLines(workflow_path, n = 5, warn = FALSE)
      
      # Check for version header
      version_line <- grep("^# gsm.utils GHA version:", lines, value = TRUE)
      
      if (length(version_line) == 0) {
        version_issues <- c(version_issues, paste0(wf, ": Missing version header"))
      } else {
        # Extract version
        file_version <- sub("^# gsm.utils GHA version:\\s*", "", version_line[1])
        if (file_version != gsm_utils_version) {
          version_issues <- c(version_issues, paste0(wf, ": Version ", file_version, " (expected ", gsm_utils_version, ")"))
        }
      }
      
      # Check for generated by header
      generated_line <- grep("^# Generated by:", lines, value = TRUE)
      if (length(generated_line) == 0) {
        version_issues <- c(version_issues, paste0(wf, ": Missing \"Generated by\" header"))
      }
    }
  }
  
  return(version_issues)
}

#' Check Critical Workflow Content
#' 
#' @description Internal function to check if critical workflow files match templates.
#' 
#' @param workflows_dir `character` path to workflows directory
#' @param existing_workflows `character` vector of existing workflow file names
#' 
#' @return `character` vector of content issues
#' @keywords internal
check_critical_workflow_content <- function(workflows_dir, existing_workflows) {
  critical_workflows <- c("R-CMD-check.yaml", "R-CMD-check-dev.yaml")
  content_issues <- character(0)
  
  for (wf in intersect(existing_workflows, critical_workflows)) {
    workflow_path <- file.path(workflows_dir, wf)
    template_path <- system.file("gha_templates/workflows", wf, package = "gsm.utils")
    
    if (file.exists(template_path)) {
      template_content <- readLines(template_path, warn = FALSE)
      workflow_content <- readLines(workflow_path, warn = FALSE)
      
      # Compare key sections (excluding comments with versions)
      template_clean <- template_content[!grepl("^#", template_content)]
      workflow_clean <- workflow_content[!grepl("^#", workflow_content)]
      
      if (!identical(template_clean, workflow_clean)) {
        content_issues <- c(content_issues, paste0(wf, ": Content differs from template"))
      }
    }
  }
  
  return(content_issues)
}

#' Report Compliance Results
#' 
#' @description Internal function to report workflow compliance check results.
#' 
#' @param missing_workflows `character` vector of missing workflows
#' @param extra_workflows `character` vector of extra workflows
#' @param version_issues `character` vector of version issues
#' @param content_issues `character` vector of content issues
#' @param has_errors `logical` whether critical errors were found
#' 
#' @return NULL (prints results to console)
#' @keywords internal
report_compliance_results <- function(missing_workflows, extra_workflows, version_issues, content_issues, has_errors) {
  # Report missing workflows
  if (length(missing_workflows) > 0) {
    cli::cli_alert_danger("Missing required workflow files:")
    for (wf in missing_workflows) {
      cli::cli_alert_danger("  - {wf}")
    }
  }
  
  # Report extra workflows
  if (length(extra_workflows) > 0) {
    cli::cli_alert_warning("Extra workflow files (not in gsm.utils templates):")
    for (wf in extra_workflows) {
      cli::cli_alert_warning("  - {wf}")
    }
  }
  
  # Report version issues
  if (length(version_issues) > 0) {
    cli::cli_alert_danger("Workflow version/header issues:")
    for (issue in version_issues) {
      cli::cli_alert_danger("  - {issue}")
    }
  }
  
  # Report content issues
  if (length(content_issues) > 0) {
    cli::cli_alert_warning("Workflow content differences (may be acceptable):")
    for (issue in content_issues) {
      cli::cli_alert_warning("  - {issue}")
    }
  }
  
  # Summary
  if (!has_errors) {
    if (length(version_issues) == 0 && length(missing_workflows) == 0) {
      cli::cli_alert_success("All workflow files are compliant with gsm.utils templates!")
    } else {
      cli::cli_alert_success("No critical issues found")
    }
  } else {
    cli::cli_alert_danger("Workflow compliance issues found!")
    cli::cli_alert_info("To fix these issues, run: gsm.utils::update_gsm_package()")
  }
}