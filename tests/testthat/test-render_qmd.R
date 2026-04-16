test_that("render_qmd_assets warns for failed renders (#67)", {
  menu_subdir <- withr::local_tempdir()
  output_dir <- withr::local_tempdir()
  bad_file <- withr::local_tempfile(
    lines = "fake file",
    tmpdir = menu_subdir,
    fileext = ".qmd"
  )
  local_mocked_bindings(
    render_qmd = function(
      qmd_file,
      output_file,
      params = NULL,
      verbose = FALSE
    ) {
      stop("Failed to render")
    }
  )
  expect_warning(
    render_qmd_assets(
      menu_subdir = menu_subdir,
      output_dir = output_dir,
      verbose = FALSE
    ),
    class = "gsm.utils-render_failure"
  )
})

test_that("render_qmd_assets returns paths to rendered files (#67)", {
  menu_subdir <- withr::local_tempdir("qmd")
  output_dir <- withr::local_tempdir("html")
  qmd1 <- fs::path(menu_subdir, "one.qmd")
  writeLines("contents", qmd1)
  qmd2 <- fs::path(menu_subdir, "two.qmd")
  writeLines("contents", qmd2)
  html1 <- fs::path(output_dir, "one.html")
  writeLines("contents", html1)
  html2 <- fs::path(output_dir, "two.html")
  writeLines("contents", html2)

  local_mocked_bindings(
    render_qmd = function(
      qmd_file,
      output_file,
      params = NULL,
      verbose = FALSE
    ) {
      output_file
    }
  )
  rendered <- render_qmd_assets(
    menu_subdir = menu_subdir,
    output_dir = output_dir,
    verbose = FALSE
  )
  expect_equal(rendered, c(html1, html2))
})
