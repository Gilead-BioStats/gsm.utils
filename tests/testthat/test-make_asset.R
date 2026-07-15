# .make_index_line ----

test_that(".make_index_line returns index line for valid input (#136)", {
  .make_index_line(5) |>
    expect_equal("index: 5")
})

test_that(".make_index_line returns NULL for absent values (#136)", {
  .make_index_line(NA) |>
    expect_null()
  .make_index_line(NULL) |>
    expect_null()
  .make_index_line(integer(0)) |>
    expect_null()
})

# .make_title_line ----

test_that(".make_title_line returns quoted title line (#136)", {
  .make_title_line("My Title") |>
    expect_equal("title: \"My Title\"")
})

# .build_asset_template ----

test_that(".build_asset_template builds front matter with title and body (#136)", {
  .build_asset_template(
    strTitle = "Test",
    intIndex = NA,
    chrBody = c("", "Content here.")
  ) |>
    expect_equal(c("---", "title: \"Test\"", "---", "", "Content here."))
})

test_that(".build_asset_template includes index when provided (#136)", {
  .build_asset_template(strTitle = "Test", intIndex = 5) |>
    expect_contains("index: 5")
})

test_that(".build_asset_template renders lHeaders as YAML (#136)", {
  .build_asset_template(
    strTitle = "Test",
    intIndex = NA,
    lHeaders = list(author = "Me", output = "html_document")
  ) |>
    expect_contains("author: Me") |>
    expect_contains("output: html_document")
})

test_that(".build_asset_template renders logicals as true/false (#136)", {
  .build_asset_template(
    strTitle = "Test",
    intIndex = NA,
    lHeaders = list(execute = list(eval = FALSE, echo = TRUE))
  ) |>
    expect_contains("  eval: false") |>
    expect_contains("  echo: true")
})

test_that(".build_asset_template skips lHeaders when empty (#136)", {
  result <- .build_asset_template(
    strTitle = "Test",
    intIndex = NA,
    lHeaders = list()
  )
  expect_equal(result[[1]], "---")
  expect_equal(result[[2]], "title: \"Test\"")
  expect_equal(result[[3]], "---")
})

# make_asset ----

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
