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

  (`string`) Title for the slide deck.

- intIndex:

  (`numeric`) Optional ordering index for the slides menu.

- output_dir:

  (`string`) Directory to write the slide deck to.

- overwrite:

  (`boolean`) Overwrite existing files? Default is `TRUE`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

Path to the created slide deck file (invisibly).
