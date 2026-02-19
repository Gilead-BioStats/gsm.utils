#' Update a GSM package with standard "AI-ready" context docs
#'
#' Copies template markdown and GitHub meta files from gsm.utils into a target
#' repository directory.
#'
#' @param strPackageDir Path to the target package repo (default: ".").
#' @param overwrite Logical; overwrite existing files (default: FALSE).
#' @param mode One of `"write"` or `"check"`.
#'   - `"write"`: copy files into `strPackageDir` according to `overwrite`.
#'   - `"check"`: do not write; return drift report only.
#' @param dry_run Logical; when `TRUE` and `mode = "write"`, report what would
#'   change without writing files.
#' @param include Optional character vector of relative template paths to sync.
#'   By default all templates are processed.
#' @param include_issue_templates Logical; when `TRUE` (default), also sync
#'   `.github/ISSUE_TEMPLATE/*` from `inst/gha_templates/ISSUE_TEMPLATE`.
#' @param ai_docs_dir Relative directory under `strPackageDir` where AI docs
#'   are synced. Default is `.github/ai`. Use `"."` to sync at repo root.
#' @param fail_on_drift Logical; when `TRUE`, error if any files are missing or
#'   differ from templates.
#'
#' @return Invisibly returns:
#' - in `mode = "write"`: destination paths (character vector)
#' - in `mode = "check"`: drift report (`data.frame`)
#' @export
update_gsm_ai_docs <- function(strPackageDir = ".",
                               overwrite = FALSE,
                               mode = c("write", "check"),
                               dry_run = FALSE,
                               include = NULL,
                               include_issue_templates = TRUE,
                               ai_docs_dir = file.path(".github", "ai"),
                               fail_on_drift = FALSE) {
  if (!dir.exists(strPackageDir)) {
    stop("strPackageDir does not exist: ", strPackageDir, call. = FALSE)
  }

  mode <- match.arg(mode)

  if (!is.character(ai_docs_dir) || length(ai_docs_dir) != 1 || !nzchar(trimws(ai_docs_dir))) {
    stop("`ai_docs_dir` must be a non-empty character scalar.", call. = FALSE)
  }

  ai_docs_dir <- trimws(ai_docs_dir)
  ai_docs_to_root <- identical(ai_docs_dir, ".") || identical(ai_docs_dir, "")

  template_dir <- system.file("ai_templates", package = "gsm.utils")
  if (identical(template_dir, "")) {
    stop("Could not find gsm.utils inst/ai_templates. Is gsm.utils installed?", call. = FALSE)
  }

  src_files <- list.files(template_dir, recursive = TRUE, full.names = TRUE, all.files = TRUE)
  src_files <- src_files[file.info(src_files)$isdir == FALSE]
  template_rel_files <- substring(src_files, nchar(template_dir) + 2)
  rel_files <- vapply(template_rel_files, function(rel_path) {
    if (isTRUE(ai_docs_to_root)) {
      return(rel_path)
    }

    normalized <- gsub("\\\\", "/", rel_path)
    if (startsWith(normalized, ".github/")) {
      rel_path
    } else {
      file.path(ai_docs_dir, rel_path)
    }
  }, character(1))

  if (!is.null(include)) {
    unknown <- setdiff(include, template_rel_files)
    if (length(unknown) > 0) {
      stop("Unknown template path(s) in include: ", paste(unknown, collapse = ", "), call. = FALSE)
    }
    keep <- template_rel_files %in% include
    src_files <- src_files[keep]
    rel_files <- rel_files[keep]
  }

  if (isTRUE(include_issue_templates)) {
    issue_template_dir <- system.file("gha_templates/ISSUE_TEMPLATE", package = "gsm.utils")
    if (identical(issue_template_dir, "")) {
      stop(
        "Could not find gsm.utils inst/gha_templates/ISSUE_TEMPLATE. Is gsm.utils installed?",
        call. = FALSE
      )
    }

    issue_src_files <- list.files(
      issue_template_dir,
      recursive = TRUE,
      full.names = TRUE,
      all.files = TRUE
    )
    issue_src_files <- issue_src_files[file.info(issue_src_files)$isdir == FALSE]
    issue_rel_files <- file.path(
      ".github",
      "ISSUE_TEMPLATE",
      substring(issue_src_files, nchar(issue_template_dir) + 2)
    )

    src_files <- c(src_files, issue_src_files)
    rel_files <- c(rel_files, issue_rel_files)
  }

  dest_files <- file.path(strPackageDir, rel_files)

  report <- data.frame(
    relative_path = rel_files,
    destination = dest_files,
    status = NA_character_,
    action = NA_character_,
    stringsAsFactors = FALSE
  )

  for (i in seq_along(src_files)) {
    src <- src_files[[i]]
    dest <- dest_files[[i]]

    dest_exists <- file.exists(dest)
    is_identical <- FALSE
    if (dest_exists) {
      is_identical <- isTRUE(unname(tools::md5sum(src)) == unname(tools::md5sum(dest)))
    }

    if (!dest_exists) {
      status <- "missing"
    } else if (is_identical) {
      status <- "identical"
    } else {
      status <- "different"
    }

    action <- "none"
    should_copy <- FALSE

    if (identical(mode, "check")) {
      action <- if (identical(status, "identical")) "none" else "drift"
    } else if (isTRUE(dry_run)) {
      if (identical(status, "missing")) {
        action <- "would_add"
      } else if (identical(status, "different") && isTRUE(overwrite)) {
        action <- "would_update"
      } else if (identical(status, "different") && !isTRUE(overwrite)) {
        action <- "skip_existing"
      }
    } else {
      if (identical(status, "missing")) {
        should_copy <- TRUE
        action <- "added"
      } else if (identical(status, "different") && isTRUE(overwrite)) {
        should_copy <- TRUE
        action <- "updated"
      } else if (identical(status, "different") && !isTRUE(overwrite)) {
        action <- "skip_existing"
      }
    }

    if (isTRUE(should_copy)) {
      dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      ok <- file.copy(src, dest, overwrite = TRUE)
      if (!isTRUE(ok)) warning("Failed to copy: ", src, " -> ", dest, call. = FALSE)
    }

    report$status[[i]] <- status
    report$action[[i]] <- action
  }

  drift_count <- sum(report$status %in% c("missing", "different"))
  if (isTRUE(fail_on_drift) && drift_count > 0) {
    stop("Detected ", drift_count, " template drift file(s).", call. = FALSE)
  }

  if (identical(mode, "check")) {
    message(
      "update_gsm_ai_docs(): checked ", nrow(report),
      " file(s); drift in ", drift_count,
      " file(s) under ", normalizePath(strPackageDir)
    )
    return(invisible(report))
  }

  added <- sum(report$action %in% c("added", "would_add"))
  updated <- sum(report$action %in% c("updated", "would_update"))
  skipped <- sum(report$action == "skip_existing")

  mode_label <- if (isTRUE(dry_run)) "dry-run" else "write"
  message(
    "update_gsm_ai_docs(): ", mode_label,
    " processed ", nrow(report), " file(s) in ", normalizePath(strPackageDir),
    " [added=", added, ", updated=", updated, ", skipped=", skipped, "]"
  )

  invisible(dest_files)
}
