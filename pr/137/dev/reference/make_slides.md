# Create a slide deck template

Creates a new RevealJS `.qmd` file from a standard template.

## Usage

``` r
make_slides(
  strTitle = "Slide Deck Title",
  intIndex = 999,
  output_dir = "pkgdown/menus/slides",
  overwrite = FALSE,
  verbose = TRUE
)
```

## Arguments

- strTitle:

  (`string`) Display title.

- intIndex:

  (`numeric`) Sort-order index. `NULL`, `NA`, and length-0 vectors are
  treated as absent.

- output_dir:

  (`string`) Directory to write the asset to.

- overwrite:

  (`boolean`) Overwrite existing files?

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

Path to the created slide deck file (invisibly).
