test_that("add_menu calls the expected helpers (#67)", {
  local_mocked_bindings(
    render_assets = function(menu_subdir, assets_dir, verbose) {
      expect_equal(menu_subdir, "test-menu")
      expect_equal(assets_dir, "pkgdown/assets")
      expect_equal(verbose, TRUE)
      return("rendered-assets/test-menu")
    },
    add_pkgdown_nav = function(
      pkgdown_yml,
      menu_subdir,
      rendered_assets,
      verbose
    ) {
      expect_equal(pkgdown_yml, "_pkgdown.yml")
      expect_equal(menu_subdir, "test-menu")
      expect_equal(rendered_assets, "rendered-assets/test-menu")
      expect_equal(verbose, TRUE)
      "done"
    }
  )
  expect_equal(
    add_menu("test-menu", "pkgdown/assets", "_pkgdown.yml", TRUE),
    "done"
  )
})

test_that("build_assets informs when source_dir doesn't exist (#67)", {
  expect_message(
    build_assets(source_dir = "nonexistent/dir"),
    "Source directory .+ does not exist"
  )
})

test_that("build_assets calls add_menu for each subdirectory of source_dir (#67)", {
  local_mocked_bindings(
    add_menu = function(menu_subdir, assets_dir, pkgdown_yml, verbose) {
      expect_true(
        stringr::str_ends(assets_dir, "pkgdown/assets")
      )
      expect_equal(fs::path_file(pkgdown_yml), "_pkgdown.yml")
      expect_equal(verbose, FALSE)
      cli::cli_inform("Called add_menu for {menu_subdir}")
      NULL
    }
  )

  source_dir <- withr::local_tempdir()
  fs::dir_create(fs::path(source_dir, "menu1"))
  fs::dir_create(fs::path(source_dir, "menu2"))

  build_assets(
    source_dir = source_dir,
    assets_dir = "pkgdown/assets",
    pkgdown_yml = "_pkgdown.yml",
    root_dir = tempdir()
  ) |>
    expect_message("Called add_menu for .+menu1") |>
    expect_message("Called add_menu for .+menu2")
})
