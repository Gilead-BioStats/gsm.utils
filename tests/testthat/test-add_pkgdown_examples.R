test_that("add_pkgdown_examples gives the expected message", {
  local_mocked_bindings(
    write_yaml = function(...) {
      message("YAML written")
    }
  )
  expect_snapshot({
    test_result <- add_pkgdown_examples(
      test_path("fixtures", "pkgdown_examples"),
      test_path("fixtures", "_pkgdown.yml"),
      rmd_dir = NULL
    )
  })
  expect_null(test_result)
})

test_that("add_pkgdown_examples adds section if it doesn't exist", {
  local_mocked_bindings(
    write_yaml = function(...) {
      message("YAML written")
    }
  )
  expect_snapshot({
    test_result <- add_pkgdown_examples(
      test_path("fixtures", "pkgdown_examples"),
      test_path("fixtures", "_pkgdown_no_examples.yml"),
      rmd_dir = NULL
    )
  })
})

test_that("add_pkgdown_examples removes examples section if no examples", {
  local_mocked_bindings(
    write_yaml = function(...) {
      message("YAML written")
    }
  )
  empty_dir <- withr::local_tempdir("examples")
  expect_snapshot(
    {
      test_result <- add_pkgdown_examples(
        empty_dir,
        test_path("fixtures", "_pkgdown.yml"),
        rmd_dir = NULL
      )
    },
    transform = function(lines) {
      sub(
        "No HTML files found in .+",
        "No HTML files found in <tempdir>",
        lines
      )
    }
  )
})
