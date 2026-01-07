test_that("summarize_github_repos validates repository format", {
  expect_error(summarize_github_repos(42), "character vector")
  expect_error(summarize_github_repos(character(0)), "at least one")
  expect_error(summarize_github_repos(c("")), "cannot contain empty strings")
  expect_error(
    summarize_github_repos(c("invalid")),
    "owner/repo"
  )
})

test_that("summarize_github_repos assembles release and milestone summaries", {
  mock_release <- list(tag_name = "v1.0.0", published_at = "2025-01-01T12:00:00Z")
  mock_milestones <- list(
    list(title = "Milestone A", open_issues = 3, closed_issues = 2),
    list(title = "Backlog", open_issues = 0, closed_issues = 0)
  )

  result <- with_mocked_bindings(
    summarize_github_repos("org/repo"),
    fetch_latest_release = function(owner, repo, token) {
      expect_equal(owner, "org")
      expect_equal(repo, "repo")
      mock_release
    },
    fetch_open_milestones = function(owner, repo, token) {
      expect_equal(owner, "org")
      expect_equal(repo, "repo")
      mock_milestones
    }
  )

  expect_s3_class(result, "data.frame")
  expect_equal(result$repo, "org/repo")
  expect_match(result$latest_release, "v1.0.0")
  expect_match(result$latest_release, "Released 2025-01-01")
  expect_match(result$latest_release, "span")
  expect_match(result$upcoming_milestones, "Milestone A")
  expect_match(result$upcoming_milestones, "3 open of 5")
})

test_that("summarize_github_repos supports multiple repositories", {
  releases <- list(
    list(tag_name = "v1.1.0", published_at = "2025-02-15T00:00:00Z"),
    NULL
  )
  milestones <- list(
    list(list(title = "Milestone B", open_issues = 1, closed_issues = 4)),
    list()
  )

  index <- 0
  result <- with_mocked_bindings(
    summarize_github_repos(c("org/repo", "org2/repo2")),
    fetch_latest_release = function(owner, repo, token) {
      index <<- index + 1
      releases[[index]]
    },
    fetch_open_milestones = function(owner, repo, token) {
      milestones[[index]]
    }
  )

  expect_equal(nrow(result), 2)
  expect_match(result$latest_release[[1]], "v1.1.0")
  expect_match(result$latest_release[[1]], "2025-02-15")
  expect_match(result$latest_release[[2]], "No release")
  expect_match(result$upcoming_milestones[[1]], "Milestone B")
  expect_match(result$upcoming_milestones[[1]], "1 open of 5")
  expect_match(result$upcoming_milestones[[2]], "None")
})

test_that("list_public_gsm_packages validates inputs", {
  expect_error(list_public_gsm_packages(org = ""), "non-empty")
  expect_error(list_public_gsm_packages(prefix = ""), "non-empty")
})

test_that("list_public_gsm_packages filters repositories", {
  mock_repos <- list(
    list(name = "gsm.core", private = FALSE, archived = FALSE),
    list(name = "gsm.kri", private = FALSE, archived = FALSE),
    list(name = "gsm.private", private = TRUE, archived = FALSE),
    list(name = "other", private = FALSE, archived = FALSE),
    list(name = "gsm.archived", private = FALSE, archived = TRUE)
  )

  result <- with_mocked_bindings(
    list_public_gsm_packages(org = "Org", prefix = "gsm."),
    safe_gh = function(fun, ...) mock_repos
  )

  expect_equal(result, c("Org/gsm.core", "Org/gsm.kri"))
})
