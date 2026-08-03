# Remove deprecated issue templates from package

Removes issue templates that we no longer recommend nor support.
Currently the only deprecated template is `1-requirement.md` — roadmap
requirements now live exclusively in `gsm.roadmap`. New deprecations
should be added to the hard-coded list below.

## Usage

``` r
remove_deprecated_issue_templates(
  strPackageDir = ".",
  overwrite = TRUE,
  verbose = TRUE
)
```

## Arguments

- strPackageDir:

  (`string`) Path to the package directory.

- overwrite:

  (`boolean`) Overwrite existing files?

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

A character vector of deleted template names, invisibly.
