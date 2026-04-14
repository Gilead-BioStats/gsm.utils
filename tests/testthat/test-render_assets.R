test_that("render_assets passes the expected variables to child functions (#67)", {
  local_mocked_bindings(
    render_rmd_assets = function(menu_subdir, output_subdir, verbose) {
      expect_equal(menu_subdir, "examples")
      expect_equal(output_subdir, fs::path("pkgdown/assets/examples"))
      expect_false(verbose)
      return(fs::path(output_subdir, "example1.html"))
    },
    render_qmd_assets = function(menu_subdir, output_subdir, verbose) {
      expect_equal(menu_subdir, "examples")
      expect_equal(output_subdir, fs::path("pkgdown/assets/examples"))
      expect_false(verbose)
      return(fs::path(output_subdir, c("example2.html", "example3.html")))
    }
  )
  expect_equal(
    render_assets("examples", "pkgdown/assets", verbose = FALSE),
    fs::path("examples", c("example1.html", "example2.html", "example3.html"))
  )
})

test_that("render_assets deals with empty returns (#67)", {
  local_mocked_bindings(
    render_rmd_assets = function(...) "",
    render_qmd_assets = function(...) ""
  )
  expect_equal(
    render_assets("examples", "pkgdown/assets", verbose = FALSE),
    fs::path(character())
  )
  local_mocked_bindings(
    render_rmd_assets = function(...) "pkgdown/assets/x"
  )
  expect_equal(
    render_assets("examples", "pkgdown/assets", verbose = FALSE),
    fs::path("x")
  )
  local_mocked_bindings(
    render_rmd_assets = function(...) "",
    render_qmd_assets = function(...) "pkgdown/assets/x"
  )
  expect_equal(
    render_assets("examples", "pkgdown/assets", verbose = FALSE),
    fs::path("x")
  )
})
