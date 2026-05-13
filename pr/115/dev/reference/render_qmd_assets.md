# Render qmd files in a menu subdirectory

Render qmd files in a menu subdirectory

## Usage

``` r
render_qmd_assets(menu_subdir, output_dir, verbose)
```

## Arguments

- menu_subdir:

  Character. Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- output_dir:

  Character. Directory to write the example to.

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.

## Value

Character vector of paths to rendered HTML files for successfully
rendered qmd files, or `""` for failed renders.
