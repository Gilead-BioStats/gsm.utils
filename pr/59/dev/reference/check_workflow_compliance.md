# Check Workflow Template Compliance

Checks if a package's GitHub Actions workflows comply with gsm.utils
templates. This function verifies file presence, version headers, and
critical content.

## Usage

``` r
check_workflow_compliance(
  strPackageDir = ".",
  bVerbose = TRUE,
  bFailOnErrors = TRUE
)
```

## Arguments

- strPackageDir:

  `character` path to package directory. Default is `"."`.

- bVerbose:

  `logical` whether to print detailed information. Default is `TRUE`.

- bFailOnErrors:

  `logical` whether to error if critical issues are found. Default is
  `TRUE`.

## Value

A list with compliance check results:

- is_compliant:

  Logical indicating overall compliance

- missing_workflows:

  Character vector of missing workflow files

- extra_workflows:

  Character vector of extra workflow files not in templates

- version_issues:

  Character vector of version/header issues

- content_issues:

  Character vector of content differences

- gsm_utils_version:

  Current gsm.utils version

## Examples

``` r
if (FALSE) { # \dontrun{
# Check current package compliance
check_workflow_compliance()

# Check another package
check_workflow_compliance("path/to/package")
} # }
```
