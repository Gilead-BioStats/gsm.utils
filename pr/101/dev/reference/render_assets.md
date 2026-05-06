# Render Rmd and qmd files in a menu subdirectory

Render Rmd and qmd files in a menu subdirectory

## Usage

``` r
render_assets(menu_subdir, assets_dir, verbose)
```

## Arguments

- menu_subdir:

  Character. Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- assets_dir:

  Character. Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.

## Value

Character vector of relative paths to rendered HTML files for
successfully rendered Rmd and qmd files.
