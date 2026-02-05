# Check Workflow File Headers

Internal function to check version and generated-by headers in workflow
files.

## Usage

``` r
check_workflow_headers(
  workflows_dir,
  existing_workflows,
  expected_workflows,
  gsm_utils_version
)
```

## Arguments

- workflows_dir:

  `character` path to workflows directory

- existing_workflows:

  `character` vector of existing workflow file names

- expected_workflows:

  `character` vector of expected workflow file names

- gsm_utils_version:

  `character` expected gsm.utils version

## Value

`character` vector of header issues
