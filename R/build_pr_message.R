#' Build PR message and optionally create a GitHub PR
#'
#' Creates a pull request body aligned to the repository PR template and can
#' optionally invoke `gh pr create`.
#'
#' @param overview `character` vector describing what changed.
#' @param test_notes `character` vector with test notes/commands. Optional.
#' @param connected_issues `character` vector of issue references (e.g.,
#'   `"123"`, `"#123"`, `"Closes #123"`). Optional.
#' @param run_gh `logical` toggle to run GitHub CLI PR creation.
#'   Default is `FALSE`.
#' @param pr_title Optional PR title. If `NULL`, a title is inferred from the
#'   current branch name.
#' @param base Base branch for PR creation when `run_gh = TRUE`. Default `"dev"`.
#' @param head Optional head branch for PR creation when `run_gh = TRUE`.
#' @param repo Optional `owner/repo` for PR creation when `run_gh = TRUE`.
#' @param draft `logical` create PR as draft when `run_gh = TRUE`.
#'
#' @return Invisibly returns a list with `body`, `title`, `gh_called`, and
#'   `gh_output`.
#' @export
build_pr_message <- function(overview,
                             test_notes = character(0),
                             connected_issues = character(0),
                             run_gh = FALSE,
                             pr_title = NULL,
                             base = "dev",
                             head = NULL,
                             repo = NULL,
                             draft = FALSE) {
  if (!is.character(overview) || length(overview) < 1 || all(trimws(overview) == "")) {
    stop("`overview` must contain at least one non-empty line.", call. = FALSE)
  }

  if (!is.logical(run_gh) || length(run_gh) != 1 || is.na(run_gh)) {
    stop("`run_gh` must be a single TRUE/FALSE value.", call. = FALSE)
  }

  if (!is.logical(draft) || length(draft) != 1 || is.na(draft)) {
    stop("`draft` must be a single TRUE/FALSE value.", call. = FALSE)
  }

  clean_lines <- function(x) {
    x <- trimws(as.character(x))
    x[nzchar(x)]
  }

  format_bullets <- function(x, fallback = "- N/A") {
    x <- clean_lines(x)
    if (length(x) == 0) {
      return(fallback)
    }
    paste0("- ", x)
  }

  format_issue <- function(x) {
    if (grepl("^(closes|close|fixes|fix)\\b", x, ignore.case = TRUE)) {
      return(x)
    }
    if (grepl("^#?\\d+$", x)) {
      num <- sub("^#", "", x)
      return(paste0("Closes #", num))
    }
    x
  }

  overview_block <- format_bullets(overview)
  test_block <- format_bullets(test_notes)
  issue_block <- format_bullets(vapply(clean_lines(connected_issues), format_issue, character(1)))
  has_connected_issues <- length(clean_lines(connected_issues)) > 0

  body <- paste(
    c(
      "## Overview",
      overview_block,
      "",
      "## Test Notes/Sample Code",
      test_block,
      "",
      "## Connected Issues",
      issue_block,
      ""
    ),
    collapse = "\n"
  )

  if (!is.character(pr_title) || length(pr_title) != 1 || !nzchar(trimws(pr_title))) {
    branch <- tryCatch(
      system2("git", c("rev-parse", "--abbrev-ref", "HEAD"), stdout = TRUE, stderr = FALSE),
      error = function(...) character(0)
    )
    branch <- clean_lines(branch)
    pr_title <- if (length(branch) > 0) paste0("[", branch[[1]], "] Update") else "Update"

    if (isTRUE(run_gh)) {
      message(
        "build_pr_message(): `pr_title` not supplied. Using inferred title: '",
        pr_title,
        "'."
      )
      message("Tip: set `pr_title = \"...\"` for a cleaner PR title.")
    }
  }

  gh_called <- FALSE
  gh_output <- character(0)

  if (isTRUE(run_gh)) {
    if (!has_connected_issues) {
      message(
        "build_pr_message(): no `connected_issues` provided. PR body will show 'N/A' in Connected Issues."
      )
      message("Tip: pass `connected_issues = c(\"123\")` to include 'Closes #123'.")
    }

    if (!is.character(base) || length(base) != 1 || !nzchar(trimws(base))) {
      message("build_pr_message(): `base` was empty; defaulting to 'dev'.")
      base <- "dev"
    }

    if (identical(trimws(base), "dev")) {
      message("build_pr_message(): creating PR against base branch 'dev'.")
      message("Tip: set `base = \"main\"` when targeting release merges.")
    }

    gh_bin <- Sys.which("gh")
    if (!nzchar(gh_bin)) {
      stop("GitHub CLI `gh` not found in PATH; set run_gh = FALSE or install gh.", call. = FALSE)
    }

    args <- c("pr", "create", "--title", pr_title, "--base", base)
    if (!is.null(head) && nzchar(trimws(head))) {
      args <- c(args, "--head", trimws(head))
    }
    if (!is.null(repo) && nzchar(trimws(repo))) {
      args <- c(args, "--repo", trimws(repo))
    }
    if (isTRUE(draft)) {
      args <- c(args, "--draft")
    }

    tf <- tempfile(fileext = ".md")
    on.exit(unlink(tf), add = TRUE)
    writeLines(body, tf, useBytes = TRUE)

    args <- c(args, "--body-file", tf)
    gh_output <- tryCatch(
      system2(gh_bin, args, stdout = TRUE, stderr = TRUE),
      error = function(e) stop("Failed to run `gh pr create`: ", e$message, call. = FALSE)
    )
    gh_called <- TRUE
  }

  invisible(list(
    body = body,
    title = pr_title,
    gh_called = gh_called,
    gh_output = gh_output
  ))
}
