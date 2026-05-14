#' Check GitHub Actions version in a package
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' This function has been replaced by a GitHub Action to handle versions more
#' cleanly and automatically. Use `add_action("workflow-template-check.yaml")`
#' (or, more generally, [update_gsm_package()]) to replace this function.
#'
#' @param ... Placeholder to prevent other errors.
#' @returns An error with instructions for updating.
#' @export
check_gha_version <- function(...) {
  lifecycle::deprecate_stop(
    when = "0.3.1",
    what = "check_gha_version()",
    details = c(
      "i" = "Use `add_action(\"workflow-template-check.yaml\")` to install a GitHub action to replace this functionality."
    )
  )
}

#' Check Workflow Template Compliance
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' This function has been replaced by a GitHub Action to handle versions more
#' cleanly and automatically. Use `add_action("workflow-template-check.yaml")`
#' (or, more generally, [update_gsm_package()]) to replace this function.
#'
#' @param ... Placeholder to prevent other errors.
#' @returns An error with instructions for updating.
#' @export
check_workflow_compliance <- function(...) {
  lifecycle::deprecate_stop(
    when = "0.3.1",
    what = "check_workflow_compliance()",
    details = c(
      "i" = "Use `add_action(\"workflow-template-check.yaml\")` to install a GitHub action to replace this functionality."
    )
  )
}

#' Create GitHub Actions Manifest
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' This function has been replaced by a GitHub Action to handle versions more
#' cleanly and automatically. Use `add_action("workflow-template-check.yaml")`
#' (or, more generally, [update_gsm_package()]) to replace this function.
#'
#' @param ... Placeholder to prevent other errors.
#' @returns An error with instructions for updating.
#' @export
create_gha_manifest <- function(...) {
  lifecycle::deprecate_stop(
    when = "0.3.1",
    what = "create_gha_manifest()",
    details = c(
      "i" = "Use `add_action(\"workflow-template-check.yaml\")` to install a GitHub action to replace this functionality."
    )
  )
}

#' Update version in GitHub Actions workflow `.yaml` files
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' This function has been replaced by a GitHub Action to handle versions more
#' cleanly and automatically. Use `add_action("workflow-template-check.yaml")`
#' (or, more generally, [update_gsm_package()]) to replace this function.
#'
#' @param ... Placeholder to prevent other errors.
#' @returns An error with instructions for updating.
#' @export
update_workflow_version <- function(...) {
  lifecycle::deprecate_stop(
    when = "0.3.1",
    what = "update_workflow_version()",
    details = c(
      "i" = "Use `add_action(\"workflow-template-check.yaml\")` to install a GitHub action to replace this functionality."
    )
  )
}
