# build_example_filename ----

test_that("build_example_filename creates correct filename (#20)", {
  build_example_filename("My Example", "Example") |>
    expect_equal("Example_My_Example.Rmd")
  build_example_filename("My Cookbook", "Cookbook") |>
    expect_equal("Cookbook_My_Cookbook.Rmd")
})

test_that("build_example_filename sanitizes special characters (#20)", {
  build_example_filename("foo--bar!!baz", "Example") |>
    expect_equal("Example_foo_bar_baz.Rmd")
  build_example_filename("--leading", "Example") |>
    expect_equal("Example_leading.Rmd")
})

# build_example_template ----

test_that("build_example_template uses provided strDetails (#20)", {
  build_example_template(
    strName = "Test",
    strType = "Example",
    strDetails = "Custom description",
    intIndex = 1
  ) |>
    expect_contains("description: \"Custom description\"") |>
    expect_contains("index: 1")
})

test_that("build_example_template falls back when strDetails is NULL (#20)", {
  build_example_template(
    strName = "Test",
    strType = "Cookbook",
    strDetails = NULL,
    intIndex = 5
  ) |>
    expect_contains(
      "description: \"Example of a Cookbook generated using gsm packages.\""
    )
})

test_that("build_example_template omits index line when intIndex is NA (#20)", {
  build_example_template(
    strName = "Test",
    strType = "Example",
    strDetails = "desc",
    intIndex = NA
  ) |>
    expect_no_match("^index:")
})

# make_example ----

test_that("make_example creates file in output_dir (#20)", {
  tmp <- withr::local_tempdir(pattern = "examples")
  make_example(
    strName = "Test_Name",
    strType = "Example",
    output_dir = tmp
  ) |>
    expect_message("Created")
  expect_snapshot_file(fs::path(tmp, "Example_Test_Name.Rmd"))
})

test_that("make_example errors when file exists and overwrite is FALSE (#20)", {
  tmp <- withr::local_tempdir(pattern = "examples")
  # Create initial file.
  make_example(strName = "Dup", strType = "Example", output_dir = tmp) |>
    expect_message("Created")
  # Create duplicate without overwrite.
  make_example(strName = "Dup", strType = "Example", output_dir = tmp) |>
    expect_error("File already exists")
})

test_that("make_example succeeds with overwrite = TRUE (#20)", {
  tmp <- withr::local_tempdir(pattern = "examples")
  # Create initial file.
  make_example(strName = "Over", strType = "Example", output_dir = tmp) |>
    expect_message("Created")
  # Create duplicate with overwrite.
  make_example(
    strName = "Over",
    strType = "Example",
    output_dir = tmp,
    overwrite = TRUE
  ) |>
    expect_no_error() |>
    expect_message("Created")
})

test_that("make_example matches arg for strType (#20)", {
  tmp <- withr::local_tempdir(pattern = "examples")
  make_example(strName = "X", strType = "Invalid", output_dir = tmp) |>
    expect_error("must be one of")
})

test_that("make_example is silent when verbose is FALSE (#136)", {
  tmp <- withr::local_tempdir(pattern = "examples")
  make_example(
    strName = "Quiet",
    strType = "Example",
    output_dir = tmp,
    verbose = FALSE
  ) |>
    expect_no_message()
})
