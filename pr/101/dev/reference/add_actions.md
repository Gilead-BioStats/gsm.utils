# Add Gilead GitHub Actions to package

Add the official Gilead GitHub Actions from
<https://github.com/Gilead-BioStats/gsm.utils@actions-v1> to a package,
and update existing Gilead GitHub Actions to the latest versions if
necessary.

## Usage

``` r
add_actions(strPackageDir = ".", overwrite = TRUE, verbose = TRUE)
```

## Arguments

- strPackageDir:

  String. Path to package directory

- overwrite:

  Logical. Overwrite existing files?

- verbose:

  Logical. Inform about changes?

## Value

A character vector of added and updated action names, invisibly.
