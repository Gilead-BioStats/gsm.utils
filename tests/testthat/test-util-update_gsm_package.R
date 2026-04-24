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
    add_gsm_actions = function(strPackageDir, overwrite, verbose) {
      expect_equal(strPackageDir, test_path())
      expect_true(overwrite)
      expect_true(verbose)
      cli::cli_inform("actions")
    },
    remove_deprecated_workflows = function(strPackageDir, overwrite, verbose) {
      expect_equal(strPackageDir, test_path())
      expect_true(overwrite)
      expect_true(verbose)
      cli::cli_inform("remove")
    }
  )
  update_gsm_package(test_path()) |>
    expect_message("issues") |>
    expect_message("actions") |>
    expect_message("remove")
})
