#' Build an agent execution prompt from issue + Context Pack
#'
#' Generates a ready-to-paste instruction block for coding agents using a
#' canonical issue reference and a filled Context Pack.
#'
#' @param issue `character` issue reference (e.g., `"gsm.qtl#123"` or URL).
#' @param context_pack `character` full Context Pack text.
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
                               context_pack,
                               lock_core_docs = TRUE,
                               strPackageDir = ".",
                               ai_docs_dir = file.path(".github", "ai")) {
  if (!is.character(issue) || length(issue) != 1 || !nzchar(trimws(issue))) {
    stop("`issue` must be a non-empty character scalar.", call. = FALSE)
  }

  if (!is.character(context_pack) || length(context_pack) != 1 || !nzchar(trimws(context_pack))) {
    stop("`context_pack` must be a non-empty character scalar.", call. = FALSE)
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

  required_fields <- c(
    "Goal",
    "Non-goals",
    "Target Repo + Branch",
    "Allowed-to-touch Files",
    "Entry Points",
    "Tests to Run",
    "Definition of Done",
    "DAG Impact"
  )

  missing_fields <- required_fields[!vapply(
    required_fields,
    function(x) grepl(x, context_pack, ignore.case = TRUE),
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
