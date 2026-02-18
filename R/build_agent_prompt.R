#' Build an agent execution prompt from issue + Context Pack
#'
#' Generates a ready-to-paste instruction block for coding agents using a
#' canonical issue reference and a filled Context Pack.
#'
#' @param issue `character` issue reference (e.g., `"gsm.qtl#123"` or URL).
#' @param context_pack Optional `character` full Context Pack text. If `NULL`
#'   (default), uses the GitHub issue body resolved from `issue`.
#' @param lock_core_docs `logical` whether to include an explicit instruction
#'   that core docs are read-only unless explicitly listed in
#'   Allowed-to-touch Files. Default is `TRUE`.
#' @param strPackageDir Path to target repo root used to resolve core docs.
#'   Default is `"."`.
#' @param ai_docs_dir Relative directory where AI docs are expected. Default is
#'   `.github/ai`.
#'
#' @return A single `character` string containing the assembled prompt.
#' @export
build_agent_prompt <- function(issue,
                               context_pack = NULL,
                               lock_core_docs = TRUE,
                               strPackageDir = ".",
                               ai_docs_dir = file.path(".github", "ai")) {
  if (!is.character(issue) || length(issue) != 1 || !nzchar(trimws(issue))) {
    stop("`issue` must be a non-empty character scalar.", call. = FALSE)
  }

  if (is.null(context_pack)) {
    context_pack <- .context_pack_from_issue(issue)
  }

  if (!is.character(context_pack) || length(context_pack) != 1 || !nzchar(trimws(context_pack))) {
    stop("`context_pack` must be a non-empty character scalar, or NULL to pull from GitHub issue body.", call. = FALSE)
  }

  if (!is.logical(lock_core_docs) || length(lock_core_docs) != 1 || is.na(lock_core_docs)) {
    stop("`lock_core_docs` must be a single TRUE/FALSE value.", call. = FALSE)
  }

  if (!is.character(strPackageDir) || length(strPackageDir) != 1 || !nzchar(trimws(strPackageDir))) {
    stop("`strPackageDir` must be a non-empty character scalar.", call. = FALSE)
  }

  if (!is.character(ai_docs_dir) || length(ai_docs_dir) != 1 || !nzchar(trimws(ai_docs_dir))) {
    stop("`ai_docs_dir` must be a non-empty character scalar.", call. = FALSE)
  }

  strPackageDir <- trimws(strPackageDir)
  ai_docs_dir <- trimws(ai_docs_dir)

  required_fields <- list(
    "Goal" = "\\bgoal\\b",
    "Non-goals" = "\\bnon[[:space:]-]*goals?\\b",
    "Target Repo + Branch" = "\\btarget[[:space:]-]*repo[[:space:]]*([+&/]|and)?[[:space:]-]*branch\\b",
    "Allowed-to-touch Files" = "\\ballowed[[:space:]-]*to[[:space:]-]*touch[[:space:]-]*files?\\b",
    "Entry Points" = "\\bentry[[:space:]-]*points?\\b",
    "Tests to Run" = "\\btests?[[:space:]-]*to[[:space:]-]*run\\b",
    "Definition of Done" = "\\bdefinition[[:space:]-]*of[[:space:]-]*done\\b",
    "DAG Impact" = "\\bdag[[:space:]-]*impact\\b"
  )

  missing_fields <- names(required_fields)[!vapply(
    required_fields,
    function(pattern) grepl(pattern, context_pack, ignore.case = TRUE, perl = TRUE),
    logical(1)
  )]

  if (length(missing_fields) > 0) {
    stop(
      "Context Pack appears incomplete. Missing field(s): ",
      paste(missing_fields, collapse = ", "),
      call. = FALSE
    )
  }

  lines <- c(
    "Execute this ticket exactly as scoped below.",
    "Do not edit files outside Allowed-to-touch Files.",
    "If required fields are missing or ambiguous, stop and ask targeted clarifying questions before coding.",
    "Run the exact tests listed in the Context Pack.",
    "Return output sections: Summary, Files changed, Patch/diff, Tests run, Downstream verification, Risks/rollback, Follow-ups.",
    paste0("Issue reference: ", trimws(issue)),
    "Context Pack:",
    trimws(context_pack)
  )

  if (isTRUE(lock_core_docs)) {
    core_docs <- c("AGENTS.md", "ECOSYSTEM.md", "SKILLS.md", "SECURITY.md", "CONTRIBUTING.md")
    core_doc_paths <- .resolve_core_doc_paths(
      strPackageDir = strPackageDir,
      ai_docs_dir = ai_docs_dir,
      core_docs = core_docs
    )

    lines <- append(
      lines,
      paste0(
        "Treat core docs as read-only unless explicitly listed in Allowed-to-touch Files: ",
        paste(core_doc_paths, collapse = ", "),
        "."
      ),
      after = 2
    )
  }

  paste(lines, collapse = "\n\n")
}


.context_pack_from_issue <- function(issue) {
  issue_parts <- .parse_issue_reference(issue)
  .fetch_github_issue_body(issue_parts$owner, issue_parts$repo, issue_parts$number)
}


.parse_issue_reference <- function(issue) {
  issue <- trimws(issue)

  url_match <- regexec(
    "^https?://github\\.com/([^/]+)/([^/]+)/issues/([0-9]+)(?:[/?#].*)?$",
    issue,
    perl = TRUE
  )
  url_parts <- regmatches(issue, url_match)[[1]]
  if (length(url_parts) == 4) {
    return(list(owner = url_parts[2], repo = url_parts[3], number = url_parts[4]))
  }

  owner_repo_match <- regexec("^([^/#\\s]+)/([^/#\\s]+)#([0-9]+)$", issue, perl = TRUE)
  owner_repo_parts <- regmatches(issue, owner_repo_match)[[1]]
  if (length(owner_repo_parts) == 4) {
    return(list(owner = owner_repo_parts[2], repo = owner_repo_parts[3], number = owner_repo_parts[4]))
  }

  repo_match <- regexec("^([^/#\\s]+)#([0-9]+)$", issue, perl = TRUE)
  repo_parts <- regmatches(issue, repo_match)[[1]]
  if (length(repo_parts) == 3) {
    return(list(
      owner = getOption("gsm.utils.github_owner", "Gilead-BioStats"),
      repo = repo_parts[2],
      number = repo_parts[3]
    ))
  }

  stop(
    "`issue` must be a GitHub issue URL, `owner/repo#123`, or `repo#123` when `context_pack = NULL`.",
    call. = FALSE
  )
}


.fetch_github_issue_body <- function(owner, repo, number) {
  api_url <- paste0("https://api.github.com/repos/", owner, "/", repo, "/issues/", number)

  issue_json <- tryCatch(
    jsonlite::fromJSON(api_url),
    error = function(e) {
      stop(
        "Unable to fetch issue body from GitHub API for `",
        owner,
        "/",
        repo,
        "#",
        number,
        "`: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  body <- issue_json$body
  if (!is.character(body) || length(body) != 1 || !nzchar(trimws(body))) {
    stop(
      "GitHub issue body is empty for `",
      owner,
      "/",
      repo,
      "#",
      number,
      "`. Provide `context_pack` explicitly.",
      call. = FALSE
    )
  }

  body
}


.resolve_core_doc_paths <- function(strPackageDir, ai_docs_dir, core_docs) {
  use_root <- identical(ai_docs_dir, ".") || identical(ai_docs_dir, "")

  vapply(core_docs, function(doc) {
    preferred <- if (isTRUE(use_root)) doc else file.path(ai_docs_dir, doc)
    preferred_exists <- file.exists(file.path(strPackageDir, preferred))
    root_exists <- file.exists(file.path(strPackageDir, doc))

    if (isTRUE(preferred_exists)) {
      preferred
    } else if (isTRUE(root_exists)) {
      doc
    } else {
      preferred
    }
  }, character(1))
}
