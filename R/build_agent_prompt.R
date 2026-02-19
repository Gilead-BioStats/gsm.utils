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
    "Goal" = "goal",
    "Non-goals" = "non[[:space:]-]*goals?",
    "Target Repo + Branch" = "target[[:space:]-]*repo(?:[[:space:]]*([+&/]|and)?[[:space:]-]*branch)?",
    "Allowed-to-touch Files" = "allowed[[:space:]-]*to[[:space:]-]*touch[[:space:]-]*files?",
    "Entry Points" = "entry[[:space:]-]*points?",
    "Tests to Run" = "tests?[[:space:]-]*to[[:space:]-]*run",
    "Definition of Done" = "definition[[:space:]-]*of[[:space:]-]*done",
    "DAG Impact" = "dag[[:space:]-]*impact"
  )

  missing_fields <- names(required_fields)[!vapply(
    required_fields,
    function(pattern) grepl(paste0("\\b", pattern, "\\b"), context_pack, ignore.case = TRUE, perl = TRUE),
    logical(1)
  )]

  empty_fields <- names(required_fields)[vapply(
    required_fields,
    function(pattern) .context_field_is_empty(context_pack, pattern),
    logical(1)
  )]

  if (length(missing_fields) > 0) {
    stop(
      "Context Pack appears incomplete. Missing field(s): ",
      paste(missing_fields, collapse = ", "),
      call. = FALSE
    )
  }

  if (length(empty_fields) > 0) {
    stop(
      "Context Pack has empty required field(s): ",
      paste(empty_fields, collapse = ", "),
      ". Use explicit placeholders like TBD/Unknown/None instead of leaving fields empty.",
      call. = FALSE
    )
  }

  refresher_docs <- .resolve_core_doc_paths(
    strPackageDir = strPackageDir,
    ai_docs_dir = ai_docs_dir,
    core_docs = c("AGENTS.md", "ECOSYSTEM.md", "ARCHITECTURE.md", "SKILLS.md")
  )

  lines <- c(
    "Agent Execution Prompt",
    "",
    "Execution protocol:",
    "- Execute this ticket exactly as scoped below.",
    "- Do not edit files outside Allowed-to-touch Files.",
    "- If required fields are missing or ambiguous, stop and ask targeted clarifying questions before coding.",
    "- Always run the full repository testthat suite: devtools::test().",
    "- Then run any additional exact checks listed in the Context Pack (or treat `None (full-suite only)` as no extra checks).",
    "- If you change function arguments, exported APIs, or roxygen docs, run devtools::document() and include generated man/NAMESPACE updates when applicable.",
    paste0("- Before coding, read AI docs for context/refresher: ", paste(refresher_docs, collapse = ", "), "."),
    "",
    "Return output sections (exact): Summary | Files changed | Patch/diff | Tests run | Downstream verification | Risks/rollback | Follow-ups.",
    "",
    paste0("Issue reference: ", trimws(issue)),
    "",
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

  paste(lines, collapse = "\n")
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


.context_field_is_empty <- function(text, label_pattern) {
  heading_pattern <- paste0("^\\s*#{1,6}\\s*", label_pattern, "\\s*$")
  kv_empty_pattern <- paste0("^\\s*", label_pattern, "\\s*:\\s*$")

  lines <- strsplit(text, "\\n", fixed = FALSE)[[1]]
  heading_idx <- grep(heading_pattern, lines, ignore.case = TRUE, perl = TRUE)

  if (length(heading_idx) > 0) {
    for (idx in heading_idx) {
      next_heading <- grep("^\\s*#{1,6}\\s+", lines, perl = TRUE)
      next_heading <- next_heading[next_heading > idx]
      end_idx <- if (length(next_heading) > 0) next_heading[1] - 1 else length(lines)

      if (idx < end_idx) {
        section_text <- paste(lines[(idx + 1):end_idx], collapse = "\n")
      } else {
        section_text <- ""
      }

      section_text <- gsub("(?s)<!--.*?-->", "", section_text, perl = TRUE)
      if (!nzchar(trimws(section_text))) {
        return(TRUE)
      }
    }
  }

  any(grepl(kv_empty_pattern, lines, ignore.case = TRUE, perl = TRUE))
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
