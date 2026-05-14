# Render qmd files in a menu subdirectory

Render qmd files in a menu subdirectory

## Usage

``` r
render_qmd_assets(menu_subdir, output_dir, verbose)
```

## Arguments

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- output_dir:

  (`string`) Directory to write the example to.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

Character vector of paths to rendered HTML files for successfully
rendered qmd files, or `""` for failed renders.
