test_that("ensure_pkgdown_menu_section adds menu to components (#67)", {
  test_result <- ensure_pkgdown_menu_section(list(), "testMenu")
  expect_equal(
    test_result$navbar,
    list(components = list(testMenu = list(text = "Test Menu", menu = list())))
  )
})

test_that("ensure_pkgdown_menu_section adds menu to left (#67)", {
  test_result <- ensure_pkgdown_menu_section(
    list(navbar = list(structure = list(left = list()))),
    "testMenu"
  )
  expect_equal(
    test_result$navbar$structure$left,
    list("testMenu")
  )
})

test_that("add_assets_to_pkgdown_menu adds items to menu (#67)", {
  local_mocked_bindings(
    construct_menu_metadata_table = function(...) {
      data.frame(
        html_file = c("asset1.html", "asset2.html"),
        title = c("Asset 1", "Asset 2"),
        index = c(2, 1)
      )
    }
  )
  test_result <- add_assets_to_pkgdown_menu(
    list(
      navbar = list(
        components = list(
          testMenu = list(
            text = "Test Menu",
            menu = list()
          )
        )
      )
    ),
    "testMenu",
    menu_subdir = "testMenu",
    rendered_assets = c("asset1.html", "asset2.html")
  )
  expect_equal(
    test_result$navbar$components$testMenu$menu,
    list(
      list(text = "Asset 2", href = "asset2.html"),
      list(text = "Asset 1", href = "asset1.html")
    )
  )
})

test_that("update_pkgdown_menu informs when verbose (#67)", {
  local_mocked_bindings(
    ensure_pkgdown_menu_section = function(pkgdown_contents, menu) list(),
    add_assets_to_pkgdown_menu = function(
      pkgdown_contents,
      menu,
      menu_subdir,
      rendered_assets
    ) {
      list()
    }
  )
  expect_message(
    update_pkgdown_menu(
      list(),
      "testMenu",
      menu_subdir = "testMenu",
      rendered_assets = c("asset1.html", "asset2.html"),
      verbose = TRUE
    ),
    "Added 2 testMenu items to pkgdown layout"
  )
})

test_that("remove_pkgdown_menu removes menu items (#67)", {
  test_result <- remove_pkgdown_menu(
    list(
      navbar = list(
        components = list(
          otherThing = list(),
          testMenu = list(
            text = "Test Menu",
            menu = list(
              list(text = "Asset 1", href = "asset1.html"),
              list(text = "Asset 2", href = "asset2.html")
            )
          )
        )
      )
    ),
    "testMenu",
    verbose = FALSE
  )
  expect_equal(
    test_result,
    list(navbar = list(components = list(otherThing = list())))
  )
})

test_that("remove_pkgdown_menu informs when verbose (#67)", {
  remove_pkgdown_menu(
    list(
      navbar = list(
        components = list(
          otherThing = list(),
          testMenu = list(
            text = "Test Menu",
            menu = list(
              list(text = "Asset 1", href = "asset1.html"),
              list(text = "Asset 2", href = "asset2.html")
            )
          )
        )
      )
    ),
    "testMenu",
    verbose = TRUE
  ) |>
    expect_message("Removing testMenu menu from pkgdown layout")
})

test_that("add_pkgdown_nav informs when pkgdown doesn't exist (#67)", {
  add_pkgdown_nav(
    pkgdown_yml = test_path("fixtures", "_pkgdown_no_nav.yml"),
    menu_subdir = "testMenu",
    rendered_assets = c("asset1.html", "asset2.html"),
    verbose = TRUE
  ) |>
    expect_message("Skipping pkgdown menu update")
})

test_that("add_pkgdown_nav adds menu items to pkgdown layout (#67)", {
  local_mocked_bindings(
    write_yaml = function(...) {
      cli::cli_inform("YAML written")
    }
  )
  add_pkgdown_nav(
    pkgdown_yml = test_path("fixtures", "_pkgdown.yml"),
    menu_subdir = "testMenu",
    rendered_assets = c("asset1.html", "asset2.html"),
    verbose = TRUE
  ) |>
    expect_message("Added 2 testMenu items to pkgdown layout") |>
    expect_message("YAML written")
})

test_that("add_pkgdown_nav removes menu from pkgdown layout (#67)", {
  local_mocked_bindings(
    write_yaml = function(...) {
      cli::cli_inform("YAML written")
    }
  )
  add_pkgdown_nav(
    pkgdown_yml = test_path("fixtures", "_pkgdown.yml"),
    menu_subdir = "examples",
    rendered_assets = character(),
    verbose = TRUE
  ) |>
    expect_message("Removing examples menu from pkgdown layout") |>
    expect_message("YAML written")
})
