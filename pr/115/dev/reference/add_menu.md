# Add a menu to pkgdown from a subdirectory of assets

Add a menu to pkgdown from a subdirectory of assets

## Usage

``` r
add_menu(menu_subdir, assets_dir, pkgdown_yml, verbose)
```

## Arguments

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- assets_dir:

  (`string`) Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- pkgdown_yml:

  (`string`) Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

`NULL` (invisibly). Called for the side effect of updating `pkgdown_yml`
with new menu items based on rendered assets.
