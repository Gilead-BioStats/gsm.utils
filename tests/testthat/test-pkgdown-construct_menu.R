test_that("empty_menu_metadata_table returns an empty df with correct columns (#67)", {
  result <- empty_menu_metadata_table()
  expect_equal(
    colnames(result),
    c("html_file", "title", "index")
  )
  expect_equal(nrow(result), 0)
})

test_that("construct_menu_metadata_table returns the expected df when menu_subdir doesn't exist (#67)", {
  expect_equal(
    construct_menu_metadata_table("nonexistent_subdir"),
    data.frame(
      html_file = character(),
      title = character(),
      index = numeric()
    )
  )
})

test_that("construct_menu_metadata_table returns the expected df when menu_subdir exists (#67)", {
  tmp <- withr::local_tempdir()
  menu_subdir <- fs::path(tmp, "menu_subdir")
  fs::dir_create(menu_subdir)

  fs::file_create(fs::path(menu_subdir, "file1.Rmd"))
  fs::file_create(fs::path(menu_subdir, "file2.Rmd"))

  result <- construct_menu_metadata_table(menu_subdir)

  expect_equal(
    colnames(result),
    c("html_file", "title", "index")
  )
  expect_equal(nrow(result), 2)
  expect_equal(unclass(result$html_file), c("file1.html", "file2.html"))
  expect_equal(result$title, c("File 1", "File 2"))
})

test_that("construct_menu_metadata_table returns an empty df when menu_subdir is empty (#67)", {
  tmp <- withr::local_tempdir()
  menu_subdir <- fs::path(tmp, "empty_menu_subdir")
  fs::dir_create(menu_subdir)

  result <- construct_menu_metadata_table(menu_subdir)

  expect_equal(
    colnames(result),
    c("html_file", "title", "index")
  )
  expect_equal(nrow(result), 0)
})

test_that("construct_menu returns an empty list when rendered_assets is empty (#67)", {
  expect_equal(
    construct_menu(NULL, NULL),
    list()
  )
})

test_that("construct_menu returns a list of menu items when rendered_assets are provided (#67)", {
  rendered_assets <- c("asset1.html", "asset2.html")
  metadata <- data.frame(
    html_file = rendered_assets,
    title = c("asset1", "asset2"),
    index = c(2, 1)
  )
  expected_menu <- list(
    list(text = "asset2", href = "asset2.html"),
    list(text = "asset1", href = "asset1.html")
  )
  expect_equal(
    construct_menu(rendered_assets, metadata),
    expected_menu
  )
})
