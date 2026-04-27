# Remove deprecated Gilead GitHub Actions from package

Remove old workflows that we no longer recommend nor support:
"R-CMD-check-dev.yaml", "pkgdown-cleanup.yaml",
"pkgdown-with-examples.yaml", "r-releaser.yaml", and "r_releaser.yaml".

## Usage

``` r
remove_deprecated_workflows(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
)
```

## Arguments

- strPackageDir:

  String. Path to package directory

- overwrite:

  Logical. Is it ok to delete existing files?

- verbose:

  Logical. Inform about changes?

## Value

A character vector of deleted action names, invisibly.
