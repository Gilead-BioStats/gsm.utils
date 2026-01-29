test_that("render_examples informs when directory missing", {
  missing_dir <- file.path(withr::local_tempdir(), "missing")
  expect_message(
    render_examples(examples_dir = missing_dir),
    "does not exist"
  )
})

test_that("render_examples informs when no Rmd files", {
  empty_dir <- withr::local_tempdir()
  expect_message(
    render_examples(examples_dir = empty_dir),
    "No \\.Rmd files found"
  )
})

test_that("render_examples renders files and adds header", {
  testthat::skip_if_not_installed("rmarkdown")

  tmp <- withr::local_tempdir()
  examples_dir <- file.path(tmp, "inst", "examples")
  dir.create(examples_dir, recursive = TRUE)

  rmd_file <- file.path(examples_dir, "example_one.Rmd")
  writeLines(
    c(
      "---",
      "title: \"My Title\"",
      "author: \"Example Author\"",
      "date: \"2026-01-01\"",
      "type: \"Example\"",
      "details: \"Details here\"",
      "---",
      "Body"
    ),
    rmd_file
  )

  output_dir <- file.path(tmp, "pkgdown", "assets", "examples")

  local_mocked_bindings(
    render_rmd = function(input, output_file, quiet = FALSE, ...) {
      writeLines(
        c(
          "<html>",
          "<body>",
          "<p>Hi</p>",
          "</body>",
          "</html>"
        ),
        output_file
      )
      invisible(output_file)
    }
  )

  outputs <- render_examples(
    examples_dir = examples_dir,
    output_dir = output_dir,
    quiet = TRUE
  )

  expect_length(outputs, 1)
  expect_true(file.exists(outputs[1]))
})
