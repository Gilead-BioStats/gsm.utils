test_that("updates existing version line in YAML files", {
  tmp <- withr::local_tempdir()
  wf_dir <- file.path(tmp, "workflows")
  dir.create(wf_dir, recursive = TRUE)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines("Package: testpkg\nVersion: 1.2.3", desc_path)

  yaml_path <- file.path(wf_dir, "test.yaml")
  writeLines(
    c(
      "# gsm.utils GHA version: 0.0.1",
      "name: Test Workflow"
    ),
    yaml_path
  )

  update_workflow_version(
    dir = wf_dir,
    description_path = desc_path
  )

  result <- readLines(yaml_path)
  expect_equal(result[1], "# gsm.utils GHA version: 1.2.3")
})


test_that("adds version line to top when missing", {
  tmp <- withr::local_tempdir()
  wf_dir <- file.path(tmp, "workflows")
  dir.create(wf_dir)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines("Package: testpkg\nVersion: 2.0.0", desc_path)

  yaml_path <- file.path(wf_dir, "no_version.yaml")
  writeLines("name: No Version", yaml_path)

  update_workflow_version(
    dir = wf_dir,
    description_path = desc_path,
    add_if_missing = TRUE
  )

  result <- readLines(yaml_path)
  expect_equal(result[1], "# gsm.utils GHA version: 2.0.0")
})

test_that("does not modify file when version missing and add_if_missing = FALSE", {
  tmp <- withr::local_tempdir()
  wf_dir <- file.path(tmp, "workflows")
  dir.create(wf_dir)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines("Package: testpkg\nVersion: 3.1.4", desc_path)

  yaml_path <- file.path(wf_dir, "unchanged.yaml")
  original <- c("name: Should Not Change")
  writeLines(original, yaml_path)

  update_workflow_version(
    dir = wf_dir,
    description_path = desc_path,
    add_if_missing = FALSE
  )

  result <- readLines(yaml_path)
  expect_identical(result, original)
})

test_that("recursively updates yaml files", {
  tmp <- withr::local_tempdir()
  wf_dir <- file.path(tmp, "workflows", "nested")
  dir.create(wf_dir, recursive = TRUE)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines("Package: testpkg\nVersion: 0.9.9", desc_path)

  yaml_path <- file.path(wf_dir, "nested.yaml")
  writeLines("# gsm.utils GHA version: 0.1.0", yaml_path)

  update_workflow_version(
    dir = file.path(tmp, "workflows"),
    description_path = desc_path,
    recursive = TRUE
  )

  result <- readLines(yaml_path)
  expect_equal(result[1], "# gsm.utils GHA version: 0.9.9")
})

test_that("errors when DESCRIPTION has no Version field", {
  tmp <- withr::local_tempdir()
  wf_dir <- file.path(tmp, "workflows")
  dir.create(wf_dir)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines("Package: testpkg", desc_path)

  writeLines("name: workflow", file.path(wf_dir, "test.yaml"))

  expect_error(
    update_workflow_version(
      dir = wf_dir,
      description_path = desc_path
    ),
    "DESCRIPTION file does not contain a Version field"
  )
})

test_that("warns when no yaml files are found", {
  tmp <- withr::local_tempdir()
  wf_dir <- file.path(tmp, "workflows")
  dir.create(wf_dir)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines("Package: testpkg\nVersion: 1.0.0", desc_path)

  expect_warning(
    update_workflow_version(
      dir = wf_dir,
      description_path = desc_path
    ),
    "No .yaml files found"
  )
})
