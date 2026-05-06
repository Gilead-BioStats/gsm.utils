# Construct a list of menu entries for rendered assets

Construct a list of menu entries for rendered assets

## Usage

``` r
construct_menu(rendered_assets, metadata)
```

## Arguments

- rendered_assets:

  Character. Path to successfully rendered HTML files to add to pkgdown
  menu.

## Value

A list of lists with `text` and `href` entries for each rendered asset,
sorted by `index` and `title` metadata from the corresponding md file.
