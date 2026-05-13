# Check GitHub Actions version in a package

**\[deprecated\]**

This function has been replaced by a GitHub Action to handle versions
more cleanly and automatically. Use
`add_action("workflow-template-check.yaml")` (or, more generally,
[`update_gsm_package()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/update_gsm_package.md))
to replace this function.

## Usage

``` r
check_gha_version(...)
```

## Arguments

- ...:

  Placeholder to prevent other errors.

## Value

An error with instructions for updating.
