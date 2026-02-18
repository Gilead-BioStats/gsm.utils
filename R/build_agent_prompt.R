#' Build an agent execution prompt from issue + Context Pack
#'
#' Generates a ready-to-paste instruction block for coding agents using a
#' canonical issue reference and a filled Context Pack.
#'
#' @param issue `character` issue reference (e.g., `"gsm.qtl#123"` or URL).
#' @param context_pack `character` full Context Pack text.
#'
#' @return A single `character` string containing the assembled prompt.
#' @export
build_agent_prompt <- function(issue, context_pack) {
  if (!is.character(issue) || length(issue) != 1 || !nzchar(trimws(issue))) {
    stop("`issue` must be a non-empty character scalar.", call. = FALSE)
  }

  if (!is.character(context_pack) || length(context_pack) != 1 || !nzchar(trimws(context_pack))) {
    stop("`context_pack` must be a non-empty character scalar.", call. = FALSE)
  }

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

  paste(lines, collapse = "\n\n")
}
