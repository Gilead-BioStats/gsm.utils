# Render example R Markdown files

Render all `.Rmd` files in an examples directory to HTML output files.
Uses standard rmarkdown rendering without injecting custom headers.

## Usage

``` r
render_examples(
  examples_dir = "inst/examples",
  output_dir = "pkgdown/assets/examples",
  recursive = FALSE,
  quiet = FALSE
)
```

## Arguments

- examples_dir:

  Character. Path to directory containing example `.Rmd` files. Default
  is `"inst/examples"`.

- output_dir:

  Character. Path to output directory for rendered HTML files. Default
  is `"pkgdown/assets/examples"`.

- recursive:

  Logical. If `TRUE`, search for `.Rmd` files recursively. Default is
  `FALSE`.

- quiet:

  Logical. Passed to
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Value

Character vector of rendered output files (invisibly).
