test_that("update_gsm_package errors when strPackageDir doesn't exist (#90)", {
  expect_error(
    update_gsm_package(strPackageDir = "nonexistent/dir"),
    "package directory does not exist"
  )
})

test_that("update_gsm_package calls the expected sub-functions (#90)", {
  local_mocked_bindings(
    add_gsm_issue_templates = function(strPackageDir, overwrite, verbose) {
      expect_equal(strPackageDir, test_path())
      expect_true(overwrite)
      expect_true(verbose)
      cli::cli_inform("issues")
    },
    remove_deprecated_issue_templates = function(strPackageDir, overwrite, verbose) {
      expect_equal(strPackageDir, test_path())
      expect_true(overwrite)
      expect_true(verbose)
      cli::cli_inform("remove-templates")
    },
    add_actions = function(strPackageDir, overwrite, verbose) {
      expect_equal(strPackageDir, test_path())
      expect_true(overwrite)
      expect_true(verbose)
      cli::cli_inform("actions")
    },
    remove_deprecated_actions = function(strPackageDir, overwrite, verbose) {
      expect_equal(strPackageDir, test_path())
      expect_true(overwrite)
      expect_true(verbose)
      cli::cli_inform("remove-actions")
    }
  )
  update_gsm_package(test_path()) |>
    expect_message("issues") |>
    expect_message("remove-templates") |>
    expect_message("actions") |>
    expect_message("remove-actions")
})

# remove_deprecated_issue_templates ----

test_that("remove_deprecated_issue_templates informs when nothing removed and verbose", {
  local_mocked_bindings(
    .remove_issue_template = function(...) character()
  )
  remove_deprecated_issue_templates() |>
    expect_equal(character()) |>
    expect_message("No deprecated issue templates found")
  remove_deprecated_issue_templates(verbose = FALSE) |>
    expect_equal(character()) |>
    expect_no_message()
})

## .remove_issue_template

test_that(".remove_issue_template returns silently when file doesn't exist", {
  templates_path <- withr::local_tempdir("templates")
  .remove_issue_template("does-not-exist.md", templates_path) |>
    expect_equal(NULL) |>
    expect_no_message()
})

test_that(".remove_issue_template errors when file exists but overwrite is false", {
  templates_path <- withr::local_tempdir("templates")
  template_name <- "1-requirement.md"
  template_path <- fs::path(templates_path, template_name)
  writeLines("Old template", template_path)
  .remove_issue_template(
    template_name,
    templates_path,
    overwrite = FALSE
  ) |>
    expect_error("Deprecated issue template .+ found")
})

test_that(".remove_issue_template removes deprecated templates", {
  templates_path <- withr::local_tempdir("templates")
  template_name <- "1-requirement.md"
  template_path <- fs::path(templates_path, template_name)
  writeLines("Old template", template_path)
  .remove_issue_template(template_name, templates_path) |>
    expect_equal(template_name) |>
    expect_message("Removing deprecated issue template")
  expect_false(fs::file_exists(template_path))
})
