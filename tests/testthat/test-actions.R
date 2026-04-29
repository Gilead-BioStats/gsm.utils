# add_actions ----

test_that("add_actions handles empty manifest (#90)", {
  local_mocked_bindings(
    .read_gilead_action_manifest = function() {
      NULL
    }
  )
  add_actions() |>
    expect_message("No canonical workflows found")
  add_actions(verbose = FALSE) |>
    expect_no_message()
})

test_that("add_actions adds each action in the manifest (#90)", {
  local_mocked_bindings(
    .read_gilead_action_manifest = function() {
      data.frame(
        name = c("action1.yaml", "action2.yaml", "action3.yaml"),
        description = "This isn't used yet so I'm repeating",
        version = c("1.0.0", "2.2.0", "3.3.3")
      )
    },
    .ensure_dir_exists = function(path) path,
    add_action = function(
      name,
      version,
      workflows_path,
      overwrite,
      verbose
    ) {
      cli::cli_inform("installing {name} v{version}")
      name
    }
  )
  add_actions() |>
    expect_equal(c("action1.yaml", "action2.yaml", "action3.yaml")) |>
    expect_message("installing action1.yaml v1.0.0") |>
    expect_message("installing action2.yaml v2.2.0") |>
    expect_message("installing action3.yaml v3.3.3")
})

test_that("add_actions informs when nothing added (#90)", {
  local_mocked_bindings(
    .read_gilead_action_manifest = function() {
      data.frame(
        name = c("action1.yaml", "action2.yaml", "action3.yaml"),
        description = "This isn't used yet so I'm repeating",
        version = c("1.0.0", "2.2.0", "3.3.3")
      )
    },
    .ensure_dir_exists = function(path) path,
    add_action = function(...) character()
  )
  add_actions() |>
    expect_equal(character()) |>
    expect_message("All workflows already up-to-date")
})

## add_action ----

test_that("action helpers work (#90)", {
  local_mocked_bindings(
    .base_url = test_path("fixtures/actions")
  )
  manifest_all <- .read_github_manifest()
  expect_named(manifest_all, "workflows")
  manifest_workflows <- .read_gilead_action_manifest()
  expect_s3_class(manifest_workflows, "data.frame")
  expect_equal(
    colnames(manifest_workflows),
    c("name", "description", "version")
  )
  action1 <- .read_workflow_template("action1.yaml")
  expect_equal(
    action1,
    c(
      "# name: action1.yaml",
      "# version: 1.0.0",
      "# Description: Description 1",
      "Contents of action 1 v1.0.0"
    )
  )
  expect_true(.workflow_up_to_date(
    "action1.yaml",
    "1.0.0",
    test_path("fixtures", "actions", "installed_workflows", "action1.yaml")
  ))
  expect_false(.workflow_up_to_date(
    "action1.yaml",
    "1.0.1",
    test_path("fixtures/actions/installed_workflows", "action1.yaml")
  ))
  expect_false(.workflow_up_to_date(
    "action2.yaml",
    "2.2.0",
    test_path("fixtures/actions/installed_workflows", "not-installed.yaml")
  ))
})

test_that("add_action errors when workflow needs an update but overwrite is FALSE (#90)", {
  local_mocked_bindings(
    .workflow_up_to_date = function(...) FALSE
  )
  add_action(
    "action1.yaml",
    "2.0.0",
    workflows_path = test_path("fixtures/actions/installed_workflows"),
    overwrite = FALSE
  ) |>
    expect_error("Workflow file .+ already exists")
})

test_that("add_action returns an empty vector when workflow is already up-to-date (#90)", {
  local_mocked_bindings(
    .workflow_up_to_date = function(...) TRUE
  )
  expect_equal(
    add_action(
      "action1.yaml",
      "2.0.0",
      workflows_path = test_path("fixtures/actions/installed_workflows")
    ),
    character()
  )
})

test_that("add_action informs when verbose is TRUE (#90)", {
  local_mocked_bindings(
    .workflow_up_to_date = function(...) FALSE,
    .update_workflow = function(name, workflow_path) name
  )
  add_action(
    "action1.yaml",
    "2.0.0",
    workflows_path = test_path("fixtures/actions/installed_workflows")
  ) |>
    expect_message("Creating or updating workflow file .+")
})

test_that("add_action updates when appropriate (#90)", {
  local_mocked_bindings(
    .workflow_up_to_date = function(...) FALSE,
    .read_workflow_template = function(...) "Contents of the workflow"
  )
  workflows_path <- withr::local_tempdir(pattern = "workflows")
  add_action(
    "action1.yaml",
    "2.0.0",
    workflows_path = workflows_path
  ) |>
    expect_equal("action1.yaml") |>
    expect_message("Creating or updating")
  expect_equal(
    readLines(fs::path(workflows_path, "action1.yaml")),
    "Contents of the workflow"
  )
})

# remove_deprecated_actions ----

test_that("remove_deprecated_actions informs when nothing removed and verbose (#90)", {
  local_mocked_bindings(
    .remove_action = function(...) character()
  )
  remove_deprecated_actions() |>
    expect_equal(character()) |>
    expect_message("No deprecated workflows found")
  remove_deprecated_actions(verbose = FALSE) |>
    expect_equal(character()) |>
    expect_no_message()
})

## .remove_action

test_that(".remove_action returns silently when file doesn't exist (#90)", {
  .remove_action(
    "does-not-exist.yaml",
    test_path("fixtures", "actions", "installed_workflows")
  ) |>
    expect_equal(character()) |>
    expect_no_message()
})

test_that(".remove_action errors when file exists but overwrite is false (#90)", {
  workflows_path <- withr::local_tempdir("workflows")
  workflow_name <- "action.yaml"
  workflow_path <- fs::path(workflows_path, workflow_name)
  writeLines("Bad workflow", workflow_path)
  .remove_action(
    workflow_name,
    workflows_path,
    overwrite = FALSE
  ) |>
    expect_error("Deprecated workflow file .+ found")
})

test_that(".remove_action removes bad workflows (#90)", {
  workflows_path <- withr::local_tempdir("workflows")
  workflow_name <- "action.yaml"
  workflow_path <- fs::path(workflows_path, workflow_name)
  writeLines("Bad workflow", workflow_path)
  .remove_action(workflow_name, workflows_path) |>
    expect_equal(workflow_name) |>
    expect_message("Removing deprecated workflow")
})
