# Add Gilead GitHub Actions to package

Add the official Gilead GitHub Actions to a package, and update existing
Gilead GitHub Actions to the latest versions if necessary.

## Usage

``` r
add_actions(strPackageDir = ".", overwrite = TRUE, verbose = TRUE)
```

## Arguments

- strPackageDir:

  (`string`) Path to the package directory.

- overwrite:

  (`boolean`) Overwrite existing files? Default is `TRUE`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

A character vector of added and updated action names, invisibly.
