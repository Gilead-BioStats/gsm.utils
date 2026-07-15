# Render Rmd files in a menu subdirectory

Render Rmd files in a menu subdirectory

## Usage

``` r
render_rmd_assets(menu_subdir, output_dir, verbose)
```

## Arguments

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- output_dir:

  (`string`) Directory to write the asset to.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

Character vector of relative paths to rendered HTML files for
successfully rendered Rmd files.
