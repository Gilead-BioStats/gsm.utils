test_that("to_title_case works with several input cases (#67)", {
  expected <- "The API Client"
  expect_equal(to_title_case("theAPIClient"), expected)
  expect_equal(to_title_case("the_API_client"), expected)
  expect_equal(to_title_case("the-API-client"), expected)
  expect_equal(to_title_case("The API Client"), expected)
  expect_equal(to_title_case("The API client"), expected)
  expect_equal(to_title_case("the API client"), expected)
})

test_that("resolve_md_title uses title if provided (#67)", {
  skip_if_not_installed("rvest")
  expect_equal(resolve_md_title("path/to/file.md", "My Title"), "My Title")
})

test_that("resolve_md_title extracts text from HTML title (#67)", {
  expect_equal(
    resolve_md_title("path/to/file.md", "<b>My Title</b>"),
    "My Title"
  )
})

test_that("resolve_md_title falls back to title case of filename if title is empty (#67)", {
  expect_equal(
    resolve_md_title("path/to/the_API_client.md", ""),
    "The API Client"
  )
  expect_equal(
    resolve_md_title("path/to/the_API_client.md", NULL),
    "The API Client"
  )
  expect_equal(
    resolve_md_title("path/to/the_API_client.md", "<html></html>"),
    "The API Client"
  )
})
