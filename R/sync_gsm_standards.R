#' Sync GSM standards (AI docs + issue templates + CI workflows)
#'
#' Provides a one-command sync/check entry point for repository standards.
#' In `mode = "write"`, it syncs AI docs (and issue templates) plus GitHub
#' Actions workflow templates. Existing repo-local `ARCHITECTURE.md` is
#' preserved (not overwritten), while missing `ARCHITECTURE.md` is still added
#' from template. In `mode = "check"`, it reports drift for AI docs and
#' workflow versions. Drift checks intentionally ignore GitHub issue templates
#' and allow `ARCHITECTURE.md` to vary by repository.
#'
#' @param strPackageDir Path to the target package repo (default: ".").
#' @param mode One of `"write"` or `"check"`.
#' @param overwrite_ai_docs Logical; overwrite existing AI docs/templates in
#'   `mode = "write"` (default: `FALSE`). Existing `ARCHITECTURE.md` is always
#'   preserved.
#' @param overwrite_actions Logical; overwrite existing `.github/workflows` in
#'   `mode = "write"` (default: `TRUE`).
#' @param dry_run Logical; in `mode = "write"`, preview AI docs changes without
#'   writing files (default: `FALSE`). Workflows are not updated when
#'   `dry_run = TRUE`.
#' @param ai_docs_dir Relative directory under `strPackageDir` where AI docs
#'   are synced. Default is `.github/ai`. Use `"."` to sync at repo root.
#' @param fail_on_drift Logical; in `mode = "check"`, error when AI docs drift
#'   (excluding `ARCHITECTURE.md` and issue templates) or workflow drift is
#'   detected.
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
                               ai_docs_dir = file.path(".github", "ai"),
                               fail_on_drift = FALSE) {
  mode <- match.arg(mode)

  if (!dir.exists(strPackageDir)) {
    stop("strPackageDir does not exist: ", strPackageDir, call. = FALSE)
  }

  if (identical(mode, "check")) {
    ai_args <- list(
      strPackageDir = strPackageDir,
      mode = "check",
      fail_on_drift = FALSE
    )
    if ("ai_docs_dir" %in% names(formals(update_gsm_ai_docs))) {
      ai_args$ai_docs_dir <- ai_docs_dir
    }
    if ("include_issue_templates" %in% names(formals(update_gsm_ai_docs))) {
      ai_args$include_issue_templates <- FALSE
    }

    ai_report <- do.call(update_gsm_ai_docs, ai_args)

    rel_paths_norm <- gsub("\\\\", "/", ai_report$relative_path)
    is_architecture_file <- grepl("(^|/)ARCHITECTURE\\.md$", rel_paths_norm)
    is_ai_drift <- ai_report$status %in% c("missing", "different")
    has_ai_drift <- any(is_ai_drift & !is_architecture_file)

    gha_report <- check_gha_version(
      strPackageDir = strPackageDir,
      bVerbose = FALSE
    )

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

  ai_args <- list(
    strPackageDir = strPackageDir,
    overwrite = overwrite_ai_docs,
    mode = "write",
    dry_run = dry_run,
    fail_on_drift = FALSE
  )
  if ("ai_docs_dir" %in% names(formals(update_gsm_ai_docs))) {
    ai_args$ai_docs_dir <- ai_docs_dir
  }

  architecture_dest <- file.path(
    strPackageDir,
    if (identical(ai_docs_dir, ".") || identical(ai_docs_dir, "")) {
      "ARCHITECTURE.md"
    } else {
      file.path(ai_docs_dir, "ARCHITECTURE.md")
    }
  )

  if (file.exists(architecture_dest)) {
    template_dir <- system.file("ai_templates", package = "gsm.utils")
    if (identical(template_dir, "")) {
      stop("Could not find gsm.utils inst/ai_templates. Is gsm.utils installed?", call. = FALSE)
    }

    template_rel_files <- list.files(
      template_dir,
      recursive = TRUE,
      full.names = FALSE,
      all.files = TRUE
    )
    template_rel_files <- template_rel_files[
      file.info(file.path(template_dir, template_rel_files))$isdir == FALSE
    ]
    template_rel_files <- gsub("\\\\", "/", template_rel_files)

    ai_args$include <- setdiff(template_rel_files, "ARCHITECTURE.md")
  }

  ai_write <- do.call(update_gsm_ai_docs, ai_args)

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
