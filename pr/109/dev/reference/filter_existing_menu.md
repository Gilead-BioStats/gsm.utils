# Filter existing menu items to only those with assets that still exist

Filter existing menu items to only those with assets that still exist

## Usage

``` r
filter_existing_menu(pkgdown_contents, menu, assets_dir)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  Character. Menu folder name.

- assets_dir:

  Character. Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

## Value

A list of existing menu items from the pkgdown YAML contents that
correspond to assets that still exist in the assets directory.
