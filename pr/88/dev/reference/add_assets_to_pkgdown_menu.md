# Update pkgdown contents with menu entries for rendered assets

Update pkgdown contents with menu entries for rendered assets

## Usage

``` r
add_assets_to_pkgdown_menu(
  pkgdown_contents,
  menu,
  menu_subdir,
  rendered_assets
)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  Character. Menu folder name.

- menu_subdir:

  Character. Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- rendered_assets:

  Character. Path to successfully rendered HTML files to add to pkgdown
  menu.

## Value

An updated list of pkgdown YAML contents with the new menu entries
added.
