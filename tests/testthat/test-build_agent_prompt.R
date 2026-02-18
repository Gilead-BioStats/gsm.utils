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
