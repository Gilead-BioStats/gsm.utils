test_that("render_rmd_assets warns for failed renders (#67)", {
  menu_subdir <- withr::local_tempdir()
  output_dir <- withr::local_tempdir()
  bad_file <- withr::local_tempfile(
    lines = "fake file",
    tmpdir = menu_subdir,
    fileext = ".Rmd"
  )
  local_mocked_bindings(
    render_rmd = function(
      strInputPath,
      strOutputFile,
      strOutputDir,
      lParams = NULL,
      quiet = FALSE
    ) {
      stop("Failed to render")
    }
  )
  expect_warning(
    render_rmd_assets(
      menu_subdir = menu_subdir,
      output_dir = output_dir,
      verbose = FALSE
    ),
    class = "gsm.utils-render_failure"
  )
})

test_that("render_rmd_assets returns paths to rendered files (#67)", {
  menu_subdir <- withr::local_tempdir("rmd")
  output_dir <- withr::local_tempdir("html")
  rmd1 <- fs::path(menu_subdir, "one.Rmd")
  writeLines("contents", rmd1)
  rmd2 <- fs::path(menu_subdir, "two.Rmd")
  writeLines("contents", rmd2)
  html1 <- fs::path(output_dir, "one.html")
  writeLines("contents", html1)
  html2 <- fs::path(output_dir, "two.html")
  writeLines("contents", html2)

  local_mocked_bindings(
    render_rmd = function(
      strInputPath,
      strOutputFile,
      strOutputDir,
      lParams = NULL,
      quiet = FALSE
    ) {
      fs::path(strOutputDir, strOutputFile)
    }
  )
  rendered <- render_rmd_assets(
    menu_subdir = menu_subdir,
    output_dir = output_dir,
    verbose = FALSE
  )
  expect_equal(rendered, c(html1, html2))
})
