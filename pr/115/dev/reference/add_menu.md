# Add a menu to pkgdown from a subdirectory of assets

Add a menu to pkgdown from a subdirectory of assets

## Usage

``` r
add_menu(menu_subdir, assets_dir, pkgdown_yml, verbose)
```

## Arguments

- menu_subdir:

  Character. Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- assets_dir:

  Character. Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- pkgdown_yml:

  Character. Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.

## Value

`NULL` (invisibly). Called for the side effect of updating `pkgdown_yml`
with new menu items based on rendered assets.
