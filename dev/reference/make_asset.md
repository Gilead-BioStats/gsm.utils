# Create a pkgdown menu asset file

Writes a completed template to the appropriate subdirectory under
`strMenuDir`. This is the generic engine behind
[`make_example()`](https://gilead-public.github.io/gsm.utils/dev/reference/make_example.md)
and similar helpers.

## Usage

``` r
make_asset(
  strFilename,
  strMenu,
  strTemplate,
  strMenuDir = "pkgdown/menus",
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- strFilename:

  (`string`) File name with extension, e.g.
  `"Example_Country_Report.Rmd"`.

- strMenu:

  (`string`) Menu subdirectory name, e.g. `"examples"` or `"slides"`.

- strTemplate:

  (`character`) Completed file body to write (a character vector of
  lines).

- strMenuDir:

  (`string`) Root directory for menu sources. Default `"pkgdown/menus"`.

- overwrite:

  (`boolean`) Overwrite existing files?

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

Path to the created file (invisibly).
