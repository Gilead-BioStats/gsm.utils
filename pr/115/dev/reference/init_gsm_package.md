# Initialize gsm Extension package

Initialize gsm Extension package

## Usage

``` r
init_gsm_package(
  strPackageDir,
  lDescriptionFields = list(),
  bIncludeWorkflowDir = TRUE,
  strOrg = "Gilead-BioStats"
)
```

## Arguments

- strPackageDir:

  (`string`) Path to the package directory.

- lDescriptionFields:

  (`list`) Description fields, passed to
  [`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html).
  Default is [`list()`](https://rdrr.io/r/base/list.html).

- bIncludeWorkflowDir:

  (`boolean`) Whether or not to include the `inst/workflow` directory in
  the root of the package. Default is `TRUE`.

- strOrg:

  (`string`) GitHub organization under which the repo should be created.
  Set to `NULL` to create the package in your personal GitHub account.
