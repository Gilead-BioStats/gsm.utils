# Initialize gsm Extension package

Initialize gsm Extension package

## Usage

``` r
init_gsm_package(
  strPackageDir,
  lDescriptionFields = list(),
  bIncludeWorkflowDir = TRUE
)
```

## Arguments

- strPackageDir:

  path to package directory

- lDescriptionFields:

  `list` of description fields, passed to
  [`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html).
  Default is [`list()`](https://rdrr.io/r/base/list.html).

- bIncludeWorkflowDir:

  `boolean` argument declaring whether or not to include the
  `inst/workflow` directory in the root of the package. Default is
  `TRUE`.
