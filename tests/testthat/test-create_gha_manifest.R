test_that("creates a valid GHA manifest JSON from workflows and issue templates", {
  tmp <- withr::local_tempdir()

  workflows_dir <- file.path(tmp, "workflows")
  issue_dir <- file.path(tmp, "ISSUE_TEMPLATE")
  dir.create(workflows_dir, recursive = TRUE)
  dir.create(issue_dir, recursive = TRUE)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines(
    c(
      "Package: gsm.utils",
      "Version: 0.2.0"
    ),
    desc_path
  )

  # Workflow YAML
  writeLines(
    c(
      "# Description: R CMD check for main branch PRs",
      "name: R-CMD-check"
    ),
    file.path(workflows_dir, "R-CMD-check.yaml")
  )

  # Issue template MD
  writeLines(
    c(
      "name: Bug report",
      "type: bug"
    ),
    file.path(issue_dir, "bug.md")
  )

  output_path <- file.path(tmp, "gha_version.json")

  create_gha_manifest(
    workflows_dir = workflows_dir,
    issue_templates_dir = issue_dir,
    repository = "https://github.com/Gilead-BioStats/gsm.utils",
    description_path = desc_path,
    output_path = output_path
  )

  expect_true(file.exists(output_path))

  manifest <- jsonlite::read_json(output_path, simplifyVector = TRUE)

  expect_equal(manifest$package, "gsm.utils")
  expect_equal(manifest$version, "0.2.0")
  expect_equal(
    manifest$repository,
    "https://github.com/Gilead-BioStats/gsm.utils"
  )

  expect_length(manifest$workflows, 3)
  expect_equal(manifest$workflows$name, "R-CMD-check.yaml")
  expect_equal(
    manifest$workflows$description,
    "R CMD check for main branch PRs"
  )
  expect_equal(
    manifest$workflows$path,
    "workflows/R-CMD-check.yaml"
  )

  expect_length(manifest$issue_templates, 2)
  expect_equal(manifest$issue_templates$name, "bug.md")
  expect_equal(manifest$issue_templates$description, "Bug report")
})

test_that("errors when workflows or issue template directories do not exist", {
  tmp <- withr::local_tempdir()

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines(
    c("Package: gsm.utils", "Version: 0.1.0"),
    desc_path
  )

  expect_error(
    create_gha_manifest(
      workflows_dir = file.path(tmp, "missing"),
      issue_templates_dir = file.path(tmp, "missing2"),
      description_path = desc_path
    )
  )
})

test_that("errors when DESCRIPTION lacks Package or Version", {
  tmp <- withr::local_tempdir()

  workflows_dir <- file.path(tmp, "workflows")
  issue_dir <- file.path(tmp, "ISSUE_TEMPLATE")
  dir.create(workflows_dir)
  dir.create(issue_dir)

  desc_path <- file.path(tmp, "DESCRIPTION")
  writeLines("Package: gsm.utils", desc_path)

  expect_error(
    create_gha_manifest(
      workflows_dir = workflows_dir,
      issue_templates_dir = issue_dir,
      description_path = desc_path
    ),
    "DESCRIPTION must contain Package and Version fields"
  )
})

