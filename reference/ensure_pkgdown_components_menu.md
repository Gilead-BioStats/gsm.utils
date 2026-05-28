# Ensure pkgdown components element has menu

Ensure pkgdown components element has menu

## Usage

``` r
ensure_pkgdown_components_menu(pkgdown_contents, menu)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  (`string`) Menu folder name.

## Value

An updated list of pkgdown YAML contents with the menu in navbar
components.
