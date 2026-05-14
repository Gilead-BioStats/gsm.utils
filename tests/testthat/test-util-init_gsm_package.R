test_that("init_gsm_package initializes a GSM package", {
  skip_if_not_installed("usethis")
  local_mocked_bindings(
    .initialize_git = function(strOrg) TRUE
  )
  withr::local_options(usethis.quiet = TRUE)
  strPackageDir <- withr::local_tempdir()
  force(strPackageDir)
  init_gsm_package(strPackageDir, lDescriptionFields = list(Language = "es")) |>
    expect_message("No deprecated issue") |>
    expect_message("Creating or updating workflow file") |>
    expect_message("Creating or updating workflow file") |>
    expect_message("Creating or updating workflow file") |>
    expect_message("Creating or updating workflow file") |>
    expect_message("Creating or updating workflow file") |>
    expect_message("No deprecated workflows")
  expect_true(fs::dir_exists(fs::path(strPackageDir, ".github")))
  expect_true(fs::dir_exists(fs::path(strPackageDir, ".github/ISSUE_TEMPLATE")))
  expect_true(fs::dir_exists(fs::path(strPackageDir, ".github/workflows")))
  expect_true(fs::dir_exists(fs::path(strPackageDir, "inst")))
  expect_true(fs::dir_exists(fs::path(strPackageDir, "inst/workflow")))
  expect_true(fs::dir_exists(fs::path(
    strPackageDir,
    "inst/workflow/1_mappings"
  )))
  expect_true(fs::dir_exists(fs::path(strPackageDir, "R")))
  expect_true(fs::dir_exists(fs::path(strPackageDir, "tests")))
  expect_true(fs::dir_exists(fs::path(strPackageDir, "tests/testthat")))
})
