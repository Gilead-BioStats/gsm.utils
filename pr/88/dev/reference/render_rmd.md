# Custom Rmarkdown render function

Rmarkdown render function that defaults to rendering intermediate Rmd
files in a temporary directory, and falls back to a writable output
directory when needed.

## Usage

``` r
render_rmd(
  strInputPath,
  strOutputFile = basename(strInputPath),
  strOutputDir = getwd(),
  lParams = NULL,
  quiet = FALSE
)
```

## Arguments

- strInputPath:

  `string` or `fs_path` Path to the template `Rmd` file.

- strOutputFile:

  `string` Filename for the output.

- strOutputDir:

  `string` or `fs_path` Path to the directory where the output will be
  saved.

- lParams:

  `list` Parameters to pass to the template `Rmd` file.

- quiet:

  Logical. Passed to
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Value

Rendered Rmarkdown file path (invisibly).
