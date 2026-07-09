# Add rendered assets to pkgdown navbar menu

Add rendered assets to pkgdown navbar menu

## Usage

``` r
add_pkgdown_nav(pkgdown_yml, menu_subdir, rendered_assets, assets_dir, verbose)
```

## Arguments

- pkgdown_yml:

  (`string`) Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- rendered_assets:

  (`character`) Paths to successfully rendered HTML files to add to
  pkgdown menu.

- assets_dir:

  (`string`) Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

`NULL` (invisibly). Updates `_pkgdown.yml` in place.
