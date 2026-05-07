# Add rendered assets to pkgdown navbar menu

Add rendered assets to pkgdown navbar menu

## Usage

``` r
add_pkgdown_nav(pkgdown_yml, menu_subdir, rendered_assets, assets_dir, verbose)
```

## Arguments

- pkgdown_yml:

  Character. Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- menu_subdir:

  Character. Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- rendered_assets:

  Character. Path to successfully rendered HTML files to add to pkgdown
  menu.

- assets_dir:

  Character. Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.

## Value

`NULL` (invisibly). Updates `_pkgdown.yml` in place.
