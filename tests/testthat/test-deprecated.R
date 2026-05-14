test_that("check_gha_version throws an informative error (#111)", {
  expect_error(
    check_gha_version(),
    class = "lifecycle_error_deprecated"
  )
})

test_that("create_gha_manifest throws an informative error (#111)", {
  expect_error(
    create_gha_manifest(),
    class = "lifecycle_error_deprecated"
  )
})

test_that("check_workflow_compliance throws an informative error (#111)", {
  expect_error(
    check_workflow_compliance(),
    class = "lifecycle_error_deprecated"
  )
})

test_that("update_workflow_version throws an informative error (#111)", {
  expect_error(
    update_workflow_version(),
    class = "lifecycle_error_deprecated"
  )
})
