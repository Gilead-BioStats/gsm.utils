# Render an individual qmd file

Render an individual qmd file

## Usage

``` r
render_qmd(qmd_file, output_file, params = NULL, verbose = FALSE)
```

## Arguments

- qmd_file:

  (`string`) Path to qmd file to render.

- output_file:

  (`string`) Path to output HTML file to create.

- params:

  List. Optional list of parameters to pass to
  [`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html).

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

`output_file` (on success) or `""` (on failure), invisibly.
