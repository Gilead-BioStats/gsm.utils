# Render Rmd and qmd files in a menu subdirectory

Render Rmd and qmd files in a menu subdirectory

## Usage

``` r
render_assets(menu_subdir, assets_dir, verbose)
```

## Arguments

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- assets_dir:

  (`string`) Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

Character vector of relative paths to rendered HTML files for
successfully rendered Rmd and qmd files.
