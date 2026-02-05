# Report Compliance Results

Internal function to report workflow compliance check results.

## Usage

``` r
report_compliance_results(
  missing_workflows,
  extra_workflows,
  version_issues,
  content_issues,
  has_errors
)
```

## Arguments

- missing_workflows:

  `character` vector of missing workflows

- extra_workflows:

  `character` vector of extra workflows

- version_issues:

  `character` vector of version issues

- content_issues:

  `character` vector of content issues

- has_errors:

  `logical` whether critical errors were found

## Value

NULL (prints results to console)
