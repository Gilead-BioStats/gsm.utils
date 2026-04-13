# Render an individual qmd file

Render an individual qmd file

## Usage

``` r
render_qmd(qmd_file, output_file, params = NULL, verbose = FALSE)
```

## Arguments

- qmd_file:

  Character. Path to qmd file to render.

- output_file:

  Character. Path to output HTML file to create.

- params:

  List. Optional list of parameters to pass to
  [`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html).

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.

## Value

Character vector of relative paths to rendered HTML files for
successfully rendered qmd files.
