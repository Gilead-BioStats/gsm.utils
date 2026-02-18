test_that("build_agent_prompt returns assembled instruction text", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo + Branch: gsm.qtl / dev",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  out <- build_agent_prompt("gsm.qtl#123", cp)

  expect_type(out, "character")
  expect_length(out, 1)
  expect_match(out, "Issue reference: gsm.qtl#123")
  expect_match(out, "Context Pack:")
  expect_match(out, "Goal: Fix qtl axis labels")
  expect_match(out, "Treat core docs as read-only")
})

test_that("build_agent_prompt uses issue body when context_pack is NULL", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo + Branch: gsm.qtl / dev",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  local_mocked_bindings(
    .fetch_github_issue_body = function(owner, repo, number) {
      expect_identical(owner, "Gilead-BioStats")
      expect_identical(repo, "gsm.qtl")
      expect_identical(number, "123")
      cp
    },
    .package = "gsm.utils"
  )

  out <- build_agent_prompt("gsm.qtl#123")

  expect_match(out, "Issue reference: gsm.qtl#123")
  expect_match(out, "Goal: Fix qtl axis labels")
})

test_that("build_agent_prompt errors for non-GitHub issue when context_pack is NULL", {
  expect_error(
    build_agent_prompt("not-a-github-issue"),
    "GitHub issue URL"
  )
})

test_that("build_agent_prompt errors when issue is invalid", {
  expect_error(
    build_agent_prompt("", "Goal: x\nNon-goals: y\nTarget Repo + Branch: z\nAllowed-to-touch Files: a\nEntry Points: b\nTests to Run: c\nDefinition of Done: d\nDAG Impact: e"),
    "issue"
  )
})

test_that("build_agent_prompt errors when context pack is incomplete", {
  cp <- "Goal: Fix thing\nNon-goals: none"

  expect_error(
    build_agent_prompt("gsm.qtl#123", cp),
    "Context Pack appears incomplete"
  )
})

test_that("build_agent_prompt accepts common Target Repo Branch header variants", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo/Branch: gsm.qtl / dev",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  expect_no_error(build_agent_prompt("gsm.qtl#123", cp))
})

test_that("build_agent_prompt errors when required markdown section is empty", {
  cp <- paste(
    "## Goal",
    "Fix qtl axis labels",
    "",
    "## Non-goals",
    "No API changes",
    "",
    "## Target Repo + Branch",
    "",
    "## Allowed-to-touch Files",
    "R/plot_qtl_summary.R",
    "",
    "## Entry Points",
    "plot_qtl_summary()",
    "",
    "## Tests to Run",
    "devtools::test(filter = 'plot_qtl_summary')",
    "",
    "## Definition of Done",
    "tests pass",
    "",
    "## DAG Impact",
    "none",
    sep = "\n"
  )

  expect_error(
    build_agent_prompt("gsm.qtl#123", cp),
    "Context Pack has empty required field"
  )
})

test_that("build_agent_prompt errors when required key-value field is empty", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo + Branch:",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  expect_error(
    build_agent_prompt("gsm.qtl#123", cp),
    "TBD/Unknown/None"
  )
})

test_that("build_agent_prompt can disable core-doc lock instruction", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo + Branch: gsm.qtl / dev",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  out <- build_agent_prompt("gsm.qtl#123", cp, lock_core_docs = FALSE)

  expect_false(grepl("Treat core docs as read-only", out, fixed = TRUE))
})

test_that("build_agent_prompt prefers contained ai docs path", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo + Branch: gsm.qtl / dev",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  out <- build_agent_prompt("gsm.qtl#123", cp)

  expect_match(out, "\\.github/ai/AGENTS\\.md")
})

test_that("build_agent_prompt falls back to root docs when present", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo + Branch: gsm.qtl / dev",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  tmp <- withr::local_tempdir()
  writeLines("# AGENTS", file.path(tmp, "AGENTS.md"))

  out <- build_agent_prompt("gsm.qtl#123", cp, strPackageDir = tmp)

  expect_match(out, "Allowed-to-touch Files: AGENTS\\.md")
  expect_false(grepl("\\.github/ai/AGENTS\\.md", out))
})

test_that("build_agent_prompt errors on invalid lock_core_docs", {
  cp <- paste(
    "Goal: Fix qtl axis labels",
    "Non-goals: No API changes",
    "Target Repo + Branch: gsm.qtl / dev",
    "Allowed-to-touch Files: R/plot_qtl_summary.R",
    "Entry Points: plot_qtl_summary()",
    "Tests to Run (Exact Commands): devtools::test(filter = 'plot_qtl_summary')",
    "Definition of Done: tests pass",
    "DAG Impact: none",
    sep = "\n"
  )

  expect_error(
    build_agent_prompt("gsm.qtl#123", cp, lock_core_docs = NA),
    "lock_core_docs"
  )
})
