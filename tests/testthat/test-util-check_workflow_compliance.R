test_that("check_workflow_compliance works with no workflows directory", {
  temp_pkg <- withr::local_tempdir("test_pkg_no_workflows_compliance")

  result <- check_workflow_compliance(
    temp_pkg,
    bVerbose = FALSE,
    bFailOnErrors = FALSE
  )
  expect_type(result, "list")
  expect_false(result$is_compliant)
  expect_gt(length(result$missing_workflows), 0)
  expect_equal(length(result$extra_workflows), 0)
})

test_that("check_workflow_compliance detects compliant workflows", {
  temp_pkg <- withr::local_tempdir("test_pkg_compliant_workflows")
  gh_dir <- fs::dir_create(temp_pkg, ".github")
  fs::dir_copy(
    fs::path_package("gsm.utils", "gha_templates", "workflows"),
    gh_dir
  )

  # Check compliance
  result <- check_workflow_compliance(
    temp_pkg,
    bVerbose = FALSE,
    bFailOnErrors = FALSE
  )
  expect_type(result, "list")
  expect_true(result$is_compliant)
  expect_equal(length(result$missing_workflows), 0)
  expect_equal(length(result$version_issues), 0)
})

test_that("check_workflow_compliance detects missing or incorrect version header", {
  temp_pkg <- withr::local_tempdir("test_pkg_bad_version_header")
  gh_dir <- fs::dir_create(temp_pkg, ".github")
  fs::dir_copy(
    fs::path_package("gsm.utils", "gha_templates", "workflows"),
    gh_dir
  )
  workflows_dir <- fs::path(temp_pkg, ".github", "workflows")

  # Corrupt the version header in R-CMD-check.yaml
  target <- fs::path(workflows_dir, "R-CMD-check.yaml")
  lines <- readLines(target, warn = FALSE)
  lines[grep("^# gsm.utils GHA version:", lines)[
    1
  ]] <- "# gsm.utils GHA version: 0.0.0-bad"
  writeLines(lines, target)

  result <- check_workflow_compliance(
    temp_pkg,
    bVerbose = FALSE,
    bFailOnErrors = FALSE
  )

  expect_type(result, "list")
  # version_issues should flag the bad header
  expect_gt(length(result$version_issues), 0)
  expect_true(any(grepl("R-CMD-check.yaml", result$version_issues)))
})

test_that("check_workflow_compliance detects extra workflow files", {
  temp_pkg <- withr::local_tempdir("test_pkg_extra_workflow")
  gh_dir <- fs::dir_create(temp_pkg, ".github")
  fs::dir_copy(
    fs::path_package("gsm.utils", "gha_templates", "workflows"),
    gh_dir
  )

  # Add a workflow file that is not in the manifest
  extra_file <- fs::path(gh_dir, "workflows", "custom-deploy.yaml")
  writeLines(c("# custom workflow", "on: push", "jobs:"), extra_file)

  result <- check_workflow_compliance(
    temp_pkg,
    bVerbose = FALSE,
    bFailOnErrors = FALSE
  )

  expect_type(result, "list")
  expect_true("custom-deploy.yaml" %in% result$extra_workflows)
})

test_that("check_workflow_compliance detects content differences in critical workflows", {
  temp_pkg <- withr::local_tempdir("test_pkg_content_diff")
  gh_dir <- fs::dir_create(temp_pkg, ".github")
  fs::dir_copy(
    fs::path_package("gsm.utils", "gha_templates", "workflows"),
    gh_dir
  )

  workflows_dir <- fs::path(temp_pkg, ".github", "workflows")

  # Modify a non-comment line in R-CMD-check.yaml to introduce a content difference
  target <- fs::path(workflows_dir, "R-CMD-check.yaml")
  lines <- readLines(target, warn = FALSE)
  # Replace the first non-comment, non-empty line with altered content
  non_comment_idx <- which(!grepl("^#|^\\s*$", lines))[1]
  lines[non_comment_idx] <- paste0(lines[non_comment_idx], " # modified")
  writeLines(lines, target)

  result <- check_workflow_compliance(
    temp_pkg,
    bVerbose = FALSE,
    bFailOnErrors = FALSE
  )

  expect_type(result, "list")
  expect_gt(length(result$content_issues), 0)
  expect_true(any(grepl("R-CMD-check.yaml", result$content_issues)))
})
