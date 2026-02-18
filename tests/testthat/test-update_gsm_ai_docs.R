test_that("update_gsm_ai_docs writes templates to target repo", {
  tmp <- withr::local_tempdir()

  paths <- update_gsm_ai_docs(strPackageDir = tmp)

  expect_type(paths, "character")
  expect_gt(length(paths), 0)
  expect_true(file.exists(file.path(tmp, "AGENTS.md")))
  expect_true(file.exists(file.path(tmp, "ai_manifest.json")))
})

test_that("update_gsm_ai_docs check mode reports drift", {
  tmp <- withr::local_tempdir()
  update_gsm_ai_docs(strPackageDir = tmp)

  writeLines("# modified", file.path(tmp, "AGENTS.md"))

  report <- update_gsm_ai_docs(strPackageDir = tmp, mode = "check")

  expect_s3_class(report, "data.frame")
  expect_true(any(report$relative_path == "AGENTS.md"))
  status <- report$status[report$relative_path == "AGENTS.md"]
  expect_equal(status, "different")
})

test_that("update_gsm_ai_docs dry_run does not overwrite existing files", {
  tmp <- withr::local_tempdir()
  update_gsm_ai_docs(strPackageDir = tmp)

  target <- file.path(tmp, "AGENTS.md")
  writeLines("# custom agents", target)

  update_gsm_ai_docs(
    strPackageDir = tmp,
    overwrite = TRUE,
    dry_run = TRUE
  )

  expect_equal(readLines(target, warn = FALSE), "# custom agents")
})

test_that("update_gsm_ai_docs include filters synced files", {
  tmp <- withr::local_tempdir()

  update_gsm_ai_docs(
    strPackageDir = tmp,
    include = c("AGENTS.md", "ai_manifest.json")
  )

  expect_true(file.exists(file.path(tmp, "AGENTS.md")))
  expect_true(file.exists(file.path(tmp, "ai_manifest.json")))
  expect_false(file.exists(file.path(tmp, "ECOSYSTEM.md")))
})

test_that("update_gsm_ai_docs include errors on unknown template", {
  tmp <- withr::local_tempdir()

  expect_error(
    update_gsm_ai_docs(strPackageDir = tmp, include = "NOT_A_TEMPLATE.md"),
    "Unknown template path"
  )
})
