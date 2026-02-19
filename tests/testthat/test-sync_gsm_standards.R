test_that("sync_gsm_standards write mode syncs docs, issues, and workflows", {
  tmp <- withr::local_tempdir()

  result <- sync_gsm_standards(strPackageDir = tmp)

  expect_type(result, "list")
  expect_true(file.exists(file.path(tmp, ".github", "ai", "AGENTS.md")))
  expect_true(file.exists(file.path(tmp, ".github", "ISSUE_TEMPLATE", "6-CONTEXT_PACK.md")))
  expect_true(file.exists(file.path(tmp, ".github", "workflows", "R-CMD-check.yaml")))
})

test_that("sync_gsm_standards check mode returns ai and gha reports", {
  tmp <- withr::local_tempdir()
  sync_gsm_standards(strPackageDir = tmp)

  report <- sync_gsm_standards(strPackageDir = tmp, mode = "check")

  expect_type(report, "list")
  expect_true("ai_docs" %in% names(report))
  expect_true("gha" %in% names(report))
  expect_s3_class(report$ai_docs, "data.frame")
  expect_type(report$gha, "list")
  expect_false(any(grepl("^\\.github/ISSUE_TEMPLATE/", gsub("\\\\", "/", report$ai_docs$relative_path))))
})

test_that("sync_gsm_standards check mode can fail on drift", {
  tmp <- withr::local_tempdir()
  sync_gsm_standards(strPackageDir = tmp)

  writeLines("# changed", file.path(tmp, ".github", "ai", "AGENTS.md"))

  expect_error(
    sync_gsm_standards(
      strPackageDir = tmp,
      mode = "check",
      fail_on_drift = TRUE
    ),
    "Detected standards drift"
  )
})

test_that("sync_gsm_standards check mode allows ARCHITECTURE drift", {
  tmp <- withr::local_tempdir()
  sync_gsm_standards(strPackageDir = tmp)

  writeLines("# repo-local architecture", file.path(tmp, ".github", "ai", "ARCHITECTURE.md"))

  expect_no_error(
    sync_gsm_standards(
      strPackageDir = tmp,
      mode = "check",
      fail_on_drift = TRUE
    )
  )
})

test_that("sync_gsm_standards check mode ignores issue template drift", {
  tmp <- withr::local_tempdir()
  sync_gsm_standards(strPackageDir = tmp)

  writeLines("# local issue template", file.path(tmp, ".github", "ISSUE_TEMPLATE", "6-CONTEXT_PACK.md"))

  expect_no_error(
    sync_gsm_standards(
      strPackageDir = tmp,
      mode = "check",
      fail_on_drift = TRUE
    )
  )
})

test_that("sync_gsm_standards write mode preserves existing ARCHITECTURE.md", {
  tmp <- withr::local_tempdir()
  sync_gsm_standards(strPackageDir = tmp)

  architecture_path <- file.path(tmp, ".github", "ai", "ARCHITECTURE.md")
  writeLines("# repo-local architecture", architecture_path)

  sync_gsm_standards(
    strPackageDir = tmp,
    overwrite_ai_docs = TRUE
  )

  expect_equal(readLines(architecture_path, warn = FALSE), "# repo-local architecture")
  expect_true(file.exists(file.path(tmp, ".github", "ai", "AGENTS.md")))
})
