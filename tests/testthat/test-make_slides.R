# .build_slides_filename ----

test_that(".build_slides_filename creates lowercase hyphenated filename (#136)", {
  .build_slides_filename("My Slide Deck") |>
    expect_equal("my-slide-deck.qmd")
})

test_that(".build_slides_filename sanitizes special characters (#136)", {
  .build_slides_filename("foo--bar!!baz") |>
    expect_equal("foo-bar-baz.qmd")
  .build_slides_filename("--leading") |>
    expect_equal("leading.qmd")
})

# .build_slides_template ----

test_that(".build_slides_template includes title and index (#136)", {
  .build_slides_template(strTitle = "Test Deck", intIndex = 3) |>
    expect_contains("title: \"Test Deck\"") |>
    expect_contains("index: 3")
})

test_that(".build_slides_template omits index line when intIndex is NA (#136)", {
  .build_slides_template(strTitle = "Test Deck", intIndex = NA) |>
    expect_no_match("^index:")
})

# make_slides ----

test_that("make_slides creates file in output_dir (#136)", {
  tmp <- withr::local_tempdir(pattern = "slides")
  make_slides(
    strTitle = "Test Deck",
    output_dir = tmp
  ) |>
    expect_message("Created")
  expect_snapshot_file(fs::path(tmp, "test-deck.qmd"))
})

test_that("make_slides errors when file exists and overwrite is FALSE (#136)", {
  tmp <- withr::local_tempdir(pattern = "slides")
  # Create initial file.
  make_slides(strTitle = "Dup Deck", output_dir = tmp) |>
    expect_message("Created")
  # Create duplicate without overwrite.
  make_slides(strTitle = "Dup Deck", output_dir = tmp) |>
    expect_error("File already exists")
})

test_that("make_slides succeeds with overwrite = TRUE (#136)", {
  tmp <- withr::local_tempdir(pattern = "slides")
  # Create initial file.
  make_slides(strTitle = "Over Deck", output_dir = tmp) |>
    expect_message("Created")
  # Create duplicate with overwrite.
  make_slides(
    strTitle = "Over Deck",
    output_dir = tmp,
    overwrite = TRUE
  ) |>
    expect_no_error() |>
    expect_message("Created")
})

test_that("make_slides is silent when verbose is FALSE (#136)", {
  tmp <- withr::local_tempdir(pattern = "slides")
  make_slides(
    strTitle = "Quiet Deck",
    output_dir = tmp,
    verbose = FALSE
  ) |>
    expect_no_message()
})
