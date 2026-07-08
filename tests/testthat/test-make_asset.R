test_that("make_asset creates directory and writes file (#136)", {
  tmp <- withr::local_tempdir()
  template <- c("---", "title: \"Test\"", "---", "", "Body content.")
  make_asset(
    strFilename = "test_file.Rmd",
    strMenu = "examples",
    strTemplate = template,
    strMenuDir = tmp
  ) |>
    expect_message("Created examples asset")
  expect_snapshot_file(fs::path(tmp, "examples", "test_file.Rmd"))
})

test_that("make_asset returns path invisibly (#136)", {
  tmp <- withr::local_tempdir()
  make_asset(
    strFilename = "vis.Rmd",
    strMenu = "examples",
    strTemplate = c("line1", "line2"),
    strMenuDir = tmp
  ) |>
    expect_invisible() |>
    expect_message("Created examples asset")
})

test_that("make_asset errors when file exists and overwrite is FALSE (#136)", {
  tmp <- withr::local_tempdir()
  template <- c("content")
  # Create initial file.
  make_asset(
    strFilename = "dup.Rmd",
    strMenu = "examples",
    strTemplate = template,
    strMenuDir = tmp
  ) |>
    expect_message("Created examples asset")
  # Create duplicate without overwrite.
  make_asset(
    strFilename = "dup.Rmd",
    strMenu = "examples",
    strTemplate = template,
    strMenuDir = tmp
  ) |>
    expect_error("File already exists")
})

test_that("make_asset succeeds with overwrite = TRUE (#136)", {
  tmp <- withr::local_tempdir()
  # Create initial file.
  make_asset(
    strFilename = "over.Rmd",
    strMenu = "examples",
    strTemplate = c("original"),
    strMenuDir = tmp
  ) |>
    expect_message("Created examples asset")
  # Create duplicate with overwrite.
  make_asset(
    strFilename = "over.Rmd",
    strMenu = "examples",
    strTemplate = c("updated"),
    strMenuDir = tmp,
    overwrite = TRUE
  ) |>
    expect_no_error() |>
    expect_message("Created examples asset")
  expect_snapshot_file(fs::path(tmp, "examples", "over.Rmd"))
})

test_that("make_asset is silent when verbose is FALSE (#136)", {
  tmp <- withr::local_tempdir()
  make_asset(
    strFilename = "quiet.Rmd",
    strMenu = "examples",
    strTemplate = c("content"),
    strMenuDir = tmp,
    verbose = FALSE
  ) |>
    expect_no_message()
})

test_that("make_asset writes to correct subdirectory (#136)", {
  tmp <- withr::local_tempdir()
  make_asset(
    strFilename = "deck.qmd",
    strMenu = "slides",
    strTemplate = c("slides content"),
    strMenuDir = tmp
  ) |>
    fs::path_dir() |>
    expect_equal(as.character(fs::path(tmp, "slides"))) |>
    expect_message("Created slides asset")
})
