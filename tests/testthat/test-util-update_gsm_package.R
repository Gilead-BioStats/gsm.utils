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
    remove_deprecated_issue_templates = function(
      strPackageDir,
      overwrite,
      verbose
    ) {
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

# add_gsm_issue_templates ----

test_that("add_gsm_issue_templates errors when path exists and overwrite is FALSE", {
  local_mocked_bindings(
    .find_issue_path = function(strPackageDir) test_path()
  )
  expect_error(
    add_gsm_issue_templates(overwrite = FALSE),
    "directory already exists"
  )
})

test_that("add_gsm_issue_templates copies expected files to issue path", {
  strPackageDir <- withr::local_tempdir()
  expect_no_error(add_gsm_issue_templates(strPackageDir))
  issuePath <- fs::path(strPackageDir, ".github", "ISSUE_TEMPLATE")
  expect_true(fs::dir_exists(issuePath))
  expect_all_true(unname(fs::file_exists(
    fs::path(
      issuePath,
      c(
        "2-bug.md",
        "3-feature.md",
        "4-technical.md",
        "5-documentation.md",
        "config.yml"
      )
    )
  )))
})

# remove_deprecated_issue_templates ----

test_that("remove_deprecated_issue_templates informs when nothing removed and verbose (#100)", {
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

test_that(".remove_issue_template returns silently when file doesn't exist (#100)", {
  templates_path <- withr::local_tempdir("templates")
  .remove_issue_template("does-not-exist.md", templates_path) |>
    expect_equal(NULL) |>
    expect_no_message()
})

test_that(".remove_issue_template errors when file exists but overwrite is false (#100)", {
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

test_that(".remove_issue_template removes deprecated templates (#100)", {
  templates_path <- withr::local_tempdir("templates")
  template_name <- "1-requirement.md"
  template_path <- fs::path(templates_path, template_name)
  writeLines("Old template", template_path)
  .remove_issue_template(template_name, templates_path) |>
    expect_equal(template_name) |>
    expect_message("Removing deprecated issue template")
  expect_false(fs::file_exists(template_path))
})

# add_contributor_guidelines ----

test_that("add_contributor_guidelines errors if can't overwrite", {
  local_mocked_bindings(
    .ensure_github_dir_exists = function(strPackageDir) "gh",
    .find_contributing = function(strPackageDir) test_path()
  )
  expect_error(
    add_contributor_guidelines(overwrite = FALSE),
    "file already exists"
  )
})

test_that("add_contributor_guidelines copies expected file to github dir", {
  strPackageDir <- withr::local_tempdir()
  expect_no_error(add_contributor_guidelines(strPackageDir))
  expect_true(fs::file_exists(fs::path(
    strPackageDir,
    ".github",
    "CONTRIBUTING.md"
  )))
})
