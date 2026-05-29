test_that("writes JSON with all required fields (#31)", {
  local_mocked_bindings(
    compute_coverage_percent = function(...) 84.7
  )

  tmp <- withr::local_tempfile(fileext = ".json")

  emit_coverage_summary(
    output_path = tmp,
    repo = "Gilead-BioStats/gsm.utils",
    sha = "abc1234",
    ref = "refs/heads/main",
    runner_os = "Linux",
    r_version = "4.4.0",
    timestamp_utc = "2026-03-30T12:00:00Z",
    quiet = TRUE
  )

  expect_true(file.exists(tmp))

  json <- jsonlite::read_json(tmp)
  expect_equal(json$repo, "Gilead-BioStats/gsm.utils")
  expect_equal(json$sha, "abc1234")
  expect_equal(json$ref, "refs/heads/main")
  expect_equal(json$runner_os, "Linux")
  expect_equal(json$r_version, "4.4.0")
  expect_equal(json$timestamp_utc, "2026-03-30T12:00:00Z")
  expect_equal(json$coverage_percent, 84.7)
})

test_that("coverage_percent is numeric and within [0, 100] (#31)", {
  local_mocked_bindings(
    compute_coverage_percent = function(...) 84.7
  )

  tmp <- withr::local_tempfile(fileext = ".json")

  emit_coverage_summary(
    output_path = tmp,
    repo = "a/b",
    sha = "abc",
    ref = "refs/heads/main",
    runner_os = "Linux",
    r_version = "4.4.0",
    timestamp_utc = "2026-01-01T00:00:00Z",
    quiet = TRUE
  )

  json <- jsonlite::read_json(tmp)
  expect_type(json$coverage_percent, "double")
  expect_gte(json$coverage_percent, 0)
  expect_lte(json$coverage_percent, 100)
})

test_that("timestamp_utc matches ISO-8601 UTC format and is parseable (#31)", {
  local_mocked_bindings(
    compute_coverage_percent = function(...) 50.0
  )

  tmp <- withr::local_tempfile(fileext = ".json")

  emit_coverage_summary(
    output_path = tmp,
    repo = "a/b",
    sha = "x",
    ref = "refs/heads/dev",
    runner_os = "Linux",
    r_version = "4.4.0",
    quiet = TRUE
  )

  json <- jsonlite::read_json(tmp)
  expect_match(
    json$timestamp_utc,
    "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$"
  )
  parsed <- as.POSIXct(
    json$timestamp_utc,
    format = "%Y-%m-%dT%H:%M:%SZ",
    tz = "UTC"
  )
  expect_false(is.na(parsed))
})

test_that("defaults resolve from environment variables (#31)", {
  local_mocked_bindings(
    compute_coverage_percent = function(...) 75.0
  )

  withr::with_envvar(
    c(
      GITHUB_REPOSITORY = "my-org/my-pkg",
      GITHUB_SHA = "deadbeef",
      GITHUB_REF = "refs/heads/main",
      RUNNER_OS = "Linux"
    ),
    {
      tmp <- withr::local_tempfile(fileext = ".json")

      emit_coverage_summary(output_path = tmp, quiet = TRUE)

      json <- jsonlite::read_json(tmp)
      expect_equal(json$repo, "my-org/my-pkg")
      expect_equal(json$sha, "deadbeef")
      expect_equal(json$ref, "refs/heads/main")
      expect_equal(json$runner_os, "Linux")
    }
  )
})

test_that("allow_fail = TRUE writes JSON with null coverage and error_message (#31)", {
  local_mocked_bindings(
    compute_coverage_percent = function(...) stop("simulated covr error")
  )

  tmp <- withr::local_tempfile(fileext = ".json")

  expect_no_error(
    emit_coverage_summary(
      output_path = tmp,
      allow_fail = TRUE,
      repo = "a/b",
      sha = "x",
      ref = "refs/heads/main",
      runner_os = "Linux",
      r_version = "4.0.0",
      timestamp_utc = "2026-01-01T00:00:00Z",
      quiet = TRUE
    )
  )

  expect_true(file.exists(tmp))

  json <- jsonlite::read_json(tmp)
  # NA_real_ with na = "null" serializes as JSON null, read back as NULL
  expect_null(json$coverage_percent)
  expect_true("error_message" %in% names(json))
  expect_match(json$error_message, "simulated covr error")
})

test_that("allow_fail = FALSE errors and does not write file (#31)", {
  local_mocked_bindings(
    compute_coverage_percent = function(...) stop("simulated covr error")
  )

  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp), add = TRUE)

  expect_error(
    emit_coverage_summary(
      output_path = tmp,
      allow_fail = FALSE,
      repo = "a/b",
      sha = "x",
      ref = "refs/heads/main",
      runner_os = "Linux",
      r_version = "4.0.0",
      timestamp_utc = "2026-01-01T00:00:00Z",
      quiet = TRUE
    ),
    "Coverage computation failed"
  )

  expect_false(file.exists(tmp))
})
