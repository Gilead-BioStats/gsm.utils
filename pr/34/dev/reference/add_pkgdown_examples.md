# Generate Examples menu in pkgdown

Scans for HTML files in a directory (default is
`pkgdown/assets/examples`) and updates a standard `_pkgdown.yml` with a
new sub-menu listing the html files.

## Usage

``` r
add_pkgdown_examples(
  examples_dir = "pkgdown/assets/examples",
  pkgdown_yml = "_pkgdown.yml"
)
```

## Arguments

- examples_dir:

  Character. Path to directory containing example HTML files. Default is
  `"pkgdown/assets/examples"`.

- pkgdown_yml:

  Character. Path to `_pkgdown.yml` file to update with menu. Default is
  `"_pkgdown.yml"`.

## Value

`NULL` invisibly.
