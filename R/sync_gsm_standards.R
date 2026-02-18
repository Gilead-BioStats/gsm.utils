#' Sync GSM standards (AI docs + issue templates + CI workflows)
#'
#' Provides a one-command sync/check entry point for repository standards.
#' In `mode = "write"`, it syncs AI docs (and issue templates) plus GitHub
#' Actions workflow templates. In `mode = "check"`, it reports drift for AI
#' docs and workflow versions.
#'
#' @param strPackageDir Path to the target package repo (default: ".").
#' @param mode One of `"write"` or `"check"`.
#' @param overwrite_ai_docs Logical; overwrite existing AI docs/templates in
#'   `mode = "write"` (default: `FALSE`).
#' @param overwrite_actions Logical; overwrite existing `.github/workflows` in
#'   `mode = "write"` (default: `TRUE`).
#' @param dry_run Logical; in `mode = "write"`, preview AI docs changes without
#'   writing files (default: `FALSE`). Workflows are not updated when
#'   `dry_run = TRUE`.
#' @param fail_on_drift Logical; in `mode = "check"`, error when AI docs drift
#'   or workflow drift is detected.
#'
#' @return Invisibly returns a list with components:
#' - `ai_docs`: AI docs drift report (`data.frame`) in check mode, or destination paths in write mode
#' - `gha`: workflow drift summary in check mode, or logical copy result in write mode
#' @export
sync_gsm_standards <- function(strPackageDir = ".",
                               mode = c("write", "check"),
                               overwrite_ai_docs = FALSE,
                               overwrite_actions = TRUE,
                               dry_run = FALSE,
                               fail_on_drift = FALSE) {
  mode <- match.arg(mode)

  if (!dir.exists(strPackageDir)) {
    stop("strPackageDir does not exist: ", strPackageDir, call. = FALSE)
  }

  if (identical(mode, "check")) {
    ai_report <- update_gsm_ai_docs(
      strPackageDir = strPackageDir,
      mode = "check",
      fail_on_drift = FALSE
    )

    gha_report <- check_gha_version(
      strPackageDir = strPackageDir,
      bVerbose = FALSE
    )

    has_ai_drift <- any(ai_report$status %in% c("missing", "different"))
    has_gha_drift <- !isTRUE(gha_report$is_current) || length(gha_report$workflows_missing) > 0

    if (isTRUE(fail_on_drift) && (has_ai_drift || has_gha_drift)) {
      stop("Detected standards drift (AI docs and/or workflows).", call. = FALSE)
    }

    message(
      "sync_gsm_standards(): check complete for ", normalizePath(strPackageDir),
      " [ai_drift=", has_ai_drift, ", gha_drift=", has_gha_drift, "]"
    )

    return(invisible(list(ai_docs = ai_report, gha = gha_report)))
  }

  ai_write <- update_gsm_ai_docs(
    strPackageDir = strPackageDir,
    overwrite = overwrite_ai_docs,
    mode = "write",
    dry_run = dry_run,
    fail_on_drift = FALSE
  )

  gha_write <- NA
  if (!isTRUE(dry_run)) {
    gha_write <- add_gsm_actions(
      strPackageDir = strPackageDir,
      overwrite = overwrite_actions
    )
  }

  message(
    "sync_gsm_standards(): write complete for ", normalizePath(strPackageDir),
    if (isTRUE(dry_run)) " [dry_run=TRUE; workflows not updated]" else ""
  )

  invisible(list(ai_docs = ai_write, gha = gha_write))
}
