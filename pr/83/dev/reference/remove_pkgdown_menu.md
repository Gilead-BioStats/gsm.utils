# Remove menu from pkgdown YAML

Remove menu from pkgdown YAML

## Usage

``` r
remove_pkgdown_menu(pkgdown_contents, menu, verbose)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  Character. Menu folder name.

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.

## Value

An updated list of pkgdown YAML contents with the menu removed.
