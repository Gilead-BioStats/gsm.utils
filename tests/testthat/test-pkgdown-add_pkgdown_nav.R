test_that("ensure_pkgdown_menu_section adds menu to components (#67, #89)", {
  test_result <- ensure_pkgdown_menu_section(list(), "testMenu")
  expect_equal(
    test_result$navbar$components,
    list(testMenu = list(text = "Test Menu", menu = list()))
  )
})

test_that("ensure_pkgdown_menu_section adds menu to missing left (#67, #89)", {
  test_result <- ensure_pkgdown_menu_section(list(), "testMenu")
  expect_equal(
    test_result$navbar$structure$left,
    c("reference", "articles", "testMenu")
  )
})

test_that("ensure_pkgdown_menu_section errors informatively for weird pkgdown (#67, #89)", {
  expect_error(
    {
      ensure_pkgdown_menu_section(
        list(navbar = list(structure = list())),
        "testMenu"
      )
    },
    "manually to prepare for menus"
  )
})

test_that("ensure_pkgdown_menu_section adds menu to left (#67, #89)", {
  test_result <- ensure_pkgdown_menu_section(
    list(navbar = list(structure = list(left = "reference"))),
    "testMenu"
  )
  expect_equal(
    test_result$navbar$structure$left,
    c("reference", "testMenu")
  )
})

test_that("add_assets_to_pkgdown_menu adds items to menu (#67, #103)", {
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
    rendered_assets = c("asset1.html", "asset2.html"),
    existing_menu = NULL
  )
  expect_equal(
    test_result$navbar$components$testMenu$menu,
    list(
      list(text = "Asset 2", href = "asset2.html"),
      list(text = "Asset 1", href = "asset1.html")
    )
  )
})

test_that("add_assets_to_pkgdown_menu preserves leftover existing menu items (#103)", {
  local_mocked_bindings(
    construct_menu_metadata_table = function(...) {
      data.frame(
        html_file = "asset2.html",
        title = "Asset 2",
        index = 1
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
    rendered_assets = "asset2.html",
    existing_menu = list(
      list(text = "Asset 1", href = "asset1.html")
    )
  )
  expect_equal(
    test_result$navbar$components$testMenu$menu,
    list(
      list(text = "Asset 2", href = "asset2.html"),
      list(text = "Asset 1", href = "asset1.html")
    )
  )
})

test_that("update_pkgdown_menu informs when verbose (#67, #103)", {
  local_mocked_bindings(
    ensure_pkgdown_menu_section = function(pkgdown_contents, menu) list(),
    add_assets_to_pkgdown_menu = function(
      pkgdown_contents,
      menu,
      menu_subdir,
      rendered_assets,
      existing_menu
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
      existing_menu = NULL,
      verbose = TRUE
    ),
    "Added 2 testMenu items to pkgdown layout"
  )
})

test_that("update_pkgdown_menu preserves existing_menu when rendered_assets is empty (#103)", {
  local_mocked_bindings(
    construct_menu_metadata_table = function(...) {
      data.frame(
        html_file = character(),
        title = character(),
        index = integer()
      )
    }
  )
  existing_menu <- list(
    list(text = "Asset 1", href = "asset1.html")
  )
  test_result <- update_pkgdown_menu(
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
    rendered_assets = character(),
    existing_menu = existing_menu,
    verbose = FALSE
  )
  expect_equal(
    test_result$navbar$components$testMenu$menu,
    existing_menu
  )
})

test_that("update_pkgdown_menu informs 0 new items when rendered_assets is empty but existing_menu is not (#103)", {
  local_mocked_bindings(
    construct_menu_metadata_table = function(...) {
      data.frame(
        html_file = character(),
        title = character(),
        index = integer()
      )
    }
  )
  expect_message(
    update_pkgdown_menu(
      list(
        navbar = list(
          components = list(
            testMenu = list(text = "Test Menu", menu = list())
          )
        )
      ),
      "testMenu",
      menu_subdir = "testMenu",
      rendered_assets = character(),
      existing_menu = list(list(text = "Asset 1", href = "asset1.html")),
      verbose = TRUE
    ),
    "Added 0 testMenu items to pkgdown layout"
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

test_that("add_pkgdown_nav informs when pkgdown doesn't exist (#67, #103)", {
  add_pkgdown_nav(
    pkgdown_yml = test_path("fixtures", "_pkgdown_no_nav.yml"),
    menu_subdir = "testMenu",
    rendered_assets = c("asset1.html", "asset2.html"),
    assets_dir = tempdir(),
    verbose = TRUE
  ) |>
    expect_message("Skipping pkgdown menu update")
})

test_that("add_pkgdown_nav adds menu items to pkgdown layout (#67, #103)", {
  local_mocked_bindings(
    filter_existing_menu = function(...) character(),
    write_yaml = function(...) {
      cli::cli_inform("YAML written")
    }
  )
  add_pkgdown_nav(
    pkgdown_yml = test_path("fixtures", "_pkgdown.yml"),
    menu_subdir = "testMenu",
    rendered_assets = c("asset1.html", "asset2.html"),
    assets_dir = tempdir(),
    verbose = TRUE
  ) |>
    expect_message("Added 2 testMenu items to pkgdown layout") |>
    expect_message("YAML written")
})

test_that("add_pkgdown_nav removes menu from pkgdown layout (#67, #103)", {
  local_mocked_bindings(
    filter_existing_menu = function(...) character(),
    write_yaml = function(...) {
      cli::cli_inform("YAML written")
    }
  )
  add_pkgdown_nav(
    pkgdown_yml = test_path("fixtures", "_pkgdown.yml"),
    menu_subdir = "examples",
    rendered_assets = character(),
    assets_dir = tempdir(),
    verbose = TRUE
  ) |>
    expect_message("Removing examples menu from pkgdown layout") |>
    expect_message("YAML written")
})

test_that("filter_existing_menu returns list() when menu is not in yaml (#103)", {
  result <- filter_existing_menu(list(), "examples", tempdir())
  expect_equal(result, list())
})

test_that("filter_existing_menu returns only items whose html files still exist (#103)", {
  tmp <- withr::local_tempdir()
  examples_dir <- fs::path(tmp, "examples")
  fs::dir_create(examples_dir)
  fs::file_create(fs::path(examples_dir, "retained.html"))

  pkgdown_contents <- list(
    navbar = list(
      components = list(
        examples = list(
          text = "Examples",
          menu = list(
            list(text = "Retained", href = "examples/retained.html"),
            list(text = "Removed", href = "examples/removed.html")
          )
        )
      )
    )
  )
  result <- filter_existing_menu(pkgdown_contents, "examples", tmp)
  expect_length(result, 1)
  expect_equal(result[[1]]$text, "Retained")
})

test_that("add_pkgdown_nav preserves existing items that were not re-rendered (#103)", {
  tmp <- withr::local_tempdir()
  examples_dir <- fs::path(tmp, "examples")
  fs::dir_create(examples_dir)
  fs::file_create(fs::path(examples_dir, "existing.html"))

  local_mocked_bindings(
    construct_menu_metadata_table = function(...) {
      data.frame(
        html_file = structure("new.html", class = c("fs_path", "character")),
        title = "New Asset",
        index = 1
      )
    },
    write_yaml = function(contents, ...) {
      menu_items <<- contents[["navbar"]][["components"]][["examples"]][[
        "menu"
      ]]
    }
  )

  pkgdown_yml <- fs::path(tmp, "_pkgdown.yml")
  yaml::write_yaml(
    list(
      navbar = list(
        components = list(
          examples = list(
            text = "Examples",
            menu = list(
              list(text = "Existing Asset", href = "examples/existing.html")
            )
          )
        )
      )
    ),
    pkgdown_yml
  )

  menu_items <- NULL
  add_pkgdown_nav(
    pkgdown_yml = pkgdown_yml,
    menu_subdir = fs::path(tmp, "examples"),
    rendered_assets = structure(
      "examples/new.html",
      class = c("fs_path", "character")
    ),
    assets_dir = tmp,
    verbose = FALSE
  )

  expect_length(menu_items, 2)
  hrefs <- purrr::map_chr(menu_items, "href")
  expect_true("examples/new.html" %in% hrefs)
  expect_true("examples/existing.html" %in% hrefs)
})
