test_that("build_pr_message returns formatted body and inferred title", {
  out <- build_pr_message(
    overview = c("Fix qtl axis labels", "Keep API unchanged"),
    test_notes = c("devtools::test(filter = 'plot_qtl_summary')"),
    connected_issues = c("123", "#456", "Closes #789")
  )

  expect_type(out, "list")
  expect_true("body" %in% names(out))
  expect_true("title" %in% names(out))
  expect_false(out$gh_called)

  expect_match(out$body, "## Overview")
  expect_match(out$body, "- Fix qtl axis labels")
  expect_match(out$body, "## Test Notes/Sample Code")
  expect_match(out$body, "## Connected Issues")
  expect_match(out$body, "- Closes #123")
  expect_match(out$body, "- Closes #456")
  expect_match(out$body, "- Closes #789")
})

test_that("build_pr_message uses N/A fallbacks", {
  out <- build_pr_message(
    overview = "Small docs update"
  )

  expect_match(out$body, "## Test Notes/Sample Code")
  expect_match(out$body, "- N/A")
})

test_that("build_pr_message validates required inputs", {
  expect_error(
    build_pr_message(overview = ""),
    "overview"
  )

  expect_error(
    build_pr_message(overview = "ok", run_gh = NA),
    "run_gh"
  )
})

test_that("build_pr_message emits friendly guidance for run_gh defaults", {
  expect_error(
    expect_message(
      expect_message(
        expect_message(
          build_pr_message(
            overview = "small fix",
            connected_issues = character(0),
            run_gh = TRUE,
            pr_title = NULL,
            base = ""
          ),
          "no `connected_issues` provided"
        ),
        "`pr_title` not supplied"
      ),
      "defaulting to 'dev'"
    ),
    "GitHub CLI `gh` not found|Failed to run `gh pr create`"
  )
})
